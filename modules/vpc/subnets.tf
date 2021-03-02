resource "aws_subnet" "ec2-subnet-one" {
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 3, 1)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "${var.region}a"
  tags              = var.tags
}

resource "aws_subnet" "ec2-subnet-two" {
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 3, 4)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "${var.region}b"
  tags              = var.tags
}

resource "aws_route_table_association" "bastion-route-table-subnet-one-association" {
  subnet_id      = aws_subnet.ec2-subnet-one.id
  route_table_id = aws_route_table.route-table.id
}
resource "aws_route_table_association" "bastion-route-table-subnet-two-association" {
  subnet_id      = aws_subnet.ec2-subnet-two.id
  route_table_id = aws_route_table.route-table.id
}

resource "aws_subnet" "rds-subnet-one" {
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 3, 2)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "${var.region}a"
  tags              = var.tags
}

resource "aws_subnet" "rds-subnet-two" {
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 3, 3)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "${var.region}b"
  tags              = var.tags
}

resource "aws_route_table_association" "rds-subnet-one-route-table-association" {
  subnet_id      = aws_subnet.rds-subnet-one.id
  route_table_id = aws_route_table.route-table.id
}

resource "aws_route_table_association" "rds-subnet-two-route-table-association" {
  subnet_id      = aws_subnet.rds-subnet-two.id
  route_table_id = aws_route_table.route-table.id
}

resource "aws_subnet" "efs-subnet" {
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 4, 1)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "${var.region}a"
  tags              = var.tags
}

resource "aws_route_table_association" "efs-subnet-route-table-association" {
  subnet_id      = aws_subnet.efs-subnet.id
  route_table_id = aws_route_table.route-table.id
}
