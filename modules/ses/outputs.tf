output "smtp_server" {
  value = "email-smtp.${var.region}.amazonaws.com"
}

output "smtp_username" {
  value = aws_iam_access_key.smtp_access_key.id
}

output "smtp_password_v4" {
  value = aws_iam_access_key.smtp_access_key.ses_smtp_password_v4
}
