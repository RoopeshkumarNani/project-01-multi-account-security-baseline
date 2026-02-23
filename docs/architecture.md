# Project 01 - Multi-Account Security Baseline Architecture

## 1. Objective
This project defines a secure, exam-focused AWS multi-account baseline for a small company. The design separates security operations from application workloads, centralizes telemetry, and applies organization guardrails to reduce compromise impact.

A multi-account model is safer than a single-account model because it enforces isolation by function. Security teams operate shared controls in dedicated accounts, application teams deploy only to workload accounts, and audit logs are stored outside workload ownership.

This architecture maps directly to AWS Certified Security - Specialty (SCS-C03) domains: identity and access management, detection and monitoring, infrastructure security, data protection, and incident response readiness.

## 2. Organization Design

### 2.1 OU Structure
- Root
  - Security OU
  - Workloads OU

### 2.2 Account Roles
- Management account:
  - Owns AWS Organizations, billing, and SCP attachment.
  - Has break-glass governance access only.
- LogArchive account:
  - Stores centralized CloudTrail and Config history in immutable S3 buckets.
  - Owns KMS keys for log encryption.
- SecurityTooling account:
  - Runs delegated admin services for GuardDuty, Security Hub, and Config aggregation.
  - Owns investigation dashboards, alert routing, and incident workflow integrations.
- DevWorkload account:
  - Hosts application resources.
  - Must not host organization-wide security management services.

### 2.3 Trust Boundaries
- Security platform administrators manage `SecurityTooling` and read protected logs in `LogArchive`.
- Workload engineers deploy only in `DevWorkload` using least-privilege roles.
- No workload role gets permissions to delete or modify centralized security logs.
- Management account is used for governance operations, not day-to-day engineering.

## 3. Centralized Logging Flow
- Log producers:
  - Organization CloudTrail management events from all member accounts.
  - CloudTrail data events for high-risk resources (selected S3 buckets, Lambda as needed).
  - AWS Config configuration snapshots and compliance evaluations.
- Log destination:
  - Primary storage is S3 in the `LogArchive` account.
  - Logs are partitioned by account and region for audit traceability.
- Log protection:
  - Server-side encryption with customer-managed KMS keys.
  - S3 Object Lock (governance mode) and versioning for tamper resistance.
  - Bucket policy denies deletes except tightly controlled break-glass role.
- Access model:
  - Security analysts get read-only access.
  - No workload principal can change retention, lifecycle, or encryption settings.

## 4. Security Services Ownership
- GuardDuty delegated admin account:
  - `SecurityTooling`
- Security Hub delegated admin account:
  - `SecurityTooling`
- AWS Config aggregator account:
  - `SecurityTooling`
- Delegated administration is preferred because it gives one operational security plane across all accounts while preserving account-level isolation.

## 5. Preventive Controls (SCP Plan)
- SCP-1:
  - Name: `DenyDisableSecurityServices`
  - Purpose: Prevent users from turning off mandatory detective controls.
  - Key denied actions:
    - `cloudtrail:StopLogging`
    - `cloudtrail:DeleteTrail`
    - `config:StopConfigurationRecorder`
    - `config:DeleteConfigurationRecorder`
    - `guardduty:DeleteDetector`
    - `securityhub:DisableSecurityHub`
- SCP-2:
  - Name: `DenyLeaveOrganization`
  - Purpose: Prevent account escape from governance boundaries.
  - Key denied actions:
    - `organizations:LeaveOrganization`
- SCP-3 (optional):
  - Name: `AllowedRegionsOnly`
  - Purpose: Restrict API activity to approved regions.
  - Key denied pattern:
    - Deny most actions when `aws:RequestedRegion` is not in approved list.

## 6. Threat Scenarios and Control Mapping
1. Threat:
   - An insider with elevated permissions attempts to stop CloudTrail to hide malicious actions.
   - Preventive control(s): `DenyDisableSecurityServices` SCP.
   - Detective control(s): Security Hub control failures, Config drift alerts, and GuardDuty anomaly signals.
2. Threat:
   - A compromised workload role tries to delete centralized logs or alter bucket policies.
   - Preventive control(s): Cross-account access boundaries, explicit S3 deny statements, KMS key policy scoping.
   - Detective control(s): CloudTrail events for denied actions, Config rule non-compliance, alerting in SecurityTooling.
3. Threat:
   - A workload account is removed from centralized oversight by leaving the organization.
   - Preventive control(s): `DenyLeaveOrganization` SCP.
   - Detective control(s): CloudTrail Organizations API monitoring and Security Hub/Config visibility checks.

## 7. Assumptions and Limits
- This project is design-first and intentionally not provisioned yet to avoid cost impact on post-July-2025 free plan accounts.
- Account IDs, ARNs, and KMS key IDs are placeholders until deployment.
- Final validation (SCP behavior, delegated admin enrollment, log retention controls) must be executed in a paid lab or sandbox account later.

## 8. Success Criteria
- Architecture is complete enough that another engineer can implement it without guessing missing control intent.
- Every major control has a clear purpose and threat mapping.
- Output artifacts derived from this document:
  - `scp-deny-disable-security-services.json`
  - `scp-deny-leave-org.json`
  - `*.tf` IaC definitions in project root
  - `docs/runbook.md` deployment and verification steps
