resource "aws_subnet" "ecs-subnet-private" {
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 3, 5)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "${var.region}a"
  tags              = var.tags
}
resource "aws_subnet" "ecs-subnet-public-one" {
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 3, 6)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "${var.region}a"
  tags              = var.tags
}
resource "aws_subnet" "ecs-subnet-public-two" {
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 3, 7)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "${var.region}b"
  tags              = var.tags
}

resource "aws_route_table" "ecs-public" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "ecs-private" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table_association" "ecs-public-subnet-one" {
  subnet_id      = aws_subnet.ecs-subnet-public-one.id
  route_table_id = aws_route_table.ecs-public.id
}
resource "aws_route_table_association" "ecs-public-subnet-two" {
  subnet_id      = aws_subnet.ecs-subnet-public-two.id
  route_table_id = aws_route_table.ecs-public.id
}

resource "aws_route_table_association" "ecs-private-subnet" {
  subnet_id      = aws_subnet.ecs-subnet-private.id
  route_table_id = aws_route_table.ecs-private.id
}

resource "aws_eip" "ecs-nat-one" {
  vpc = true
}
resource "aws_eip" "ecs-nat-two" {
  vpc = true
}

resource "aws_nat_gateway" "ecs-ngw-one" {
  subnet_id     = aws_subnet.ecs-subnet-public-one.id
  allocation_id = aws_eip.ecs-nat-one.id

  depends_on = [aws_internet_gateway.igw]
}
resource "aws_nat_gateway" "ecs-ngw-two" {
  subnet_id     = aws_subnet.ecs-subnet-public-two.id
  allocation_id = aws_eip.ecs-nat-two.id

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route" "ecs-public-igw" {
  route_table_id         = aws_route_table.ecs-public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "ecs-private-ngw-one" {
  route_table_id         = aws_route_table.ecs-private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ecs-ngw-one.id
}
