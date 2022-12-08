# Overwrite org policies
# Need External VM
module "allowExternalIP" {
  source           = "terraform-google-modules/org-policy/google"

  policy_for      = "project"    # either of organization, folder or project
  project_id   = "${var.project_id}"       # either of org id, folder id or project id
  constraint       = "constraints/compute.vmExternalIpAccess"    # constraint identifier without constriants/ prefix. Example "compute.requireOsLogin"
  policy_type      = "list"            # either of list or boolean
  enforce = false
}

module "allowCanIpForward" {
  source           = "terraform-google-modules/org-policy/google"

  policy_for      = "project"    # either of organization, folder or project
  project_id   = "${var.project_id}"       # either of org id, folder id or project id
  constraint       = "constraints/compute.vmCanIpForward"    # constraint identifier without constriants/ prefix. Example "compute.requireOsLogin"
  policy_type      = "list"            # either of list or boolean
  enforce          = false
  # exclude_projects = [var.project_id]
}

module "dontRequireShieldedVM" {
  source           = "terraform-google-modules/org-policy/google"

  policy_for      = "project"    # either of organization, folder or project
  project_id   = "${var.project_id}"       # either of org id, folder id or project id
  constraint       = "constraints/compute.requireShieldedVm"    # constraint identifier without constriants/ prefix. Example "compute.requireOsLogin"
  policy_type      = "boolean"            # either of list or boolean
  enforce = false
}

# Configure required APIs
module "enabled_google_apis" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 14.0"

  project_id                  = var.project_id
  disable_services_on_destroy = false

  activate_apis = [
    "iam.googleapis.com", 
    "anthos.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "gkehub.googleapis.com",
    "anthosconfigmanagement.googleapis.com",
    "meshconfig.googleapis.com",
    "mesh.googleapis.com",
    "multiclusteringress.googleapis.com",
    "multiclusterservicediscovery.googleapis.com"
  ]
}

# Create a default network
module "vpc" {
    source  = "terraform-google-modules/network/google//modules/vpc"
    version = "~> 6.0.0"

    project_id   = var.project_id
    network_name = "default"
    auto_create_subnetworks = true

    shared_vpc_host = false
}
