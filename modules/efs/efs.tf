resource "aws_efs_file_system" "efs-assets" {
  tags = var.tags
}

resource "aws_efs_mount_target" "mount" {
  file_system_id  = aws_efs_file_system.efs-assets.id
  subnet_id       = var.subnet_ids.efs-subnet
  security_groups = [
    var.security_group_ids.nfs
  ]
}
