# Use the LogArchive account context for log bucket and KMS resources.
provider "aws" {
  alias   = "log_archive"
  region  = var.aws_region
  profile = var.log_archive_profile
}

# Read the management account identity for org trail policy scoping.
data "aws_caller_identity" "management" {}

# Read the LogArchive account identity for key policy administration.
data "aws_caller_identity" "log_archive" {
  provider = aws.log_archive
}

# Read current partition so ARNs work across aws/aws-us-gov partitions.
data "aws_partition" "current" {}

# Create the centralized S3 bucket that stores organization CloudTrail logs.
resource "aws_s3_bucket" "org_trail_logs" {
  provider            = aws.log_archive
  bucket              = var.org_trail_bucket_name
  object_lock_enabled = true
  force_destroy       = false
}

# Enable S3 versioning to preserve historical log object versions.
resource "aws_s3_bucket_versioning" "org_trail_logs" {
  provider = aws.log_archive
  bucket   = aws_s3_bucket.org_trail_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enforce default object lock retention to increase tamper resistance.
resource "aws_s3_bucket_object_lock_configuration" "org_trail_logs" {
  provider = aws.log_archive
  bucket   = aws_s3_bucket.org_trail_logs.id

  rule {
    default_retention {
      mode = "GOVERNANCE"
      days = var.object_lock_retention_days
    }
  }
}

# Block all forms of public access on the centralized audit log bucket.
resource "aws_s3_bucket_public_access_block" "org_trail_logs" {
  provider = aws.log_archive
  bucket   = aws_s3_bucket.org_trail_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Build the KMS key policy for CloudTrail encryption in the LogArchive account.
data "aws_iam_policy_document" "cloudtrail_kms_policy" {
  # Allow full key administration to the LogArchive account root principal.
  statement {
    sid    = "AllowLogArchiveRootAdmin"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.log_archive.account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  # Allow CloudTrail to encrypt/decrypt log files under the expected trail context.
  statement {
    sid    = "AllowCloudTrailUseOfKey"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values = [
        "arn:${data.aws_partition.current.partition}:cloudtrail:*:${data.aws_caller_identity.management.account_id}:trail/*"
      ]
    }
  }
}

# Create the KMS key used to encrypt centralized CloudTrail logs.
resource "aws_kms_key" "cloudtrail_logs" {
  provider                = aws.log_archive
  description             = "KMS key for organization CloudTrail logs"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.cloudtrail_kms_policy.json
}

# Create a stable alias to simplify key references in operations.
resource "aws_kms_alias" "cloudtrail_logs" {
  provider      = aws.log_archive
  name          = "alias/org-cloudtrail-logs"
  target_key_id = aws_kms_key.cloudtrail_logs.key_id
}

# Enforce SSE-KMS by default for all objects written to the log bucket.
resource "aws_s3_bucket_server_side_encryption_configuration" "org_trail_logs" {
  provider = aws.log_archive
  bucket   = aws_s3_bucket.org_trail_logs.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.cloudtrail_logs.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

# Build the S3 bucket policy required for CloudTrail ACL check and log delivery.
data "aws_iam_policy_document" "cloudtrail_bucket_policy" {
  # Permit CloudTrail to validate bucket ACL before log delivery.
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.org_trail_logs.arn]
  }

  # Permit CloudTrail to write log objects with bucket-owner-full-control ACL.
  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = ["s3:PutObject"]
    resources = [
      "${aws_s3_bucket.org_trail_logs.arn}/AWSLogs/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

# Attach the CloudTrail delivery policy to the log bucket.
resource "aws_s3_bucket_policy" "org_trail_logs" {
  provider = aws.log_archive
  bucket   = aws_s3_bucket.org_trail_logs.id
  policy   = data.aws_iam_policy_document.cloudtrail_bucket_policy.json
}

# Create an organization-level CloudTrail in the management account.
resource "aws_cloudtrail" "organization_trail" {
  name                          = "org-security-trail"
  s3_bucket_name                = aws_s3_bucket.org_trail_logs.id
  kms_key_id                    = aws_kms_key.cloudtrail_logs.arn
  include_global_service_events = true
  is_multi_region_trail         = true
  is_organization_trail         = true
  enable_log_file_validation    = true

  depends_on = [aws_s3_bucket_policy.org_trail_logs]
}

# Output trail name for runbook and validation checkpoints.
output "org_trail_name" {
  value = aws_cloudtrail.organization_trail.name
}

# Output trail ARN for integrations and evidence capture.
output "org_trail_arn" {
  value = aws_cloudtrail.organization_trail.arn
}

# Output bucket name to confirm correct log archive destination.
output "log_bucket_name" {
  value = aws_s3_bucket.org_trail_logs.id
}
