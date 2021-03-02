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
variable "route53_zone_id" {
  type = string
}
variable "ses_bucket_name" {
  type = string
}