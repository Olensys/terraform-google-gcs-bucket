# terraform-google-gcs-bucket

Cloud Storage bucket with uniform access, public access prevention, optional versioning, lifecycle, CORS and IAM

## Opinions

- `uniform_bucket_level_access = true`: object ACLs are disabled, access is IAM only.
- `public_access_prevention = "enforced"`: the bucket can never be made public.
- `storage_class = "STANDARD"`.
- Versioning is off unless `versioning_enabled = true`.
- Encryption is Google-managed unless `kms_key_name` is set.

Inputs `lifecycle_rules` and `cors_rules` mirror the shapes of `terraform-aws-s3-bucket`, so consumers can switch clouds without reshaping them. Each lifecycle rule maps to up to three GCS rules (current expiry, noncurrent expiry, multipart abort).

## Usage

```hcl
module "this" {
  source = "git::https://github.com/Olensys/terraform-google-gcs-bucket.git?ref=v1.0.0"

  name       = "example-bucket"
  project_id = "example-project"
  location   = "US"
  context = {
    organization = "olensys"
    environment  = "dev"
    application  = "example"
    owner        = "platform"
    cost_center  = "eng"
  }
}
```

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
| <a name="input_versioning_enabled"></a> [versioning\_enabled](#input\_versioning\_enabled) | Whether object versioning is enabled. | `bool` | `false` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cors_config"></a> [cors\_config](#output\_cors\_config) | GCS CORS configuration passed to the bucket, mapped from cors\_rules. Null when create is false. |
| <a name="output_hardening"></a> [hardening](#output\_hardening) | Hardening values passed to the bucket: uniform\_bucket\_level\_access, public\_access\_prevention and versioning. Null when create is false. |
| <a name="output_id"></a> [id](#output\_id) | Identifier of the bucket. Null when create is false. |
| <a name="output_labels"></a> [labels](#output\_labels) | Labels applied to the bucket, with context.extra\_tags merged in. Null when create is false. |
| <a name="output_lifecycle_rules_config"></a> [lifecycle\_rules\_config](#output\_lifecycle\_rules\_config) | GCS lifecycle rules passed to the bucket, mapped from lifecycle\_rules. Null when create is false. |
| <a name="output_name"></a> [name](#output\_name) | Name of the bucket. Null when create is false. |
| <a name="output_self_link"></a> [self\_link](#output\_self\_link) | Self link of the bucket. Null when create is false. |
| <a name="output_url"></a> [url](#output\_url) | gs:// URL of the bucket. Null when create is false. |
<!-- END_TF_DOCS -->
