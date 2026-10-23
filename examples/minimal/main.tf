terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = { source = "hashicorp/google", version = ">= 6.0, < 8.0" }
  }
}

variable "project_id" {
  description = "Project that owns the bucket."
  type        = string
}

module "this" {
  source = "../../"

  name       = "olensys-example-bucket"
  project_id = var.project_id
  location   = "US"
  context = {
    organization = "olensys"
    environment  = "test"
    application  = "example"
    owner        = "platform"
    cost_center  = "eng"
  }
}

output "url" {
  description = "gs:// URL of the bucket."
  value       = module.this.url
}
