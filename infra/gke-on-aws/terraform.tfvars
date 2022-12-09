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
