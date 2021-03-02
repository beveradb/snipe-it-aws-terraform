resource "aws_alb" "bastion-alb" {
  name               = "${var.project_name_hyphenated}-bastion-alb"
  internal           = false
  load_balancer_type = "application"

  subnets = [
    var.subnet_ids.ec2-subnet-one,
    var.subnet_ids.ec2-subnet-two
  ]

  security_groups = [
    var.security_group_ids.egress,
    var.security_group_ids.http,
    var.security_group_ids.ssh,
  ]

  tags = var.tags
}

resource "aws_lb_target_group" "bastion-alb-tg" {
  name        = "${var.project_name_hyphenated}-bastion-alb-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    enabled = true
    path    = "/"
  }

  depends_on = [aws_alb.bastion-alb]
  tags       = var.tags
}

resource "aws_lb_target_group_attachment" "bastion-alb-tg-attach" {
  target_group_arn = aws_lb_target_group.bastion-alb-tg.arn
  target_id        = aws_instance.bastion-instance.id
  port             = 80

  depends_on = [aws_lb_target_group.bastion-alb-tg]
}

resource "aws_alb_listener" "bastion-alb-http" {
  load_balancer_arn = aws_alb.bastion-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bastion-alb-tg.arn
  }
}

resource "aws_alb_listener" "bastion-alb-https" {
  load_balancer_arn = aws_alb.bastion-alb.arn
  port              = "443"
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bastion-alb-tg.arn
  }

  certificate_arn = var.acm_cert_arn
}

resource "aws_route53_record" "bastion-lb-dns" {
  zone_id = var.route53_zone_id
  name    = "bastionlb.${var.domain}"
  type    = "CNAME"
  ttl     = "5"
  records = [aws_alb.bastion-alb.dns_name]
}
