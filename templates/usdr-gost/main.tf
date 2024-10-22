data "coder_workspace" "this" {}
data "coder_external_auth" "github" {
  id = "primary-github"
}

resource "coder_agent" "coder" {
  os    = "linux"
  arch  = "amd64"
  dir   = "/home/coder/usdr-gost"
  order = 1

  env = {
    GITHUB_TOKEN = data.coder_external_auth.github.access_token
    PGHOST       = "localhost"
    PGUSER       = "postgres"
  }

  metadata {
    display_name = "CPU Usage"
    key          = "0_cpu_usage"
    script       = "coder stat cpu"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "RAM Usage"
    key          = "1_ram_usage"
    script       = "coder stat mem"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Home Disk Usage"
    key          = "2_home_disk"
    script       = "coder stat disk --path $${HOME}"
    interval     = 60
    timeout      = 1
  }
}

module "git-config" {
  source   = "registry.coder.com/modules/git-config/coder"
  version  = "1.0.3"
  agent_id = coder_agent.coder.id

  allow_email_change    = true
  allow_username_change = true
}

module "clone_gost" {
  source   = "registry.coder.com/modules/git-clone/coder"
  version  = "1.0.2"
  agent_id = coder_agent.coder.id

  url = "https://github.com/usdigitalresponse/usdr-gost"
}

module "nodejs" {
  source   = "registry.coder.com/modules/nodejs/coder"
  version  = "1.0.10"
  agent_id = coder_agent.coder.id

  node_versions = [
    "18",
    "20",
  ]
  default_node_version = "20"
}

module "prepare_postgres" {
  # source     = "../../modules/prepare_postgres"
  source     = "git::https://github.com/tortitude/coder-templates.git//modules/prepare_postgres?ref=dev/setup-gost"
  agent_id   = coder_agent.coder.id
  pguser     = "postgres"
  pgpassword = "password123"
  db_names   = ["usdr_grants", "usdr_grants_test"]
}

resource "coder_script" "prepare_gost_dotenvs" {
  agent_id           = coder_agent.coder.id
  display_name       = "prepare_gost_dotenvs:"
  run_on_start       = true
  start_blocks_login = true

  script = templatefile("${path.module}/prepare_gost_dotenvs.sh", {
    REPO_DIR = module.clone_gost.repo_dir,
    SERVER_REWRITES = {
      POSTGRES_URL          = "postgres://postgres:password123@localhost:5432/usdr_grants"
      POSTGRES_TEST_URL     = "postgres://postgres:password123@localhost:5432/usdr_grants_test"
      AWS_ACCESS_KEY_ID     = "test"
      AWS_SECRET_ACCESS_KEY = "test"
      NODEMAILER_HOST       = ""
      WEBSITE_DOMAIN        = "<website url>"
    }
  })
}

