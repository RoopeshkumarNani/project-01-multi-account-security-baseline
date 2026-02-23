# Runbook: Multi-Account Security Baseline

## Scope
This runbook defines the safe workflow for a design-only AWS security baseline lab.

## Preconditions
- Terraform installed (`>= 1.6`)
- AWS CLI configured (profiles if needed)
- Do not run `terraform apply` on this free-plan account

## Local Validation Workflow (Current)
1. Keep values in `terraform.tfvars.example` (or local-only `terraform.tfvars` if needed).
2. Run:
   ```bash
   terraform fmt -recursive
   terraform validate
   ```
3. Fix all syntax or reference issues until validation succeeds.

## Planned Deployment Workflow (Future Paid Sandbox Only)
1. Provision organization (`organization.tf`)
2. Create OUs (`ous.tf`)
3. Create member accounts (`accounts.tf`)
4. Create and attach SCPs (`scp.tf` + JSON policies)
5. Configure delegated admins (`delegated-admin.tf`)
6. Configure organization CloudTrail and secure log destination (`cloudtrail-org.tf`)
7. Configure Config org aggregation (`config-org.tf`)

## Post-Deployment Verification (Future)
- Organization exists with `feature_set = ALL`
- OUs exist: `Security`, `Workloads`
- Accounts are in correct OUs
- SCPs are attached at intended targets
- Delegated admin set to `SecurityTooling` for GuardDuty and Security Hub
- Config delegated admin and aggregator are active
- Org CloudTrail is enabled, multi-region, and log-file validation is on
- Log bucket uses KMS encryption, object lock, and restricted access policy

## Rollback Note
This project is currently design-only. No live resources were created, so no destroy step is required now.
