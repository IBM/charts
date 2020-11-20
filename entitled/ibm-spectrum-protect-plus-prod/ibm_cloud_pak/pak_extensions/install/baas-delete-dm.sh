#!/bin/bash

#==================================================================================================
echo "Delete datamover deployment after upgrade"
#==================================================================================================

echo "kubectl delete pods -l app.kubernetes.io/name=baas -n baas"
kubectl delete pods -l app.kubernetes.io/name=baas -n baas

DM_NAME=" baas-datamover"
RESTORE_NAME=" restore-baas-datamover"

# find and delete all data mover related networkpolicies
NLINES=$(kubectl get netpol --all-namespaces 2>&1 | grep -e "${DM_NAME}" -e "${RESTORE_NAME}" | wc -l)
if [ "${NLINES}" -gt 0 ]; then
    kubectl get netpol --all-namespaces | grep -e "${DM_NAME}" -e "${RESTORE_NAME}" | while read -r line ; do
        trimmedline="$(echo "${line}" | awk '{$1=$1};1')"
        NAMESPACE=$(echo "${trimmedline}" | cut -f1 -d ' ')
        NETPOL=$(echo "${trimmedline}" | cut -f2 -d ' ')
        echo "Info: Deleting networkpolcy ${NETPOL} from namespace ${NAMESPACE} ..."
        kubectl delete netpol "${NETPOL}" -n "${NAMESPACE}" --force --grace-period=0
    done
fi
# find and delete all data mover related services
NLINES=$(kubectl get svc --all-namespaces 2>&1 | grep -e "${DM_NAME}" -e "${RESTORE_NAME}" | wc -l)
if [ "${NLINES}" -gt 0 ]; then
    kubectl get svc --all-namespaces | grep -e "${DM_NAME}" -e "${RESTORE_NAME}" | while read -r line ; do
        trimmedline="$(echo "${line}" | awk '{$1=$1};1')"
        NAMESPACE=$(echo "${trimmedline}" | cut -f1 -d ' ')
        SERVICE=$(echo "${trimmedline}" | cut -f2 -d ' ')
        echo "Info: Deleting service ${SERVICE} from namespace ${NAMESPACE} ..."
        kubectl delete svc "${SERVICE}" -n "${NAMESPACE}" --force --grace-period=0
    done
fi
# find and delete all data mover related deployments
NLINES=$(kubectl get deploy --all-namespaces 2>&1 | grep -e "${DM_NAME}" -e "${RESTORE_NAME}" | wc -l)
if [ "${NLINES}" -gt 0 ]; then
    kubectl get deploy --all-namespaces | grep -e "${DM_NAME}" -e "${RESTORE_NAME}" | while read -r line ; do
        trimmedline="$(echo "${line}" | awk '{$1=$1};1')"
        NAMESPACE=$(echo "${trimmedline}" | cut -f1 -d ' ')
        DEPLOY=$(echo "${trimmedline}" | cut -f2 -d ' ')
        echo "Info: Deleting deployment ${DEPLOY} from namespace ${NAMESPACE} ..."
        kubectl delete deploy "${DEPLOY}" -n "${NAMESPACE}" --force --grace-period=0
    done
fi
# find and delete any remaining data mover related pods that were not
# deleted when the deployment was deleted
NLINES=$(kubectl get pod --all-namespaces 2>&1 | grep -e "${DM_NAME}" -e "${RESTORE_NAME}" | wc -l)
if [ "${NLINES}" -gt 0 ]; then
    kubectl get pod --all-namespaces | grep -e "${DM_NAME}" -e "${RESTORE_NAME}" | while read -r line ; do
        trimmedline="$(echo "${line}" | awk '{$1=$1};1')"
        NAMESPACE=$(echo "${trimmedline}" | cut -f1 -d ' ')
        POD=$(echo "${trimmedline}" | cut -f2 -d ' ')
        echo "Info: Deleting pod ${POD} from namespace ${NAMESPACE} ..."
        kubectl delete pod "${POD}" -n "${NAMESPACE}" --force --grace-period=0
    done
fi
# find and delete all data mover related serviceaccount
NLINES=$(kubectl get serviceaccount --all-namespaces 2>&1 | grep -e "${DM_NAME}" -e "${RESTORE_NAME}" | wc -l)
if [ "${NLINES}" -gt 0 ]; then
    kubectl get serviceaccount --all-namespaces | grep -e "${DM_NAME}" -e "${RESTORE_NAME}" | while read -r line ; do
        trimmedline="$(echo "${line}" | awk '{$1=$1};1')"
        NAMESPACE=$(echo "${trimmedline}" | cut -f1 -d ' ')
        SERVICEACCOUNT=$(echo "${trimmedline}" | cut -f2 -d ' ')
        echo "Info: Deleting serviceaccount ${SERVICEACCOUNT} from namespace ${NAMESPACE} ..."
        kubectl delete serviceaccount "${SERVICEACCOUNT}" -n "${NAMESPACE}" --force --grace-period=0
    done
fi
