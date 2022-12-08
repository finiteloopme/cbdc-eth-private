variable "project_id" {
  description = "Project ID to be used to setup the infrastructure"
  
}

variable "fleet_membership_id" {
  description = "Fleet membership ID for GKE clusters.  E.g. set this to match PROJECT_ID"
}

variable "gcp_region" {
  description = "Default region for the services"
  default="us-central1"
}

variable "gcp_zone" {
  description = "Default zone for the services"
  default="us-central1-a"
}

variable "gcp_gke_clusters" {
  description = "List of all the GKE cluster IDs in GCP"
  type = list(string)
  default = ["gcp-gke-1", "gcp-gke-2"]
}