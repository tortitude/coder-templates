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
  default     = null
}

variable "coder_parameter_order" {
  type        = number
  description = "The order determines the position of a template parameter in the UI/CLI presentation. The lowest order is shown first and parameters with equal order are sorted by name (ascending order)."
  default     = null
}

data "coder_parameter" "git_config_use_gh" {
  name         = "git_config_use_gh"
  order        = var.coder_parameter_order != null ? var.coder_parameter_order + 0 : null
  display_name = "Git config from GitHub"
  description  = "Use the workspace owner's GitHub to configure git user.name and user.email (anonymized `@users.noreply.github.com` address)."
  type         = "bool"
  default      = "true"
}

data "coder_parameter" "git_config_user_name" {
  name         = "git_config_user_name"
  order        = var.coder_parameter_order != null ? var.coder_parameter_order + 1 : null
  display_name = "Git config user name"
  description  = "Ignored when `${data.coder_parameter.git_config_use_gh.display_name}` is selected."
  type         = "string"
  default      = ""
}

data "coder_parameter" "git_config_user_email" {
  name         = "git_config_user_email"
  order        = var.coder_parameter_order != null ? var.coder_parameter_order + 2 : null
  display_name = "Git config user email"
  description  = "Ignored when `${data.coder_parameter.git_config_use_gh.display_name}` is selected."
  type         = "string"
  default      = ""
}

data "coder_parameter" "set_gh_token" {
  count        = var.external_auth_id != null ? 1 : 0
  name         = "set_gh_token"
  display_name = "Set workspace `GH_TOKEN` environment variable to the owner's GitHub access token."
  type         = "bool"
  default      = true
}

data "coder_external_auth" "this" {
  count = var.external_auth_id != null ? 1 : 0
  id    = var.external_auth_id
}

resource "coder_env" "gh_token" {
  count    = var.set_gh_token && var.external_auth_id != null ? 1 : 0
  agent_id = var.agent_id
  name     = "GH_TOKEN"
  value    = one(data.coder_external_auth.this[*].access_token)
}

resource "coder_script" "this" {
  agent_id           = var.agent_id
  display_name       = "GH Git Config"
  run_on_start       = true
  start_blocks_login = true

  script = templatefile("${path.module}/run.sh", {
    GH_TOKEN       = try(one(data.coder_external_auth.this[*].access_token), null)
    GIT_USER_NAME  = data.coder_parameter.git_config_user_name.value
    GIT_USER_EMAIL = data.coder_parameter.git_config_user_email.value
  })
}
