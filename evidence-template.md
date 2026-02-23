# Evidence Template: Project 01

## Purpose
Capture proof artifacts for each control so revision before SCS-C03 is fast and structured.

## Metadata
- Date:
- Reviewer:
- Environment:
- Notes:

## 1. Terraform Quality Evidence
### 1.1 Formatting
- Command:
  ```bash
  terraform fmt -recursive -check
  ```
- Output file or screenshot:

### 1.2 Validation
- Command:
  ```bash
  terraform validate
  ```
- Output file or screenshot:

## 2. Architecture Evidence
- File: `docs/architecture.md`
- Proof points:
  - OU and account model
  - Trust boundaries
  - Threat-to-control mapping
- Screenshot or snippet reference:

## 3. SCP Evidence
- Files:
  - `scp-deny-disable-security-services.json`
  - `scp-deny-leave-org.json`
  - `scp.tf`
- Proof points:
  - Required deny actions exist
  - Policies are attached at root
- Screenshot or snippet reference:

## 4. Logging and Data Protection Evidence
- File: `cloudtrail-org.tf`
- Proof points:
  - Organization trail enabled
  - Multi-region + log validation enabled
  - S3 bucket object lock/versioning/public access block
  - SSE-KMS configuration and key policy scope
- Screenshot or snippet reference:

## 5. Delegated Admin Evidence
- Files:
  - `delegated-admin.tf`
  - `config-org.tf`
- Proof points:
  - GuardDuty delegated admin
  - Security Hub delegated admin
  - Config delegated admin and aggregator
- Screenshot or snippet reference:

## 6. Variables and Reusability Evidence
- Files:
  - `variables.tf`
  - `terraform.tfvars.example`
- Proof points:
  - No hardcoded account emails in Terraform resources
  - Region/profile/bucket/retention parameterized
  - Example vars file contains placeholders only
- Screenshot or snippet reference:

## 7. Sign-off
- [ ] Evidence complete for all sections
- [ ] Quality gates passed
- [ ] Ready for future deployment in paid sandbox
