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

variable "pguser" {
  description = "The postgres username to use."
  type        = string
  default     = "pguser"
}

variable "pgpassword" {
  description = "The postgres password to set for var.pguser"
  sensitive   = true
  type        = string
  default     = "password123"
}

variable "db_names" {
  description = "The name(s) of the postgres databases to create."
  type        = list(string)
  default     = []
}

variable "pghost" {
  description = "Value to set as PGHOST environment variable."
  type        = string
  default     = "localhost"
}

resource "coder_env" "pguser" {
  agent_id = var.agent_id
  name     = "PGUSER"
  value    = var.pguser
}

resource "coder_env" "pgpassword" {
  agent_id = var.agent_id
  name     = "PGPASSWORD"
  value    = var.pgpassword
}

resource "coder_env" "pghost" {
  agent_id = var.agent_id
  name     = "PGHOST"
  value    = var.pghost
}

resource "coder_script" "this" {
  agent_id           = var.agent_id
  display_name       = "Prepare Postgres"
  icon               = "https://www.postgresql.org/favicon.ico"
  run_on_start       = true
  start_blocks_login = true

  script = templatefile("${path.module}/run.sh", {
    DB_NAMES   = var.db_names,
    PGUSER     = var.pguser,
    PGPASSWORD = var.pgpassword,
  })
}
