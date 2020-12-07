
provider "aws" {
  version = "~> 2.0"
  region = "ap-east-1"
  profile = "default"
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "terraform-lock"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_s3_bucket" "bucket" {
  region = "ap-east-1"
  acl    = "private"
}