# Define an SCP that blocks attempts to disable core security telemetry services.
resource "aws_organizations_policy" "deny_disable_security_services" {
  name        = "DenyDisableSecurityServices"
  description = "Prevents disabling core security monitoring services"
  type        = "SERVICE_CONTROL_POLICY"

  content = file("${path.module}/scp-deny-disable-security-services.json")
}

# Attach the SCP at the org root so it applies to all OUs and member accounts.
resource "aws_organizations_policy_attachment" "attach_deny_disable_to_root" {
  policy_id = aws_organizations_policy.deny_disable_security_services.id
  target_id = aws_organizations_organization.org.roots[0].id
}

# Define an SCP that prevents member accounts from leaving the organization boundary.
resource "aws_organizations_policy" "deny_leave_organization" {
  name        = "DenyLeaveOrganization"
  description = "Prevents accounts from leaving AWS Organizations"
  type        = "SERVICE_CONTROL_POLICY"

  content = file("${path.module}/scp-deny-leave-org.json")
}

# Attach the leave-org SCP at root to enforce governance consistently everywhere.
resource "aws_organizations_policy_attachment" "attach_deny_leave_to_root" {
  policy_id = aws_organizations_policy.deny_leave_organization.id
  target_id = aws_organizations_organization.org.roots[0].id
}
