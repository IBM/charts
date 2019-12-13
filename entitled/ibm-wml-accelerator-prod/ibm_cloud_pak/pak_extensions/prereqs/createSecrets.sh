#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2018.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################
#
#
# This script takes 3 (ICP) or 4 (IKS) arguments:
#  1. Namespace where the chart will be installed
#  2. Release name
#  3. Docker Registry, ICP internal docker registry or IKS registry
#  4. Namespace to use for singletons (only for IKS)#
# Example:
#   1. For ICP
#     createSecrets.sh example1-namespace example1-release-name mycluster.icp:8500
#   2. For IKS
#     createSecrets.sh example1-namespace example1-release-name registry.ng.bluemix.net wmla-singletons 
#
help_text="This script takes 3 (ICP) or 4 (IKS) arguments:
1. Namespace where the chart will be installed
2. Release name
3. Docker Registry, ICP internal docker registry or IKS registry
4. Namespace to use for singletons (only for IKS)

Example:
 1. For ICP
   createSecrets.sh example1-namespace example1-release-name mycluster.icp:8500
 2. For IKS
   createSecrets.sh example1-namespace example1-release-name registry.ng.bluemix.net  wmla-singletons

During execution, this script checks if environment variables WMLA_DOCKER_USER, WMLA_DOCKER_PASSWORD, WMLA_IBMCLOUD_APIKEY are set.
- If environment variable WMLA_DOCKER_USER is set (e.g., export WMLA_DOCKER_USER=<docker_user>), script doesn't prompt for <docker_user>.
  If WMLA_DOCKER_USER isn't defined or has string length equal to 0, script prompts for <docker_user>.
- If environment variable WMLA_DOCKER_PASSWORD is set (e.g., export WMLA_DOCKER_PASSWORD=<docker_password>, script doesn't prompt for <docker_password>.
  If WMLA_DOCKER_PASSWORD isn't defined or has string length equal to 0, script prompts for <docker_password>.
- If environment variable WMLA_IBMCLOUD_APIKEY is set (e.g., export WMLA_IBMCLOUD_APIKEY=<ibmcloud_apikey>, script doesn't prompt for <api key>.
  If WMLA_IBMCLOUD_APIKEY isn't defined or has string length equal to 0, script prompts for <api key>."

if [ "$1" = "--help" -o "$1" = "-h" ];then
  echo "$help_text"
  exit 0
fi

namespace="{{ NAMESPACE }}"
singletons_namespace="{{ SINGLETONS_NAMESPACE }}"
release_name="{{ RELEASE }}"
username="{{ USERNAME }}"
password="{{ PASSWORD }}"
docker_registry="{{ DOCKER_REGISTRY }}"
docker_key="{{ DOCKERKEY }}"
docker_config_json="{{ DOCKER_CONFIG_JSON }}"
apikey="{{ APIKEY }}"

clusterType="cp4d"
kubectl version | grep -i iks > /dev/null
if [ $? -eq 0 ]; then
    clusterType="iks"
fi

# Arguments check for IKS
if [ $clusterType = "iks" -a  "$#" -lt 4 ]; then
    echo "$help_text"
    exit 1
fi

# Arguments check for CP4D
if [ $clusterType = "cp4d" -a  "$#" -lt 3 ]; then
    echo "$help_text"
    exit 1
fi

if [ $clusterType = "cp4d" ]; then
    namespace_arg=$1
    release_name_arg=$2
    docker_registry_arg=$3

    echo "Enter Docker Credentials:"
    if [ -z $WMLA_DOCKER_USER ]; then
        read -p "Username: " username_arg
        echo 
    else
        username_arg=$WMLA_DOCKER_USER
    fi

    if [ -z $WMLA_DOCKER_PASSWORD ]; then
        read -sp "Password: " password_arg
        echo 
    else
        password_arg=$WMLA_DOCKER_PASSWORD
    fi

    echo
else
    namespace_arg=$1
    release_name_arg=$2
    docker_registry_arg=$3
    singletons_namespace_arg=$4

    echo "Enter Registry Credentials:"
    if [ -z $WMLA_DOCKER_USER ]; then
        read -p "Username: " username_arg
        echo 
    else
        username_arg=$WMLA_DOCKER_USER
    fi

    if [ -z $WMLA_DOCKER_PASSWORD ]; then
        read -sp "Password: " password_arg
        echo 
    else
        password_arg=$WMLA_DOCKER_PASSWORD
    fi

    if [ -z $WMLA_IBMCLOUD_APIKEY ]; then
        read -sp "Apikey for ibmcloud: " apikey_arg
        echo 
    else
        apikey_arg=$WMLA_IBMCLOUD_APIKEY
    fi
    base64_apikey="$(echo -n ${apikey_arg} | base64)"
fi
base64_username="$(echo ${username_arg} | base64)"
base64_password="$(echo ${password_arg} | base64 -w 0)"
encoded_dockerkey="$(echo -n ${username_arg}:${password_arg} | base64 -w 0)"

#Create directory for template files
templateDir="templateDir/${namespace_arg}_${release_name_arg}"
mkdir -p ${templateDir}

if [ $clusterType = "cp4d" ]; then
    # Create secrets
    # Replace namespace , releasename , encoded username and password in  secret_template.yaml
    sed -e "s/${namespace}/${namespace_arg}/g; \
            s/${release_name}/${release_name_arg}/g; \
            s/${username}/${base64_username}/g; \
            s/${password}/${base64_password}/g" \
        secret_template.yaml > ${templateDir}/${namespace_arg}_${release_name_arg}_secret.yaml
    kubectl create -f ${templateDir}/${namespace_arg}_${release_name_arg}_secret.yaml
else
    # Create secret for docker and ibmcloud login in IKS
    # Replace namespace , releasename , encoded username, password & apikey in  secret_template_iks.yaml
    sed -e "s/${namespace}/${namespace_arg}/g; \
              s/${release_name}/${release_name_arg}/g; \
              s/${username}/${base64_username}/g; \
              s/${password}/${base64_password}/g; \
              s/${apikey}/${base64_apikey}/g" \
          secret_template_iks.yaml > ${templateDir}/${namespace_arg}_${release_name_arg}_secret.yaml
    kubectl create -f ${templateDir}/${namespace_arg}_${release_name_arg}_secret.yaml
fi


# Create secrets for docker pull from inside master password
# Replace docker_registry and encoded_dockerkey in secret_config.json
sed -e "s/${docker_registry}/${docker_registry_arg}/g; \
        s/${docker_key}/${encoded_dockerkey}/g" \
    secret_config.json > ${templateDir}/${namespace_arg}_${release_name_arg}_secret_config.json

registry_key=$(cat ${templateDir}/${namespace_arg}_${release_name_arg}_secret_config.json | base64 -w 0)
# Replace this registry-key , namespace and releasename in secret_helm_template.yaml
sed -e "s/${namespace}/${namespace_arg}/g; \
          s/${release_name}/${release_name_arg}/g; \
          s/${docker_config_json}/${registry_key}/g" \
    secret_helm_template.yaml > ${templateDir}/${namespace_arg}_${release_name_arg}_secret_helm.yaml

kubectl create -f ${templateDir}/${namespace_arg}_${release_name_arg}_secret_helm.yaml

if [ $clusterType = "iks" ]; then
    # Create Secrets for singletons
    # Create the namespace for the singletons if it doesn't exist already
    if ! kubectl get namespace $singletons_namespace_arg > /dev/null 2>&1; then
      kubectl create namespace $singletons_namespace_arg
    fi
    # Create registry Secret
    # Replace releasename encoded username and password in secret_singleton_template.yaml
    output_secret_yaml=${templateDir}/${singletons_namespace_arg}_secret_singleton_admin.yaml
    sed -e "s/${singletons_namespace}/${singletons_namespace_arg}/g; \
            s/${docker_config_json}/${registry_key}/g" \
         secret_singleton_template.yaml > ${output_secret_yaml}
    # Create secret wmla-singleton-registrykey if it doesn't exist already
    if kubectl get -f ${output_secret_yaml} > /dev/null 2>&1; then
        echo "Secret $(cat ${output_secret_yaml} | grep -o " name:.*") already exists in $(cat ${output_secret_yaml} | grep -o "namespace:.*")"
    else
        kubectl create -f ${output_secret_yaml} -n $singletons_namespace_arg
    fi
    # Create admin Secret
    output_secret_yaml=${templateDir}/${namespace_arg}_${release_name_arg}_secret_iks.yaml
    sed -e "s/${singletons_namespace}/${singletons_namespace_arg}/g; \
            s/${username}/${base64_username}/g; \
            s/${password}/${base64_password}/g; \
            s/${apikey}/${base64_apikey}/g" \
        secret_singleton_admin_template_iks.yaml > ${output_secret_yaml}
    if kubectl get -f ${output_secret_yaml} > /dev/null 2>&1; then
        echo "Secret $(cat ${output_secret_yaml} | grep -o " name:.*") already exists in $(cat ${output_secret_yaml} | grep -o "namespace:.*")"
    else
        kubectl create -f ${output_secret_yaml} -n $singletons_namespace_arg
    fi
fi
