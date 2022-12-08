# Configure variables in terraform.tfvars appropriately
PROJECT_ID=anthos-demo-kunall
GCP_REGION=us-central1
GCP_ZONE=${GCP_REGION}-a
 # This should matach terraform.backend.gcs.bucket in versions.tf
TF_STATE_BUCKET_NAME=${PROJECT_ID}-config

# If required get user credentials to use for Terraform
.PHONY: auth
auth:
	gcloud auth application-default login

# 1. Initialise project config
.PHONY: init
init:
	gcloud config set project ${PROJECT_ID}
	gcloud config set compute/zone ${GCP_ZONE}
	# Create a bucket if it doesn't exist
	gsutil ls -b gs://${TF_STATE_BUCKET_NAME} || gsutil mb -c standard -l ${GCP_REGION} gs://${TF_STATE_BUCKET_NAME}
	gsutil versioning set on gs://${TF_STATE_BUCKET_NAME}
	terraform init

# 2. Create a TF plan
.PHONY: build
build:
	terraform plan -out=${TF_STATE_BUCKET_NAME}.tfout

# 3. Apply the TF plan
.PHONY: deploy
deploy:
	terraform apply ${TF_STATE_BUCKET_NAME}.tfout
	
# 4. Undeploy the infrastructure
.PHONY: undeploy
undeploy:
	terraform destroy

# Clean TF files
.PHONY: tf-clean
tf-clean:
	rm -fr .terraform*
