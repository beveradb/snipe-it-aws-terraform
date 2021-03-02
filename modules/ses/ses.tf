# SES domain identity
resource "aws_ses_domain_identity" "domain-identity" {
  domain = var.domain
}

# Route53 TXT record for SES validation
resource "aws_route53_record" "ses-verification-record" {
  zone_id = var.route53_zone_id
  name    = "_amazonses.${aws_ses_domain_identity.domain-identity.id}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.domain-identity.verification_token]
}

# Route53 CNAME records for DKIM
resource "aws_route53_record" "ses-dkim-record" {
  count   = 3
  zone_id = var.route53_zone_id
  name    = "${element(aws_ses_domain_dkim.ses-domain-dkim.dkim_tokens, count.index)}._domainkey"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.ses-domain-dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

# Route53 MX record to handle outbound email bounces
resource "aws_route53_record" "ses-domain-mail-from-mx-record" {
  zone_id = var.route53_zone_id
  name    = aws_ses_domain_mail_from.ses-domain-mail-from.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.${var.region}.amazonses.com"]
}

# Route53 TXT record for SPF
resource "aws_route53_record" "ses_domain_mail_from_txt" {
  zone_id = var.route53_zone_id
  name    = aws_ses_domain_mail_from.ses-domain-mail-from.mail_from_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com -all"]
}

resource "aws_ses_domain_identity_verification" "ses-verification" {
  domain = aws_ses_domain_identity.domain-identity.id

  depends_on = [aws_route53_record.ses-verification-record]
}

# SES domain DKIM
resource "aws_ses_domain_dkim" "ses-domain-dkim" {
  domain = aws_ses_domain_identity.domain-identity.domain
}

resource "aws_ses_email_identity" "admin-email-identity" {
  email = "admin@${var.domain}"
}

# SES domain mail sender
resource "aws_ses_domain_mail_from" "ses-domain-mail-from" {
  domain           = aws_ses_domain_identity.domain-identity.domain
  mail_from_domain = "bounce.${aws_ses_domain_identity.domain-identity.domain}"
}

variable "bucket_name" {
  default = ""
}
resource "aws_s3_bucket" "ses_bucket_name" {
  bucket = var.ses_bucket_name

  force_destroy = true
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "ses_inbox" {
  bucket = aws_s3_bucket.ses_bucket_name.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowSESPuts",
            "Effect": "Allow",
            "Principal": {
                "Service": "ses.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.ses_bucket_name.arn}/*",
            "Condition": {
                "StringEquals": {
                    "aws:Referer": "${data.aws_caller_identity.current.account_id}"
                }
            }
        }
    ]
}
POLICY

  lifecycle {
    ignore_changes = [
      policy
    ]
  }
}

resource "aws_ses_receipt_rule_set" "rule_set" {
  rule_set_name = "${var.domain}_ses_receipt_rule_set"
}

resource "aws_ses_active_receipt_rule_set" "rule_set" {
  rule_set_name = aws_ses_receipt_rule_set.rule_set.id
}

resource "aws_route53_record" "data_zone_mx" {
  zone_id = var.route53_zone_id
  name    = var.domain
  type    = "MX"
  ttl     = "600"

  records = ["5 inbound-smtp.${var.region}.amazonaws.com."]
}

resource "aws_ses_receipt_rule" "s3store" {
  depends_on = [aws_s3_bucket_policy.ses_inbox, aws_route53_record.data_zone_mx]

  name          = "mailtos3"
  rule_set_name = aws_ses_receipt_rule_set.rule_set.id

  recipients   = ["admin@${var.domain}"]
  enabled      = true
  scan_enabled = false
  s3_action {
    bucket_name       = aws_s3_bucket.ses_bucket_name.id
    object_key_prefix = "inbox"
    position          = 1
  }
}

# Random ID generator
resource "random_id" "username" {
  keepers = {
    zone_id = var.route53_zone_id
  }

  byte_length = 6
}

# IAM user for SES SMTP
resource "aws_iam_user" "smtp_user" {
  name = "${var.project_name_hyphenated}-ses-smtp-${random_id.username.hex}"
}

# IAM policy to send emails via SMTP through SES
resource "aws_iam_user_policy" "smtp_policy" {
  name = "${aws_iam_user.smtp_user.name}-policy"
  user = aws_iam_user.smtp_user.name

  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Effect":"Allow",
      "Action":[
        "ses:SendEmail",
        "ses:SendRawEmail"
      ],
      "Resource":"*",
      "Condition":{
        "StringLike":{
          "ses:FromAddress": "*@${var.domain}"
        }
      }
    }
  ]
}
EOF

  lifecycle {
    ignore_changes = [
      policy
    ]
  }
}

# IAM access key for SES SMTP user
resource "aws_iam_access_key" "smtp_access_key" {
  user = aws_iam_user.smtp_user.name
}
