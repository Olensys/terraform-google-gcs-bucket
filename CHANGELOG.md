# Changelog

## 1.1.0

### Fixes

- normalise `context.extra_tags` keys and values to valid GCP label syntax (lowercase, `[^a-z0-9_-]` replaced by `-`, 63 characters); `labels` are applied verbatim and win
- `versioning_enabled` is now `bool` with `default = null`, resolved as `coalesce(var.versioning_enabled, var.context.environment == "prod")`
### Tests

- prod default on, dev default off and explicit override cases for versioning
- `test_tags_contract` now covers mixed-case extra tags and verifies normalisation

### Docs

- Usage shows the naming module; Opinions describe label normalisation

### Behaviour changes

- `labels` output and applied labels now contain normalised keys and values for `context.extra_tags` (for example `Team = "Core Team"` becomes `team = "core-team"`). Callers that relied on mixed-case or space-containing extra tags must expect the normalised form; values passed in `labels` are unchanged.
- `versioning_enabled` now defaults to `true` when `context.environment` is `prod` (it stays `false` elsewhere). Prod callers that want versioning off must set `versioning_enabled = false` explicitly; other callers need no change.

## 1.0.0

- Cloud Storage bucket with uniform access, public access prevention, optional versioning, lifecycle, CORS, CMEK and IAM members, wrapping terraform-google-modules/cloud-storage/google//modules/simple_bucket 12.4.1. Lifecycle and CORS inputs mirror terraform-aws-s3-bucket.
