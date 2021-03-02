output "db_endpoint" {
  value = aws_rds_cluster.db-cluster.endpoint
}
output "db_username" {
  value = aws_rds_cluster.db-cluster.master_username
}
output "db_password" {
  value = aws_rds_cluster.db-cluster.master_password
}
output "db_port" {
  value = aws_rds_cluster.db-cluster.port
}