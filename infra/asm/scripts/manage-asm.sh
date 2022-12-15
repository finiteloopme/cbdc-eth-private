#!/usr/bin/env bash

# Four arguments expected
# 1. ASM version. E.g. 1.15
# 2. Fleet id
# 3. Action: install or uninstall
# 4. Fleet membership ID
# ./manage-asm.sh 1.15 anthos-demo-kunall install 
if [ "$#" -lt 3 ]; then
    >&2 echo "Not all expected arguments set."
    exit 1
fi

ASM_VERSION=$1; shift
FLEET_ID=$1; shift
ACTION=$1; shift
FLEET_MEMBERSHIP_ID=$1; shift
ASMCLI=asmcli

if test -f "${ASMCLI}"; then
    echo "${ASMCLI} exists.  No need to download again"
else
    echo "Downloading ${ASMCLI}..."
    curl https://storage.googleapis.com/csm-artifacts/asm/asmcli_${ASM_VERSION} > ${ASMCLI}
    chmod 755 asmcli
fi

gcloud container hub memberships get-credentials ${FLEET_MEMBERSHIP_ID}

if [ "${ACTION}" == "install" ]; then
    echo "Installing ASM..."
    rm -fr ./tmp/asm-output-dir/${FLEET_MEMBERSHIP_ID}
    mkdir -p ./tmp/asm-output-dir/${FLEET_MEMBERSHIP_ID}
    # install script
    ./${ASMCLI} install \
    --fleet_id ${FLEET_ID} \
    --output_dir ./tmp/asm-output-dir/${FLEET_MEMBERSHIP_ID} \
    --platform multicloud \
    --enable_all \
    --ca mesh_ca \
    --option stackdriver
else
    echo "Uninstalling ASM..."
    # uninstall script
    kubectl label namespace default istio.io/rev-
    kubectl label namespace default istio-injection-
    kubectl delete controlplanerevision -n istio-system
    kubectl delete validatingwebhookconfiguration,mutatingwebhookconfiguration -l operator.istio.io/component=Pilot
    istioctl x uninstall --purge
    kubectl delete namespace istio-system asm-system --ignore-not-found=true
fi
