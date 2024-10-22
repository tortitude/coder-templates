locals {
  kubernetes_namespace = "dev"
  kubernetes_resource_prefix = join("-", [
    "coder",
    "ws",
    lower(data.coder_workspace.this.owner),
    lower(data.coder_workspace.this.name),
  ])
}

locals {
  main_docker_image = "ghcr.io/tortitude/coder-templates:gost-feature-development-v3"
}

resource "kubernetes_pod" "main" {
  count      = data.coder_workspace.this.start_count
  depends_on = [kubernetes_persistent_volume_claim.home-directory]

  metadata {
    name      = "${local.kubernetes_resource_prefix}-main"
    namespace = local.kubernetes_namespace
  }

  spec {
    security_context {
      run_as_user = "1000"
      fs_group    = "1000"
    }

    container {
      name              = "workspace-container"
      image             = local.main_docker_image
      image_pull_policy = "Always"
      command           = ["sh", "-c", coder_agent.coder.init_script]

      security_context {
        run_as_user = "1000"
      }

      env {
        name  = "CODER_AGENT_TOKEN"
        value = coder_agent.coder.token
      }
      # env {
      #   name  = "PGUSER"
      #   value = local.postgres_user
      # }
      env {
        name  = "PGHOST"
        value = "localhost"
      }
      env {
        name  = "EDGE_PORT"
        value = "4566"
      }
      env {
        name  = "LOCALSTACK_HOSTNAME"
        value = "localhost"
      }
      env {
        name  = "AWS_REGION"
        value = "us-west-2"
      }
      env {
        name  = "AWS_DEFAULT_REGION"
        value = "us-west-2"
      }
      env {
        name  = "DOCKER_HOST"
        value = "tcp://localhost:2375"
      }

      resources {
        requests = {
          cpu    = "250m"
          memory = "500m"
        }
        limits = {
          cpu    = 3
          memory = "10G"
        }
      }

      volume_mount {
        mount_path = "/home/coder"
        name       = "home-directory"
      }
    }

    container {
      name  = "docker-dind"
      image = "docker:dind"
      security_context {
        privileged  = true
        run_as_user = "0"
      }
      command = ["dockerd", "--host", "tcp://127.0.0.1:2375"]
      volume_mount {
        name       = "dind-storage"
        mount_path = "/var/lib/docker"
      }
    }

    container {
      name              = "postgres-container"
      image             = "postgres:13"
      image_pull_policy = "Always"
      security_context {
        run_as_user = "999"
      }
      resources {
        requests = {
          cpu    = "250m"
          memory = "500m"
        }
        limits = {
          cpu    = 3
          memory = "10G"
        }
      }
      env {
        name  = "PGDATA"
        value = "/var/lib/postgresql/data/k8s"
      }
      env {
        name  = "POSTGRES_PASSWORD"
        value = "password123"
      }
      volume_mount {
        mount_path = "/var/lib/postgresql/data"
        name       = "postgres-data-directory"
      }
    }

    volume {
      name = "home-directory"
      persistent_volume_claim {
        claim_name = kubernetes_persistent_volume_claim.home-directory.metadata[0].name
      }
    }
    volume {
      name = "dind-storage"
      persistent_volume_claim {
        claim_name = kubernetes_persistent_volume_claim.dind.metadata[0].name
        read_only  = false
      }
    }
    volume {
      name = "postgres-data-directory"
      persistent_volume_claim {
        claim_name = kubernetes_persistent_volume_claim.postgres-data-directory.metadata[0].name
      }
    }
  }
}

resource "coder_metadata" "workspace_info" {
  count       = data.coder_workspace.this.start_count
  resource_id = kubernetes_pod.main[0].id

  item {
    key   = "website url"
    value = local.port_forward_urls["8080"]
  }

  item {
    key   = "api url"
    value = local.port_forward_domains["3000"]
  }

  item {
    key   = "branch url"
    value = "https://github.com/usdigitalresponse/usdr-gost/tree/${data.coder_parameter.git_checkout_branch_name.value}"
  }

  item {
    key   = "main image"
    value = local.main_docker_image
  }

  item {
    key   = "agent id"
    value = coder_agent.coder.id
  }
}
