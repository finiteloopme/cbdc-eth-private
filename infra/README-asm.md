# Configuration of Anthos Service Mesh

> Mac OS can cause issues.  Recommended way is using Cloud Shell

## Get `ASMCLI`

```bash
# Assuming ASM version of 1.15
curl https://storage.googleapis.com/csm-artifacts/asm/asmcli_1.15 > asmcli
chmod 755 asmcli
```

## Get list of Hub Memberships

```bash
gcloud container hub memberships list
```

> Sample output
> ```bash
> NAME: aws-gke-cs
> EXTERNAL_ID: e6e8b077-83ec-44e4-97a4-81e572b13a16
> LOCATION: global
> 
> NAME: anthos-demo-kunall-gcp-gke-2
> EXTERNAL_ID: 2bfce5e5-c7d7-499f-8dc3-eb17c9742378
> LOCATION: global
> 
> NAME: anthos-demo-kunall-gcp-gke-1
> EXTERNAL_ID: 32b25fab-a750-4b23-8777-d34ca2ce8121
> LOCATION: global
> ```

## Install `ASM` for each cluster

> Assuming that kubeconfig file is at `~/.kube/confg`

```bash
# Repeat for each membership
# 1. anthos-demo-kunall-gcp-gke-1
# 2. anthos-demo-kunall-gcp-gke-2
# 3. aws-gke-cs
export MEMBERSHIP_ID=aws-gke-cs
gcloud container hub memberships get-credentials ${MEMBERSHIP_ID}
# Install ASM
rm -fr ./tmp/asm-output-dir/${MEMBERSHIP_ID}
mkdir -p ./tmp/asm-output-dir/${MEMBERSHIP_ID}
./asmcli install \
    --fleet_id anthos-demo-kunall \
    --output_dir ./tmp/asm-output-dir/${MEMBERSHIP_ID} \
    --kubeconfig /home/admin_/.kube/config \
    --platform multicloud \
    --enable_all \
    --ca mesh_ca \
    --option stackdriver 
```
