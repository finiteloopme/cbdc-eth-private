data "google_project" "gcp_project"{
  project_id = var.project_id
}

# Create the cluster
module "gke" {
  source             = "terraform-google-modules/kubernetes-engine/google"
  version            = "~> 24.0"
  project_id         = data.google_project.gcp_project.project_id
  name               = var.cluster_id
  region             = var.gcp_region
  zones              = [var.gcp_zone]
  initial_node_count = 3
  identity_namespace = "enabled" # Set workload identity "${var.project_id}.svc.id.goog"
  cluster_resource_labels = { "mesh_id" : "proj-${data.google_project.gcp_project.number}" }
  network            = "default"
  subnetwork         = "default"
  ip_range_pods      = ""
  ip_range_services  = ""
}

# Register a fleet membership for the cluster
resource "google_gke_hub_membership" "fleet_membership" {
  provider = google-beta
  project = "${var.project_id}"
  membership_id = "${var.fleet_membership_id}-${var.cluster_id}"
  endpoint {
    gke_cluster {
     resource_link = "//container.googleapis.com/${module.gke.cluster_id}"
    }
  }
  # Enable fleet workload identity
  authority {
   issuer = "https://container.googleapis.com/v1/${module.gke.cluster_id}"
  }
}

# module "asm-on-gke-on-gcp" {
#   source = "../asm"

#   project_id = var.project_id
#   cluster_id = module.gke.name
#   gcp_location = module.gke.location
#   fleet_id   = google_gke_hub_membership.fleet_membership.membership_id
  
# }
