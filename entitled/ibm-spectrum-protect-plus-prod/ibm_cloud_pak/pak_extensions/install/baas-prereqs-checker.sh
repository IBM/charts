#!/bin/bash

. ./baas-options.sh

THIS_SCRIPT=${0##*/}
BAAS_LOG_DIR="/tmp"
LOGFILE="${BAAS_LOG_DIR}/${THIS_SCRIPT}_$(date +%Y%m%d-%H%M%S).log"
KUBERNETES_MIN_VERSION=1.17
DOCKER_MIN_VERSION=17.09.00
HELM_MIN_VERSION=3.3.0
HELM_ERR_VERSION=3.3.3
OCP_MIN_VERSION=4.5.0
HELM_WARNING=""

# Print a message and exit
function err_exit()
{
  echo "ERROR: $@" >&2
  echo "Refer to log file at $LOGFILE for more information!"
  print_log "ERROR: $@"
  exit 1
}

# Print a message to screen and logfile
function print_msg()
{
  echo -e "$@"
  print_log "ERROR: $@"
}

# Print a message to log file only
function print_log()
{
  echo -e "[$(date +%Y-%m-%d.%H:%M:%S)] $@" >> $LOGFILE
}

function check_license_prereqs()
{
  # Check if license value is true
  print_msg "INFORMATION: Checking for license acceptance..."
  if ! cat ./baas-values.yaml | grep "license: true" >>$LOGFILE 2>&1
  then
    print_msg "INFORMATION: The license is located in the directory ibm-spectrum-protect-plus-prod/LICENSES/LICENSE-en."
    print_msg "INFORMATION: Versions are available in other languages at: https://ibm.biz/BdqkAf"
    return 1
  fi

  print_msg "INFORMATION: Passed"
  return 0
}

function valid_ip()
{
  local  ip=$1
  local  stat=1

  if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
      OIFS=$IFS
      IFS='.'
      ip=($ip)
      IFS=$OIFS
      [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
          && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
      stat=$?
  fi
  return $stat
}


function check_sppaddress_prereqs()
{
  # Check if license value is true
  print_msg "INFORMATION: Checking the values of SPPips and SPPfqdn..."
  if ! cat ./baas-values.yaml | grep "SPPips:" >>$LOGFILE 2>&1
  then
    print_msg "ERROR: SPPips is missing from baas-values.yaml."
    return 1
  fi

  ip=$(grep -oP '^SPPips:\s+\K\S+' ./baas-values.yaml)
  print_msg "INFORMATION:  - Using SPPips: ${ip}"
  if ! valid_ip $ip
  then
    print_msg "ERROR: The value for SPPips is not a valid IP address."
    return 1
  fi

  if ! cat ./baas-values.yaml | grep "SPPfqdn:" >>$LOGFILE 2>&1
  then
    print_msg "ERROR: SPPfqdn is missing from baas-values.yaml."
    return 1
  fi

  fqdn=$(grep -oP '^SPPfqdn:\s+\K\S+' ./baas-values.yaml)
  print_msg "INFORMATION:  - Using SPPfqdn: ${fqdn}"
  result=`echo $fqdn | grep -P '(?=^.{1,254}$)(^(?>(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,})$)'`
  if [[ -z "$result" ]]
  then
    # SPPfqdn can be a IPaddress too
    if ! valid_ip $fqdn
    then
      print_msg "ERROR: The value for SPPfqdn is not a valid fully qualified domain name."
      return 1
    fi
  fi
    
  print_msg "INFORMATION: Passed"
  return 0

}

function check_kubectl_prereqs()
{
  print_msg "INFORMATION: Checking for kubectl on local system..."
  if ! which kubectl >>$LOGFILE 2>&1
  then
    print_msg "ERROR: kubectl is either not installed or not in the local path. Install kubectl or adjust the local path to run the kubectl command line tool."
    return 1
  fi
  print_msg "INFORMATION: Passed"

  print_msg "INFORMATION: Checking for active connection to target Kubernetes cluster..."
  if ! kubectl get nodes -o wide >>$LOGFILE 2>&1
  then
    print_msg "ERROR: Kubectl is not connected to a Kubernetes target cluster. Configure kubectl, login as cluster-admin to the Kubernetes target cluster."
    return 2
  else
    [[ "${TGT_CLUSTER}" == "" ]] && TGT_CLUSTER="$(kubectl config current-context)"
    print_msg "INFORMATION:  - Kubectl is connected to the Kubernetes target cluster >>${TGT_CLUSTER}<<."
  fi
  print_msg "INFORMATION: Passed"

  print_msg "INFORMATION: Checking for minimum Kubernetes version ${KUBERNETES_MIN_VERSION}..."
  KUBERNETES_VERSION=$(kubectl version | grep 'Client Version' | awk -F\GitVersion: '{print $2}' | awk -F\" '{print $2}' | awk -F\v '{print $2}')
  print_msg "INFORMATION:  - Detected Kubernetes version ${KUBERNETES_VERSION}."
  if [ "$KUBERNETES_VERSION" != "$(printf "$KUBERNETES_VERSION\n$KUBERNETES_MIN_VERSION\n" | sort -gr | head -1 )" ]
  then
    return 1
  fi

  print_msg "INFORMATION: Passed"
  return 0
}

# Check Docker prerequisites (run AFTER check_helm_prereqs() to set BAAS_VERSION from Helm chart)
function check_docker_prereqs()
{
  # Check if Docker is running on local system
  print_msg "INFORMATION: Checking for Docker running on the local system..."
  if ! docker ps >/dev/null 2>&1
  then
    print_msg "ERROR: Docker is not installed or not running on this local system. Start or install Docker."
    return 1
  fi
  print_msg "INFORMATION: Passed"

  print_msg "INFORMATION: Checking for minimum Docker version ${DOCKER_MIN_VERSION}..."
  DOCKER_VERSION=$(docker version | grep 'Version' | head -1 | awk '{print $2}')
  print_msg "INFORMATION:  - Detected Docker version ${DOCKER_VERSION}."
  if [ "$DOCKER_VERSION" != "$(printf "$DOCKER_VERSION\n$DOCKER_MIN_VERSION\n" | sort -gr | head -1 )" ]
  then
    return 1
  fi

# Check if docker registry and namespace match in baas-options.sh and baas-values.yaml
  print_msg "INFORMATION: Checking Docker values..."
  print_msg "INFORMATION:  - Using Docker registry: ${DOCKER_REGISTRY_ADDRESS}"
  print_msg "INFORMATION:  - Using Docker namespace: ${DOCKER_REGISTRY_NAMESPACE}"
  VALUES_OK="true"
  if ! cat ./baas-values.yaml | grep "imageRegistry: ${DOCKER_REGISTRY_ADDRESS}" >>$LOGFILE 2>&1
  then
    print_msg "INFORMATION: The value for imageRegistry in baas-values.yaml does not match the value for DOCKER_REGISTRY_ADDRESS in baas-options.sh"
    VALUES_OK="false"
  fi
  if ! cat ./baas-values.yaml | grep "imageRegistryNamespace: ${DOCKER_REGISTRY_NAMESPACE}" >>$LOGFILE 2>&1
  then
    print_msg "INFORMATION: The value for imageRegistryNamespace in baas-values.yaml does not match the value for DOCKER_REGISTRY_NAMESPACE in baas-options.sh"
    VALUES_OK="false"
  fi

  if [ "$VALUES_OK" = "false" ]
  then
    print_msg "INFORMATION: The imageRegistry value and DOCKER_REGISTRY_ADDRESS value must match, and the imageRegistryNamespace value and DOCKER_REGISTRY_NAMESPACE value must match."
    return 1
  fi

  print_msg "INFORMATION: Passed"
  return 0
}

# Check OCP prerequisites
function check_ocp_prereqs()
{
  if cat ./baas-values.yaml | grep "isOCP: true" >>$LOGFILE 2>&1
  then
    # Check if oc is available on local system
    print_msg "INFORMATION: Checking for the oc command line tool on local system..."
    if ! which oc >>$LOGFILE 2>&1
    then
      print_msg "ERROR: oc is either not installed or not in the local path. Install oc or adjust the local path to run the oc command line tool."
      return 1
    fi
    print_msg "INFORMATION: Passed"

    print_msg "INFORMATION: Checking that oc is logged in..."
    if ! oc version >>$LOGFILE 2>&1
    then
      print_msg "ERROR: The oc version command returned a non-zero return code. Are you properly logged in and is there an active connection to an OpenShift cluster?"
      return 1
    fi
    print_msg "INFORMATION: Passed"

    # Check if we are actively logged in to an OpenShift / RHEL OCP target system
    print_msg "INFORMATION: Checking for active connection to target OpenShift cluster..."
    if OCP_USER="$(oc whoami)"
    then
      print_log "INFORMATION:  - Logged into an OpenShift cluster as $OCP_USER"
    else
      print_msg "ERROR: You do not seem to be logged in to an OpenShift cluster. Log in with a regular cluster-admin account (oc login)."
      return 1
    fi
    print_msg "INFORMATION: Passed"

  #  print_msg "INFORMATION: Checking for an account token for user $OCP_USER ..."
  #  if ! OCP_USER_TOKEN="$(oc whoami -t)"
  #  then
  #    print_log "WARNING: An account token for user $OCP_USER could not be retrieved (e.g. when running as system:admin). In this case the admin needs to have logged in to the cluster image registry manually (e.g. docker login)."
  #  else
  #    print_msg "INFORMATION: Passed"
  #  fi

    print_msg "INFORMATION: Checking for active connection to target OpenShift cluster..."
    if ! oc get nodes -o wide >>$LOGFILE 2>&1
    then
      print_msg "ERROR: The OpenShift (oc) command line tools does not seem to be connected to an actual OpenShift target cluster. Login to an OpenShift target cluster as cluster-admin."
      return 2
    else
      [[ "${TGT_CLUSTER}" == "" ]] && TGT_CLUSTER="$(oc status | head -1 | awk '{print $NF}')"
      print_msg "INFORMATION:  - Connected as >>${OCP_USER}<< to the OpenShift target cluster >>${TGT_CLUSTER}<<."
    fi
    print_msg "INFORMATION: Passed"

    OCP_VERSION_CLIENT=$(oc version | grep 'Client Version' | awk '{print $3}')
    OCP_VERSION_SERVER=$(oc version | grep 'Server Version' | awk '{print $3}')

    # Need to ensure that the 'Client' and 'Server' parts are at the same version, before proceeding
    print_msg "INFORMATION: Checking that OpenShift Client and Server versions match..."
    print_msg "INFORMATION:  - Detected OpenShift client version ${OCP_VERSION_CLIENT}."
    print_msg "INFORMATION:  - Detected OpenShift server version ${OCP_VERSION_SERVER}."
    if [[ "$OCP_VERSION_CLIENT" != "$OCP_VERSION_SERVER" ]]
    then
      print_msg "WARNING: There is an OpenShift version mismatch between the 'Client' and 'Server'."
    fi
    print_msg "INFORMATION: Passed"

    print_msg "INFORMATION: Checking for minimum OpenShift version ${OCP_MIN_VERSION}..."
    print_msg "INFORMATION:  - Detected OpenShift version ${OCP_VERSION_CLIENT}."
    if [ "$OCP_VERSION_CLIENT" != "$(printf "$OCP_VERSION_CLIENT\n$OCP_MIN_VERSION\n" | sort -gr | head -1 )" ]
    then
      return 1
    fi

    print_msg "INFORMATION: Passed"

  fi

  return 0
}

# Check helm prerequisites
function check_helm3_prereqs()
{
  # Check if helm command is available on local system
  print_msg "INFORMATION: Checking for helm3 client availability on the local system..."
  if ! which helm3 >>$LOGFILE 2>&1
  then
    print_msg "INFORMATION: The helm3 client is either not installed or not in the local path."
    print_msg "INFORMATION: Install helm 3 and ensure that the binary name is helm3 to allow coexistence with helm 2."
    return 1
  fi
  print_msg "INFORMATION: Passed"

  # Check if helm is initialized on local system
  print_msg "INFORMATION: Checking for proper initialization of helm3 on the local system..."
  if ! helm3 version >>$LOGFILE 2>&1
  then
    print_msg "ERROR: Helm 3 is not properly initialized on this local system."
    return 1
  fi
  print_msg "INFORMATION: Passed"

  # Check for valid helm version

  print_msg "INFORMATION: Checking for minimum Helm version ${HELM_MIN_VERSION}..."
  HELM_VERSION=$(helm3 version 2>/dev/null | grep "version.BuildInfo" | awk -F\{ '{print $2}' | awk -F\Version: '{print $2}' | awk -F\" '{print $2}' | awk -F\v '{print $2}')
  print_msg "INFORMATION:  - Detected Helm version ${HELM_VERSION}"

  if [ "$HELM_VERSION" != "$(printf "$HELM_VERSION\n$HELM_MIN_VERSION\n" | sort -gr | head -1 )" ]
  then
    return 1
  fi

  # check helm3 Warning, WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/labuser/.kube/config
  if [[ $HELM_VERSION == $HELM_ERR_VERSION  ]]
  then
    HELM_WARNING=$(helm3 version | grep "WARNING: Kubernetes configuration file is group-readable. This is insecure.")
  fi

  # helm3.3.3 report "WARNING: Kubernetes configuration file is group-readable. This is insecure...". It is an issue, we should report error for this version
  if [[ $HELM_VERSION == $HELM_ERR_VERSION && $HELM_WARNING != "" ]]
  then
    echo "WARNINGS FROM HELM OUTPUT: $HELM_WARNING"
    print_msg "ERROR: helm version $HELM_ERR_VERSION has an issue and is not supported. Please refer to https://github.com/helm/helm/issues/8776"
    return 1
  fi
  
  print_msg "INFORMATION: Passed"
  return 0
}

# Ensure that the license has been accepted
check_license_prereqs || err_exit "The value for license in baas-values.yaml must be set to true to accept the license before continuing."

# Ensure that SPPips and SPPfqdn are in the baas-values.yaml file and are valid
check_sppaddress_prereqs || err_exit "The value for SPPips and SPPfqdn in baas-values.yaml must exist and be in the correct format before continuing."

# Check for the minimum version of kubernetes
check_kubectl_prereqs || err_exit "Kubernetes ${KUBERNETES_MIN_VERSION} or higher needs to be installed and configured before continuing."

# Check for the minimum version of OCP
check_docker_prereqs || err_exit "Docker ${DOCKER_MIN_VERSION} or higher needs to be installed and values configured before continuing."

# Check for the minimum version of kubernetes
check_ocp_prereqs || err_exit "OpenShift ${OCP_MIN_VERSION} or higher needs to be installed and configured before continuing."

# Check for the minimum version of Helm
check_helm3_prereqs || err_exit "Helm3 ${HELM_MIN_VERSION} or higher needs to be installed and configured before continuing."