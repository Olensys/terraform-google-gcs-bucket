# terraform-google-gcs-bucket

Cloud Storage bucket with uniform access, public access prevention, optional versioning, lifecycle, CORS and IAM

## Opinions

- `uniform_bucket_level_access = true` by default: object ACLs are disabled, access is IAM only. Setting it to `false` is an explicit opt-out from the secure default that re-enables ACLs; it exists so an existing bucket that still uses ACLs can be imported and tightened later.
- `public_access_prevention = "enforced"` by default: the bucket can never be made public. `"inherited"` is an explicit opt-out that lets the organisation policy decide, so objects may be made public; it exists for the same adoption case.
- Soft delete follows the provider default (7 days) unless `soft_delete_retention_seconds` is set (`0` disables it, otherwise 7 to 90 days in seconds).
- `storage_class = "STANDARD"`.
- Versioning defaults to on in prod and off elsewhere; set `versioning_enabled` to `true` or `false` to override.
- Encryption is Google-managed unless `kms_key_name` is set.
- `context.extra_tags` keys and values are normalised to valid GCP label syntax (lowercase, `[^a-z0-9_-]` → `-`, 63 chars); `labels` are applied verbatim and win.

Inputs `lifecycle_rules` and `cors_rules` mirror the shapes of `terraform-aws-s3-bucket`, so consumers can switch clouds without reshaping them. Each lifecycle rule maps to up to three GCS rules (current expiry, noncurrent expiry, multipart abort).

## Usage

```hcl
module "naming" {
  source  = "git::https://github.com/Olensys/terraform-null-naming.git?ref=v1.0.1"
  context = var.context
}

module "this" {
  source = "git::https://github.com/Olensys/terraform-google-gcs-bucket.git?ref=v1.1.0"

  name       = module.naming.name
  project_id = "example-project"
  location   = "US"
  context = var.context
  labels  = module.naming.labels
}
```

## Adopting an existing bucket

Every input has a default equal to the value the module used to hard-code, so existing callers see no plan diff. To import a bucket created elsewhere, match `location`, `versioning_enabled`, `kms_key_name`, `uniform_bucket_level_access`, `public_access_prevention` and `soft_delete_retention_seconds` to its live settings and run:

```hcl
import {
  to = module.this.module.this[0].google_storage_bucket.bucket
  id = "<bucket name>"
}
```

Once the bucket is managed, flip `uniform_bucket_level_access` back to `true` and `public_access_prevention` back to `"enforced"` to return to the secure defaults.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.0, < 8.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_this"></a> [this](#module\_this) | terraform-google-modules/cloud-storage/google//modules/simple_bucket | 12.4.1 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_context"></a> [context](#input\_context) | Deployment context used for naming, tagging and environment-dependent defaults. | <pre>object({<br/>    organization = string<br/>    environment  = string<br/>    application  = string<br/>    component    = optional(string)<br/>    owner        = string<br/>    cost_center  = string<br/>    extra_tags   = optional(map(string), {})<br/>  })</pre> | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Bucket location: a region (for example europe-west1), a multi-region (US, EU, ASIA) or a dual-region name. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Bucket name. 3 to 63 characters: lowercase letters, digits, dots, underscores and hyphens, starting and ending with a letter or digit. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | ID of the project that owns the bucket. | `string` | n/a | yes |
| <a name="input_cors_rules"></a> [cors\_rules](#input\_cors\_rules) | CORS rules for the bucket. | <pre>list(object({<br/>    allowed_origins = list(string)<br/>    allowed_methods = list(string)<br/>    allowed_headers = optional(list(string), [])<br/>    max_age_seconds = optional(number, 3600)<br/>  }))</pre> | `[]` | no |
| <a name="input_create"></a> [create](#input\_create) | Whether to create any resources. Set false to create nothing. | `bool` | `true` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Whether destroying the bucket also deletes all objects in it. | `bool` | `false` | no |
| <a name="input_iam_members"></a> [iam\_members](#input\_iam\_members) | Bucket IAM bindings as a map of role to the list of members granted that role. | `map(list(string))` | `{}` | no |
| <a name="input_kms_key_name"></a> [kms\_key\_name](#input\_kms\_key\_name) | Cloud KMS key (projects/<p>/locations/<l>/keyRings/<r>/cryptoKeys/<k>) used as the default customer-managed encryption key. Null uses Google-managed encryption. | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels merged onto the bucket, applied last. Callers must already normalise them for GCP. | `map(string)` | `{}` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules) | Lifecycle rules. expiration\_days deletes current objects; noncurrent\_expiration\_days deletes noncurrent versions; abort\_incomplete\_multipart\_days aborts stale multipart uploads; prefix limits a rule to an object name prefix. | <pre>list(object({<br/>    id                              = string<br/>    prefix                          = optional(string)<br/>    expiration_days                 = optional(number)<br/>    noncurrent_expiration_days      = optional(number)<br/>    abort_incomplete_multipart_days = optional(number, 7)<br/>  }))</pre> | `[]` | no |
| <a name="input_public_access_prevention"></a> [public\_access\_prevention](#input\_public\_access\_prevention) | Public access prevention: enforced (default, the bucket can never be made public) or inherited (the organisation policy decides, so objects may be made public). inherited is an explicit opt-out meant for adopting an existing bucket. | `string` | `"enforced"` | no |
| <a name="input_soft_delete_retention_seconds"></a> [soft\_delete\_retention\_seconds](#input\_soft\_delete\_retention\_seconds) | Soft delete retention in seconds. Null (default) leaves the provider default (currently 7 days); 0 disables soft delete; otherwise 604800 (7 days) to 7776000 (90 days). | `number` | `null` | no |
| <a name="input_uniform_bucket_level_access"></a> [uniform\_bucket\_level\_access](#input\_uniform\_bucket\_level\_access) | Whether uniform bucket-level access is on (object ACLs disabled, IAM only). Default true is the library's secure default; false is an explicit opt-out that re-enables ACLs, meant for adopting an existing bucket that still uses them. | `bool` | `true` | no |
| <a name="input_versioning_enabled"></a> [versioning\_enabled](#input\_versioning\_enabled) | Whether object versioning is enabled. Null defaults to true in prod and false elsewhere. | `bool` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cors_config"></a> [cors\_config](#output\_cors\_config) | GCS CORS configuration passed to the bucket, mapped from cors\_rules. Null when create is false. |
| <a name="output_hardening"></a> [hardening](#output\_hardening) | Hardening values passed to the bucket: uniform\_bucket\_level\_access, public\_access\_prevention, versioning and soft\_delete\_retention\_seconds. Null when create is false. |
| <a name="output_id"></a> [id](#output\_id) | Identifier of the bucket. Null when create is false. |
| <a name="output_labels"></a> [labels](#output\_labels) | Labels applied to the bucket, with context.extra\_tags merged in. Null when create is false. |
| <a name="output_lifecycle_rules_config"></a> [lifecycle\_rules\_config](#output\_lifecycle\_rules\_config) | GCS lifecycle rules passed to the bucket, mapped from lifecycle\_rules. Null when create is false. |
| <a name="output_name"></a> [name](#output\_name) | Name of the bucket. Null when create is false. |
| <a name="output_self_link"></a> [self\_link](#output\_self\_link) | Self link of the bucket. Null when create is false. |
| <a name="output_url"></a> [url](#output\_url) | gs:// URL of the bucket. Null when create is false. |
<!-- END_TF_DOCS -->
