terraform {
  required_version = ">= 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 0.12"
    }
  }
}

variable "agent_id" {
  type        = string
  description = "The ID of a Coder agent."
}

variable "always_install" {
  description = "Ignore results of var.skip_if_command_exists check and always install tflint, even if it is already installed."
  type        = bool
  default     = false
}

variable "skip_if_command_exists" {
  description = "Avoid reinstallation if this command already exists (when `command -v var.skip_if_command_exists` has nonzero exit code)"
  type        = string
  default     = "tflint"
}

variable "clear_gh_token" {
  description = "Unsets the $GH_TOKEN env var when downloading tflint from GitHub."
  type        = string
  default     = false
}

resource "coder_script" "this" {
  agent_id           = var.agent_id
  display_name       = "tflint:"
  run_on_start       = true
  start_blocks_login = true

  script = templatefile("${path.module}/run.sh", {
    TFLINT_INSTALLER_FORCE_INSTALL          = var.always_install ? "1" : "0"
    TFLINT_INSTALLER_SKIP_IF_COMMAND_EXISTS = var.skip_if_command_exists,
    TFLINT_INSTALLER_CLEAR_GH_TOKEN         = var.clear_gh_token ? "1" : "0"
  })
}
