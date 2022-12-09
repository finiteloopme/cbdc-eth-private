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


# Authorise Cloud Logging / Monitoring
# Can only be done after first Anthos cluster is created
module "project-iam-bindings-logs-and-mon" {
  source   = "terraform-google-modules/iam/google//modules/projects_iam"
  projects = [var.project_id]
  mode     = "additive"
  bindings = {
    "roles/gkemulticloud.telemetryWriter" = [
      "serviceAccount:${var.project_id}.svc.id.goog[gke-system/gke-telemetry-agent]",
    ]
  }

  depends_on = [
    module.gke-on-gcp
  ]
}

# GKE on AWS
module "gke-on-aws"{
  source = "./gke-on-aws"

  gcp_project_id = "anthos-demo-kunall"
  #add up to 10 GCP Ids for cluster admin via connect gateway
  admin_users = ["admin@kunall.altostrat.com"]
  name_prefix = "aws-gke"
  /* supported instance types
  https://cloud.google.com/anthos/clusters/docs/multi-cloud/aws/reference/supported-instance-types
  */
  node_pool_instance_type     = "t3.medium"
  control_plane_instance_type = "t3.medium"
  # "1.22.8-gke.2100"
  cluster_version             = "1.24.5-gke.200"
  /*
  Use 'gcloud container aws get-server-config --location [gcp-region]' to see Availability --
  https://cloud.google.com/anthos/clusters/docs/multi-cloud/aws/reference/supported-regions
  */
  gcp_location              = "us-east4"
  aws_region                = "us-east-1"
  subnet_availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

}
