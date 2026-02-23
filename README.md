# Project 01: Multi-Account Security Baseline (Design-Only)

## Objective
Build an AWS Security Specialty (SCS-C03) aligned multi-account security architecture without provisioning resources yet.

## What This Project Covers
- AWS Organizations baseline
- OU and account structure
- SCP guardrails
- Delegated admin model (GuardDuty, Security Hub, Config)
- Organization CloudTrail + secure log archive design
- Terraform structure and validation

## Why Design-Only
This account is on the post-July-15-2025 free plan. Creating or joining Organizations can trigger paid-plan behavior.
So this project focuses on architecture, policy, and IaC quality without `terraform apply`.

## Project Structure
- `organization.tf`: organization and root outputs
- `ous.tf`: Security and Workloads OUs
- `accounts.tf`: LogArchive, SecurityTooling, and DevWorkload accounts
- `scp.tf`: SCP resources and root attachments
- `scp-deny-disable-security-services.json`: deny disabling core security controls
- `scp-deny-leave-org.json`: deny leaving org
- `delegated-admin.tf`: delegated admin resources
- `cloudtrail-org.tf`: org CloudTrail + secure S3/KMS log design
- `config-org.tf`: org Config aggregator design
- `variables.tf`: reusable inputs
- `terraform.tfvars.example`: safe sample values
- `docs/architecture.md`: security architecture and threat mapping
- `docs/runbook.md`: deployment and verification process
- `docs/checklist.md`: SCS-C03 control mapping checklist

## Validation Commands
```bash
terraform fmt -recursive
terraform validate
```

## Current Status
- IaC written and validated
- No infrastructure provisioned
