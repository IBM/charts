#!/bin/bash
# ===================================================================================================
# IBM Confidential
# OCO Source Materials
# 5725-W99
# (c) Copyright IBM Corp. 1998, 2020
# The source code for this program is not published or otherwise divested of its
# trade secrets, irrespective of what has been deposited with the U.S. Copyright Office.
# ===================================================================================================
#  BaaS: Service Manager - collect-logs.sh                                                     
# ===================================================================================================
#
# Purpose: Deploy BaaS components on OpenShift and IBM Cloud Private / Kubernetes environments
#
# Usage: collect-logs.sh 
#
# ===================================================================================================
#  Prerequisites:
#  - Kubectl, oc (OpenShift only), Docker (with login to cluster image registry) and Helm3
#  - User needs to be logged in to the target cluster as cluster-admin
# ===================================================================================================
# ===================================================================================================

# ----------------
#  Global options
# ----------------

# NAME OF SCRIPT AND OPTIONS
THIS_SCRIPT=${0##*/}
THIS_SCRIPT_OPTIONS="$@"

BAAS_RELEASE_NAME="baas" 
PRODUCT_NAMESPACE="baas"
SPP_IP_ADDRESSES=""
SPP_PORT=""
SPP_ADMIN=""
SPP_PASSWORD=""
IS_OCP=""
VELERO_NAMESPACE=""
BAAS_LOG_DIR="/tmp"                      # Local system directory for log collection and command debug log 
BAAS_DEBUG_LOG_DIRNAME="baas_debug_logs" # Log collection directory name as BAAS_DEBUG_LOG_DIRNAME_20190331-195933 located under BAAS_LOG_DIR
BAAS_AUX_LOGCOLLECT="collect-logs.py"

# Progress will be logged to the following file
LOGFILE="${BAAS_LOG_DIR}/${THIS_SCRIPT}_$(date +%Y%m%d-%H%M%S).log"

# Show command usage and exit
function exit_show_usage()
{
  cmd=$(basename $0)
  cat << EOF

USAGE: $cmd [-x | -h ]

Collect baas logs for debugging purposes

TASKS
  -x : Include all external components for log collection (-l), e.g. all SPP instances
  -h : Displays user help

EOF
  print_log "Exiting. Wrong command usage: $THIS_SCRIPT $THIS_SCRIPT_OPTIONS"
  exit 1
}

# Print a message and exit
function err_exit()
{
  echo "ERROR: $@" >&2
  echo "Please refer to log file at $LOGFILE for more information!"
  print_msg "ERROR: $@"
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


# Collect debug logs from SPP server(s)
# Requires Python3 helper script (BAAS_AUX_LOGCOLLECT) and SPP_IP_ADDRESSES & SPP_PORT
function collect_logs_spp()
{
  IFSOLD="$IFS"
  IFS=","
  for ipaddr in $SPP_IP_ADDRESSES
  do
    print_msg "Start downloading logs from SPP at IP address ${ipaddr}:${SPP_PORT} to ${DEBUG_LOG_ARCHIVE}/spp-${ipaddr}.zip at $(date):"
    print_log "INFO: Executing external command python3 $BAAS_AUX_LOGCOLLECT ${ipaddr} $SPP_ADMIN [password hidden] ${DEBUG_LOG_ARCHIVE}/spp-${ipaddr}.zip" 
    if ! python3 $BAAS_AUX_LOGCOLLECT "${ipaddr}" "$SPP_ADMIN" "$SPP_PASSWORD" "${DEBUG_LOG_ARCHIVE}/spp-${ipaddr}.zip" >>$LOGFILE 2>&1
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

# Collect debug logs from all CBP components on cluster
# Requires kubectl and helm3 and PRODUCT_NAMESPACE (from baas_config.cfg)
function collect_logs_CBS()
{
  print_msg "Collecting information and logs from components..."
  
  # Collect helm information
  helm3 status ${BAAS_RELEASE_NAME} $HELM_TLS -n ${PRODUCT_NAMESPACE}  >"${DEBUG_LOG_ARCHIVE}/helm-status.out"
  helm3 history ${BAAS_RELEASE_NAME} $HELM_TLS -n ${PRODUCT_NAMESPACE} >"${DEBUG_LOG_ARCHIVE}/helm-history.out"

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
    for container in $(kubectl get pod ${pod} -o jsonpath='{.spec.containers[*].name}' -n ${PRODUCT_NAMESPACE})
    do
      print_msg "Collecting ${container} logs..."
      kubectl logs ${pod} -c ${container} -n ${PRODUCT_NAMESPACE}               >"${DEBUG_LOG_ARCHIVE}/kubectl-${pod}-${container}.log" 2>&1 \
      && kubectl logs ${pod} -c ${container} -n ${PRODUCT_NAMESPACE} --previous >"${DEBUG_LOG_ARCHIVE}/kubectl-${pod}-${container}-prev.log" 2>&1
    done
  done
  
  # Collect other Kubernetes resource information in namespace (service secret configmap serviceaccount networkpolicy clusterrole clusterrolebinding role rolebinding customresourcedefinition)
  # Only collect these resource detail information related to baas
  for resource in service secret configmap serviceaccount networkpolicy clusterrole clusterrolebinding role rolebinding \
                  customresourcedefinition HorizontalPodAutoscaler PersistentVolumeClaim kafka
  do
    print_msg "Collecting BaaS ${resource} information..."
    kubectl get ${resource} -n ${PRODUCT_NAMESPACE} >"${DEBUG_LOG_ARCHIVE}/kubectl-${resource}.out"
    kubectl get ${resource}  -n ${PRODUCT_NAMESPACE} -l app.kubernetes.io/instance=baas | grep -v '^NAME' | while read object nothing
    do
      kubectl get ${resource} ${object} -n ${PRODUCT_NAMESPACE} >"${DEBUG_LOG_ARCHIVE}/kubectl-${resource}-${object}.out"
      echo "- - - "                                                      >>"${DEBUG_LOG_ARCHIVE}/kubectl-${resource}-${object}.out"
      kubectl get ${resource} ${object} -n ${PRODUCT_NAMESPACE}  -o yaml >>"${DEBUG_LOG_ARCHIVE}/kubectl-${resource}-${object}.out"
      echo "- - - "                                                      >>"${DEBUG_LOG_ARCHIVE}/kubectl-${resource}-${object}.out"
      kubectl describe ${resource} ${object} -n ${PRODUCT_NAMESPACE}   >>"${DEBUG_LOG_ARCHIVE}/kubectl-${resource}-${object}.out"
    done
  done

  # Collect kafka operator information on Openshift environment
  if [[ $IS_OCP == true ]]  
  then
    for resource in OperatorGroup Subscription
    do
      print_msg "Collecting BaaS ${resource} information..."
      kubectl get ${resource}  -n ${PRODUCT_NAMESPACE} >"${DEBUG_LOG_ARCHIVE}/kubectl-${resource}.out"
      kubectl get ${resource}  -n ${PRODUCT_NAMESPACE} | grep -v '^NAME' | while read object nothing
      do
        kubectl get ${resource} ${object} -n ${PRODUCT_NAMESPACE}          >"${DEBUG_LOG_ARCHIVE}/kubectl-${resource}-${object}.out"
        echo "- - - "                                                      >>"${DEBUG_LOG_ARCHIVE}/kubectl-${resource}-${object}.out"
        kubectl get ${resource} ${object} -n ${PRODUCT_NAMESPACE} -o yaml >>"${DEBUG_LOG_ARCHIVE}/kubectl-${resource}-${object}.out"
        echo "- - - "                                                      >>"${DEBUG_LOG_ARCHIVE}/kubectl-${resource}-${object}.out"
        kubectl describe ${resource} ${object} -n ${PRODUCT_NAMESPACE}    >>"${DEBUG_LOG_ARCHIVE}/kubectl-${resource}-${object}.out"
      done
    done
  fi


  # Collect certmon cronjob and job on k8s environment
  if [[ $IS_OCP == false ]]  
  then
    for resource in CronJob Job
    do
      print_msg "Collecting BaaS ${resource} information..."
      kubectl get ${resource}  -n ${PRODUCT_NAMESPACE} >"${DEBUG_LOG_ARCHIVE}/kubectl-${resource}.out"
      kubectl get ${resource}  -n ${PRODUCT_NAMESPACE} | grep -v '^NAME' | while read object nothing
      do
        kubectl get ${resource} ${object} -n ${PRODUCT_NAMESPACE}          >"${DEBUG_LOG_ARCHIVE}/kubectl-${resource}-${object}.out"
        echo "- - - "                                                      >>"${DEBUG_LOG_ARCHIVE}/kubectl-${resource}-${object}.out"
        kubectl get ${resource} ${object} -n ${PRODUCT_NAMESPACE} -o yaml >>"${DEBUG_LOG_ARCHIVE}/kubectl-${resource}-${object}.out"
        echo "- - - "                                                      >>"${DEBUG_LOG_ARCHIVE}/kubectl-${resource}-${object}.out"
        kubectl describe ${resource} ${object} -n ${PRODUCT_NAMESPACE}    >>"${DEBUG_LOG_ARCHIVE}/kubectl-${resource}-${object}.out"
      done
    done
  fi
  
  # Collect baasreq information
  kubectl get baasreq --all-namespaces -o yaml >>"${DEBUG_LOG_ARCHIVE}/baasreq.out"
  
  # Collect velero information
  if ! collect_logs_velero
  then
    print_msg "Collect velero information fail."
  fi
  
  print_msg "Finished collecting information and logs from CBS components..."
  return 0
}

# Collect logs and information from velero namespace
function collect_logs_velero()
{
  print_msg "Collecting information and logs from velero..."
  
  if [ $VELERO_NAMESPACE == "" ]
  then
    print_msg "Warning: Cannot find velero specific information from helm values. Velero is not configured. Skipping collection of velero logs... "
	return 0
  fi
  
  # Overview of all resources from namespace 
  kubectl get all -n ${VELERO_NAMESPACE} -o wide >"${DEBUG_LOG_ARCHIVE}/velero-all.out" 2>/dev/null
    
  
  # Collect pod information and container logs
  print_msg "Collecting velero pod information..."
  kubectl get pods -n ${VELERO_NAMESPACE} -o wide >"${DEBUG_LOG_ARCHIVE}/velero-pods.out"
  

  kubectl get pods -n ${VELERO_NAMESPACE} | grep -v '^NAME' | while read pod nothing
  do
    echo "- - - "                                           >>"${DEBUG_LOG_ARCHIVE}/velero-${pod}.out"
    kubectl describe pod ${pod} -n ${VELERO_NAMESPACE}    >>"${DEBUG_LOG_ARCHIVE}/velero-${pod}.out"
  done
  
  kubectl logs deployment/velero -n ${VELERO_NAMESPACE} > "${DEBUG_LOG_ARCHIVE}/velero.log" 2>&1 \
  && kubectl logs deployment/velero -n ${VELERO_NAMESPACE} --previous >"${DEBUG_LOG_ARCHIVE}/velero-prev.log" 2>&1
	
  # Collect backupstoragelocation information from namespace
  kubectl get backupstoragelocation default -n ${VELERO_NAMESPACE} -o yaml >"${DEBUG_LOG_ARCHIVE}/velero-backupstoragelocation.out" 2>/dev/null 
  return 0
}

function get_baas_values_from_helm()
{
  if ! helm3 get values ${BAAS_RELEASE_NAME} -n $PRODUCT_NAMESPACE >/dev/null 2>&1
  then
    print_msg "Error: helm3 get values ${BAAS_RELEASE_NAME} -n $PRODUCT_NAMESPACE. "
    return 1
  fi

  IS_OCP=$(helm3 get values ${BAAS_RELEASE_NAME} -n $PRODUCT_NAMESPACE | grep "isOCP:" | awk '{print $2}' | xargs)
  if [[ $IS_OCP  == "" ]]
  then
    print_msg "Error: get "IS_OCP:" return empty. "
    return 2
  fi
  
  VELERO_NAMESPACE=$(helm3 get values ${BAAS_RELEASE_NAME} -n $PRODUCT_NAMESPACE | grep "veleroNamespace:" | awk '{print $2}' | xargs)
  if [[ $VELERO_NAMESPACE  == "" ]]
  then
    print_msg "Warning: get "VELERO_NAMESPACE:" return empty. "
    return 0
  fi
  return 0

}


function get_spp_values_from_helm()
{
  if ! helm3 get values ${BAAS_RELEASE_NAME} -n $PRODUCT_NAMESPACE >/dev/null 2>&1
  then
    print_msg "Error: helm3 get values ${BAAS_RELEASE_NAME} -n $PRODUCT_NAMESPACE. "
    return 1
  fi

  sppaddrs=$(helm3 get values ${BAAS_RELEASE_NAME} -n $PRODUCT_NAMESPACE | grep "SPPips:" |  awk '{$1=""; print $0}' | xargs )
  if [[ $sppaddrs  == "" ]]
  then
    print_msg "Error: get "SPPips:" return empty. "
    return 2
  fi
  SPP_IP_ADDRESSES=($sppaddrs)

  SPP_PORT=$(helm3 get values ${BAAS_RELEASE_NAME} -n $PRODUCT_NAMESPACE | grep "SPPport:" | awk '{print $2}' | xargs)
  if [[ $SPP_PORT  == "" ]]
  then
    print_msg "Error: get "SPP_PORT:" return empty. "
    return 2
  fi
  
  return 0
}

# Retrieve baasadmin and password from baas-secret to collect logs from SPP
function get_spp_secret_from_secret()
{
  # Extract BAAS_ADMIN credentials from baas-secret
  if kubectl get secret ${BAAS_SECRET_NAME} -n ${PRODUCT_NAMESPACE} -o yaml >/dev/null 2>&1
  then
    SPP_PASSWORD="$(kubectl get secret ${BAAS_SECRET_NAME} -n ${PRODUCT_NAMESPACE} -o yaml | grep 'baaspassword:' |  awk 'NR==1' | awk '{print $2}' | base64 -d)"
    print_log "INFO: SPP_PASSWORD=[hidden] (retrieved from ${BAAS_SECRET_NAME})"
    SPP_ADMIN="$(kubectl get secret ${BAAS_SECRET_NAME} -n ${PRODUCT_NAMESPACE} -o yaml | grep 'baasadmin:' |  awk 'NR==1' | awk '{print $2}' | base64 -d)"
    print_log "INFO: SPP_ADMIN = $SPP_ADMIN (retrieved from ${BAAS_SECRET_NAME})"
  fi
  
  if [[ $SPP_ADMIN != "" ]] && [[ SPP_PASSWORD == "" ]]
  then
    if ! get_password "SPP ADMIN" "$SPP_ADMIN"
    then
      return 1
    else
      SPP_PASSWORD="$MYANSWER"
      print_msg "INFO: BAAS_PASSWORD=[hidden] (retrieved from user input)"
    fi
  fi
  
  return 0    
}

# ======
#  Main
# ======
baas_include_spp=false
# Prepare target location for log collection
DEBUG_LOG_NAME="${BAAS_DEBUG_LOG_DIRNAME}_$(date +%Y%m%d-%H%M%S)"
DEBUG_LOG_ARCHIVE="${BAAS_LOG_DIR}/${DEBUG_LOG_NAME}"

# ----------------------------
# Parse command line arguments
# ----------------------------
while getopts ":hx" opt; do
  case $opt in   
    x)
      baas_include_spp=true
      ;;
    h)
      exit_show_usage
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
shift $((OPTIND -1))

print_msg "CHECK: Available space in target dir for debug log collection:\n$(df -h ${BAAS_LOG_DIR})"

if ! mkdir -p  "$DEBUG_LOG_ARCHIVE"
then
  err_exit "Could not create directory $DEBUG_LOG_ARCHIVE to collect debug logs from BaaS deployment! Please check space in ${BAAS_LOG_DIR}!"
fi

# Check if namespace is correct
if ! kubectl get namespace $PRODUCT_NAMESPACE >>$LOGFILE 2>&1
then
  err_exit "Could not access the Kubernetes namespace >>${PRODUCT_NAMESPACE}<<. Please specify the correct namespace or make sure you have authorization to access this namespace."
fi

# Check helm3 installed
print_msg "Checking for proper initialization of helm3 on local system..."
if ! helm3 version >>$LOGFILE 2>&1 && ! helm3 version --tls >>$LOGFILE 2>&1
then 
  err_exit "Helm3 is not properly initialized on this local system. Please properly initialize the helm3 framework."
fi
 

# Get values from baas helm
if ! get_baas_values_from_helm
then
  err_exit "Could not get baas values from helm get values command. Please check using helm staus baas command."
fi

# Collect Kubernetes component logs
if ! collect_logs_CBS
then
  print_msg "Collection of product debug logs of its Kubernets components failed!"
else
  print_msg "Collected BaaS debug logs of its Kubernetes components."
fi

#check whether python3 installed
if [[ $baas_include_spp == true ]] && ! python3 --version >>$LOGFILE 2>&1
then
  baas_include_spp = false
  print_msg "Skipping SPP debug log collection: Python3 is required. "
fi
  

if [[ $baas_include_spp == true ]] && ! get_spp_values_from_helm
then
  baas_include_spp = false
  print_msg "Skipping SPP debug log collection: Could not get spp values from helm3 get values command. Please check using helm3 staus baas command."
fi

if [[ $baas_include_spp == true ]] && ! get_spp_secret_from_secret
then
  baas_include_spp = false
  print_msg "Skipping SPP debug log collection: SPP Server admin password was not provided."
fi

if [[ $baas_include_spp == true ]]
then
  if ! collect_logs_spp
  then
    print_msg "Collection of SPP debug logs failed!"
  else
    print_msg "Collected SPP debug logs."
  fi
else
  print_msg "Skipped SPP debug log collection."
fi

# Collect installer logs
cp -a $LOGFILE "$DEBUG_LOG_ARCHIVE"
  
# Collect option file
#cp -a $BAAS_CONFIG_FILE "$DEBUG_LOG_ARCHIVE"

# Package logs into tar.gz archive
if ! tar -czvf "${DEBUG_LOG_ARCHIVE}.tar.gz" -C "${BAAS_LOG_DIR}" "${DEBUG_LOG_NAME}" >>$LOGFILE 2>&1
then
  print_msg "Problem occurred when packaging logs at ${DEBUG_LOG_ARCHIVE} into ${DEBUG_LOG_ARCHIVE}.tar.gz. Please check space in ${BAAS_LOG_DIR}."  
else
  rm -rf "${DEBUG_LOG_ARCHIVE}"
  print_msg "$(ls -al ${DEBUG_LOG_ARCHIVE}.tar.gz)" 
  print_msg "Debug log collection finished at $(date). Please provide debug log archive ${DEBUG_LOG_ARCHIVE}.tar.gz to IBM support for further analysis."
fi

# -------------
# End of Script
# -------------
exit 0


