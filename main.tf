terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0"
    }
  }
}

########################
# Variables (optional)
########################

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-1"
}

# Change ONLY this value in a PR to get a plan diff
# without touching the S3 bucket
variable "demo_pr_marker" {
  type        = string
  description = "PR-plan demo marker"
  default     = "v5"
}

########################
# Providers
########################

provider "aws" {
  region = var.aws_region
}

########################
# Stable random suffix
########################

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

########################
# Real infrastructure
########################

resource "aws_s3_bucket" "demo" {
  bucket = "env0-opentofu-demo-${random_id.bucket_suffix.hex}"
}

resource "aws_s3_bucket_versioning" "demo" {
  bucket = aws_s3_bucket.demo.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "demo" {
  bucket                  = aws_s3_bucket.demo.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

########################
# PR-plan demo change
########################

resource "null_resource" "pr_plan_demo" {
  triggers = {
    demo_pr_marker = var.demo_pr_marker
  }
}

########################
# Outputs
########################

output "bucket_name" {
  value = aws_s3_bucket.demo.bucket
}

output "demo_pr_marker_effective" {
  value = var.demo_pr_marker
}
