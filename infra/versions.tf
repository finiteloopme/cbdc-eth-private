terraform {
  backend "gcs" {
    # This value should match ${TF_STATE_BUCKET_NAME} in the Makefile
    bucket = "anthos-demo-kunall-config"
    prefix = "terraform/infra/state"
  }
  required_providers {
    google-beta = {
      source = "hashicorp/google-beta"
      version = "4.44.1"
    }
  }
}
provider "google-beta" {
  project = "${var.project_id}"
}