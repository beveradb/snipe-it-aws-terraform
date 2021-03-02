resource "aws_security_group" "egress" {
  name        = "${var.project_name_hyphenated}-egress"
  description = "Allow all outbound traffic"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = var.tags
}

resource "aws_security_group" "http" {
  name        = "${var.project_name_hyphenated}-http"
  description = "HTTP, HTTPS and API traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = var.tags
}

resource "aws_security_group" "ssh" {
  name        = "${var.project_name_hyphenated}-ssh"
  description = "SSH traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = var.tags
}

resource "aws_security_group" "mysql" {
  name        = "${var.project_name_hyphenated}-mysql"
  description = "Allow ingress to MySQL"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = var.tags
}

resource "aws_security_group" "nfs" {
  name        = "${var.project_name_hyphenated}-nfs"
  description = "Allow ingress to NFS for EFS mount"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 111
    to_port     = 111
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = var.tags
}
