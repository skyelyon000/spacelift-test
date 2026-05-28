variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}
variable "environment" {
  description = "Environment name (used in resource names and tags)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}
variable "enable_versioning" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = false
}
variable "ssm_message" {
  description = "Value stored in the SSM parameter — change this to trigger a new run"
  type        = string
  default     = "Hello from Spacelift!"
}
variable "create_iam_role" {
  description = "Whether to create the playground IAM role (set to true to test approval policies)"
  type        = bool
  default     = false
}
