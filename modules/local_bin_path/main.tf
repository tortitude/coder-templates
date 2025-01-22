terraform {
  required_version = "~> 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = "~> 2.0"
    }
  }
}

variable "agent_id" {
  description = "The ID of a Coder agent."
  type        = string
}

variable "rcfile" {
  description = "Path to rcfile to modify. Must be relative to $HOME!"
  type        = string

  validation {
    condition     = !startswith(var.rcfile, "/")
    error_message = "The rcfile path must be relative to $HOME (e.g. `.bashrc` or `.zshrc`)."
  }
}

variable "local_bin_dir" {
  description = "Directory that holds local binaries and will be added to $PATH. Must be relative to $HOME!"
  type        = string
  default     = ".local/bin"

  validation {
    condition     = !startswith(var.local_bin_dir, "/")
    error_message = "The direcctory path must be relative to $HOME (e.g. `.local/bin`)."
  }
}

variable "symlinks" {
  description = "Mappings of binaries in $PATH to symlink targets that will be created under var.local_bin_dir."
  type = list(object({
    source = string
    target = string
  }))
  default = []
}

resource "coder_script" "this" {
  agent_id           = var.agent_id
  display_name       = "Prepare .local/bin dir"
  run_on_start       = true
  start_blocks_login = true

  script = templatefile("${path.module}/run.sh", {
    RCFILE          = var.rcfile,
    LOCAL_BIN_DIR   = var.local_bin_dir,
    ENSURE_SYMLINKS = coalesce(var.symlinks, [])
  })
}
