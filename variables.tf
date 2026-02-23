# Region used by all providers in this project.
variable "aws_region" {
  description = "Primary AWS region for provider configuration"
  type        = string
  default     = "ap-southeast-1"
}

# AWS CLI profile for the management account (default provider).
variable "management_profile" {
  description = "AWS CLI profile name for Management account"
  type        = string
  default     = "management"
}

# AWS CLI profile for the LogArchive account (aliased provider).
variable "log_archive_profile" {
  description = "AWS CLI profile name for LogArchive account"
  type        = string
  default     = "logarchive"
}

# AWS CLI profile for the SecurityTooling account (aliased provider).
variable "security_tooling_profile" {
  description = "AWS CLI profile name for SecurityTooling account"
  type        = string
  default     = "securitytooling"
}

# Email used when creating the LogArchive member account.
variable "log_archive_account_email" {
  description = "Email for LogArchive account creation"
  type        = string
}

# Email used when creating the SecurityTooling member account.
variable "security_tooling_account_email" {
  description = "Email for SecurityTooling account creation"
  type        = string
}

# Email used when creating the DevWorkload member account.
variable "dev_workload_account_email" {
  description = "Email for DevWorkload account creation"
  type        = string
}

# Globally unique bucket name for organization CloudTrail logs.
variable "org_trail_bucket_name" {
  description = "Unique S3 bucket name for organization CloudTrail logs"
  type        = string
}

# Default object lock retention period (in days) for audit logs.
variable "object_lock_retention_days" {
  description = "Default Object Lock retention (governance mode)"
  type        = number
  default     = 30
}
