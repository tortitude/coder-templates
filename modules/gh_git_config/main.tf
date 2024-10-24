terraform {
  required_version = ">= 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 1.0"
    }
  }
}

variable "agent_id" {
  description = "The ID of a Coder agent."
  type        = string
}

variable "external_auth_id" {
  description = "Identifier for the Coder external auth provider. The associated access token will be used to configure git."
  type        = string
}

variable "set_gh_token" {
  description = "If true, sets the GH_TOKEN environment variable to the configured access token"
  type        = bool
  default     = true
}

data "coder_external_auth" "this" {
  id = var.external_auth_id
}

resource "coder_env" "gh_token" {
  count    = var.set_gh_token ? 1 : 0
  agent_id = var.agent_id
  name     = "GH_TOKEN"
  value    = data.coder_external_auth.this.access_token
}

resource "coder_script" "this" {
  agent_id           = var.agent_id
  display_name       = "GH Git Config"
  run_on_start       = true
  start_blocks_login = true

  script = templatefile("${path.module}/run.sh", {
    GH_TOKEN = data.coder_external_auth.this.access_token
  })
}
