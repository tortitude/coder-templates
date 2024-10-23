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

variable "plugins" {
  description = "List of ohmyzsh plugins to enable."
  type = list(string)
  default = []
}

variable "set_preferred_shell" {
    description = "Whether to set zsh as the preferred shell."
    type = bool
    default = true
}

resource "coder_script" "this" {
  agent_id           = var.agent_id
  display_name       = "Set up ohmyzsh"
  run_on_start       = true
  start_blocks_login = true

  script = templatefile("${path.module}/run.sh", {
    OMZ_PLUGINS = var.plugins
    SET_PREFERRED_SHELL = var.set_preferred_shell
  })
}
