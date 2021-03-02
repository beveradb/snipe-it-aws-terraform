variable "tags" {
  type = map(string)
}
variable "project_name_hyphenated" {
  type = string
}
variable "region" {
  type = string
}
variable "domain" {
  type = string
}

variable "vpc_id" {
  type = string
}
variable "route53_zone_id" {
  type = string
}
variable "acm_cert_arn" {
  type = string
}

variable "security_group_ids" {
  type = map(string)
}
variable "subnet_ids" {
  type = map(string)
}

variable "efs_filesystem_id" {
  type = string
}

# If we provide a docker image reference here, it'll try to pull from docker hub (so ECS task needs internet access, NAT gateway etc.)
# If we leave it blank, it'll try to pull from the private ECR repository, so you need to push to ECR from your local machine
variable "docker_image" {
  type = string
}
variable "docker_image_version" {
  type    = string
  default = "latest"
}
variable "container_health_check_grace_period_seconds" {
  type    = number
  default = 60
}
variable "container_port" {
  type    = number
  default = 80
}
variable "container_env_vars_config" {
  type    = string
  default = ""
}
