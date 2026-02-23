# Use the SecurityTooling account context because the aggregator is centralized there.
provider "aws" {
  alias   = "security_tooling"
  region  = var.aws_region
  profile = var.security_tooling_profile
}

# Create a single org-wide AWS Config aggregator for centralized compliance visibility.
resource "aws_config_configuration_aggregator" "org" {
  provider = aws.security_tooling
  name     = "org-config-aggregator"

  # Aggregate configuration/compliance data from all organization accounts and regions.
  organization_aggregation_source {
    all_regions = true
    role_arn    = "arn:aws:iam::${aws_organizations_account.security_tooling.id}:role/AWSConfigRoleForOrganizations"
  }

  # Ensure delegated admin registration exists before aggregator creation.
  depends_on = [aws_organizations_delegated_administrator.config_admin]
}

# Output aggregator name for future validation and runbook checks.
output "config_aggregator_name" {
  value = aws_config_configuration_aggregator.org.name
}
