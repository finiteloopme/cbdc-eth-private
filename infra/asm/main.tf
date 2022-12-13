# data "google_container_cluster" "gke_cluster" {
#   name     = var.cluster_id
#   location = var.gcp_location
# }

# data "google_client_config" "default" {}

# provider "kubernetes" {
#   host                   = "https://${data.google_container_cluster.gke_cluster.endpoint}"
#   # token                  = data.google_client_config.default.access_token
#   cluster_ca_certificate = base64decode(data.google_container_cluster.gke_cluster.master_auth.0.cluster_ca_certificate)
#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     args        = ["container", "fleet", "memberships", "get-credentials", var.cluster_name]
#     command     = "gcloud"
#   }
# }

# module "asm" {
#   source            = "terraform-google-modules/kubernetes-engine/google//modules/asm"
#   project_id        = var.project_id
#   cluster_name      = data.google_container_cluster.gke_cluster.name
#   cluster_location  = module.gke.location
#   enable_cni        = true
#   fleet_id          = var.fleet_id
# }

# Manage ASM deployment
resource "asm" "asm-gke"{

  provisioner "local-exec" {
    when = create
    command = "./scripts/manage-asm.sh ${var.asm_version} ${var.fleet_id} install ${var.fleet_id}"
  }

  provisioner "local-exec" {
    when = destroy
    command = "./scripts/manage-asm.sh ${var.asm_version} ${var.fleet_id} uninstall ${var.fleet_id}"
  }

}