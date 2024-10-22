terraform {
  required_version = "1.9.2"
  required_providers {
    coder = {
      source  = "coder/coder"
      version = "1.0.4"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.33.0"
    }
  }
}
