resource "aws_db_subnet_group" "rds-subnet-group" {
  name       = "${var.project_name_hyphenated}-subnet-group"
  subnet_ids = [
    var.subnet_ids.rds-subnet-one,
    var.subnet_ids.rds-subnet-two
  ]

  tags = var.tags
}

resource "random_pet" "random-pet" {
  length    = "2"
  separator = "_"
}

resource "random_password" "random-password" {
  length  = 20
  special = false
}

resource "aws_rds_cluster" "db-cluster" {
  cluster_identifier     = "${var.project_name_hyphenated}-db-cluster"
  engine                 = "aurora-mysql"
  engine_mode            = "serverless"
  engine_version         = "5.7.mysql_aurora.2.07.1"
  port                   = "3306"
  database_name          = var.db_name
  master_username        = random_pet.random-pet.id
  master_password        = random_password.random-password.result
  enable_http_endpoint   = true
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.rds-subnet-group.name
  vpc_security_group_ids = [
    var.security_group_ids.egress,
    var.security_group_ids.http,
    var.security_group_ids.mysql
  ]
  scaling_configuration {
    min_capacity = 2
  }
}
