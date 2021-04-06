provider "aws" {
  region = var.region
}

locals {
  #iam_user = var.iam_user == null ?         
  s3_name = "${var.s3_prefix}-${lower(random_string.random.result)}-${var.region}"

  arn_root = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  arn_user = var.iam_user == null ? aws_iam_user.admin[0].arn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.iam_user}"

  arn_kms = aws_kms_key.a.arn
  arn_s3  = "${aws_s3_bucket.mail_export.arn}/*"

  account_id = data.aws_caller_identity.current.account_id
}

# Use this data source to get the access to the effective Account ID, User ID, and ARN in which Terraform is authorized.
data "aws_caller_identity" "current" {}

# This data source can be used to fetch information about a specific IAM user.
data "aws_iam_user" "example" {
  count = var.iam_user == null ? 0 : 1

  user_name = var.iam_user
}

# Create IAM user if var.iam_user is null.
resource "aws_iam_user" "admin" {
  count = var.iam_user == null ? 1 : 0

  name = "mail-export-admin"

  tags = {
    Name      = "mail-export-admin"
    terraform = true
  }
}

# Add WorkMail Admin policy to the IAM user if var.iam_user is null.
resource "aws_iam_user_policy" "workmail_admin" {
  count = var.iam_user == null ? 1 : 0

  name = "WorkMail-Admin"
  user = aws_iam_user.admin[0].name

  # Terraform's "jsonencode" function converts a Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "workmail:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "cloudshell:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Template file for the KMS key policy.
data "template_file" "kms_key_policy" {
  template = file("${path.module}/kms-key-policy.json.tpl")

  vars = {
    arn_root = local.arn_root
    arn_user = local.arn_user
  }
}

# Create KMS Key for encrypting the mail.
resource "aws_kms_key" "a" {
  description = "KMS key to use for encrypting exported mail messages"

  deletion_window_in_days = 7
  policy                  = data.template_file.kms_key_policy.rendered
}

# Create alias for the KMS key.
resource "aws_kms_alias" "a" {
  name          = "alias/mail-export-key"
  target_key_id = aws_kms_key.a.key_id
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

# Manages S3 bucket-level Public Access Block configuration.
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.mail_export.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Template file for the IAM role trust policy.
data "template_file" "iam_role_trust" {
  template = file("${path.module}/iam-role-trust.json.tpl")

  vars = {
    account_id = local.account_id
  }
}

# Template file for the IAM role policy.
data "template_file" "iam_role_policy" {
  template = file("${path.module}/iam-role-policy.json.tpl")

  vars = {
    arn_kms = local.arn_kms
    arn_s3  = local.arn_s3
  }
}

# IAM role.
resource "aws_iam_role" "main" {
  name = "aws-workmail-export-role"
  path = "/"

  assume_role_policy = data.template_file.iam_role_trust.rendered
}

# IAM  role policy.
resource "aws_iam_role_policy" "main" {
  name = "aws-workmail-export-role-policy"
  role = aws_iam_role.main.id

  policy = data.template_file.iam_role_policy.rendered
}