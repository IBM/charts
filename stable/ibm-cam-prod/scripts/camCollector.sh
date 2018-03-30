#!/bin/bash
#
#Licensed Materials - Property of IBM
#5737-E67
#(C) Copyright IBM Corporation 2016, 2017 All Rights Reserved.
#US Government Users Restricted Rights - Use, duplication or
#disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#

usage() { echo "Usage: $0 [-t <icp-floating-ip>] [-u <icp-admin-user>] [-p <icp-admin-password>]" 1>&2; exit 1; }

collectDiagnosticsData() {
    echo "******************************* CAM diagnostics data collected on ${cam_diagnostic_collection_date} *******************************"
    echo -e "\n"

    services_ns="services"
    kubesystem_ns="kube-system"

    export CLUSTER_NAME=mycluster.icp

    echo "**********************************************************"
    echo "GET auth token from IBM Cloud Private."
    echo "**********************************************************"
    if [ -z "${u}" ]; then
      u="admin"
    fi

    result=$(curl -s -k -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" -d "grant_type=password&username=${u}&password=${p}&scope=openid" https://$t:8443/idprovider/v1/auth/identitytoken --write-out "\n%{http_code}" --silent)
    status="${result##*$'\n'}"
    response="${result%$'\n'*}"
    if [ "$status" -eq 200 ] 
    then
        export AUTH_ACCESS_TOKEN=$(echo $response} | cut -d':' -f2 | sed 's/^"\([^"]*\).*/\1/')
        export AUTH_ID_TOKEN=$(echo $response} | cut -d':' -f7 | sed 's/^"\([^"]*\).*/\1/')
        echo "Successfully retrieved authentication token from IBM Cloud Private"
    else
        echo "Failed to retrieve authentication token from IBM Cloud Private. Ensure that you provided the correct admin password."
        return 1
    fi
    echo -e "\n"

    echo "**********************************************************"
    echo "Setup Kubectl config"
    echo "**********************************************************"
    kubectl config set-cluster $CLUSTER_NAME --server=https://$t:8001 --insecure-skip-tls-verify=true
    kubectl config set-context $CLUSTER_NAME-context --cluster=$CLUSTER_NAME
    kubectl config set-credentials $CLUSTER_NAME-user --token=$AUTH_ID_TOKEN
    kubectl config set-context $CLUSTER_NAME-context --user=$CLUSTER_NAME-user --namespace=$services_ns
    kubectl config use-context $CLUSTER_NAME-context
    echo -e "\n"

    echo "**********************************************************"
    echo "Checking if Helm is setup correctly for IBM Cloud Private"
    echo "**********************************************************"
    helm list --tls > /dev/null 2>&1
    if [ $? -ne 0 ]; then
      echo "Helm client is not installed and/or configured. Configure the Helm client by following the IBM Cloud Private 'Setting up the Helm CLI' doc"
      return 1
    fi
    
    echo "**********************************************************"
    echo "GET HELM version"
    echo "**********************************************************"
    helm version --tls
    echo -e "\n"

    echo "**********************************************************"
    echo "GET list of deployed HELM charts"
    echo "**********************************************************"
    helm list --tls 
    echo -e "\n"

    echo "**********************************************************"
    echo "GET status of all deployed CAM HELM charts"
    echo "**********************************************************"
    echo -e "\n"

    getDeployedCAMChartsResult=$(helm list --short --tls | grep -i cam)
    echo "Getting status for the following deployed CAM HELM charts"
    echo "-----------------------------------------------------------"
    echo "${getDeployedCAMChartsResult}"
    echo -e "\n"

    echo "$getDeployedCAMChartsResult" |
    while read deployedCAMChart; do
        helm status $deployedCAMChart --tls
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

    echo "**********************************************************"
    echo "GET Persistent Volumes in Services namespace"
    echo "**********************************************************"
    kubectl get persistentvolume
    echo -e "\n"

    echo "**********************************************************"
    echo "GET Persistent Volume Claims in Services namespace"
    echo "**********************************************************"
    kubectl get persistentvolumeclaims --namespace=$services_ns
    echo -e "\n"

    echo "**********************************************************"
    echo "DESCRIBE Persistent Volume Claims in Services namespace"
    echo "**********************************************************"
    echo -e "\n"

    getPersistentVolumeClaimsResult=$(kubectl get persistentvolumeclaims --namespace=$services_ns --output=name | sed s/"persistentvolumeclaims\/"/""/)
    echo "Running DESCRIBE for the following Persistent Volume Claims"
    echo "-----------------------------------------------------------"
    echo "${getPersistentVolumeClaimsResult}"
    echo -e "\n"

    echo "$getPersistentVolumeClaimsResult" |
    while read persistentVolumeClaim; do
        kubectl describe persistentvolumeclaims $persistentVolumeClaim --namespace=$services_ns
        echo -e "----------------------------------------------------------------\n"
    done
    echo -e "\n"

    echo "**********************************************************"
    echo "GET ConfigMaps in Services namespace"
    echo "**********************************************************"
    kubectl get configmaps --namespace=$services_ns
    echo -e "\n"

    echo "**********************************************************"
    echo "DESCRIBE OAUTH-CLIENT-MAP ConfigMap in Services namespace"
    echo "**********************************************************"
    kubectl describe configmaps oauth-client-map --namespace=$services_ns
    echo -e "\n"

    echo "**********************************************************"
    echo "GET Kubernetes Pods in Services namespace"
    echo "**********************************************************"
    kubectl get pods --namespace=$services_ns
    echo -e "\n"

    echo "**********************************************************"
    echo "DESCRIBE Kubernetes Pods in Services namespace"
    echo "**********************************************************"
    echo -e "\n"

    getCAMPodsResult=$(kubectl get pods --namespace=$services_ns --output=name | sed s/"pods\/"/""/)
    echo "Running DESCRIBE for the following pods"
    echo "---------------------------------------"
    echo "${getCAMPodsResult}"
    echo -e "\n"

    echo "$getCAMPodsResult" |
    while read camPodName; do
        kubectl describe pods $camPodName --namespace=$services_ns
        echo -e "----------------------------------------------------------------\n"
    done
    echo -e "\n"

    echo "**********************************************************"
    echo "Downloading logs from CAM pods"
    echo "**********************************************************"
    echo "$getCAMPodsResult" |
    while read camPodName; do
        echo "Downloading logs from pod ${camPodName}"
        if [[ $camPodName = *"mongo"* ]] || [[ $camPodName = *"redis"* ]]; then
            kubectl cp ${camPodName}:/var/log/ ${cam_diagnostic_data_folder}/${camPodName} --namespace=$services_ns 2>&1
        else
            kubectl cp ${camPodName}:/var/camlog/${camPodName} ${cam_diagnostic_data_folder}/${camPodName} --namespace=$services_ns 2>&1
        fi        
        echo "Successfully downloaded logs from pod ${camPodName}"
    done
    echo -e "\n"
   
    echo "**********************************************************"
    echo "GET Kubernetes Pods in Kube-system namespace"
    echo "**********************************************************"
    kubectl get pods --namespace=$kubesystem_ns
    echo -e "\n"

    echo "**********************************************************"
    echo "DESCRIBE Kubernetes Pods in Kube-Systems namespace"
    echo "**********************************************************"
    echo -e "\n"
    
    getPodsResult=$(kubectl get pods --namespace=$kubesystem_ns --output=name | sed s/"pods\/"/""/)
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
while getopts "t:p:u:" o; do
    case "${o}" in
        t)
            t=${OPTARG}
            ;;
        p)
            p=${OPTARG}
            ;;
        u)
            u=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${t}" ] || [ -z "${p}" ]; then
    usage
fi

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

cam_diagnostic_collection_date=`date +"%d_%m_%y_%H_%M_%S"`
echo "******************************* CAM diagnostics data collected on ${cam_diagnostic_collection_date} *******************************"
echo ""

tempFolder="/tmp"
cam_diagnostic_data_folder_name="cam_diagnostic_data_${cam_diagnostic_collection_date}"
cam_diagnostic_data_folder="${tempFolder}/${cam_diagnostic_data_folder_name}"
cam_diagnostic_data_log="${cam_diagnostic_data_folder}/cam-diagnostics-data.log"
cam_diagnostic_data_zipped_file="${cam_diagnostic_data_folder}.tgz"
echo "Creating temporary folder ${cam_diagnostic_data_folder}"
if `mkdir ${cam_diagnostic_data_folder}`; then
    echo "Successfully created temporary folder ${cam_diagnostic_data_folder}"
else
    echo "Failed creating temporary folder ${cam_diagnostic_data_folder}"
    exit 1
fi

echo "Collecting Diagnostics data. Please wait...."
collectDiagnosticsData $@ > ${cam_diagnostic_data_log}
if [ $? -eq 0 ]; then
    echo "Successfully collected CAM diagnostics data"
else
    echo "Error occurred while trying to collect CAM diagnostics data. Check ${cam_diagnostic_data_log} for details"
    exit 1
fi

echo "Zipping up Diagnostics data from ${cam_diagnostic_data_folder}"
tar cfz ${cam_diagnostic_data_zipped_file} --directory ${tempFolder} ${cam_diagnostic_data_folder_name}
if [ $? -eq 0 ]; then
    echo "Cleaning up temporary folder ${cam_diagnostic_data_folder}"
    rm -rf ${cam_diagnostic_data_folder}
    echo "******************************* Successfully collected and zipped up CAM diagnostics data. The diagnostics data is available at ${cam_diagnostic_data_zipped_file} *******************************"
else
    echo "******************************* Failed to zip up diagnostics data. Diagnostics data folder is available at ${cam_diagnostic_data_folder} *******************************" 
fi