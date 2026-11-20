terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.71.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_iam_policy" "my_policy" {
  name = "AdministratorAccess"
}

resource "aws_kms_key" "encryption_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = var.bucket_deletion_window
}

# create s3 bucket
resource "aws_s3_bucket" "assessment-s3b" {
  bucket = "assessment-s3b"

  tags = {
    Name        = "assessment-s3b"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "assessment-s3b" {
  bucket = aws_s3_bucket.assessment-s3b.bucket
  acl    = "private"
}

# enable s3 bucket versioning
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.assessment-s3b.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

# create bucket encryption key
resource "aws_s3_bucket_server_side_encryption_configuration" "enc_config" {
  bucket = aws_s3_bucket.assessment-s3b.bucket
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.encryption_key.arn
      sse_algorithm     = var.sse_algo
    }
    bucket_key_enabled       = true
    blocked_encryption_types = ["SSE-C"]
  }
}

# block public access
resource "aws_s3_bucket_public_access_block" "acl_config" {
  bucket = aws_s3_bucket.assessment-s3b.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# setup ownership
resource "aws_s3_bucket_ownership_controls" "ownership_config" {
  bucket = aws_s3_bucket.assessment-s3b.bucket

  rule {
    object_ownership = var.bucket_owner
  }
}

# setup lifecycle
resource "aws_s3_bucket_lifecycle_configuration" "s3_lifecycle" {
  bucket = aws_s3_bucket.assessment-s3b.bucket

  rule {
    id = "rule-id-1"
    filter {
      prefix = "avatar/"
    }
    status = "Enabled"
  }
}

# output
output "s3_bucket_name" {
  value = aws_s3_bucket.assessment-s3b.bucket_domain_name
}

output "policy_arn" {
  value = data.aws_iam_policy.my_policy.arn
}
