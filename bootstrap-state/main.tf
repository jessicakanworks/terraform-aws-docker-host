# Run once per AWS account to create the state bucket and lock table used by backend.tf
provider "aws" { region = "eu-west-1" }
resource "aws_s3_bucket" "state" { bucket = "CHANGEME-tfstate" }
resource "aws_s3_bucket_versioning" "state" { bucket = aws_s3_bucket.state.id  versioning_configuration { status = "Enabled" } }
resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id
  rule { apply_server_side_encryption_by_default { sse_algorithm = "AES256" } }
}
resource "aws_dynamodb_table" "locks" {
  name = "terraform-locks"  billing_mode = "PAY_PER_REQUEST"  hash_key = "LockID"
  attribute { name = "LockID"  type = "S" }
}
