variable "name"       { type = string }
variable "cidr"       { type = string  default = "10.0.0.0/16" }
variable "public_cidr"{ type = string  default = "10.0.1.0/24" }
variable "az"         { type = string }

resource "aws_vpc" "this" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true
  tags = { Name = "${var.name}-vpc" }
}
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_cidr
  availability_zone       = var.az
  map_public_ip_on_launch = true
  tags = { Name = "${var.name}-public" }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.name}-igw" }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route { cidr_block = "0.0.0.0/0" gateway_id = aws_internet_gateway.igw.id }
  tags = { Name = "${var.name}-public-rt" }
}
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
output "vpc_id"           { value = aws_vpc.this.id }
output "public_subnet_id" { value = aws_subnet.public.id }
