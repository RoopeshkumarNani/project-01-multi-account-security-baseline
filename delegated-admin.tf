# Set SecurityTooling as delegated GuardDuty organization admin.
resource "aws_guardduty_organization_admin_account" "gd_admin" {
  admin_account_id = aws_organizations_account.security_tooling.id
}

# Set SecurityTooling as delegated Security Hub organization admin.
resource "aws_securityhub_organization_admin_account" "sh_admin" {
  admin_account_id = aws_organizations_account.security_tooling.id
}

# Register SecurityTooling as delegated administrator for AWS Config org features.
resource "aws_organizations_delegated_administrator" "config_admin" {
  account_id        = aws_organizations_account.security_tooling.id
  service_principal = "config.amazonaws.com"
}
