# Create a dedicated OU for centrally managed security accounts.
resource "aws_organizations_organizational_unit" "security_ou" {
  name      = "Security"
  parent_id = aws_organizations_organization.org.roots[0].id
}

# Create a separate OU for application and workload accounts.
resource "aws_organizations_organizational_unit" "workloads_ou" {
  name      = "Workloads"
  parent_id = aws_organizations_organization.org.roots[0].id
}

# Output Security OU ID for account placement and policy targeting.
output "security_ou_id" {
  value = aws_organizations_organizational_unit.security_ou.id
}

# Output Workloads OU ID for account placement and policy targeting.
output "workloads_ou_id" {
  value = aws_organizations_organizational_unit.workloads_ou.id
}
