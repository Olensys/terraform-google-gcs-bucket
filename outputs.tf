output "id" {
  description = "Identifier of the bucket. Null when create is false."
  value       = var.create ? module.this[0].bucket.id : null
}

output "name" {
  description = "Name of the bucket. Null when create is false."
  value       = var.create ? module.this[0].name : null
}

output "self_link" {
  description = "Self link of the bucket. Null when create is false."
  value       = var.create ? module.this[0].bucket.self_link : null
}

output "url" {
  description = "gs:// URL of the bucket. Null when create is false."
  value       = var.create ? module.this[0].url : null
}

output "labels" {
  description = "Labels applied to the bucket, with context.extra_tags merged in. Null when create is false."
  value       = var.create ? local.labels : null
}

output "lifecycle_rules_config" {
  description = "GCS lifecycle rules passed to the bucket, mapped from lifecycle_rules. Null when create is false."
  value       = var.create ? local.lifecycle_rules : null
}

output "cors_config" {
  description = "GCS CORS configuration passed to the bucket, mapped from cors_rules. Null when create is false."
  value       = var.create ? local.cors : null
}

output "hardening" {
  description = "Hardening values passed to the bucket: uniform_bucket_level_access, public_access_prevention and versioning. Null when create is false."
  value       = var.create ? local.hardening : null
}
