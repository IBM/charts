#!/bin/bash
#
###############################################################################
# Licensed Materials - Property of IBM.
# Copyright IBM Corporation 2018, 2019. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
# Contributors:
#  IBM Corporation - initial API and implementation
###############################################################################

PRODUCT_NAME=APM
CHART_NAME=ibm-cloud-appmgmt-prod
TLS_OPT=--tls
since=4h

usage() {
    echo "A script to collect logs from your running Kubernetes cluster for delivery to IBM Support." 1>&2;
    echo "" 1>&2;
    echo "Usage:" 1>&2;
    echo "  $0 [-i] [-s <timespan>]" 1>&2;
    echo "" 2>&1;
    echo "Flags:" 2>&1;
    echo "  -i Use an insecure (no TLS) connection to the helm pacakge manager." 2>&1;
    echo "  -s Timespan of logs to collect. Default is 4h" 2>&1;
    echo "" 2>&1;
    echo "" 2>&1;
    echo "" 2>&1;
    exit 1;
}

collectDiagnosticsData() {
    echo "******************************* ${PRODUCT_NAME} diagnostics data collected on ${diagnostic_collection_date} *******************************"
    echo -e "\n"

    kubesystem_ns="kube-system"

    echo "**********************************************************"
    echo "Checking if Helm is setup correctly for IBM Cloud Private"
    echo "**********************************************************"
    helm list ${TLS_OPT} > /dev/null 2>&1
    if [ $? -ne 0 ]; then
      echo "Helm client is not installed and/or configured. Configure the Helm client by following the IBM Cloud Private 'Setting up the Helm CLI' doc"
      return 1
    else
      echo "Helm client is properly installed and configured."
      echo -e "\n"
    fi

    echo "**********************************************************"
    echo "GET HELM version"
    echo "**********************************************************"
    helm version ${TLS_OPT}
    echo -e "\n"

    echo "**********************************************************"
    echo "GET list of deployed HELM charts"
    echo "**********************************************************"
    helm list ${TLS_OPT}
    echo -e "\n"

    echo "**********************************************************"
    echo "GET status of all deployed ${PRODUCT_NAME} HELM charts"
    echo "**********************************************************"
    echo -e "\n"

    getDeployedChartsResult=$(helm list ${TLS_OPT} | grep -i ${CHART_NAME})
    echo "Getting status for the following deployed ${PRODUCT_NAME} HELM charts"
    echo "-----------------------------------------------------------"
    echo "${getDeployedChartsResult}"
    echo -e "\n"

    echo "$getDeployedChartsResult" |
    while read deployedChart; do
        helm status $deployedChart ${TLS_OPT}
        echo -e "----------------------------------------------------------------\n"
    done
    echo -e "\n"

    echo "**********************************************************"
    echo "GET Kubernetes version"
    echo "**********************************************************"
    kubectl version
    echo -e "\n"

    echo "**********************************************************"
    echo "GET Kubernetes namespaces"
    echo "**********************************************************"
    kubectl get namespaces
    echo -e "\n"
    echo "Identifying the namespaces used by the ${PRODUCT_NAME} HELM charts"
    echo "-----------------------------------------------------------"
    NAMESPACES=("services")

    while read deployedChart; do
        NAMESPACES+=($(helm status $deployedChart ${TLS_OPT} | grep "NAMESPACE" | awk '{print $2}'))
    done <<< "$getDeployedChartsResult"

    echo $(IFS=, ; echo "${NAMESPACES[*]}")

    echo -e "\n"

    echo "**********************************************************"
    echo "GET Persistent Volumes"
    echo "**********************************************************"
    kubectl get persistentvolume
    echo -e "\n"

    for ns in "${NAMESPACES[@]}"
    do
      echo "**********************************************************"
      echo "GET Persistent Volume Claims in $ns namespace"
      echo "**********************************************************"
      kubectl get persistentvolumeclaims --namespace=$ns
      echo -e "\n"

      echo "**********************************************************"
      echo "DESCRIBE Persistent Volume Claims in $ns namespace"
      echo "**********************************************************"
      echo -e "\n"

      getPersistentVolumeClaimsResult=$(kubectl get persistentvolumeclaims --namespace=$ns --output=name | sed s/"persistentvolumeclaims\/"/""/)
      echo "Running DESCRIBE for the following Persistent Volume Claims"
      echo "-----------------------------------------------------------"
      echo "${getPersistentVolumeClaimsResult}"
      echo -e "\n"

      echo "$getPersistentVolumeClaimsResult" |
      while read persistentVolumeClaim; do
          kubectl describe persistentvolumeclaims $persistentVolumeClaim --namespace=$ns
          echo -e "----------------------------------------------------------------\n"
      done
      echo -e "\n"

      echo "**********************************************************"
      echo "GET ConfigMaps in $ns namespace"
      echo "**********************************************************"
      kubectl get configmaps --namespace=$ns
      echo -e "\n"

      echo "**********************************************************"
      echo "DESCRIBE OAUTH-CLIENT-MAP ConfigMap in $ns namespace"
      echo "**********************************************************"
      kubectl describe configmaps oauth-client-map --namespace=$ns
      echo -e "\n"

      echo "**********************************************************"
      echo "GET Kubernetes Pods in $ns namespace"
      echo "**********************************************************"
      kubectl get pods --namespace=$ns
      echo -e "\n"
      
      echo "**********************************************************"
      echo "GET Kubernetes Pods in $ns namespace sorted by node"
      echo "**********************************************************"
      kubectl get pods -o wide --namespace=$ns  --sort-by=".status.hostIP"
      echo -e "\n"


      getPodsResult=$(kubectl get pods --namespace=$ns --output=name | cut -d'/' -f2-)

      getPodCount=$(kubectl get pods --namespace=$ns --output=name | wc -l)

      if [ "${getPodCount}" -ne "0" ]; then

        echo "**********************************************************"
        echo "DESCRIBE Kubernetes Pods in $ns namespace"
        echo "**********************************************************"
        echo -e "\n"

        echo "Running DESCRIBE for the following pods"
        echo "---------------------------------------"
        echo "${getPodsResult}"
        echo -e "\n"

        echo "$getPodsResult" |
        while read podName; do
          kubectl describe pods $podName --namespace=$ns
          echo -e "----------------------------------------------------------------\n"
        done
        echo -e "\n"

        echo "**********************************************************"
        echo "Downloading logs from pods in $ns namespace"
        echo "**********************************************************"
        echo "$getPodsResult" |
        while read podName; do
            echo "Downloading logs from pod ${podName}"
            podContainers=$(kubectl get pods --namespace=${ns} ${podName} -o jsonpath='{.spec.containers[*].name}')

            for podContainer in ${podContainers}
            do
                echo "Downloading logs for container ${podContainer}"
                # if pod name contains temasda get the log from beginning
                if [[ ${podName} == *"temasda"* ]]; then
                   kubectl --namespace=$ns logs ${podName} -c ${podContainer} >> "${diagnostic_data_folder}/${podName}-${podContainer}-$ns.log"  2>&1
                else
                   kubectl --namespace=$ns logs ${podName} -c ${podContainer} --since ${since} >> "${diagnostic_data_folder}/${podName}-${podContainer}-$ns.log"  2>&1
                fi
            done
            echo "Successfully downloaded logs from pod ${podName}"
        done
        echo -e "\n"
      fi
    done

    echo "**********************************************************"
    echo "GET Kubernetes Pods in $kubesystem_ns namespace"
    echo "**********************************************************"
    kubectl get pods --namespace=$kubesystem_ns
    echo -e "\n"

    echo "**********************************************************"
    echo "DESCRIBE Kubernetes Pods in $kubesystem_ns namespace"
    echo "**********************************************************"
    echo -e "\n"

    getPodsResult=$(kubectl get pods --namespace=$kubesystem_ns --output=name | cut -d'/' -f2-)
    echo "Running DESCRIBE for the following pods"
    echo "---------------------------------------"
    echo "${getPodsResult}"
    echo -e "\n"

    echo "$getPodsResult" |
    while read podName; do
        kubectl describe pods $podName --namespace=$kubesystem_ns
        echo -e "----------------------------------------------------------------\n"
    done
}

#########################################################################################
#                                MAIN
#########################################################################################
while getopts "is:" o; do
    case "${o}" in
        i)  TLS_OPT=''
            ;;
        s)  since=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

echo "**********************************************************"
echo "Checking for Kubectl/HELM Client"
echo "**********************************************************"
if ! which kubectl; then
    echo "kubectl command not found. Ensure that you have kubectl installed."
    exit 1
fi

if ! which helm; then
    echo "Helm client is not installed and/or configured. Configure the Helm client by following the IBM Cloud Private 'Setting up the Helm CLI' doc"
    exit 1
fi
echo -e "\n"

diagnostic_collection_date=`date --utc +%Y%m%dT%H%M%SZ`
echo "******************************* ${PRODUCT_NAME} diagnostics data collected on ${diagnostic_collection_date} *******************************"
echo ""

tempFolder="containerLogs"
mkdir ${tempFolder}
diagnostic_data_folder_name="diagnostic_data_${diagnostic_collection_date}"
diagnostic_data_folder="${tempFolder}/${diagnostic_data_folder_name}"
diagnostic_data_log="${diagnostic_data_folder}/diagnostics-data.log"
diagnostic_data_zipped_file="${diagnostic_data_folder}.tgz"
echo "Creating temporary folder ${diagnostic_data_folder}"
if `mkdir ${diagnostic_data_folder}`; then
    echo "Successfully created temporary folder ${diagnostic_data_folder}"
else
    echo "Failed creating temporary folder ${diagnostic_data_folder}"
    exit 1
fi

echo "Collecting Diagnostics data. Please wait...."
collectDiagnosticsData $@ > ${diagnostic_data_log} 2>&1
if [ $? -eq 0 ]; then
    echo "Successfully collected ${PRODUCT_NAME} diagnostics data"
else
    echo "Error occurred while trying to collect ${PRODUCT_NAME} diagnostics data. Check ${diagnostic_data_log} for details"
    exit 1
fi

echo "Zipping up Diagnostics data from ${diagnostic_data_folder}"
tar cfz ${diagnostic_data_zipped_file} --directory ${tempFolder} ${diagnostic_data_folder_name}
if [ $? -eq 0 ]; then
    echo "Cleaning up temporary folder ${diagnostic_data_folder}"
    rm -rf ${diagnostic_data_folder}
    echo "******************************* Successfully collected and zipped up ${PRODUCT_NAME} diagnostics data. *******************************"
    echo "The diagnostics data is available at ${diagnostic_data_zipped_file}"
else
    echo "******************************* Failed to zip up diagnostics data. Diagnostics data folder is available at ${diagnostic_data_folder} *******************************"
fi
