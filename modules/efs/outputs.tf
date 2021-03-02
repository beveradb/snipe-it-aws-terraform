output "efs_filesystem_id" {
  value = aws_efs_file_system.efs-assets.id
}

output "efs_dns_name" {
  value = "${aws_efs_file_system.efs-assets.id}.efs.${var.region}.amazonaws.com"
}
