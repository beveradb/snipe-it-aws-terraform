output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "route53_zone_id" {
  value = data.aws_route53_zone.route53-zone.id
}

output "security_group_ids" {
  value = {
    egress = aws_security_group.egress.id
    http   = aws_security_group.http.id
    ssh    = aws_security_group.ssh.id
    mysql  = aws_security_group.mysql.id
    nfs    = aws_security_group.nfs.id
  }
}

output "acm_cert_arn" {
  value = aws_acm_certificate.acm-cert.arn
}

output "subnet_ids" {
  value = {
    ec2-subnet-one        = aws_subnet.ec2-subnet-one.id
    ec2-subnet-two        = aws_subnet.ec2-subnet-two.id
    rds-subnet-one        = aws_subnet.rds-subnet-one.id
    rds-subnet-two        = aws_subnet.rds-subnet-two.id
    ecs-subnet-private    = aws_subnet.ecs-subnet-private.id
    ecs-subnet-public-one = aws_subnet.ecs-subnet-public-one.id
    ecs-subnet-public-two = aws_subnet.ecs-subnet-public-two.id
    efs-subnet            = aws_subnet.efs-subnet.id
  }
}
