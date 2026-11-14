# Pass-through inputs that let a caller import an existing bucket without a
# live change. Every default reproduces the previous hard-coded value.
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

run "test_defaults_match_previous_literals" {
  command = plan

  assert {
    condition     = output.hardening.uniform_bucket_level_access == true && output.hardening.public_access_prevention == "enforced" && output.hardening.soft_delete_retention_seconds == null
    error_message = "uniform access on, public access prevention enforced and provider-default soft delete must be the defaults."
  }

  assert {
    condition     = module.this[0].bucket.uniform_bucket_level_access == true && module.this[0].bucket.public_access_prevention == "enforced"
    error_message = "the defaults must reach the bucket resource."
  }
}

run "test_uniform_bucket_level_access_opt_out" {
  command = plan

  variables {
    uniform_bucket_level_access = false
  }

  assert {
    condition     = module.this[0].bucket.uniform_bucket_level_access == false
    error_message = "uniform_bucket_level_access = false must be passed through."
  }
}

run "test_public_access_prevention_inherited" {
  command = plan

  variables {
    public_access_prevention = "inherited"
  }

  assert {
    condition     = module.this[0].bucket.public_access_prevention == "inherited"
    error_message = "public_access_prevention = inherited must be passed through."
  }
}

run "test_public_access_prevention_validation" {
  command = plan

  variables {
    public_access_prevention = "unspecified"
  }

  expect_failures = [var.public_access_prevention]
}

run "test_soft_delete_retention_override" {
  command = plan

  variables {
    soft_delete_retention_seconds = 2592000
  }

  assert {
    condition     = module.this[0].bucket.soft_delete_policy[0].retention_duration_seconds == 2592000
    error_message = "soft_delete_retention_seconds must reach soft_delete_policy."
  }
}

run "test_soft_delete_disabled_with_zero" {
  command = plan

  variables {
    soft_delete_retention_seconds = 0
  }

  assert {
    condition     = module.this[0].bucket.soft_delete_policy[0].retention_duration_seconds == 0
    error_message = "soft_delete_retention_seconds = 0 must disable soft delete."
  }
}

run "test_soft_delete_retention_too_short" {
  command = plan

  variables {
    soft_delete_retention_seconds = 86400
  }

  expect_failures = [var.soft_delete_retention_seconds]
}

run "test_soft_delete_retention_too_long" {
  command = plan

  variables {
    soft_delete_retention_seconds = 7776001
  }

  expect_failures = [var.soft_delete_retention_seconds]
}
