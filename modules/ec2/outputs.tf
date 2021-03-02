output "bastion_eip_dns_addr" {
  value = aws_eip.bastion-eip.public_dns
}

output "bastion_host_subdomain" {
  value = "bastion.${var.domain}"
}

output "bastion_subdomain_url" {
  value = "http://bastion.${var.domain}"
}

output "bastion_alb_dns_addr" {
  value = aws_alb.bastion-alb.dns_name
}

output "bastion_lb_subdomain_url" {
  value = "http://bastionlb.${var.domain}"
}