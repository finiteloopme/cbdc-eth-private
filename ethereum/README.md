
# Warning

> The instructions for deploying to multi-cloud are not included yet.
> Deploys successfully to a single cluster.

# Hardcoded values

> TODO: remove this hard coding

`PROJECT_ID` has been hardcoded in:  

1. ./block-explorer/kustomization.yaml: `cloud_sql_connection`
2. ./block-explorer/service_account.yaml: `iam.gke.io/gcp-service-account`

# Installation steps

```bash
cd all
kubectl apply -k .
```

# Uninstallation steps

```bash
cd all
kubectl delete -k .
```
