provider "aws" {
  region = var.region
}

locals {
  s3_name        = "${var.s3_prefix}-${lower(random_string.random.result)}-${var.region}"
}

# The random string needed for injecting randomness in the name of the S3 bucket.
resource "random_string" "random" {
  length  = 12
  special = false
}

# S3 bucket for exported mailbox content.
resource "aws_s3_bucket" "mail_export" {
  bucket = local.s3_name
  acl    = "private"

  force_destroy = "true"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "ExpireOldVersionsAfter30Days"
    enabled = true

    noncurrent_version_expiration {
      days = 30
    }
  }
}
