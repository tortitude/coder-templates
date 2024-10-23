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

variable "target_file" {
  description = "Full path of the dotenv file to write."
  type        = string
  nullable    = false
}

variable "allow_overwrite" {
  description = "If false and target_file exists, the script will do nothing. Useful for only populating on workspace creation, but not restarts."
  type        = bool
  default     = false
}

variable "copy_from" {
  description = "(Optional) Path to source file (e.g. /path/to/.env.example) to seed target_file."
  type        = string
  default     = ""
}

variable "env_vars" {
  description = "Map of environment variables to replace within or add to target_file."
  type        = map(string)
  default     = {}
}

variable "wait_for" {
  description = "Directories and/or files that must exist before any dotenv files are built."
  type = list(object({
    path     = string
    timeout  = optional(number)
    inverval = optional(number, 1)
  }))
  default = []
}

variable "script_display_name" {
  description = "The display name of the script to display logs in the dashboard."
  type        = string
}

variable "start_blocks_login" {
  description = "This option determines whether users can log in immediately or must wait for the workspace to finish running this script upon startup. If not enabled, users may encounter an incomplete workspace when logging in. This option only sets the default, the user can still manually override the behavior."
  type        = bool
  default     = false
}

resource "coder_script" "this" {
  agent_id           = var.agent_id
  display_name       = var.script_display_name
  run_on_start       = true
  start_blocks_login = var.start_blocks_login

  script = templatefile("${path.module}/run.sh", {
    TARGET_DOTENV   = var.target_file
    SOURCE_DOTENV   = var.copy_from
    ALLOW_OVERWRITE = var.allow_overwrite ? "true" : "false"
    ENV_VARS        = var.env_vars
    WAIT_FOR = [
      for waiter in var.wait_for : {
        path     = waiter.path
        timeout  = max(coalesce(try(waiter.timeout, null), 0), 0)
        interval = max(coalesce(try(waiter.interval, null), 0), 1)
      }
    ]
  })
}
