output "ecs_alb_dns_addr" {
  value = aws_alb.ecs-alb.dns_name
}

output "ecs_subdomain_url" {
  value = "https://ecs.${var.domain}"
}
