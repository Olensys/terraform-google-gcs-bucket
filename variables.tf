variable "name" {
  description = "Bucket name. 3 to 63 characters: lowercase letters, digits, dots, underscores and hyphens, starting and ending with a letter or digit."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9._-]{1,61}[a-z0-9]$", var.name))
    error_message = "name must match ^[a-z0-9][a-z0-9._-]{1,61}[a-z0-9]$ (3 to 63 characters)."
  }
}

variable "context" {
  description = "Deployment context used for naming, tagging and environment-dependent defaults."
  type = object({
    organization = string
    environment  = string
    application  = string
    component    = optional(string)
    owner        = string
    cost_center  = string
    extra_tags   = optional(map(string), {})
  })
  validation {
    condition     = contains(["dev", "staging", "prod", "test", "shared"], var.context.environment)
    error_message = "context.environment must be one of dev, staging, prod, test, shared."
  }
}

variable "project_id" {
  description = "ID of the project that owns the bucket."
  type        = string
}

variable "create" {
  description = "Whether to create any resources. Set false to create nothing."
  type        = bool
  default     = true
}

variable "location" {
  description = "Bucket location: a region (for example europe-west1), a multi-region (US, EU, ASIA) or a dual-region name."
  type        = string
  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9-]*$", var.location))
    error_message = "location must be a Cloud Storage location such as US, EU or europe-west1."
  }
}

variable "versioning_enabled" {
  description = "Whether object versioning is enabled. Null defaults to true in prod and false elsewhere."
  type        = bool
  default     = null
}

variable "lifecycle_rules" {
  description = "Lifecycle rules. expiration_days deletes current objects; noncurrent_expiration_days deletes noncurrent versions; abort_incomplete_multipart_days aborts stale multipart uploads; prefix limits a rule to an object name prefix."
  type = list(object({
    id                              = string
    prefix                          = optional(string)
    expiration_days                 = optional(number)
    noncurrent_expiration_days      = optional(number)
    abort_incomplete_multipart_days = optional(number, 7)
  }))
  default = []
}

variable "cors_rules" {
  description = "CORS rules for the bucket."
  type = list(object({
    allowed_origins = list(string)
    allowed_methods = list(string)
    allowed_headers = optional(list(string), [])
    max_age_seconds = optional(number, 3600)
  }))
  default = []
}

variable "kms_key_name" {
  description = "Cloud KMS key (projects/<p>/locations/<l>/keyRings/<r>/cryptoKeys/<k>) used as the default customer-managed encryption key. Null uses Google-managed encryption."
  type        = string
  default     = null
}

variable "iam_members" {
  description = "Bucket IAM bindings as a map of role to the list of members granted that role."
  type        = map(list(string))
  default     = {}
}

variable "force_destroy" {
  description = "Whether destroying the bucket also deletes all objects in it."
  type        = bool
  default     = false
}

variable "uniform_bucket_level_access" {
  description = "Whether uniform bucket-level access is on (object ACLs disabled, IAM only). Default true is the library's secure default; false is an explicit opt-out that re-enables ACLs, meant for adopting an existing bucket that still uses them."
  type        = bool
  default     = true
}

variable "public_access_prevention" {
  description = "Public access prevention: enforced (default, the bucket can never be made public) or inherited (the organisation policy decides, so objects may be made public). inherited is an explicit opt-out meant for adopting an existing bucket."
  type        = string
  default     = "enforced"
  validation {
    condition     = contains(["enforced", "inherited"], var.public_access_prevention)
    error_message = "public_access_prevention must be enforced or inherited."
  }
}

variable "soft_delete_retention_seconds" {
  description = "Soft delete retention in seconds. Null (default) leaves the provider default (currently 7 days); 0 disables soft delete; otherwise 604800 (7 days) to 7776000 (90 days)."
  type        = number
  default     = null
  validation {
    condition     = var.soft_delete_retention_seconds == null ? true : (var.soft_delete_retention_seconds == 0 || (var.soft_delete_retention_seconds >= 604800 && var.soft_delete_retention_seconds <= 7776000))
    error_message = "soft_delete_retention_seconds must be null, 0, or between 604800 and 7776000."
  }
}

variable "labels" {
  description = "Labels merged onto the bucket, applied last. Callers must already normalise them for GCP."
  type        = map(string)
  default     = {}
}
