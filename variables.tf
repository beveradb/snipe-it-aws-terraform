# This should be a domain name which you've already purchased (or registered for free, e.g. a dot.tk domain)
# and which you've already set up as a hosted zone in your AWS account, with nameservers pointing correctly etc.
variable "primary_domain" {
  type = string
}
variable "admin_email" {
  type = string
}
variable "region" {
  type    = string
  default = "eu-west-1"
}
variable "aws_zones" {
  type    = list(string)
  default = ["eu-west-1a", "eu-west-1b"]
}
variable "project_name_proper_case" {
  type    = string
  default = "Snipe IT"
}
variable "project_name_hyphenated" {
  type    = string
  default = "snipe"
}
variable "docker_image" {
  type    = string
  default = "linuxserver/snipe-it"
}
variable "docker_image_version" {
  type    = string
  default = "version-v5.0.12"
}
variable "container_port" {
  type    = number
  default = 80
}
variable "db_name" {
  type    = string
  default = "snipe"
}
variable "tags" {
  type    = map(string)
  default = {
    Name      = "snipe-terraform"
    Terraform = "true"
  }
}
variable "ec2_ssh_key_name" {
  type    = string
  default = "SnipeSSHKey"
}
variable "ec2_ssh_public_key" {
  type    = string
  default = "ssh-rsa ........... <insert your own SSH public key here> .................."
}
