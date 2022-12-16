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
  # node_pool_instance_type     = "t3.medium"
  node_pool_instance_type     = "t3.2xlarge"
  # control_plane_instance_type = "t3.medium"
  control_plane_instance_type = "t3.2xlarge"
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

# Cloud SQL for block-explorer

# ------------------------------------------------------------------------------
# CREATE A RANDOM SUFFIX AND PREPARE RESOURCE NAMES
# ------------------------------------------------------------------------------

resource "random_id" "name" {
  byte_length = 2
}

locals {
  # If name_override is specified, use that - otherwise use the name_prefix with a random string
  # db_instance_name        = var.name_override == null ? format("%s-%s", var.name_prefix, random_id.name.hex) : var.name_override
  db_instance_name        = "blockscout"
  # private_network_name = "sql-private-network-${random_id.name.hex}"
  private_ip_name      = "sql-private-ip-${random_id.name.hex}"
}

# ------------------------------------------------------------------------------
# USE DEFAULT COMPUTE NETWORK
# ------------------------------------------------------------------------------

# Simple network, auto-creates subnetworks
# resource "google_compute_network" "private_network" {
#   provider = google-beta
#   name     = local.private_network_name
# }
data "google_compute_network" "default_network" {
  name = "default"
  project = var.project_id
}
# Reserve global internal address range for the peering
resource "google_compute_global_address" "private_ip_address" {
  provider      = google-beta
  name          = local.private_ip_name
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = data.google_compute_network.default_network.self_link
}

# Establish VPC network peering connection using the reserved address range
resource "google_service_networking_connection" "private_vpc_connection" {
  provider                = google-beta
  network                 = data.google_compute_network.default_network.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

module "postgres-db-blockscout" {
  source  = "GoogleCloudPlatform/sql-db/google//modules/postgresql"

  name                 = local.db_instance_name
  random_instance_name = false
  database_version     = "POSTGRES_14"
  project_id           = var.project_id
  zone                 = "us-central1-b"
  region               = "us-central1"
  tier                 = "db-custom-4-15360" #4CPU 16GB

  deletion_protection = false

  additional_users = [
    {
      name = "admin"
      password = "fr54fwfr22SDF4r"
    },
  ]
  ip_configuration = {
    ipv4_enabled        = true
    private_network     = data.google_compute_network.default_network.self_link
    require_ssl         = false
    allocated_ip_range  = null
    authorized_networks = []
  }

  module_depends_on = [
    # module.private-service-access.peering_completed,
    resource.google_service_networking_connection.private_vpc_connection
  ]
}

resource "google_compute_firewall" "http-https-fw"{
  name    = "allow-http-s"
  network = "default"
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
    # TODO: restrict to using specific IP
  source_ranges = ["0.0.0.0/0"]
}
