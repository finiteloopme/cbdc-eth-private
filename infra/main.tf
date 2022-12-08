# Configure project
module "configure-project"{
    source = "./project-setup"
    project_id = var.project_id
}

# Configure GKE clusters with hub/fleet membership
module "gke-on-gcp"{
    source = "./gke-on-gcp"
    
    for_each = toset(var.gcp_gke_clusters)
    cluster_id = each.key
    project_id = var.project_id
    gcp_zone = var.gcp_zone
    fleet_membership_id = var.project_id

    depends_on = [
      module.configure-project
    ]
}

# Enable Config Management for the hub
resource "google_gke_hub_feature" "configmanagement_acm_feature" {
  provider = google-beta
  name     = "configmanagement"
  location = "global"
}

# Enable Multi Cluster Service Discovery for the hub
resource "google_gke_hub_feature" "multiclusterservicediscovery_acm_feature" {
  name = "multiclusterservicediscovery"
  location = "global"
  labels = {
    foo = "bar"
  }
  provider = google-beta
}

# Enable Service mesh for fleet
resource "google_gke_hub_feature" "servicemesh_hub_feature" {
  provider = google-beta
  name = "servicemesh"
  location = "global"
}

# Enable Multi Cluster Ingress for the hub
resource "google_gke_hub_feature" "multiclusteringress_acm_feature" {
  provider = google-beta
  name     = "multiclusteringress"
  location = "global"
  spec {
    # Config Cluster
    multiclusteringress {
      config_membership = "projects/${var.project_id}/locations/global/memberships/${var.project_id}-gcp-gke-1" # Hard coded first cluster from var.gcp_gke_clusters
    }
  }
}

