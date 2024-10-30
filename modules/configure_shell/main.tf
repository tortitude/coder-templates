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

variable "coder_parameter_order" {
  type        = number
  description = "The order determines the position of a template parameter in the UI/CLI presentation. The lowest order is shown first and parameters with equal order are sorted by name (ascending order)."
  default     = null
}

locals {
  supported_shells = ["bash", "zsh"]
}

variable "preferred_shell_default" {
  type        = string
  description = "Pre-selected default value for preferred shell parameter"
  default     = null
  validation {
    condition     = contains(concat(local.supported_shells, [null]), var.preferred_shell_default)
    error_message = "Default value be null or a supported shell (one of: ${join(", ", local.supported_shells)})"
  }
}

variable "omz_default_plugins" {
  type        = list(string)
  description = "Pre-selected ohmyzsh plugins to install (if zsh is selected as preferred shell)"
  default     = []
}

variable "bash_default_completions" {
  type        = list(string)
  description = "Pre-selected paths to bash completion scripts to enable (if bash is selected as preferred shell)"
  default     = []
  validation {
    condition     = alltrue([for item in var.bash_default_completions : length(split(" ", item)) == 2])
    error_message = "Each default completion entry must be a space-separated path and name (e.g. `/path/to/aws_completer aws`)"
  }
}

data "coder_parameter" "preferred_shell" {
  name    = "configure_shell_preferred_shell"
  type    = "string"
  mutable = true
  default = var.preferred_shell_default

  order        = try(var.coder_parameter_order + 0, null)
  display_name = "Preferred shell"
  description  = "What command-line shell do you want to use?"

  option {
    name  = "bash"
    value = "bash"
  }

  option {
    name  = "zsh"
    value = "zsh"
  }
}

data "coder_parameter" "omz_plugins" {
  name    = "omz_plugins"
  type    = "list(string)"
  mutable = true
  default = jsonencode(coalesce(var.omz_default_plugins, []))
  # "aws", "docker", "docker-compose", "extract", "fd", "git", "gh", "npm", "nvm", "postgres", "pre-commit", "ripgrep", "terraform", "themes", "yarn"

  order        = try(var.coder_parameter_order + 1, null)
  display_name = "Preferred shell: Oh My Zsh plugins"
  description  = "Select [plugins](https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins) to enable for [Oh My ZSH](https://ohmyz.sh/). Only effective if zsh is the preferred shell."
}

data "coder_parameter" "bash_completions" {
  name    = "bash_completions"
  type    = "list(string)"
  mutable = true
  default = jsonencode(coalesce(var.bash_default_completions, []))

  order        = try(var.coder_parameter_order + 2, null)
  display_name = "Preferred shell: Bash completions"
  description  = "Path(s) to bash completion scripts to enable and the associated complete command, e.g. `/path/to/aws_completer aws`. Only effective if bash is the preferred shell."
}

locals {
  bash_completions = [for completion in data.coder_parameter.bash_completions : split(" ", completion)]
}

resource "coder_script" "setup_bash" {
  count = data.coder_parameter.preferred_shell.value == "bash" ? 1 : 0

  agent_id           = var.agent_id
  display_name       = "Set up bash"
  run_on_start       = true
  start_blocks_login = true

  script = templatefile("${path.module}/setup_bash.sh", chunklist(flatten([
    for should_be_pair__path__name in local.bash_completions :
    length(should_be_pair__path__name) == 2 ? should_be_pair__path__name : []
  ]), 2))
}

resource "coder_script" "setup_zsh" {
  count = data.coder_parameter.preferred_shell.value == "zsh" ? 1 : 0

  agent_id           = var.agent_id
  display_name       = "Set up zsh"
  run_on_start       = true
  start_blocks_login = true

  script = templatefile("${path.module}/setup_zsh.sh", {
    OMZ_PLUGINS = data.coder_parameter.omz_plugins.value
  })
}
