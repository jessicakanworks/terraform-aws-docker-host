terraform {
  required_version = ">= 1.6"
  required_providers { aws = { source = "hashicorp/aws", version = "~> 5.60" } }
}
provider "aws" {
  region = var.region
  default_tags { tags = { Project = "notes", Env = "dev", ManagedBy = "terraform" } }
}

module "vpc" {
  source = "../../modules/vpc"
  name   = "notes-dev"
  az     = "${var.region}a"
}
module "webserver" {
  source         = "../../modules/webserver"
  name           = "notes-dev"
  vpc_id         = module.vpc.vpc_id
  subnet_id      = module.vpc.public_subnet_id
  my_ip          = var.my_ip
  ssh_public_key = var.ssh_public_key
}

variable "region"         { type = string  default = "eu-west-1" }
variable "my_ip"          { type = string }
variable "ssh_public_key" { type = string  sensitive = true }

output "public_ip"  { value = module.webserver.public_ip }
output "ssh"        { value = "ssh ubuntu@${module.webserver.public_ip}" }
