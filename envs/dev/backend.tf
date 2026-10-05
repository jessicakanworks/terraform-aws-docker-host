terraform {
  backend "s3" {
    bucket         = "CHANGEME-tfstate"
    key            = "notes/dev/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
