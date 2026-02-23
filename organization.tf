# Configure Terraform and pin the AWS provider version for reproducible behavior.
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Use the management account profile because Organizations is administered there.
provider "aws" {
  region  = var.aws_region
  profile = var.management_profile
}

# Create the AWS Organization and enable SCP support plus trusted service access.
resource "aws_organizations_organization" "org" {
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "guardduty.amazonaws.com",
    "securityhub.amazonaws.com",
    "sso.amazonaws.com"
  ]
  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY"
  ]
  feature_set = "ALL"
}

# Output the Organization ID for referencing in later modules and verification.
output "organization_id" {
  value = aws_organizations_organization.org.id
}

# Output the root ID so OU creation and policy attachments can target the org root.
output "root_id" {
  value = aws_organizations_organization.org.roots[0].id
}
