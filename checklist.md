# SCS-C03 Checklist: Project 01

## Identity and Access Management
- [ ] Management account used for governance only
- [ ] Security operations isolated in `SecurityTooling`
- [ ] Workload operations isolated in `DevWorkload`
- [ ] Trust boundaries documented in architecture

## Detection and Monitoring
- [ ] Organization CloudTrail defined
- [ ] Multi-region trail enabled
- [ ] Log-file validation enabled
- [ ] Centralized logging destination defined (`LogArchive`)
- [ ] GuardDuty delegated admin configured (design)
- [ ] Security Hub delegated admin configured (design)
- [ ] Config aggregator configured (design)

## Infrastructure Security
- [ ] OU structure defined (`Security`, `Workloads`)
- [ ] Account placement aligns to least privilege by function
- [ ] SCP to prevent disabling security controls defined
- [ ] SCP to prevent leaving organization defined

## Data Protection
- [ ] Log bucket encryption with KMS defined
- [ ] Bucket public access blocked
- [ ] Object lock and versioning defined
- [ ] Bucket policy allows CloudTrail writes and restricts unsafe access

## Incident Response Readiness
- [ ] Centralized, immutable audit trail design documented
- [ ] Threat-to-control mapping documented
- [ ] Runbook includes verification steps for future deployment

## Quality Gates
- [ ] `terraform fmt -recursive` passes
- [ ] `terraform validate` passes
- [ ] No hardcoded personal values in committed files
- [ ] `terraform.tfvars` kept local only (if used)
