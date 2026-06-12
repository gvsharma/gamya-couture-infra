resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name            = "${var.name_prefix}-vpc"
    Tier            = "network"
    ResourcePurpose = "network-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name            = "${var.name_prefix}-igw"
    ResourcePurpose = "network-internet-gateway"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.public_subnet_cidr
  availability_zone       = local.az
  map_public_ip_on_launch = true

  tags = {
    Name            = "${var.name_prefix}-public-${local.az}"
    Tier            = "public"
    ResourcePurpose = "network-subnet-public-ec2"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name            = "${var.name_prefix}-public-rt"
    ResourcePurpose = "network-route-table-public"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Private subnets for RDS (two AZs required by DB subnet group; no NAT/IGW route).
resource "aws_subnet" "private" {
  count = 2

  vpc_id            = aws_vpc.this.id
  cidr_block        = local.private_subnet_cidrs[count.index]
  availability_zone = local.azs[count.index]

  tags = {
    Name            = "${var.name_prefix}-private-${local.azs[count.index]}"
    Tier            = "private"
    Role            = "rds"
    ResourcePurpose = "network-subnet-private-rds"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name            = "${var.name_prefix}-private-rt"
    ResourcePurpose = "network-route-table-private"
  }
}

resource "aws_route_table_association" "private" {
  count = 2

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
