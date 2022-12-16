
# Hardcoded values

> TODO: remove this hard coding

`PROJECT_ID` has been hardcoded in:  

1. ./block-explorer/kustomization.yaml: `cloud_sql_connection`
2. ./block-explorer/service_account.yaml: `iam.gke.io/gcp-service-account`

# Installation steps

```bash
cd env
kubectl apply -k .
```

# Uninstallation steps

```bash
cd env
kubectl delete -k .
```
