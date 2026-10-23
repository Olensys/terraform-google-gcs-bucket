mock_provider "google" {}

variables {
  context = {
    organization = "olensys"
    environment  = "test"
    application  = "example"
    owner        = "platform"
    cost_center  = "eng"
  }
  name       = "example-bucket"
  project_id = "example-project"
  location   = "US"
}

run "test_uniform_access_and_public_prevention" {
  command = plan

  # SMOKE: asserts the hardening values this wrapper passes to the upstream module; the applied bucket attributes are proven by complete.tftest.hcl and trivy.
  assert {
    condition     = output.hardening.uniform_bucket_level_access == true && output.hardening.public_access_prevention == "enforced"
    error_message = "uniform access must be on and public access prevention enforced."
  }
}

run "test_versioning_off_default" {
  command = plan

  # SMOKE: asserts the versioning value passed to the upstream module; the applied bucket attribute is proven by complete.tftest.hcl.
  assert {
    condition     = output.hardening.versioning == false
    error_message = "versioning must default to off."
  }
}

run "test_cors_mapped" {
  command = plan

  variables {
    cors_rules = [{
      allowed_origins = ["https://example.com"]
      allowed_methods = ["GET", "HEAD"]
      allowed_headers = ["Content-Type"]
      max_age_seconds = 600
    }]
  }

  assert {
    condition     = output.cors_config[0].origin == tolist(["https://example.com"])
    error_message = "allowed_origins must map to cors origin."
  }
  assert {
    condition     = output.cors_config[0].method == tolist(["GET", "HEAD"]) && output.cors_config[0].response_header == tolist(["Content-Type"]) && output.cors_config[0].max_age_seconds == 600
    error_message = "methods, headers and max age must map to the GCS cors fields."
  }
}

run "test_lifecycle_mapped" {
  command = plan

  variables {
    lifecycle_rules = [{
      id                              = "expire-logs"
      prefix                          = "logs/"
      expiration_days                 = 30
      noncurrent_expiration_days      = 7
      abort_incomplete_multipart_days = 3
    }]
  }

  assert {
    condition     = length(output.lifecycle_rules_config) == 3
    error_message = "expiration, noncurrent expiration and abort must map to three GCS rules."
  }
  assert {
    condition     = output.lifecycle_rules_config[0].action.type == "Delete" && output.lifecycle_rules_config[0].condition.age == 30 && output.lifecycle_rules_config[0].condition.matches_prefix == "logs/"
    error_message = "expiration_days must map to a Delete rule on age with the prefix."
  }
  assert {
    condition     = output.lifecycle_rules_config[1].action.type == "Delete" && output.lifecycle_rules_config[1].condition.days_since_noncurrent_time == 7 && output.lifecycle_rules_config[1].condition.with_state == "ARCHIVED"
    error_message = "noncurrent_expiration_days must map to a Delete rule on archived objects."
  }
  assert {
    condition     = output.lifecycle_rules_config[2].action.type == "AbortIncompleteMultipartUpload" && output.lifecycle_rules_config[2].condition.age == 3
    error_message = "abort_incomplete_multipart_days must map to an AbortIncompleteMultipartUpload rule."
  }
}

run "test_create_false_plans_nothing" {
  command = plan

  variables {
    create = false
  }

  assert {
    condition     = output.id == null && output.name == null && output.self_link == null && output.url == null && output.labels == null && output.lifecycle_rules_config == null && output.cors_config == null && output.hardening == null
    error_message = "every output must be null when create is false."
  }
}

run "test_name_length_validation" {
  command = plan

  variables {
    name = "a234567890123456789012345678901234567890123456789012345678901234"
  }

  expect_failures = [var.name]
}

run "test_name_length_validation_63_accepted" {
  command = plan

  variables {
    name = "a23456789012345678901234567890123456789012345678901234567890123"
  }

  assert {
    condition     = output.name == "a23456789012345678901234567890123456789012345678901234567890123"
    error_message = "a 63 character name must be accepted."
  }
}

run "test_tags_contract" {
  command = plan

  variables {
    labels = { owner = "x" }
    context = {
      organization = "olensys"
      environment  = "test"
      application  = "example"
      owner        = "platform"
      cost_center  = "eng"
      extra_tags   = { owner = "y", team = "z" }
    }
  }

  assert {
    condition     = output.labels.owner == "x"
    error_message = "var.labels must win over context.extra_tags."
  }
  assert {
    condition     = output.labels.team == "z"
    error_message = "context.extra_tags must be merged."
  }
}
