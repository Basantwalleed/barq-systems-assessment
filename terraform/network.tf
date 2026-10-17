# Custom VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Public subnet for the Kubernetes nodes
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone_a
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet"
    Tier = "public"
  }
}

# Private database subnet in Availability Zone A
resource "aws_subnet" "database_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.database_subnet_a_cidr
  availability_zone = var.availability_zone_a

  tags = {
    Name = "${var.project_name}-database-subnet-a"
    Tier = "private"
  }
}

# Private database subnet in Availability Zone B
resource "aws_subnet" "database_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.database_subnet_b_cidr
  availability_zone = var.availability_zone_b

  tags = {
    Name = "${var.project_name}-database-subnet-b"
    Tier = "private"
  }
}

# Internet Gateway for public subnet traffic
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Private route tables: no direct route to the Internet Gateway
resource "aws_route_table" "database_a" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-database-a-rt"
  }
}

resource "aws_route_table" "database_b" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-database-b-rt"
  }
}

resource "aws_route_table_association" "database_a" {
  subnet_id      = aws_subnet.database_a.id
  route_table_id = aws_route_table.database_a.id
}

resource "aws_route_table_association" "database_b" {
  subnet_id      = aws_subnet.database_b.id
  route_table_id = aws_route_table.database_b.id
}
