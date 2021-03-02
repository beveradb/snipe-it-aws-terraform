variable "tags" {
  type = map(string)
}
variable "project_name_hyphenated" {
  type = string
}
variable "db_name" {
  type = string
}

variable "security_group_ids" {
  type = map(string)
}
variable "subnet_ids" {
  type = map(string)
}