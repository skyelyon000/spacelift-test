# =============================================================================
# Spacelift Playground — main.tf
# A simple set of AWS resources to experiment with Spacelift features:
#   - Stack management, drift detection, policies, notifications, etc.
# =============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "spacelift"
      Project     = "playground"
    }
  }
}

# -----------------------------------------------------------------------------
# Random suffix so resource names don't collide between runs
# -----------------------------------------------------------------------------
resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  name_prefix = "${var.environment}-playground-${random_id.suffix.hex}"
}

# -----------------------------------------------------------------------------
# S3 bucket — good for testing drift detection (manually delete/add a tag)
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "playground" {
  bucket = "${local.name_prefix}-bucket"
}

resource "aws_s3_bucket_versioning" "playground" {
  bucket = aws_s3_bucket.playground.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "playground" {
  bucket = aws_s3_bucket.playground.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "playground" {
  bucket = aws_s3_bucket.playground.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -----------------------------------------------------------------------------
# SSM Parameter — cheap, fast resource great for iterating on Spacelift runs
# -----------------------------------------------------------------------------

resource "aws_ssm_parameter" "playground" {
  name  = "/${var.environment}/playground/message"
  type  = "String"
  value = var.ssm_message

  tags = {
    Purpose = "spacelift-playground"
  }
}

# -----------------------------------------------------------------------------
# IAM Role — useful for testing policy-as-code and approval flows
# -----------------------------------------------------------------------------

resource "aws_iam_role" "playground" {
  count = var.create_iam_role ? 1 : 0

  name = "${local.name_prefix}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
      }
    ]
  })

  tags = {
    Purpose = "spacelift-playground"
  }
}
