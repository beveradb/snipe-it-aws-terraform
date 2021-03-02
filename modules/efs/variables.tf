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

variable "subnet_ids" {
  type = map(string)
}
variable "security_group_ids" {
  type = map(string)
}