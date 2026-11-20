variable "aws_provider_version" {
  type    = string
  default = "6.71.0"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "bucket_deletion_window" {
  type    = number
  default = 10
}

variable "sse_algo" {
  type    = string
  default = "aws:kms"
}

variable "bucket_owner" {
  type    = string
  default = "BucketOwnerPreferred"
}
