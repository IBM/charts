#!/bin/bash
# ===================================================================================================
# IBM Confidential
# OCO Source Materials
# 5725-W99
# (c) Copyright IBM Corp. 1998, 2020
# The source code for this program is not published or otherwise divested of its
# trade secrets, irrespective of what has been deposited with the U.S. Copyright Office.
# ===================================================================================================
#  BaaS: Service Manager - baas_install.sh                                                     v6.12
# ===================================================================================================
#
# Purpose: Deploy BaaS components on OpenShift and IBM Cloud Private / Kubernetes environments
#
# Usage: baas_install.sh [-i|-u|-d|-l|-s] (-h) (-x) (-y) (-f BaaS-Config-File)
#
# ===================================================================================================
#  Prerequisites:
#  - Kubectl, oc (OpenShift only), Docker (with login to cluster image registry) and Helm
#  - User needs to be logged in to the target cluster as cluster-admin
# ===================================================================================================
# ===================================================================================================

# ----------------
#  Global options
# ----------------

# NAME OF SCRIPT AND OPTIONS
THIS_SCRIPT=${0##*/}
THIS_SCRIPT_OPTIONS="$@"

# GLOBAL VARIABLES
BAAS_VERSION=""            # Will be derived from the Helm chart appVersion in chart.yaml and used for all image tags
BAAS_HELM_CHART="../../../../ibm-spectrum-protect-plus-prod"    # Helm chart name and Helm chart directory name in local installation directory
BAAS_RELEASE_NAME="baas"   # Helm release name for the deployment otherwise Helm will automatically chose one (e.g., like happy-panda)
BAAS_SECRET_NAME="${BAAS_RELEASE_NAME}-secret"     # BaaS secret name (e.g. baas-secret) to retrieve credentials for BAAS_PASSWORD for debug log collection. This value should be in sync with BAAS_SECRET_NAME from baas-secret.sh.
BAAS_CFGMAP_NAME="${BAAS_RELEASE_NAME}-configmap"  # BaaS configMap name (e.g. baas-configmap) to retrieve deployment data for debug log collection
BAAS_CONFIG_FILE="baas_config.cfg"                 # BaaS config file that contains the local environment customization provided by the system admin before deployment
BAAS_HELM_OVERRIDE_FILE="baas_values.yaml"         # Temporary override values.yaml file for the Helm chart when invoked with helm install/update
BAAS_IMAGES="scheduler controller transaction-manager transaction-manager-worker transaction-manager-redis datamover spp-agent kafka cert-monitor"
#BAAS_PODS="baas-controller baas-scheduler baas-transaction-manager baas-etcd-client baas-etcd-spp-job-control-store"
BAAS_LOG_DIR="/tmp"        # Local system directory for log collection and command debug log 
BAAS_DEBUG_LOG_DIRNAME="baas_debug_logs" # Log collection directory name as BAAS_DEBUG_LOG_DIRNAME_20190331-195933 located under BAAS_LOG_DIR
HELM_TLS=""                # Secure Helm configuration using TLS with --tls as additional helm command line option for a secure Helm connection
OCP=false                  # Are we talking to an OCP or standard K8s cluster?
OCP_USER=""                # OCP user (e.g. system:admin), needs to be a cluster-admin account (clusterrole)
OCP_USER_TOKEN=""          # OCP user token for docker login to OCP image registry (Note: the system:admin account does not have a token and cannot login to the OCP image registry)
TGT_CLUSTER=""             # Target cluster identification / name to confirm during install
DEL_HELM_CONFIG_FILE=true  # Remove temporary Helm chart values override file to leave no file on the system with the BAAS_ADMIN and DATAMOVER_PASSWORD (even if these are base64 encrypted), default should be 'true'
KUBERNETES_VERSION=""      # Will be retrieved from the system
KUBERNETES_MIN_VERSION=1.16
HELM_MIN_VERSION=2.16.0
HELM_MAX_VERSION=3.00.0

# HELPER SCRIPTS
BAAS_AUX_LOGCOLLECT="baas_collect_logs.py"

# LOCAL CONFIG VARIABLES WILL BE READ FROM baas_config.cfg FILE
BAAS_ADMIN=""
BAAS_PASSWORD=""
SPP_IP_ADDRESSES=""
SPP_PORT=""
PRODUCT_NAMESPACE=""
PRODUCT_TARGET_PLATFORM="K8S"
PRODUCT_LOCALIZATION="en_US"
PRODUCT_LOGLEVEL="INFO"
PRODUCT_IMAGE_REGISTRY=""
PRODUCT_IMAGE_REGISTRY_NAMESPACE=""
PRODUCT_IMAGE_REGISTRY_SECRET_NAME=""
CLUSTER_CIDR=""
CLUSTER_API_SERVER_IP_ADDRESS=""
CLUSTER_API_SERVER_PORT=""
CLUSTER_NAME=""
SPP_AGENT_SERVICE_NODEPORT=""
LICENSE=""

# Progress will be logged to the following file
LOGFILE="${BAAS_LOG_DIR}/${THIS_SCRIPT}_$(date +%Y%m%d-%H%M%S).log"
BAASREQ_CRD_NAME="baasreqs.baas.io"

# Enable error trap
# set -E
# trap "trap - ERR; Error" ERR

# ----------------------
#  Function definitions 
# ----------------------

# Show command usage and exit
function exit_show_usage()
{
  cmd=$(basename $0)
  cat << EOF

USAGE: $cmd [-i|-u|-d|-l|-s] (-h) (-x) (-y) (-f BaaS-Config-File)

Installs/upgrades/deletes (-i|-u|-d) or collects (-l) logs for the IBM BaaS solution based on the customized input defined in the baas_config.cfg file.

TASKS

  -i : New installation of BaaS
  -u : Upgrade an existing installation of BaaS
  -d : Deinstall an existing installation of BaaS
  -s : Show status of BaaS Helm deployment
  -l : Collect logs for debugging purposes

  -h : Displays user help

OPTIONS

  -x : Include all external components for log collection (-l), e.g. all SPP instances
  -y : Don't prompt for confirmation during installation. Always assume 'yes' to continue.
  -f : Specify full path to BaaS config file (default: baas_config.cfg)

EOF
  print_log "Exiting. Wrong command usage: $THIS_SCRIPT $THIS_SCRIPT_OPTIONS"
  exit 1
}

# Print a message and exit
function err_exit()
{
  echo "ERROR: $@" >&2
  echo "Please refer to log file at $LOGFILE for more information!"
  print_log "ERROR: $@"
  exit 1
}

# Print a message to screen and logfile
function print_msg()
{
  echo -e "$@"
  echo -e "[$(date +%Y-%m-%d.%H:%M:%S)] $@" >> $LOGFILE
}

# Print a message to log file only
function print_log()
{
  echo -e "[$(date +%Y-%m-%d.%H:%M:%S)] $@" >> $LOGFILE
}

# Source BaaS main config file
# -> Sets OCP=true/false to run appropriate OCP or K8S sections in this script 
function source_config_file()
{
  if [[ -f "$BAAS_CONFIG_FILE" ]] 
  then
    print_msg "Sourcing BaaS configuration file $BAAS_CONFIG_FILE..."
    . "$BAAS_CONFIG_FILE"
  else
    print_msg "ERROR: Config file for BaaS deployment is missing ($BAAS_CONFIG_FILE)!"
    return 1
  fi
  
  # Check mandatory variables
  [[ "$BAAS_ADMIN" == "" ]] && print_msg "ERROR: BaaS admin account name not set in $BAAS_CONFIG_FILE." && return 10
  print_log "INFO: BAAS_ADMIN=$BAAS_ADMIN"
  # IF BAAS_PASSWORD IS NOT SET IN BAAS_CONFIG_FILE THEN PROMPT FOR IT DURING INSTALLATION
  [[ "$BAAS_PASSWORD" == "" ]] && print_log "INFO: BAAS_PASSWORD=[not set in config file / will be prompted for]" || print_log "INFO: BAAS_PASSWORD=[entry hidden from log / set in config file]"

  if [[ "$LICENSE" == "NOTACCEPTED" ]]
  then
    prompt_license_check 
    [[ "$LICENSE" == "ACCEPTED" ]] && print_log "INFO: LICENSE=$LICENSE" || return 10
  fi
  print_log "INFO: LICENSE=$LICENSE"

  [[ "$SPP_IP_ADDRESSES" == "" ]] && print_msg "ERROR: No list of IP addresses for SPP servers defined in $BAAS_CONFIG_FILE." && return 30
  print_log "INFO: SPP_IP_ADDRESSES=$SPP_IP_ADDRESSES"
  [[ "$SPP_PORT" == "" ]] && print_msg "ERROR: No network port for SPP servers defined in $BAAS_CONFIG_FILE." && return 35
  [[ "$SPP_PORT" -lt "1" ]] && print_msg "ERROR: SPP port is less than 1 in $BAAS_CONFIG_FILE." && return 35 
  [[ "$SPP_PORT" -gt "4294967295" ]] && print_msg "ERROR: SPP port is greater than 4,294,967,295 in $BAAS_CONFIG_FILE." && return 35 
  print_log "INFO: SPP_PORT=$SPP_PORT"
  
  [[ "$CLUSTER_CIDR" == "" ]] && print_msg "ERROR: No cluster CIDR defined in $BAAS_CONFIG_FILE." && return 40
  print_log "INFO: CLUSTER_CIDR=$CLUSTER_CIDR"
  [[ "$CLUSTER_API_SERVER_IP_ADDRESS" == "" ]] && print_msg "ERROR: No cluster API server ip address defined in $BAAS_CONFIG_FILE." && return 40
  print_log "INFO: CLUSTER_API_SERVER_IP_ADDRESS=$CLUSTER_API_SERVER_IP_ADDRESS"
  [[ "$CLUSTER_API_SERVER_PORT" == "" ]] && print_msg "ERROR: No cluster API server port defined in $BAAS_CONFIG_FILE." && return 40
  [[ "$CLUSTER_API_SERVER_PORT" -lt "1" ]] && print_msg "ERROR: cluster API server port is less than 1 in $BAAS_CONFIG_FILE." && return 35 
  [[ "$CLUSTER_API_SERVER_PORT" -gt "4294967295" ]] && print_msg "ERROR: cluster API server port is greater than 4,294,967,295 in $BAAS_CONFIG_FILE." && return 35 
  print_log "INFO: CLUSTER_API_SERVER_PORT=$CLUSTER_API_SERVER_PORT"


  if [[ "$SPP_AGENT_SERVICE_NODEPORT" == "" ]]
  then
     print_log "INFO: SPP_AGENT_SERVICE_NODEPORT is not specified in $BAAS_CONFIG_FILE. A random nodePort will be assigned."
  else
     [[ "$SPP_AGENT_SERVICE_NODEPORT" -lt "1" ]] && print_msg "ERROR: spp agent service nodePort is less than 1 in $BAAS_CONFIG_FILE." && return 35 
     [[ "$SPP_AGENT_SERVICE_NODEPORT" -gt "4294967295" ]] && print_msg "ERROR: spp agent service nodePort is greater than 4294967295 in $BAAS_CONFIG_FILE." && return 35 
     print_log "INFO: SPP_AGENT_SERVICE_NODEPORT=$SPP_AGENT_SERVICE_NODEPORT"
  fi


  [[ "$PRODUCT_NAMESPACE" == "" ]] && print_msg "ERROR: No target namespace (e.g. baas) for the product deployment defined in $BAAS_CONFIG_FILE." && return 70
  print_log "INFO: PRODUCT_NAMESPACE=$PRODUCT_NAMESPACE"

  [[ "$PRODUCT_IMAGE_REGISTRY" == "" ]] && print_msg "ERROR: No image registry defined in $BAAS_CONFIG_FILE." && return 80
  print_log "INFO: PRODUCT_IMAGE_REGISTRY=$PRODUCT_IMAGE_REGISTRY"
  [[ "$PRODUCT_IMAGE_REGISTRY_NAMESPACE" == "" ]] && print_msg "WARNING: No registry namespace defined in $BAAS_CONFIG_FILE. Assuming a local cluster image registry. The product's deployment namespace will be used."
  print_log "INFO: PRODUCT_IMAGE_REGISTRY_NAMESPACE=$PRODUCT_IMAGE_REGISTRY_NAMESPACE"
  if [[ "$PRODUCT_IMAGE_REGISTRY_NAMESPACE" == ""  ]]
  then
    PRODUCT_IMAGE_REGISTRY_NAMESPACE=$PRODUCT_NAMESPACE
  fi
  [[ "$PRODUCT_IMAGE_REGISTRY_SECRET_NAME" == "" ]] && print_msg "WARNING: No secret name for imagePullSecret for image registry provided in $BAAS_CONFIG_FILE. May not be required for local cluster registry."
  print_log "INFO: PRODUCT_IMAGE_REGISTRY_SECRET_NAME=$PRODUCT_IMAGE_REGISTRY_SECRET_NAME"

  [[ "$CLUSTER_NAME" == "" ]] && print_msg "ERROR: No cluster Name defined in $BAAS_CONFIG_FILE." && return 40
  print_log "INFO: CLUSTER_NAME=$CLUSTER_NAME"

  # LOCALIZATION options are: 
  # en_US (English USA), cs_CZ (Czech Czech Republic), de_DE (German Germany), es_ES (Spanish Spain), 
  # fr_FR (French France), hu_HU (Hungarian Hungary), it_IT (Italian Italy), ja_JP (Japanese Japan), 
  # pl_PL (Polish Poland), pt_BR (Portuguese Brazil), ru_RU (Russian Russia), zh_CN (Chinese Simplified China), zh_TW (Chinese Traditional Taiwan)
  case "$PRODUCT_LOCALIZATION" in
      en_US|cs_CZ|de_DE|es_ES|fr_FR|hu_HU|it_IT|ja_JP|pl_PL|pt_BR|ru_RU|zh_CN|zh_TW)
          print_msg "Using product localization $PRODUCT_LOCALIZATION as defined in $BAAS_CONFIG_FILE for the deployment."
          ;;
      *)
          PRODUCT_LOCALIZATION="en_US"
          print_msg "WARNING: No product localization defined in $BAAS_CONFIG_FILE. Using default localization for en_US (English, USA)."
          ;;
  esac
  print_log "INFO: PRODUCT_LOCALIZATION=$PRODUCT_LOCALIZATION"
  # PRODUCT_LOGLEVEL trace options are: INFO, DEBUG, ERROR
  print_log "INFO: PRODUCT_LOGLEVEL=$PRODUCT_LOGLEVEL"
  PRODUCT_LOGLEVEL=$PRODUCT_LOGLEVEL

  # TARGET CONTAINER ORCHESTRATION PLATFORM:
  # OCP = OpenShift
  # K8S = Generic Kubernetes
  OCP=false
  case "$PRODUCT_TARGET_PLATFORM" in
      OCP|ocp)
          PRODUCT_TARGET_PLATFORM="OCP"
          OCP=true
          BAAS_HELM_CHART="baas-openshift/baas"
          print_msg "Targeting OpenShift ($PRODUCT_TARGET_PLATFORM) as container orchestration platform as defined in $BAAS_CONFIG_FILE for the deployment."
          ;;
      K8S|K8s|k8s)
          PRODUCT_TARGET_PLATFORM="K8S"
          print_msg "Targeting generic Kubernetes ($PRODUCT_TARGET_PLATFORM) as container orchestration platform as defined in $BAAS_CONFIG_FILE for the deployment."
          ;;
      *)
          PRODUCT_TARGET_PLATFORM="K8S"
          print_msg "WARNING: No proper target container orchestration platform type defined (OCP,K8S) in $BAAS_CONFIG_FILE. Using K8S for generic Kubernetes platforms."
          ;;
  esac
  print_log "INFO: PRODUCT_TARGET_PLATFORM=$PRODUCT_TARGET_PLATFORM"
  print_log "INFO: OCP=$OCP"
  
  return 0
}

# Check Docker prerequisites (run AFTER check_helm_prereqs() to set BAAS_VERSION from Helm chart)
function check_docker_prereqs()
{
  # Skip this check if baas_nopush option is selected for using an external image registry with preloaded BaaS images 
  if [[ $baas_nopush == true ]]
  then
     return 0
  fi

  # Check if Docker is running on local system
  print_msg "Checking for Docker running on the local system..."
  if ! docker ps >/dev/null 2>&1
  then
    print_msg "Docker is not installed or not running on this local system. Please start or install Docker."
    return 1
  fi

  # Check if BaaS Docker image file is present
  BAAS_DOCKER_LOAD_IMAGEFILE="./images/baas-${BAAS_VERSION}.tar.gz"
  [[ ! -f "$BAAS_DOCKER_LOAD_IMAGEFILE" ]] && print_msg "BaaS Docker image file $BAAS_DOCKER_LOAD_IMAGEFILE is not present." && return 5

  return 0  
}

# Check kubectl prerequisites
# -> Sets TGT_CLUSTER
function check_kubectl_prereqs()
{
  # Check if kubectl is available on local system
  print_msg "Checking for kubectl command line tool on local system..."
  if ! which kubectl >>$LOGFILE 2>&1
  then
    print_msg "The kubectl command line tool is either not installed or not in the local path. Please install kubectl or adjust the local path to run the kubectl command line tool."
    return 1
  fi
  if ! kubectl version >>$LOGFILE 2>&1 
  then
    print_msg "Kubectl is not connected to a Kubernetes target cluster. Please configure kubectl, login as cluster-admin to the Kubernetes target cluster and re-run the installation script."
    return 1
  fi
  print_msg "Checking for active connection to target Kubernetes cluster..."
  if ! kubectl get nodes -o wide >>$LOGFILE 2>&1
  then
    print_msg "Kubectl is not connected to a Kubernetes target cluster. Please configure kubectl, login as cluster-admin to the Kubernetes target cluster and re-run the installation script."
    return 2
  else
    [[ "${TGT_CLUSTER}" == "" ]] && TGT_CLUSTER="$(kubectl config current-context)"
    print_msg "Kubectl is connected to the Kubernetes target cluster >>${TGT_CLUSTER}<<."
  fi

  KUBERNETES_VERSION=$(kubectl version | grep 'Client Version' | awk -F\GitVersion: '{print $2}' | awk -F\" '{print $2}' | awk -F\v '{print $2}')
  if [ "$KUBERNETES_VERSION" != "$(printf "$KUBERNETES_VERSION\n$KUBERNETES_MIN_VERSION\n" | sort -gr | head -1 )" ] 
  then
    print_msg "To proceed with the installation, Kubernetes must be at version 1.16 or later. Update Kubernetes and run the installation again."
    return 1
  fi

  return 0  
}

# Check OCP prerequisites
# -> Sets OCP_USER
# -> Sets OCP_USER_TOKEN
# -> Sets TGT_CLUSTER
function check_oc_prereqs()
{
  # Check if oc is available on local system
  print_msg "Checking for oc command line tool on local system..."
  if ! which oc >>$LOGFILE 2>&1
  then
    print_msg "The oc command line tool is either not installed or not in the local path. Please install oc or adjust the local path to run the oc command line tool."
    return 1
  fi
  if ! oc version >>$LOGFILE 2>&1 
  then
    print_msg "WARNING: The oc version command returned a non-zero return code. Are we properly logged in and do we have an active connection to an OpenShift cluster?"
  fi
  # Check if we are actively logged in to an OpenShift / RHEL OCP target system
  print_msg "Checking for active connection to target OpenShift cluster..."
  if OCP_USER="$(oc whoami)" 
  then
    print_log "Logged into an OpenShift cluster as $OCP_USER"
  else
    print_msg "You do not seem to be logged in to an OpenShift cluster. Please log in with a regular cluster-admin account (oc login)."
    return 1
  fi
  if ! OCP_USER_TOKEN="$(oc whoami -t)"
  then
    print_log "WARNING: An account token for user $OCP_USER could not be retrieved (e.g. when running as system:admin). In this case the admin needs to have logged in to the cluster image registry manually (e.g. docker login)."
  fi
  #if [[ $OCP_USER != "system:admin" ]] 
  #then
  #  print_msg "Logged in as $OCP_USER. Please log in as system:admin user with >>oc login -u system:admin<< on the OCP master node and re-run the installation script."
  #  return 1
  #fi
  if ! oc get nodes -o wide >>$LOGFILE 2>&1
  then
    print_msg "The OpenShift (oc) command line tools does not seem to be connected to an actual OpenShift target cluster. Please login to an OpenShift target cluster as cluster-admin and re-run the installation script."
    return 2
  else
    [[ "${TGT_CLUSTER}" == "" ]] && TGT_CLUSTER="$(oc status | head -1 | awk '{print $NF}')"
    print_msg "Connected as >>${OCP_USER}<< to the OpenShift target cluster >>${TGT_CLUSTER}<<."
  fi

  return 0  
}

# Check helm prerequisites
# -> Sets HELM_TLS option for helm commands
function check_helm_prereqs()
{
  # Check if helm command is available on local system
  print_msg "Checking for helm client availability on local system..."
  if ! which helm >>$LOGFILE 2>&1
  then
    print_msg "The helm client is either not installed or not in the local path. Please install helm or adjust the local path to run the helm client command."
    return 1
  fi

  # Check if helm is initialized on local system
  print_msg "Checking for proper initialization of helm client/server on local system..."
  if ! helm version >>$LOGFILE 2>&1 && ! helm version --tls >>$LOGFILE 2>&1
  then 
    print_msg "Helm is not properly initialized on this local system. Please properly initialize the helm client/server framework."
    return 1
  fi
 
  # Check if helm requires --tls option for Cloud Native edition
  if ! helm version >/dev/null 2>&1 
  then
      HELM_TLS="--tls"
  fi

  HELM_VERSION_C=$(helm version | grep 'Client' | awk -F\{ '{print $2}' | awk -F\SemVer: '{print $2}' | awk -F\" '{print $2}' | awk -F\v '{print $2}')
  HELM_VERSION_S=$(helm version | grep 'Server' | awk -F\{ '{print $2}' | awk -F\SemVer: '{print $2}' | awk -F\" '{print $2}' | awk -F\v '{print $2}')

  # Need to ensure that the 'Client' and 'Server' parts of the Helm are at the same version, before proceeding
  [[ "$HELM_VERSION_C" != "$HELM_VERSION_S" ]] && print_msg "There is a Helm version mismatch between the 'Client' and 'Server' parts. Please update before proceeding with the install again." && return 1

  # Need to ensure that when Kubernetes version is greater than 1.16, then Helm version has to be at least 2.16.1 or greater.
  # If that is not the case, we should report an error and exit the installation.

  # Use the sort command to find out if the right versions are installed on the system.
  if [ "$KUBERNETES_VERSION" = "$(printf "$KUBERNETES_VERSION\n$KUBERNETES_MIN_VERSION\n" | sort -gr | head -1 )" ] 
  then
   # Need to ensure that in the case there is no double digit after first decimal point, to add a 0 in front of the number.
   # Example: Helm version = 2.9.1 - this will be changed to 2.09.1 to ensure that sorting is done accurately.
   temp="$(echo $HELM_VERSION_C | cut -d'.' -f2)"
   length=${#temp}
   if [ $length == 1 ]
   then
      HELM_VERSION_C="${HELM_VERSION_C:0:2}0${HELM_VERSION_C:2}"
   fi
   if [ "$HELM_VERSION_C" = "$(printf "$HELM_VERSION_C\n$HELM_MIN_VERSION\n" | sort -g | head -1 )" ] || [ "$HELM_VERSION_C" = "$(printf "$HELM_VERSION_C\n$HELM_MAX_VERSION\n" | sort -gr | head -1 )" ]
      then
        print_msg "To proceed with the installation in the Kubernetes 1.16 environment, Helm must be at version 2.16.1 or later but cannot be at version 3.x. Update Helm and run the installation again."
        return 1
   fi
  fi

  return 0
}

# Check helm chart prerequisites
# -> Sets BAAS_VERSION to baas Helm chart version as found in baas/Chart.yaml
function check_helm_chart_prereqs()
{
  # Check if helm chart is present
  [[ ! -e "$BAAS_HELM_CHART" ]] && print_msg "BaaS Helm chart is missing in local directory at ${BAAS_HELM_CHART}" && return 5

  # Get Helm chart version
  BAAS_VERSION=$(cat ${BAAS_HELM_CHART}/Chart.yaml | grep "^appVersion:" | awk '{print $2}')
  [[ $? -ne 0 ]] && print_msg "Could not determine BaaS Helm chart version." && return 10
  print_msg "Found BaaS version $BAAS_VERSION of Helm chart $BAAS_HELM_CHART"

  return 0
}

# If LICENSE field is not set to ACCEPTED in baas_config.cfg, prompt for license check at install tim
# and allow customer to accept otherwise installation will stop.
function prompt_license_check()
{
  # Request BAAS_ADMIN password (so it is not in clear text in the baas_config.cfg file)
  # Three failed attempts to enter the password will abort script execution
  if [[ $LICENSE == "NOTACCEPTED" ]]
  then 
    if ! request_input "LICENSE" "Please review the license located at licenses/LICENSE-en (versions are available in other languages at http://www-03.ibm.com/software/sla/sladb.nsf/searchlis/?searchview&searchorder=4&searchmax=0&query=(Spectrum+Protect+Plus)) and enter \"ACCEPTED\" to continue the installation: "
    then
      err_exit "The product license was not accepted. The installation cannot continue."
    fi
    LICENSE="$MYANSWER"
    
    [[ $LICENSE != "ACCEPTED" ]] && print_msg "ERROR: LICENSE was not accepted." && return 10

    # Need to update LICENSE field in baas_config.cfg
    sed -i 's/\(LICENSE\=\).*/\1"'ACCEPTED'"/' ${BAAS_CONFIG_FILE}

    print_log "INFO: LICENSE=$LICENSE (from user input)"
  fi

  return 0
}

# Load and push BaaS Docker images
# Uses OCP=true/false to attempt docker login as fallback if initial push fails 
function load_push_images()
{
  # Skip this step if baas_nopush option is selected for using an external image registry with preloaded BaaS images 
  if [[ $baas_nopush == true ]]
  then
    print_msg "Using image registry >>${PRODUCT_IMAGE_REGISTRY}/${PRODUCT_IMAGE_REGISTRY_NAMESPACE}<<"
    [[ "$PRODUCT_IMAGE_REGISTRY_SECRET_NAME" != "" ]] && print_msg "Using imagePullSecret as provided in >>${PRODUCT_IMAGE_REGISTRY_SECRET_NAME}<<" || print_msg "No imagePullSecret provided in >>${BAAS_CONFIG_FILE}<<"
    return 0
  fi

  # Preload packaged Docker images (no download from the internet necessary)
  print_msg "Loading Docker images from ${BAAS_DOCKER_LOAD_IMAGEFILE} into local Docker image repository..."
  if ! docker load --input $BAAS_DOCKER_LOAD_IMAGEFILE
  then
    print_msg "Could not successfully load Docker images from ${BAAS_DOCKER_LOAD_IMAGEFILE} into local Docker image repository!"
    return 1
  fi 

  # Push docker images to remote image registry
  print_msg "Pushing Docker images to image registry at ${PRODUCT_IMAGE_REGISTRY}..."
  for image in $BAAS_IMAGES
  do 
    if ! docker tag baas-${image}:${BAAS_VERSION} ${PRODUCT_IMAGE_REGISTRY}/${PRODUCT_IMAGE_REGISTRY_NAMESPACE}/baas-${image}:${BAAS_VERSION}
    then
      print_msg "Could not tag Docker image ${PRODUCT_IMAGE_REGISTRY}/${PRODUCT_IMAGE_REGISTRY_NAMESPACE}/baas-${image}:${BAAS_VERSION}."
      return 2
    fi
    if ! docker push ${PRODUCT_IMAGE_REGISTRY}/${PRODUCT_IMAGE_REGISTRY_NAMESPACE}/baas-${image}:${BAAS_VERSION}
    then
      if [[ $OCP == true  ]]
      then
        # OCP: If docker push fails try to do a proper docker login on OCP first if we have a token (provided we're not the system:admin account) and run on the installation master node
        if [[ "$OCP_USER_TOKEN" != "" ]]
        then
          print_msg "Trying to login to image registry at ${PRODUCT_IMAGE_REGISTRY}..."
          if docker login -u anyuser -p "${OCP_USER_TOKEN}" ${PRODUCT_IMAGE_REGISTRY} >>$LOGFILE 2>&1
          then
            if ! docker push ${PRODUCT_IMAGE_REGISTRY}/${PRODUCT_IMAGE_REGISTRY_NAMESPACE}/baas-${image}:${BAAS_VERSION}
            then 
              print_msg "Could not push the image ${PRODUCT_IMAGE_REGISTRY}/${PRODUCT_IMAGE_REGISTRY_NAMESPACE}/baas-${image}:${BAAS_VERSION} to the cluster image registry at ${PRODUCT_IMAGE_REGISTRY} as user $OCP_USER. Please manually login to the cluster image registry with # docker login ${PRODUCT_IMAGE_REGISTRY} using a regular cluster-admin account before starting the installation!"
              return 4
            fi
          else
            print_msg "Could not perform a docker login for user $OCP_USER to the cluster image registry at ${PRODUCT_IMAGE_REGISTRY_NAMESPACE}. Please manually login to the cluster image registry with # docker login ${PRODUCT_IMAGE_REGISTRY} using a regular cluster-admin account before starting the installation!"
            return 5
          fi
        else
          print_msg "The current cluster user account $OCP_USER does not provide a token to automatically login to the cluster image registry. Please manually login to the cluster image registry with # docker login ${PRODUCT_IMAGE_REGISTRY} using a regular cluster-admin account before starting the installation!"
          return 6
        fi
      else
        # K8s: If docker push fails try to do a proper docker login on K8s first if we run on the installation master node or have proper certificates setup
        print_msg "Trying to login to image registry at ${PRODUCT_IMAGE_REGISTRY}..."
        if docker login ${PRODUCT_IMAGE_REGISTRY} >>$LOGFILE 2>&1
        then
          if ! docker push ${PRODUCT_IMAGE_REGISTRY}/${PRODUCT_IMAGE_REGISTRY_NAMESPACE}/baas-${image}:${BAAS_VERSION}
          then 
            print_msg "Could not push the image ${PRODUCT_IMAGE_REGISTRY}/${PRODUCT_IMAGE_REGISTRY_NAMESPACE}/baas-${image}:${BAAS_VERSION} to the cluster image registry at ${PRODUCT_IMAGE_REGISTRY}. Please manually login to the cluster image registry with # docker login ${PRODUCT_IMAGE_REGISTRY} before starting the installation!"
            return 4
          fi
        else
          print_msg "Could not perform a docker login for user to the cluster image registry at ${PRODUCT_IMAGE_REGISTRY}. Please manually login to the cluster image registry with # docker login ${PRODUCT_IMAGE_REGISTRY} before starting the installation!"
          return 5
        fi
      fi
    else
      print_msg "Finished pushing docker images to image registry at ${PRODUCT_IMAGE_REGISTRY}."
    fi
  done
  
  return 0
}

# Prompt for a PASSWORD and return password in MYANSWER (so it is not entered in clear text in the baas_config.cfg file)
function get_password()
{
  CNT=0; MAXCNT=3
  MYANSWER=""; MYANSWER1=""; MYANSWER2="";
  while [ $CNT -lt $MAXCNT ]
  do
    print_msg "Requesting password for $1 ACCOUNT ($2)... Hit return without any input to abort."
    echo
    echo "------------------------[$1 PASSWORD REQUIRED]------------------------"
    read -s -p "Please enter the $2 ACCOUNT PASSWORD:  "  MYANSWER1
    echo
    read -s -p "Please repeat the $2 ACCOUNT PASSWORD: "  MYANSWER2
    echo
    echo "-----------------------------------------------------------------------"
    echo
    if [[ "$MYANSWER1" == "$MYANSWER2" ]] && [[ "$MYANSWER1" != "" ]] 
    then
      MYANSWER="$MYANSWER1"
      return 0
    elif [[ "$MYANSWER1" == "$MYANSWER2" ]] && [[ "$MYANSWER1" == "" ]]
    then
      MYANSWER=""
      print_msg "An empty password was entered. Password input for the $1 account ($2) aborted by user." 
      return 1
    else
      let CNT=CNT+1
    fi
  done
  MYANSWER=""
  print_msg "$CNT failed attempts to specify a password for the $1 account ($2)." 
  
  return 5 
}

# Prompt for a PRODUCT_NAMESPACE and return it in MYANSWER (so we do not rely on baas_config.cfg for debug log collection)
function request_input()
{
  MYANSWER=""; MYANSWER1="";
  print_msg "Requesting $1 for log collection... Hit return without any input to abort."
  echo
  echo "-------------------------[USER INPUT REQUIRED]-------------------------"
  read -r -p "$2"  MYANSWER1
  echo "-----------------------------------------------------------------------"
  echo
  if [[ "$MYANSWER1" == "" ]]
  then
    MYANSWER=""
    return 1
  fi
  MYANSWER="$MYANSWER1"
  
  return 0 
}

# Retrieve BAAS_ADMIN account name from baas-secret to collect logs from SPP
function get_adm_account_from_secret()
{
  # Extract BAAS_ADMIN account name from baas-secret
  BAAS_ADMIN=""
  if kubectl get secret ${BAAS_SECRET_NAME} -n ${PRODUCT_NAMESPACE} -o yaml >/dev/null 2>&1
  then
    BAAS_ADMIN="$(kubectl get secret ${BAAS_SECRET_NAME} -n ${PRODUCT_NAMESPACE} -o yaml | grep 'baasadmin:' | awk '{print $2}' | base64 -d)"
    print_log "INFO: BAAS_ADMIN=$BAAS_ADMIN (retrieved from ${BAAS_SECRET_NAME})"
  else
    print_msg "Unable to obtain BAAS_ADMIN from ${BAAS_SECRET_NAME}"
    return 1
  fi
  
  return 0    
}

# Retrieve baasadmin password from baas-secret to collect logs from SPP
function get_adm_password_from_secret()
{
  # Extract BAAS_ADMIN credentials from baas-secret
  BAAS_PASSWORD=""
  if kubectl get secret ${BAAS_SECRET_NAME} -n ${PRODUCT_NAMESPACE} -o yaml >/dev/null 2>&1
  then
    BAAS_PASSWORD="$(kubectl get secret ${BAAS_SECRET_NAME} -n ${PRODUCT_NAMESPACE} -o yaml | grep 'baaspassword:' | awk '{print $2}' | base64 -d)"
    print_log "INFO: BAAS_PASSWORD=[hidden] (retrieved from ${BAAS_SECRET_NAME})"
  else
    if ! get_password "BAAS ADMIN" "$BAAS_ADMIN"
    then
      return 1
    else
      BAAS_PASSWORD="$MYANSWER"
      print_log "INFO: BAAS_PASSWORD=[hidden] (retrieved from user input)"
    fi
  fi
  
  return 0    
}

# Retrieve list of SPP IP addresses from baas-configmap to collect logs from SPP
function get_spp_addresses_from_cfgmap()
{
  # Extract SPP IP addresses from baas-configmap
  SPP_IP_ADDRESSES=""
  if kubectl get configmap ${BAAS_CFGMAP_NAME} -n ${PRODUCT_NAMESPACE} -o yaml >/dev/null 2>&1
  then
    SPP_IP_ADDRESSES="$(kubectl get configmap ${BAAS_CFGMAP_NAME} -n ${PRODUCT_NAMESPACE} -o yaml | grep 'SPPips:' | awk '{print $2}')"
    print_log "INFO: SPP_IP_ADDRESSES=$SPP_IP_ADDRESSES (retrieved from $BAAS_CFGMAP_NAME)"
  else
    if ! request_input "SPP IP ADDRESSES" "Please specify SPP IP addresses (as comma separated list, no spaces): "
    then
      return 1
    else
      SPP_IP_ADDRESSES="$MYANSWER"
      print_log "INFO: SPP_IP_ADDRESSES=$SPP_IP_ADDRESSES (retrieved from user input)"
    fi
  fi
    
  return 0    
}

# Retrieve list of SPP PORT from baas-configmap to collect logs from SPP
function get_spp_port_from_cfgmap()
{
  # Extract SPP IP addresses from baas-configmap
  SPP_PORT=""
  if kubectl get configmap ${BAAS_CFGMAP_NAME} -n ${PRODUCT_NAMESPACE} -o yaml >/dev/null 2>&1
  then
    SPP_PORT="$(kubectl get configmap ${BAAS_CFGMAP_NAME} -n ${PRODUCT_NAMESPACE} -o yaml | grep 'SPPport:' | awk '{print $2}')"
    # Remove surrounding quotation marks if present (automatically added / not under control, compare SPPips and SPPport)
    SPP_PORT_TEMP="${SPP_PORT%\"}"
    SPP_PORT="${SPP_PORT_TEMP#\"}"
    print_log "INFO: SPP_PORT=$SPP_PORT (retrieved from $BAAS_CFGMAP_NAME)"
  else
    if ! request_input "SPP PORT" "Please specify SPP port (e.g. 443): "
    then
      return 1
    else
      SPP_PORT="$MYANSWER"
      print_log "INFO: SPP_PORT=$SPP_PORT (retrieved from user input)"
    fi
  fi
    
  return 0    
}

# Configure local Helm values override file
function create_helm_values()
{
  # Create local Helm values configuration file
  echo "# BaaS version ${BAAS_VERSION} - Local Helm config" > $BAAS_HELM_OVERRIDE_FILE
  echo "# Created at $(date +%Y-%m-%d.%H:%M:%S)" >> $BAAS_HELM_OVERRIDE_FILE

  # Add config for product license
  echo "License: \"${LICENSE}\"" >> $BAAS_HELM_OVERRIDE_FILE

  # Add access to external components like IBM Spectrum Protect Plus instances
  echo "SPPips: \"${SPP_IP_ADDRESSES}\"" >> $BAAS_HELM_OVERRIDE_FILE
  echo "SPPport: \"${SPP_PORT}\"" >> $BAAS_HELM_OVERRIDE_FILE
   
  # Add config for networkpolicy
  echo "clusterCIDR: \"${CLUSTER_CIDR}\"" >> $BAAS_HELM_OVERRIDE_FILE
  echo "clusterAPIServerips: \"${CLUSTER_API_SERVER_IP_ADDRESS}\"" >> $BAAS_HELM_OVERRIDE_FILE
  echo "clusterAPIServerport: \"${CLUSTER_API_SERVER_PORT}\"" >> $BAAS_HELM_OVERRIDE_FILE
 
  # Add config for spp agent service nodePort
  echo "sppAgentServiceNodePort: \"${SPP_AGENT_SERVICE_NODEPORT}\"" >> $BAAS_HELM_OVERRIDE_FILE

  # Add config for cluster name
  echo "clusterName: \"${CLUSTER_NAME}\"" >> $BAAS_HELM_OVERRIDE_FILE

  # Add product localization (default: en_US)
  echo "productLocale: \"${PRODUCT_LOCALIZATION}\"" >> $BAAS_HELM_OVERRIDE_FILE

  # Add product trace log level (default: INFO)
   echo "productLoglevel: \"${PRODUCT_LOGLEVEL}\"" >> $BAAS_HELM_OVERRIDE_FILE

  # Add target container orchestration plattform customizations (default: K8S)
  if [[ $PRODUCT_TARGET_PLATFORM == "OCP" ]] 
  then    
    echo "isOCP: true"  >> $BAAS_HELM_OVERRIDE_FILE
  else
    echo "isK8S: true" >> $BAAS_HELM_OVERRIDE_FILE    
  fi

  # Add product image registry 
  echo "imageRegistry: \"${PRODUCT_IMAGE_REGISTRY}\"" >> $BAAS_HELM_OVERRIDE_FILE
  echo "imageRegistryNamespace: \"${PRODUCT_IMAGE_REGISTRY_NAMESPACE}\"" >> $BAAS_HELM_OVERRIDE_FILE
  echo "imageRegistrySecret: \"${PRODUCT_IMAGE_REGISTRY_SECRET_NAME}\"" >> $BAAS_HELM_OVERRIDE_FILE

  if [[ $? -ne 0 ]] 
  then 
    print_msg "Error creating Helm values configuration file >>${BAAS_HELM_OVERRIDE_FILE}<<."
    return 1
  else
    print_log "INFO: Created temporary Helm values file >>${BAAS_HELM_OVERRIDE_FILE}<< for Helm chart deployment."
  fi
  
  return 0
}

function verify_baasproduct_deleted()
{
  completed=false 
  # wait 5 minutes to get all pods deleted
  totalseconds=300
  interval=20
  while [[ $completed == false &&  $totalseconds -gt 0   ]]
  do  
    podscount=$(kubectl get pods -l app.kubernetes.io/name=${BAAS_RELEASE_NAME} -n ${PRODUCT_NAMESPACE} --no-headers | wc -l)
    if [ $podscount -eq 0 ]
    then
      completed=true
      return 0
    fi
    sleep $interval
    totalseconds=$((totalseconds-interval))
  done
  
  if [[ $completed == false ]]
  then 
    # If pods are in error state, we need to manually delete them
    result=($(kubectl get pods -l app.kubernetes.io/name=${BAAS_RELEASE_NAME} -n ${PRODUCT_NAMESPACE} --no-headers | awk '{print $1, $3}'))
    [[ -z $result ]] && return 0
     
    i=0
    podName=
    podStatus=
    for item in "${result[@]}"
    do
      if [ $((i%2)) -eq 0 ]
      then
        # even items are column "NAME"
        podName=$item
      else
        # odd items are column "STATUS"
        podStatus=$item
        [[ $podStatus == "Error" ]]  && kubectl delete pod ${podName} -n ${PRODUCT_NAMESPACE} >>$LOGFILE 2>&1
        [[ $podStatus == "Terminating" ]] && kubectl delete pod ${podName} --grace-period=0 --force -n ${PRODUCT_NAMESPACE} >>$LOGFILE 2>&1
     fi
     i=$((i+1))
    done
    
    # Verify once more that allo pods were indeed deleted
    podscount=$(kubectl get pods -l app.kubernetes.io/name=${BAAS_RELEASE_NAME} -n ${PRODUCT_NAMESPACE} --no-headers | wc -l)
    if [ $podscount -eq 0 ]
    then
      return 0
    else
      return 1
    fi
  else
    return 0
  fi
}


# Install all SASE container components
# Requires OCP=true/false to be set accordingly 
function install_sase()
{
  # Create BaaS project (OCP) or namespace (K8s) if it does not exist before uploading images into registry
  if [[ $OCP == true ]]
  then
    # Create new project on OCP for BaaS
    if oc new-project $PRODUCT_NAMESPACE >/dev/null 2>&1
    then
      print_msg "Created new project and namespace >>${PRODUCT_NAMESPACE}<< for product deployment"
    elif oc get project $PRODUCT_NAMESPACE >/dev/null 2>&1
    then
      print_msg "Using existing project and namespace >>${PRODUCT_NAMESPACE}<< for product deployment."
    else
      print_msg "Could not create a new project and namespace >>${PRODUCT_NAMESPACE}<< for product deployment. Please check authorization of the user account."
      return 15
    fi
  else
    # Create new namespace on Kubernetes for BaaS (these steps basically also work on OCP)
    if kubectl create namespace $PRODUCT_NAMESPACE >/dev/null 2>&1
    then
      print_msg "Created namespace >>${PRODUCT_NAMESPACE}<< for product deployment"
    elif kubectl get namespace $PRODUCT_NAMESPACE >/dev/null 2>&1
    then
      print_msg "Using existing namespace >>${PRODUCT_NAMESPACE}<< for product deployment."
    else
      print_msg "Could not create namespace >>${PRODUCT_NAMESPACE}<< for product deployment. Please check authorization of the user account."
      return 20
    fi
  fi
  kubectl label --overwrite namespace ${PRODUCT_NAMESPACE} namespace=baas >/dev/null

  # Check if BaaS deployment already exists
  if helm status ${BAAS_RELEASE_NAME} $HELM_TLS >/dev/null 2>&1
  then
    status=$(helm list baas --output yaml | grep 'Status' | awk '{print $2}')
    [[ $status == "DEPLOYED" ]] && print_msg "The product installation cancelled. Another version of the product is already deployed. Run the install script (baas_isntall.sh) again with the upgrade option (-u)." && print_msg "$(helm history ${BAAS_RELEASE_NAME} $HELM_TLS)"
    [[ $status == "FAILED" ]] && print_msg "The product installation cancelled. A problem occurred while deploying the product. Check the install log, fix the problem, use the uninstall (-d) option before trying another installation."
    return 1  
  fi
  
  # delete old baasreqs.baas.io CRD (10.1.5)
  # old CRD file does not contain validation section 
  if  kubectl get crd $BAASREQ_CRD_NAME >/dev/null 2>&1
  then
    if ! kubectl get crd $BAASREQ_CRD_NAME -o yaml | grep validation >/dev/null 2>&1
    then
	  if ! kubectl delete crd $BAASREQ_CRD_NAME
	  then
	    print_msg "Could not delete crd baasreqs.baas.io. Please delete it manually, then re-run install again. "
		return 1
	  fi
	fi
  fi

  # Load and push Docker images
  if ! load_push_images
  then
    print_msg "Product installation aborted. Could not push Docker images to local cluster registry at ${PRODUCT_IMAGE_REGISTRY}/${PRODUCT_NAMESPACE}."
    return 30      
  fi
 
  # Create Helm values from config file
  if ! create_helm_values
  then
    print_msg "Product installation aborted. Could not create temporary Helm config file >>${BAAS_HELM_OVERRIDE_FILE}<<."
    return 10      
  fi
  
  # Create Helm deployment (using --tls for IBM Cloud Private)
  print_msg "Deploying product release >>${BAAS_RELEASE_NAME}<< version ${BAAS_VERSION} to target cluster >>${TGT_CLUSTER}<<"

  print_log "INFO: Executing command: helm install ${BAAS_HELM_CHART} -f ${BAAS_HELM_OVERRIDE_FILE} -n ${BAAS_RELEASE_NAME} --namespace ${PRODUCT_NAMESPACE} $HELM_TLS"
  if ! helm install $BAAS_HELM_CHART -f ${BAAS_HELM_OVERRIDE_FILE} -n ${BAAS_RELEASE_NAME} --namespace ${PRODUCT_NAMESPACE} $HELM_TLS
  then
    print_msg "Deployment of product release >>${BAAS_RELEASE_NAME}<< version ${BAAS_VERSION} into namespace >>${PRODUCT_NAMESPACE}<< failed."

    # Check if BaaS deployment was successfully created
    if helm status ${BAAS_RELEASE_NAME} $HELM_TLS >/dev/null 2>&1
    then
      status=$(helm list baas --output yaml | grep 'Status' | awk '{print $2}')
      [[ $status == "DEPLOYED" ]] && print_msg "The product installation cancelled. Another version of the product is already deployed. Run the install script (baas_isntall.sh) again with the upgrade option (-u)." && print_msg "$(helm history ${BAAS_RELEASE_NAME} $HELM_TLS)"
      [[ $status == "FAILED" ]] && print_msg "The product installation cancelled. A problem occurred while deploying the product. Check the install log, fix the problem, use the uninstall (-d) option before trying another installation."
    fi

    # Remove temporary Helm chart values override file to leave no file on the system with the BAAS_ADMIN and DATAMOVER_PASSWORD (even if  these are base64 encrypted)
    [[ $DEL_HELM_CONFIG_FILE == true ]] && print_log "INFO: Removing >>${BAAS_HELM_OVERRIDE_FILE}<< file." && ( rm -f ${BAAS_HELM_OVERRIDE_FILE} >/dev/null 2>&1 || print_log "WARNING: Failed to remove >>${BAAS_HELM_OVERRIDE_FILE}<< file." )
    return 40
  fi 

  # Remove temporary Helm chart values override file to leave no file on the system with the BAAS_ADMIN and DATAMOVER_PASSWORD (even if  these are base64 encrypted)
  [[ $DEL_HELM_CONFIG_FILE == true ]] && print_log "INFO: Removing >>${BAAS_HELM_OVERRIDE_FILE}<< file." && ( rm -f ${BAAS_HELM_OVERRIDE_FILE} >/dev/null 2>&1 || print_log "WARNING: Failed to remove >>${BAAS_HELM_OVERRIDE_FILE}<< file." )

  return 0
}

# Deinstall SASE helm depoyment 
function deinstall_sase()
{
  chart_deleted=false

  # Delete Helm deployment (use --tls for IBM Cloud Private - Cloud Native / Enterprise Edition)
   if ! helm status ${BAAS_RELEASE_NAME} $HELM_TLS >/dev/null 2>&1
  then
    print_msg "No product deployment with >>${BAAS_RELEASE_NAME}<< release name found on target cluster >>${TGT_CLUSTER}<<! Was it already deleted?"
    return 0
  fi 
  
  # Retrieve the docker image repository name and its namespace before the helm chart is deleted
  IMG_REG=$(helm get values ${BAAS_RELEASE_NAME} | grep "imageRegistry:" | awk '{print $2}')
  IMG_REG_NS=$(helm get values ${BAAS_RELEASE_NAME} | grep "imageRegistryNamespace:" | awk '{print $2}')
  if [[ $PRODUCT_NAMESPACE == "" ]]
  then
    # Retrieve PRODUCT_NAMESPACE from helm list command
    PRODUCT_NAMESPACE=$(helm list baas --output yaml | grep Namespace | awk '{print $2}')
  fi

  print_msg "Deleting product release >>${BAAS_RELEASE_NAME}<< from target cluster >>${TGT_CLUSTER}<<:"
  print_msg "$(helm list ${BAAS_RELEASE_NAME} $HELM_TLS)"
  if ! helm delete ${BAAS_RELEASE_NAME} --purge $HELM_TLS
  then
    print_msg "Deletion of product deployment with >>${BAAS_RELEASE_NAME}<< release name failed."
    return 5
  fi 

  # Need to check if the ${BAAS_RELEASE_NAME} is deleted before trying to remove the docker images otherwise there is always an error 
  # trying to remove a few images since the helm chart is still not completely removed yet.. 

  print_msg "Wait all ${BAAS_RELEASE_NAME} pods are stopped... "
  if ! verify_baasproduct_deleted
  then
    print_msg "Could not delete baas product in 5 minutes, please check log for detailed information "
    return 3
  fi

  # Delete the ${BAAS_SECRET_NAME}
  print_msg "Deleting the ${BAAS_SECRET_NAME} ..."
  kubectl delete secret ${BAAS_SECRET_NAME} -n ${PRODUCT_NAMESPACE}

  return 0
}

# Show status of SASE helm depoyment 
function status_sase()
{
  # Show status of Helm deployment (use --tls for IBM Cloud Private - Cloud Native / Enterprise Edition)
  print_msg "Status of BaaS Helm deployment at $(date):"

  if helm status ${BAAS_RELEASE_NAME} $HELM_TLS >/dev/null 2>&1
  then
    echo; echo "##### RELEASE HISTORY AND STATUS #####" | tee -a $LOGFILE; echo
    helm list  ${BAAS_RELEASE_NAME} $HELM_TLS   | tee -a $LOGFILE
    echo
    helm history ${BAAS_RELEASE_NAME} $HELM_TLS | tee -a $LOGFILE
    echo; echo "##### CURRENT STATUS #####" | tee -a $LOGFILE; echo
    helm status  ${BAAS_RELEASE_NAME} $HELM_TLS | tee -a $LOGFILE
  else
    print_msg "No BaaS deployment of release ${BAAS_RELEASE_NAME} found. Has the product been deployed properly?"
    return 5
  fi 

  return 0
}

# Upgrade SASE helm deployment 
function upgrade_sase()
{
  # Upgrade Helm deployment (use --tls for IBM Cloud Private - Cloud Native / Enterprise Edition)
  print_msg "Upgrading product release >>${BAAS_RELEASE_NAME}<< to version ${BAAS_VERSION}"
  
  # Check if a BaaS Helm chart is already installed
  if ! helm status ${BAAS_RELEASE_NAME} $HELM_TLS >/dev/null 2>&1
  then
    print_msg "Product upgrade aborted. There is no product release of name ${BAAS_RELEASE_NAME} installed on the cluster to upgrade. Please use option -i to perform a fresh product install first."
    return 1
  else
    echo
    print_msg "### STATE OF PRODUCT RELEASE BEFORE UPGRADE ###\n$(helm list ${BAAS_RELEASE_NAME} $HELM_TLS)"
    echo
    print_msg "### PRODUCT RELEASE HISTORY BEFORE UPGRADE ###\n$(helm history ${BAAS_RELEASE_NAME} $HELM_TLS)"
    # Hide extended product release status from stdout 
    print_log "### EXTENDED STATUS OF PRODUCT RELEASE BEFORE UPGRADE ###\n$(helm status ${BAAS_RELEASE_NAME} $HELM_TLS)" 
    echo
  fi
  
  # delete old baasreqs.baas.io CRD (10.1.5)
  # old CRD file does not contain validation section 
  if  kubectl get crd $BAASREQ_CRD_NAME >/dev/null 2>&1
  then
    if ! kubectl get crd $BAASREQ_CRD_NAME -o yaml | grep validation >/dev/null 2>&1
    then
	  if ! kubectl delete crd $BAASREQ_CRD_NAME
	  then
	    print_msg "Could not delete crd baasreqs.baas.io. Please delete it manually, then re-run install again. "
		return 1
	  fi
	fi
  fi
  
  # Create Helm values from config file
  if ! create_helm_values
  then
    print_msg "Product upgrade aborted. Could not create temporary Helm config file (${BAAS_HELM_OVERRIDE_FILE})."
    return 5      
  fi
  
  # Load and push Docker images
  if ! load_push_images
  then
    print_msg "Product upgrade aborted. Could not push Docker images to cluster image registry at >>${PRODUCT_IMAGE_REGISTRY}/${PRODUCT_NAMESPACE}<<."
    return 10
  fi

  echo
  print_msg "Starting product release upgrade..."
  print_log "INFO: Executing command: helm upgrade ${BAAS_RELEASE_NAME} ${BAAS_HELM_CHART} -f ${BAAS_HELM_OVERRIDE_FILE} --namespace ${PRODUCT_NAMESPACE} $HELM_TLS"
  if ! helm upgrade ${BAAS_RELEASE_NAME} ${BAAS_HELM_CHART} -f ${BAAS_HELM_OVERRIDE_FILE} --namespace ${PRODUCT_NAMESPACE} $HELM_TLS --force | tee -a $LOGFILE
  then
    print_msg "Product upgrade of ${BAAS_RELEASE_NAME} release in namespace ${PRODUCT_NAMESPACE} to version ${BAAS_VERSION} failed."
    # Remove temporary Helm chart values override file to leave no file on the system with the BAAS_ADMIN and DATAMOVER_PASSWORD (even if  these are base64 encrypted)
    [[ $DEL_HELM_CONFIG_FILE == true ]] && print_log "INFO: Removing >>${BAAS_HELM_OVERRIDE_FILE}<< file." && ( rm -f ${BAAS_HELM_OVERRIDE_FILE} >/dev/null 2>&1 || print_log "WARNING: Failed to remove >>${BAAS_HELM_OVERRIDE_FILE}<< file." )
    return 50
  else

    # Delete running pods after upgrade
    if [[ $baas_delete_pods == true ]]
    then
    # delete dm and dm networkpoicy firstly
      ./baas_uninstall_dm.sh
      echo
      print_msg "Resetting containers after upgrade..."
      print_log "INFO: Executing command: kubectl delete pods -l app.kubernetes.io/name=${BAAS_RELEASE_NAME} -n ${PRODUCT_NAMESPACE}"
      #kubectl delete pod $(kubectl get pods -n ${PRODUCT_NAMESPACE} | cut -f 1 -d ' ' | tail -n+2) -n ${PRODUCT_NAMESPACE}
      kubectl delete pods -l app.kubernetes.io/name=${BAAS_RELEASE_NAME} -n ${PRODUCT_NAMESPACE}
      print_msg "Reset of containers completed."
    fi

    print_msg "Upgrade of release ${BAAS_RELEASE_NAME} in namespace ${PRODUCT_NAMESPACE} to version ${BAAS_VERSION} finished."
    echo
    print_msg "### PRODUCT RELEASE HISTORY AFTER UPGRADE ###\n$(helm history ${BAAS_RELEASE_NAME} $HELM_TLS)"
  fi

  # Remove temporary Helm chart values override file to leave no file on the system with the BAAS_ADMIN and DATAMOVER_PASSWORD (even if  these are base64 encrypted)
  [[ $DEL_HELM_CONFIG_FILE == true ]] && print_log "INFO: Removing >>${BAAS_HELM_OVERRIDE_FILE}<< file." && ( rm -f ${BAAS_HELM_OVERRIDE_FILE} >/dev/null 2>&1 || print_log "WARNING: Failed to remove >>${BAAS_HELM_OVERRIDE_FILE}<< file." )

  return 0
}

# Collect debug logs from all SASE components on cluster
# Requires kubectl and helm and PRODUCT_NAMESPACE (from baas_config.cfg)
function collect_logs_sase()
{
  print_msg "Collecting information and logs from SASE components..."
  
  # Collect helm information
  helm status ${BAAS_RELEASE_NAME} $HELM_TLS  >"${DEBUG_LOG_ARCHIVE}/helm-status.out"
  helm history ${BAAS_RELEASE_NAME} $HELM_TLS >"${DEBUG_LOG_ARCHIVE}/helm-history.out"

  # Overview of all resources from namespace 
  kubectl get all -n ${PRODUCT_NAMESPACE} -o wide >"${DEBUG_LOG_ARCHIVE}/kubectl-baas-all.out" 2>/dev/null
    
  # Collect deployment information
  print_msg "Collecting BaaS deployment information..."
  kubectl get deployment -n ${PRODUCT_NAMESPACE} -o wide >"${DEBUG_LOG_ARCHIVE}/kubectl-deploy.out"
  kubectl get deployment -n ${PRODUCT_NAMESPACE} | grep -v '^NAME' | while read deploy nothing
  do
    kubectl get deployment ${deploy} -n ${PRODUCT_NAMESPACE} -o wide  >"${DEBUG_LOG_ARCHIVE}/kubectl-${deploy}.out"
    echo "- - - "                                                     >>"${DEBUG_LOG_ARCHIVE}/kubectl-${deploy}.out"
    kubectl get deployment ${deploy} -n ${PRODUCT_NAMESPACE} -o yaml >>"${DEBUG_LOG_ARCHIVE}/kubectl-${deploy}.out"
    echo "- - - "                                                     >>"${DEBUG_LOG_ARCHIVE}/kubectl-${deploy}.out"
    kubectl describe deployment ${deploy} -n ${PRODUCT_NAMESPACE}    >>"${DEBUG_LOG_ARCHIVE}/kubectl-${deploy}.out"
  done
  
  # Collect pod information and container logs
  print_msg "Collecting BaaS pod information..."
  kubectl get pods -n ${PRODUCT_NAMESPACE} -o wide >"${DEBUG_LOG_ARCHIVE}/kubectl-pods.out"
  kubectl get pods -n ${PRODUCT_NAMESPACE} | grep -v '^NAME' | while read pod nothing
  do
    kubectl get pod ${pod} -n ${PRODUCT_NAMESPACE} -o wide  >"${DEBUG_LOG_ARCHIVE}/kubectl-${pod}.out"
    echo "- - - "                                           >>"${DEBUG_LOG_ARCHIVE}/kubectl-${pod}.out"
    kubectl get pod ${pod} -n ${PRODUCT_NAMESPACE} -o yaml >>"${DEBUG_LOG_ARCHIVE}/kubectl-${pod}.out"
    echo "- - - "                                           >>"${DEBUG_LOG_ARCHIVE}/kubectl-${pod}.out"
    kubectl describe pod ${pod} -n ${PRODUCT_NAMESPACE}    >>"${DEBUG_LOG_ARCHIVE}/kubectl-${pod}.out"
    for container in $(kubectl get pod ${pod} -o jsonpath='{.spec.containers[*].name}' -n baas)
    do
      print_msg "Collecting ${container} logs..."
      kubectl logs ${pod} -c ${container} -n ${PRODUCT_NAMESPACE}               >"${DEBUG_LOG_ARCHIVE}/kubectl-${pod}-${container}.log" 2>&1 \
      && kubectl logs ${pod} -c ${container} -n ${PRODUCT_NAMESPACE} --previous >"${DEBUG_LOG_ARCHIVE}/kubectl-${pod}-${container}-prev.log" 2>&1
    done
  done
  
  # Collect other Kubernetes resource information in namespace
  for resource in service secret configmap serviceaccount networkpolicy
  do
    print_msg "Collecting BaaS ${resource} information..."
    kubectl get ${resource} -n ${PRODUCT_NAMESPACE} >"${DEBUG_LOG_ARCHIVE}/kubectl-${resource}.out"
    kubectl get ${resource} -n ${PRODUCT_NAMESPACE} | grep -v '^NAME' | while read object nothing
    do
      kubectl get ${resource} ${object} -n ${PRODUCT_NAMESPACE}          >"${DEBUG_LOG_ARCHIVE}/kubectl-${resource}-${object}.out"
      echo "- - - "                                                      >>"${DEBUG_LOG_ARCHIVE}/kubectl-${resource}-${object}.out"
      kubectl get ${resource} ${object} -n ${PRODUCT_NAMESPACE} -o yaml >>"${DEBUG_LOG_ARCHIVE}/kubectl-${resource}-${object}.out"
      echo "- - - "                                                      >>"${DEBUG_LOG_ARCHIVE}/kubectl-${resource}-${object}.out"
      kubectl describe ${resource} ${object} -n ${PRODUCT_NAMESPACE}    >>"${DEBUG_LOG_ARCHIVE}/kubectl-${resource}-${object}.out"
    done
  done
    
  # Collect controller clusterrolebinding information
  print_msg "Collecting BaaS clusterrolebinding information..."
  kubectl get clusterrolebinding ${BAAS_RELEASE_NAME}-controller -n ${PRODUCT_NAMESPACE}          >"${DEBUG_LOG_ARCHIVE}/kubectl-clusterrolebinding-ctl.out"
  echo "- - - "                                                                                   >>"${DEBUG_LOG_ARCHIVE}/kubectl-clusterrolebinding-ctl.out"
  kubectl get clusterrolebinding ${BAAS_RELEASE_NAME}-controller -n ${PRODUCT_NAMESPACE} -o yaml >>"${DEBUG_LOG_ARCHIVE}/kubectl-clusterrolebinding-ctl.out"
  echo "- - - "                                                                                   >>"${DEBUG_LOG_ARCHIVE}/kubectl-clusterrolebinding-ctl.out"
  kubectl describe clusterrolebinding ${BAAS_RELEASE_NAME}-controller -n ${PRODUCT_NAMESPACE}    >>"${DEBUG_LOG_ARCHIVE}/kubectl-clusterrolebinding-ctl.out"

  print_msg "Finished collecting information and logs from SASE components..."

  return 0
}

# Collect debug logs from SPP server(s)
# Requires Python3 helper script (BAAS_AUX_LOGCOLLECT) and SPP_IP_ADDRESSES & SPP_PORT
function collect_logs_spp()
{
  IFSOLD="$IFS"
  IFS=","
  for ipaddr in $SPP_IP_ADDRESSES
  do
    print_msg "Start downloading logs from SPP at IP address ${ipaddr}:${SPP_PORT} to ${DEBUG_LOG_ARCHIVE}/spp-${ipaddr}.zip at $(date):"
    print_LOG "INFO: Executing external command python3 $BAAS_AUX_LOGCOLLECT ${ipaddr} $BAAS_ADMIN [password hidden] ${DEBUG_LOG_ARCHIVE}/spp-${ipaddr}.zip" 
    if ! python3 $BAAS_AUX_LOGCOLLECT "${ipaddr}" "$BAAS_ADMIN" "$BAAS_PASSWORD" "${DEBUG_LOG_ARCHIVE}/spp-${ipaddr}.zip" >>$LOGFILE 2>&1
    then
      # SPP debug log collection script waits for 3 minutes until it fails when no SPP responds 
      print_msg "Download of logs from SPP at IP address ${ipaddr} to ${DEBUG_LOG_ARCHIVE}/spp-${ipaddr}.zip failed. Please check network connectivity or if SPP is up."
      IFS="$IFSOLD"
      return 1
    fi
  done
  IFS="$IFSOLD"

  return 0
}

function get_confirmation()
{
  # Request confirmation that we are targeting the right Kubernetes cluster before moving on 
  if [[ $baas_skip_confirmation == false ]]
  then
    echo "------------------------[CONFIRMATION REQUIRED]------------------------"
    print_msg "$@"
    MYANSWER=""
    read -p "Please enter 'yes' to continue (all other input aborts script execution): " MYANSWER
    echo "-----------------------------------------------------------------------"
    if [[ "$MYANSWER" != "yes" ]]
    then
      return 1
    fi
  fi
  
  return 0
}

function show_installationprogress()
{
  # pods array
  declare -a components
  # pods status array
  declare -a status
  # not running pods array
  declare -a incompletes
  completed=false
  returnvalue=0
  # wait 5 minutes to get all pods start
  totalseconds=300
  interval=10
  result=($(kubectl get pods -l app.kubernetes.io/name=${BAAS_RELEASE_NAME} -n ${PRODUCT_NAMESPACE} --no-headers | awk '{print $1, $3}'))

  [[ -z $result ]] && print_msg "Installation failed because no pods were found. For more information, refer to the installation log." && return 1

  print_msg "-----------------------------------------------------------------------"
  print_msg "waiting... 5:00 minutes"
  while [[ $completed == false ]]
  do
    i=0
    components=()
    status=()
    incompletes=()
    for item in "${result[@]}"
    do
      if [ $((i%2)) -eq 0 ]
      then
        # even items are column "NAME"
        components[$((i/2))]=$item
      else
        # odd items are column "STATUS"
        status[$((i/2))]=$item
     fi
     i=$((i+1))
    done

    i=0
    j=0
	# get all pods which is not Running status and stored in incompletes array
    for containerstatus in "${status[@]}"
    do 
      if [[ $containerstatus == "Running" ]] || [[ $containerstatus == "Completed" ]]
      then
        print_msg "Pod ${components[i]} started."
      else
        incompletes[$((j))]=${components[$((i))]}
        j=$((j+1))
      fi
      i=$((i+1))
    done

    if [ ${#incompletes[@]} -gt 0 ]
    then
    # check the status for not Running pods after 10 seconds
      pods=""
      incompletesnumber=0
      for container in "${incompletes[@]}"
      do 
        pods="$pods $container "
        print_msg "Waiting for pod $container to start."
        incompletesnumber=$((incompletesnumber+1))
      done
      
      totalseconds=$((totalseconds-interval))
      remainminute=$((totalseconds/60))
      remainsecond=$((totalseconds%60))
      sleep $interval
      print_msg "-----------------------------------------------------------------------"
      second=$(printf "%02d" $remainsecond)
      print_msg "waiting... $remainminute:$second minutes"
      result=($(kubectl get pods  $pods  -n ${PRODUCT_NAMESPACE} --no-headers | awk '{print $1, $3}'))
      #kubectl get pods  $pods  -n baas --no-headers
      if [ $totalseconds -le 0 ]
      then
        print_msg "Not all Pods in baas namespace are in Running status in 5 minutes. Check the status with one of the following commands:"
        print_msg "helm status ${BAAS_RELEASE_NAME} $HELM_TLS"
        print_msg "or"
        print_msg "${THIS_SCRIPT} -s"
        print_msg "or"
        print_msg "kubectl get all -n ${PRODUCT_NAMESPACE}"
        if [ $incompletesnumber -le 1 ]
        then
          print_msg "The pod: $pods is not in Running status"
        else
          print_msg "The pods: $pods are not in Running status"
        fi
        completed=true
        returnvalue=1
      fi
    else
      # all pods are running
      print_msg "-----------------------------------------------------------------------"
      print_msg "kubectl get pods -l app.kubernetes.io/name=${BAAS_RELEASE_NAME} -n ${PRODUCT_NAMESPACE}"
      kubectl get pods -l app.kubernetes.io/name=${BAAS_RELEASE_NAME} -n ${PRODUCT_NAMESPACE}
      print_msg "-----------------------------------------------------------------------"
      print_msg "All pods are running."
      sleep 30
      if  helm status ${BAAS_RELEASE_NAME} $HELM_TLS | grep 'MISSING\|Missing\|ERROR\|Error\|CrashLoopBackOff\|no matching container' >/dev/null 2>&1
      then
        print_msg "Not all resources are installed successfully. Please check the following result."
        print_msg "-----------------------------------------------------------------------"
        print_msg "helm status ${BAAS_RELEASE_NAME} $HELM_TLS | grep 'MISSING\|Missing\|ERROR\|Error\|CrashLoopBackOff\|no matching container'"
        helm status ${BAAS_RELEASE_NAME} $HELM_TLS | grep 'MISSING\|Missing\|ERROR\|Error\|CrashLoopBackOff\|no matching container'
        print_msg "-----------------------------------------------------------------------"
        returnvalue=1
      else
        print_msg "All resources are installed successfully."
        print_msg "Installation is completed."
      fi    
      completed=true
    fi
  done
  return $returnvalue
}

function check_ports_values_yaml()
{
   print_msg "Validating port values in ${BAAS_HELM_CHART}/values.yaml"

   awk '
        BEGIN {
            goodCount=0;
            badCount=0;
        } 
        {
           if ((substr($1,1,1) !~ /#/) &&
               ((tolower($1)) ~ /port:/))
              {  
                s=$2; 
                gsub(/"/,"",s); 
                s=s+0; 
                if (s >=1 && s <= 4294967295)
                   {
                      goodCount += 1;
                   }
                else
                   {
                      badCount += 1;
                      if (s < 1)
                         {
                            print "ERROR: " $1 " is less than 1 in values.yaml"
                         }
                      else
                         {                                                 
                            print "ERROR: " $1 " is greater than 4,294,967,295 in values.yaml"
                         }
                   }
              }
         }
         END {
             if (badCount > 0)
               {
                  exit badCount;
               }
         }
         ' ${BAAS_HELM_CHART}/values.yaml
}

function convert_fqdn_to_ipaddress()
{

   # getent ahostsv4 - Look ipv4 IP address
   # grep the STREAM out put line and use head to get only the first line
   # use cut to get the first field, delimited by a space (default is tab)
   the_ipaddress=$(getent ahostsv4 $1 | grep STREAM | head -n 1 | cut -d ' ' -f 1)

   if [ -z "$the_ipaddress" ]
   then
      # zero length result so must have been invalid to start
      print_msg "ERROR: Invalid ip address $1"
      return 1
   fi
   
   if [ "$the_ipaddress" == "$1" ]
   then
      # If they match, then was already in ip address form
      print_msg "$1 is already an ipaddress"
   else
      # Yay, we converted FQDN to ip address
      print_msg "Converted FQDN ($1) to ipaddress ($the_ipaddress)"
   fi

   return 0
}

function check_nodeport()
{

   # Get the list of used nodePorts in this cluster
   allNodePortsInUse=(`kubectl get svc --all-namespaces -o go-template='{{range .items}}{{range.spec.ports}}{{if .nodePort}}{{.nodePort}}{{"\n"}}{{end}}{{end}}{{end}}'`)
   baasNodePortsInUse=(`kubectl get svc -n $PRODUCT_NAMESPACE -o go-template='{{range .items}}{{range.spec.ports}}{{if .nodePort}}{{.nodePort}}{{"\n"}}{{end}}{{end}}{{end}}'`)
   
   if [[ " ${allNodePortsInUse[@]} " =~ " ${1} " ]]; 
   then
      # The nodePort is already in use!
 
      # Is BaaS already using it? (upgrade scenario)
      if [[ " ${baasNodePortsInUse[@]} " =~ " ${1} " ]]; 
      then
         print_msg "The nodePort ${1} is already in use by BaaS"
         return 0
      fi
 
       print_msg "ERROR: SPP_AGENT_SERVICE_NODEPORT ${1} is already in use."
       print_msg "The following NODEPORTs are already in use on the cluster: ${allNodePortsInUse[@]}"
       return 1
   fi
   
   return 0
}


# ======
#  Main
# ======

# Default tasks
baas_install=false
baas_nopush=true
baas_upgrade=false
baas_deinstall=false
baas_logs=false
baas_status=false
baas_include_spp=false
baas_skip_confirmation=false
baas_task=false
baas_task_conflict=false
baas_delete_pods=false

# ----------------------------
# Parse command line arguments
# ----------------------------
while getopts ":iudslf:hnxy" opt; do
  case $opt in
    i)
      [[ $baas_task == true  ]] && baas_task_conflict=true
      baas_install=true
      baas_task=true
      ;;
    u)
      [[ $baas_task == true  ]] && baas_task_conflict=true
      baas_upgrade=true
      baas_task=true
      baas_delete_pods=true
      ;;
    d)
      [[ $baas_task == true  ]] && baas_task_conflict=true
      baas_deinstall=true
      baas_task=true
      ;;
    s)
      [[ $baas_task == true  ]] && baas_task_conflict=true
      baas_status=true
      baas_task=true
      ;;
    l)
      [[ $baas_task == true  ]] && baas_task_conflict=true
      baas_logs=true
      baas_task=true
      ;;
    h)
      exit_show_usage
      ;;
    x)
      baas_include_spp=true
      ;;
    y)
      baas_skip_confirmation=true
      ;;
    f)
      BAAS_CONFIG_FILE="$OPTARG"
      ;;
    \?)
      echo
      echo "ERROR: Invalid option: -$OPTARG" >&2
      exit_show_usage
      ;;
    :)
      echo
      echo "ERROR: Option -$OPTARG requires an argument." >&2
      exit_show_usage
      ;;
  esac
done

if [[ $baas_task == false || $baas_task_conflict == true ]]
then
  print_msg "None or conflicting mandatory task options (-i, -u, -d, -l, -s) specified."
  exit_show_usage
fi

# =====================
#    Start of Script
# =====================

# Print a message to log file only
print_log "=== New Run ($0 $@) ==="
print_msg "Script $THIS_SCRIPT started at $(date). A log of this transaction is written to ${LOGFILE} ."

# -------------------
# Check prerequisites
# -------------------
print_msg "### Starting prerequisites check at $(date) ###"

# Check prerequisites for install and source BaaS config file
# Sourcing of baas_config.cfg absolutely required (PRODUCT_TARGET_PLATFORM & OCP=true/false is set accordingly)
if [[ $baas_install == true ]]
then
  source_config_file || err_exit "Could not obtain proper configuration for BaaS deployment from BaaS config file (${BAAS_CONFIG_FILE})."
  check_helm_chart_prereqs || err_exit "Could not locate Helm chart ($BAAS_HELM_CHART) and determine product version."

  # source_config_file validated these address values were present in the baas_config.cfg
  # now, convert any FQDN values to IP address formp
  the_ipaddress=""
  convert_fqdn_to_ipaddress $SPP_IP_ADDRESSES || err_exit "Invalid SPP_IP_ADDRESSES $SPP_IP_ADDRESSES specified in BaaS config file (${BAAS_CONFIG_FILE})."
  SPP_IP_ADDRESSES=$the_ipaddress

  the_ipaddress=""
  convert_fqdn_to_ipaddress $CLUSTER_API_SERVER_IP_ADDRESS || err_exit "Invalid CLUSTER_API_SERVER_IP_ADDRESS $CLUSTER_API_SERVER_IP_ADDRESS specified in BaaS config file (${BAAS_CONFIG_FILE})."
  CLUSTER_API_SERVER_IP_ADDRESS=$the_ipaddress

  # updates to check ports
  check_ports_values_yaml || err_exit "${BAAS_HELM_CHART}/values.yaml contains invalid port settings"

  # Check the spagent service nodePort isn't already in use
  check_nodeport $SPP_AGENT_SERVICE_NODEPORT || err_exit "Invalid SPP_AGENT_SERVICE_NODEPORT $SPP_AGENT_SERVICE_NODEPORT specified in BaaS config file (${BAAS_CONFIG_FILE})."

  # Check if we are running against an OCP or K8s cluster
  if [[ $PRODUCT_TARGET_PLATFORM == "OCP" ]]
  then
    check_oc_prereqs && check_helm_prereqs && check_docker_prereqs || err_exit "Prerequisites for oc, Helm or Docker not satisfied."
  else
    check_kubectl_prereqs && check_helm_prereqs && check_docker_prereqs || err_exit "Prerequisites for kubectl, Helm or Docker not satisfied."
  fi

  # Request BAAS_ADMIN password (so it is not in clear text in the baas_config.cfg file)
  # Three failed attempts to enter the password will abort script execution
  if [[ $BAAS_PASSWORD == "" ]]
  then 
    if ! get_password "BAAS ADMIN" "$BAAS_ADMIN"
    then
      print_msg "Failed attempt to specify a password for the BaaS admin account ($BAAS_ADMIN)." 
      return 5
    else
      BAAS_PASSWORD="$MYANSWER"
    fi
  fi

  # At install time only, generate the agent credentials
  DATAMOVER_USER="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)"
  DATAMOVER_PASSWORD="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)"

  # Generate the ${BAAS_SECRET_NAME} 
  ./baas_secret.sh ${PRODUCT_NAMESPACE} ${BAAS_ADMIN} ${BAAS_PASSWORD} ${DATAMOVER_USER} ${DATAMOVER_PASSWORD}

fi

# Check prerequisites for upgrade and source BaaS config file
# Sourcing of baas_config.cfg absolutely required (PRODUCT_TARGET_PLATFORM & OCP=true/false is set accordingly)
if [[ $baas_upgrade == true ]]
then
  source_config_file || err_exit "Could not obtain proper configuration for BaaS deployment from BaaS config file (${BAAS_CONFIG_FILE})."
  check_helm_chart_prereqs || err_exit "Could not locate Helm chart ($BAAS_HELM_CHART) and determine product version."

  # source_config_file validated these address values were present in the baas_config.cfg
  # now, convert any FQDN values to IP address formp
  the_ipaddress=""
  convert_fqdn_to_ipaddress $SPP_IP_ADDRESSES || err_exit "Invalid SPP_IP_ADDRESSES $SPP_IP_ADDRESSES specified in BaaS config file (${BAAS_CONFIG_FILE})."
  SPP_IP_ADDRESSES=$the_ipaddress

  the_ipaddress=""
  convert_fqdn_to_ipaddress $CLUSTER_API_SERVER_IP_ADDRESS || err_exit "Invalid CLUSTER_API_SERVER_IP_ADDRESS $CLUSTER_API_SERVER_IP_ADDRESS specified in BaaS config file (${BAAS_CONFIG_FILE})."
  CLUSTER_API_SERVER_IP_ADDRESS=$the_ipaddress
  
  # updates to check ports
  check_ports_values_yaml || err_exit "${BAAS_HELM_CHART}/values.yaml contains invalid port settings"

  # Check the spagent service nodePort isn't already in use
  check_nodeport $SPP_AGENT_SERVICE_NODEPORT || err_exit "Invalid SPP_AGENT_SERVICE_NODEPORT $SPP_AGENT_SERVICE_NODEPORT specified in BaaS config file (${BAAS_CONFIG_FILE})."

  # Check if we are running against an OCP or K8s cluster
  if [[ $PRODUCT_TARGET_PLATFORM == "OCP" ]]
  then
    check_oc_prereqs && check_helm_prereqs && check_docker_prereqs || err_exit "Prerequisites for oc, Helm or Docker not satisfied."
  else
    check_kubectl_prereqs && check_helm_prereqs && check_docker_prereqs || err_exit "Prerequisites for kubectl, Helm or Docker not satisfied."
  fi

  # Ensure the ${BAAS_SECRET_NAME} exists
  if ! kubectl get secret ${BAAS_SECRET_NAME} -n ${PRODUCT_NAMESPACE} -o yaml >/dev/null 2>&1
  then
    err_exit "Could not find ${BAAS_SECRET_NAME} in namespace ${PRODUCT_NAMESPACE}. Please run baas-secret.sh first to create the secret and re-run the installation."
  fi
fi

# Check prerequisites for deinstall and status (purely based on Helm)
# Sourcing of baas_config.cfg not required for deinstall or status (i.e. PRODUCT_TARGET_PLATFORM & OCP=true/false is not set)
if [[ $baas_deinstall == true || $baas_status == true ]]
then
  check_helm_chart_prereqs || err_exit "Could not locate Helm chart ($BAAS_HELM_CHART) and determine product version."
  if [[ $PRODUCT_TARGET_PLATFORM == "OCP" ]]
  then
    check_oc_prereqs && check_helm_prereqs || err_exit "Prerequisites for oc or Helm not satisfied."
  else
    check_kubectl_prereqs && check_helm_prereqs || err_exit "Prerequisites for kubectl or Helm not satisfied."
  fi
fi

# Check prerequisites for debug log collection (based on kubectl and Helm)
# PRODUCT_NAMESPACE is required to gather information from current deployment
if [[ $baas_logs == true ]]
then
  # source_config_file || err_exit "Could not obtain proper configuration for BaaS deployment from BaaS config file (${BAAS_CONFIG_FILE})."
  check_kubectl_prereqs && check_helm_prereqs || err_exit "Prerequisites for kubectl or Helm not satisfied."
  if ! request_input "PRODUCT NAMESPACE" "Please specify Kubernetes namespace where the product is deployed: "
  then
    err_exit "Kubernetes namespace where the product is deployed was not specified."
  fi
  PRODUCT_NAMESPACE="$MYANSWER"
  print_log "INFO: PRODUCT_NAMESPACE=$PRODUCT_NAMESPACE (from user input)"
fi

# -----------------------
# Install BaaS containers
# -----------------------
if [[ $baas_install == true ]]
then
  print_msg "### Starting installation of product release ${BAAS_RELEASE_NAME} version $BAAS_VERSION at $(date) ###"
  # Request confirmation that we are targeting the right current Kubernetes cluster context before moving on 
  if ! get_confirmation "Please confirm to continue with installation to target cluster >>${TGT_CLUSTER}<<:"
  then
    err_exit "New install of product release ${BAAS_RELEASE_NAME} to target cluster aborted by user."
  fi
  # Install BaaS Helm chart
  if ! install_sase
  then
    err_exit "Installation of product release ${BAAS_RELEASE_NAME} version $BAAS_VERSION to target cluster failed."
  else  
    #print_msg "Please wait for components to start up. Check status with: # helm status ${BAAS_RELEASE_NAME} $HELM_TLS or # ${THIS_SCRIPT} -s or # kubectl get all -n ${PRODUCT_NAMESPACE}"
    print_msg "Waiting for components to start up..."
	if ! show_installationprogress
	then
	  err_exit "Installation of product release ${BAAS_RELEASE_NAME} version $BAAS_VERSION to target cluster failed."
	else
	  print_msg "Product release >>${BAAS_RELEASE_NAME}<< version ${BAAS_VERSION} has been installed in namespace >>${PRODUCT_NAMESPACE}<< at $(date)."
	fi
  fi
fi

# -----------------------
# Upgrade BaaS containers
# -----------------------
if [[ $baas_upgrade == true ]]
then
  print_msg "### Starting product upgrade to version $BAAS_VERSION at $(date) ###"
  # Request confirmation that we are targeting the right current Kubernetes cluster context before moving on 
  if ! get_confirmation "Please confirm to continue with product upgrade in target cluster >>${TGT_CLUSTER}<<:"
  then
    err_exit "Product upgrade aborted by user."
  fi
  # Upgrade BaaS Helm chart
  if ! upgrade_sase
  then
    err_exit "Product upgrade of release ${BAAS_RELEASE_NAME} to version ${BAAS_VERSION} in namespace >>${PRODUCT_NAMESPACE}<< failed"
  else
    echo
	print_msg "Waiting for components to start up..."
	if ! show_installationprogress
	then
	  err_exit "Product upgrade of release ${BAAS_RELEASE_NAME} to version ${BAAS_VERSION} in namespace >>${PRODUCT_NAMESPACE}<< failed"
	else
	  print_msg "Product release >>${BAAS_RELEASE_NAME}<< version ${BAAS_VERSION} has been installed in namespace >>${PRODUCT_NAMESPACE}<< at $(date)."
	fi
  fi
fi

# -----------------------
# Delete BaaS containers
# -----------------------
if [[ $baas_deinstall == true ]]
then
  print_msg "### Starting deinstallation of product release >>${BAAS_RELEASE_NAME}<< at $(date) ###"
  # Request confirmation that we are targeting the right current Kubernetes cluster context before moving on 
  if ! get_confirmation "Please confirm to remove product release >>${BAAS_RELEASE_NAME}<< from target cluster context >>${TGT_CLUSTER}<<:"
  then
    err_exit "Removal of product release >>${BAAS_RELEASE_NAME}<< from target cluster aborted by USER."
  fi
  
  # because dm deployed by tm , but it cannot uninstalled it automatically
  ./baas_uninstall_dm.sh

  # Deinstall product Helm chart
  if ! deinstall_sase
  then
    err_exit "Deinstall of product release >>${BAAS_RELEASE_NAME}<< components failed."
  else
    print_msg "Product release >>${BAAS_RELEASE_NAME}<< has been removed from the target cluster context >>${TGT_CLUSTER}<<. Please remove the namespace manually if required."
  fi
  
fi

# ------------------------------
# Show status of BaaS containers
# ------------------------------
if [[ $baas_status == true ]]
then
  print_msg "### Showing status of current BaaS Helm deployment at $(date) ###"
  if ! status_sase
  then
    err_exit "Status of BaaS Helm deployment: not deployed or in failed state."
  fi
fi

# -----------------------
# Collect logs
# -----------------------
if [[ $baas_logs == true ]]
then
  print_msg "### Start collecting debug logs from product deployment in namespace >>${PRODUCT_NAMESPACE}<< at $(date) ###"
  
  # Prepare target location for log collection
  DEBUG_LOG_NAME="${BAAS_DEBUG_LOG_DIRNAME}_$(date +%Y%m%d-%H%M%S)"
  DEBUG_LOG_ARCHIVE="${BAAS_LOG_DIR}/${DEBUG_LOG_NAME}"
  print_log "CHECK: Available space in target dir for debug log collection:\n$(df -h ${BAAS_LOG_DIR})"
  if ! mkdir -p  "$DEBUG_LOG_ARCHIVE"
  then
    err_exit "Could not create directory $DEBUG_LOG_ARCHIVE to collect debug logs from BaaS deployment! Please check space in ${BAAS_LOG_DIR}!"
  fi

  # Check if namespace is correct
  if ! kubectl get namespace $PRODUCT_NAMESPACE >>$LOGFILE 2>&1
  then
    err_exit "Could not access the Kubernetes namespace >>${PRODUCT_NAMESPACE}<<. Please specify the correct namespace or make sure you have authorization to access this namespace."
  fi

  # Collect Kubernetes component logs
  if ! collect_logs_sase
  then
    print_msg "Collection of product debug logs of its Kubernets components failed!"
  else
    print_msg "Collected BaaS debug logs of ist Kubernetes components."
  fi

  # Get baasadmin user name for SPP debug log collection
  if [[ $baas_include_spp == true ]] && ! get_adm_account_from_secret
  then
    print_msg "Skipping SPP debug log collection as BaaS admin account user name was not provided."
    baas_include_spp=false
  fi
    
  # Get baasadmin password for SPP debug log collection
  if [[ $baas_include_spp == true ]] && ! get_adm_password_from_secret
  then
    print_msg "Skipping SPP debug log collection as BaaS admin password was not provided."
    baas_include_spp=false
  fi

  # Get SPP IP addresses for SPP debug log collection
  if [[ $baas_include_spp == true ]] && ! get_spp_addresses_from_cfgmap
  then
    print_msg "Skipping SPP debug log collection as SPP IP addresses were not provided."
    baas_include_spp=false
  fi
  
  # Get SPP port for SPP debug log collection
  if [[ $baas_include_spp == true ]] && ! get_spp_port_from_cfgmap
  then
    print_msg "Skipping SPP debug log collection as SPP port was not provided."
    baas_include_spp=false
  fi
  
  # Collect SPP logs
  if [[ $baas_include_spp == true ]]
  then
    if ! collect_logs_spp
    then
      print_msg "Collection of SPP debug logs failed!"
    else
      print_msg "Collected SPP debug logs."
    fi
  else
    print_msg "Skipped SPP debug log collection (select -x option to include SPP logs)."
  fi

  # Collect installer logs
  cp -a $LOGFILE "$DEBUG_LOG_ARCHIVE"
  
  # Collect baas_config 
  cp -a $BAAS_CONFIG_FILE "$DEBUG_LOG_ARCHIVE"

  # Package logs into tar.gz archive
  if ! tar -czvf "${DEBUG_LOG_ARCHIVE}.tar.gz" -C "${BAAS_LOG_DIR}" "${DEBUG_LOG_NAME}" >>$LOGFILE 2>&1
  then
    print_msg "Problem occurred when packaging logs at ${DEBUG_LOG_ARCHIVE} into ${DEBUG_LOG_ARCHIVE}.tar.gz. Please check space in ${BAAS_LOG_DIR}."  
  else
    rm -rf "${DEBUG_LOG_ARCHIVE}"
    print_log "$(ls -al ${DEBUG_LOG_ARCHIVE}.tar.gz)" 
    print_msg "Debug log collection finished at $(date). Please provide debug log archive ${DEBUG_LOG_ARCHIVE}.tar.gz to IBM support for further analysis."
  fi
fi

# -------------
# End of Script
# -------------
print_msg "Script $THIS_SCRIPT finished at $(date). A log of this transaction has been written to ${LOGFILE} ."
exit 0
