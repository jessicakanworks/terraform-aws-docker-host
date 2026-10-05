variable "name"           { type = string }
variable "vpc_id"         { type = string }
variable "subnet_id"      { type = string }
variable "instance_type"  { type = string  default = "t3.micro" }
variable "my_ip"          { type = string
  validation { condition = can(cidrhost("${var.my_ip}/32", 0))  error_message = "my_ip must be an IPv4 address." } }
variable "ssh_public_key" { type = string }
variable "app_port"       { type = number  default = 8000 }

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter { name = "name"  values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"] }
}
resource "aws_security_group" "web" {
  name   = "${var.name}-sg"
  vpc_id = var.vpc_id
  ingress { from_port = 22            to_port = 22            protocol = "tcp" cidr_blocks = ["${var.my_ip}/32"] }
  ingress { from_port = var.app_port  to_port = var.app_port  protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }
  ingress { from_port = 443           to_port = 443           protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }
  egress  { from_port = 0 to_port = 0 protocol = "-1" cidr_blocks = ["0.0.0.0/0"] }
  tags = { Name = "${var.name}-sg" }
}
resource "aws_key_pair" "deploy" {
  key_name   = "${var.name}-key"
  public_key = var.ssh_public_key
}
resource "aws_instance" "app" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = aws_key_pair.deploy.key_name
  user_data              = file("${path.module}/user-data.sh")
  root_block_device { volume_size = 20  volume_type = "gp3"  encrypted = true }
  metadata_options { http_tokens = "required" }   # IMDSv2 only
  tags = { Name = "${var.name}-app" }
}
resource "aws_eip" "app" {
  instance = aws_instance.app.id
  domain   = "vpc"
}
output "public_ip"   { value = aws_eip.app.public_ip }
output "instance_id" { value = aws_instance.app.id }
