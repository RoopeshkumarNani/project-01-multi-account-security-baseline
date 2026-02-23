# Create a dedicated account to store immutable security and audit logs.
resource "aws_organizations_account" "log_archive" {
  name      = "LogArchive"
  email     = var.log_archive_account_email
  parent_id = aws_organizations_organizational_unit.security_ou.id

  close_on_deletion = false
}

# Create a dedicated account to host centralized security tooling and delegated admins.
resource "aws_organizations_account" "security_tooling" {
  name      = "SecurityTooling"
  email     = var.security_tooling_account_email
  parent_id = aws_organizations_organizational_unit.security_ou.id

  close_on_deletion = false
}

# Create a workload account where application teams deploy business resources.
resource "aws_organizations_account" "dev_workload" {
  name      = "DevWorkload"
  email     = var.dev_workload_account_email
  parent_id = aws_organizations_organizational_unit.workloads_ou.id

  close_on_deletion = false
}

# Output LogArchive account ID for cross-account policies and integrations.
output "log_archive_account_id" {
  value = aws_organizations_account.log_archive.id
}

# Output SecurityTooling account ID for delegated-admin service configuration.
output "security_tooling_account_id" {
  value = aws_organizations_account.security_tooling.id
}

# Output DevWorkload account ID for future workload policy scope and onboarding.
output "dev_workload_account_id" {
  value = aws_organizations_account.dev_workload.id
}
