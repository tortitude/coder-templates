locals {
  kubernetes_namespace = "dev"
  kubernetes_resource_prefix = join("-", [
    "coder",
    "ws",
    lower(data.coder_workspace.this.owner),
    lower(data.coder_workspace.this.name),
  ])
}