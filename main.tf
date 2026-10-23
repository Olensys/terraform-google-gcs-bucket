locals {
  extra_labels = { for k, v in var.context.extra_tags :
  substr(replace(lower(k), "/[^a-z0-9_-]/", "-"), 0, 63) => substr(replace(lower(v), "/[^a-z0-9_-]/", "-"), 0, 63) }
  labels = merge(local.extra_labels, var.labels)

  # S3-shaped lifecycle rules mapped to GCS rules: current-object expiry, noncurrent expiry, multipart abort.
  lifecycle_rules = flatten([
    for r in var.lifecycle_rules : [
      for rule in [
        r.expiration_days == null ? null : {
          action = { type = "Delete", storage_class = null }
          condition = {
            age                        = r.expiration_days
            with_state                 = null
            matches_prefix             = r.prefix
            days_since_noncurrent_time = null
          }
        },
        r.noncurrent_expiration_days == null ? null : {
          action = { type = "Delete", storage_class = null }
          condition = {
            age                        = null
            with_state                 = "ARCHIVED"
            matches_prefix             = r.prefix
            days_since_noncurrent_time = r.noncurrent_expiration_days
          }
        },
        r.abort_incomplete_multipart_days == null ? null : {
          action = { type = "AbortIncompleteMultipartUpload", storage_class = null }
          condition = {
            age                        = r.abort_incomplete_multipart_days
            with_state                 = null
            matches_prefix             = r.prefix
            days_since_noncurrent_time = null
          }
        },
      ] : rule if rule != null
    ]
  ])

  cors = [
    for c in var.cors_rules : {
      origin          = c.allowed_origins
      method          = c.allowed_methods
      response_header = c.allowed_headers
      max_age_seconds = c.max_age_seconds
    }
  ]

  iam_members = flatten([
    for role, members in var.iam_members : [
      for member in members : { role = role, member = member }
    ]
  ])

  hardening = {
    uniform_bucket_level_access = true
    public_access_prevention    = "enforced"
    versioning                  = coalesce(var.versioning_enabled, var.context.environment == "prod")
  }
}

module "this" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "12.4.1"

  count = var.create ? 1 : 0

  project_id               = var.project_id
  name                     = var.name
  location                 = var.location
  storage_class            = "STANDARD"
  bucket_policy_only       = local.hardening.uniform_bucket_level_access
  public_access_prevention = local.hardening.public_access_prevention
  versioning               = local.hardening.versioning
  force_destroy            = var.force_destroy
  labels                   = local.labels
  lifecycle_rules          = local.lifecycle_rules
  cors                     = local.cors
  iam_members              = local.iam_members
  encryption               = var.kms_key_name == null ? null : { default_kms_key_name = var.kms_key_name }
}
