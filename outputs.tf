output "vpc_id" {
  value = module.vpc.vpc_id
}

output "db_endpoint" {
  value = module.rds.db_endpoint
}
output "db_username" {
  value = module.rds.db_username
}
output "db_password" {
  value = module.rds.db_password
}
output "db_port" {
  value = module.rds.db_port
}

output "ecs_alb_dns_addr" {
  value = module.ecs.ecs_alb_dns_addr
}

output "ecs_subdomain_url" {
  value = module.ecs.ecs_subdomain_url
}

output "smtp_server" {
  value = module.ses.smtp_server
}

output "smtp_username" {
  value = module.ses.smtp_username
}

output "smtp_password_v4" {
  value = module.ses.smtp_password_v4
}

output "efs_filesystem_id" {
  value = module.efs.efs_filesystem_id
}

output "efs_dns_name" {
  value = module.efs.efs_dns_name
}

output "ec2_bastion_host_eip_dns" {
  value = module.ec2.bastion_eip_dns_addr
}

output "ec2_bastion_host_subdomain" {
  value = module.ec2.bastion_host_subdomain
}
