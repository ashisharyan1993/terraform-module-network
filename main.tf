locals {
  prifix = var.vpc_prifix == "" ? "Dev" : var.vpc_prifix
 }

# VPC
resource "aws_vpc" "default" {
    cidr_block = var.vpc_cidr_block
    enable_dns_hostnames = true
    tags = {
       Name = "${local.prifix}-vpc"
    }
}
# Internet Gateway
resource "aws_internet_gateway" "default" {
    vpc_id = aws_vpc.default.id

    tags = {
       Name = "${local.prifix}-igw"
    }
}

# Subnets Public
resource "aws_subnet" "public-subnet" {
    vpc_id            = aws_vpc.default.id
    cidr_block        = var.public_subnet_cidr_block
    availability_zone = "${var.region}a"
    map_public_ip_on_launch = true
    tags = {
       Name = "${local.prifix}-public-sub"
    }
}
# Subnets Private
resource "aws_subnet" "private-subnet" {
    vpc_id            = aws_vpc.default.id
    cidr_block        = var.private_subnet_cidr_block
    availability_zone = "${var.region}b"

    tags = {
       Name = "${local.prifix}-private-sub"
    }
}

# Route Tables
resource "aws_route_table" "rt-public" {
    vpc_id = aws_vpc.default.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.default.id
    }

    tags = {
       Name = "${local.prifix}-rt-public"
    }
}
# Route Tables Association
resource "aws_route_table_association" "public-rt-association" {
    subnet_id = aws_subnet.public-subnet.id
    route_table_id = aws_route_table.rt-public.id
}
resource "aws_route_table_association" "private-rt-association" {
    subnet_id = aws_subnet.private-subnet.id
    route_table_id = aws_route_table.rt-public.id
}
