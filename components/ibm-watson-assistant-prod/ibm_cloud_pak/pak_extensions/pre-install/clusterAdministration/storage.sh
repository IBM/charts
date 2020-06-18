#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2019.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################

#
# This script can be used to create local-volume PV's for POC environments in ICP4D or create the Portworx Storage Class.
#
# It is provided as is. 
#
# To create local volumes, the script should be run from a machine that has ssh access to all the nodes in your ICP4D development environment.
#
# Usage: storage.sh [--enablePortworx] [--pgBackupLocalStorage true | false | only] [--path PATH]  [--release RELEASE_NAME]  [--label LABEL] [--nodes node1,node2,node3,node4,node5] [--nodesForDatastore DATASTORE node1,node2,...,node_n] [--tmp DIR] [--force] [--cli oc | kubectl] [--help]
#
# You can optionally provide the (base) PATH used on nodes to store the PV data (defaults to /mnt/local-storage/storage/watson/assistant)
#    actual PV are then created as a subdirectories at ${PATH}/${RELEASE_NAME}/${VOLUME} (where VOLUME are like mongodb-80gi-1)
# You can optionally provide the release name for which you create the PV                (defaults to timestamp in a format: YYYY-MM-DD--HH-mm)
# You can optionally specify the label(s) to use when selecting the nodes. If not provided you may be asked for a label interactively.
#                        consider using e.g., --label node-role.kubernetes.io/worker=true"
#                        or                   --label beta.kubernetes.io/arch=amd64"
#
# You can optionally specify to which nodes the PV should be bounded(--nodes).
#    After the --nodes parameter a list of 5 comma separated node names to be used for PVs has to be provided;
# if the --nodes parameter is not provided, 5 nodes are randomly selected from nodes having specified label.
#
# Considerations for DEV clusters having less then 5 nodes.
#    In such a case you have to provide the list of 5 nodes as a parameter, but you can specify a node multiple times in the list.
#      e.g., --nodes node1,node2,node1,node2
#    Notice that for such a cluster you have to set --values global.podAntiAffinity=Disable
#
# The scipt will bound PVs using this schema:
#    PV type  | node1                              | node2                              | node3                              | node4                          | node5
#   ----------+------------------------------------+------------------------------------+------------------------------------+--------------------------------+--------------------------------
#    mongodb  | wa-${RELEASE_NAME}-mongodb-80gi-1  | wa-${RELEASE_NAME}-mongodb-80gi-2  | wa-${RELEASE_NAME}-mongodb-80gi-3  |                                |
#    etcd     | wa-${RELEASE_NAME}-etcd-10gi-1     | wa-${RELEASE_NAME}-etcd-10gi-2     | wa-${RELEASE_NAME}-etcd-10gi-3     | wa-${RELEASE_NAME}-etcd-10gi-4 | wa-${RELEASE_NAME}-etcd-10gi-5
#    postgres | wa-${RELEASE_NAME}-postgres-10gi-1 | wa-${RELEASE_NAME}-postgres-10gi-2 | wa-${RELEASE_NAME}-postgres-10gi-3 |                                |
#    minio    | wa-${RELEASE_NAME}-minio-5gi-1     | wa-${RELEASE_NAME}-mini0-5gi-2     | wa-${RELEASE_NAME}-minio-5gi-3     | wa-${RELEASE_NAME}-minio-5gi-4 |
#    backup   | wa-${RELEASE_NAME}-backup-1gi-1    |                                    |                                    |                                |
#
# You can optionally overrides nodes used by the PV of particular datastore using --nodesForDatastore. Can be specified multiple times.
#  Requires 2 parametes - DATASTORE - possible values: mongodb etcd postgres minio
#    comma separated list of nodes (ip's): e.g., node1,node2,node3, means first PV will be bound to node1, second PV will be bound to node2, ...
#################################################################

set -o nounset
set -e
#set -x

#################################################################
# You may wish to customise the script by changing these
# variables from their defaults
#################################################################
# You can specify ssh args you want to use here, for example if you need to provide an ssh certificate
SSH_ARGS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
# Create a Unique Identifier for the PV's, can be overwritten by --release option
RELEASE=$(date +%Y-%m-%d--%H-%M)
# The location on each node to store the actual PV data (can be overriden by --path parameter)
LOCAL_PATH="/mnt/local-storage/storage/watson/assistant"
# The node labels to use when selecting which nodes to create local-volume directories on.
# If no label is specified, all the nodes / labels will be listed as options.
LABEL=""

# List of nodes in the cluster having specified label (is filled automatically later)
NODES=""
# Directory to store temporary files
tmpDir=/tmp

#Dir script was called from
baseDir=$(pwd)

#by default, don't delete existing data directories on nodes
force_dir_creation=false

declare AFFINITIES_NODES=""   # Space separated list of nodes for node affinities (default if not provided for particular PV type)

AFFINITY_MINIMUM_NODE_COUNT=5 # The smallest number of nodes for affinity
OCVERSION=
USER_CLI=
CLI=oc

enable_portworx=false
pgBackupLocalStorage=true

#################################################################
# End of variables
#################################################################

function die() {
  echo "$@" 1>&2

  exit 99
}

function showHelp() {
  echo "Usage storage.sh [--enablePortworx] [--pgBackupLocalStorage true | false | only] [--path PATH] [--release RELEASE_NAME] [--label LABEL] [--nodes node1,node2,node3,node4,node5] [--nodesForDatastore DATASTORE node1,node2,...,node_n] [--tmp DIR] [--force] [--cli oc | kubectl] [--help]"
  echo "Script creates local-storage persistent volumes on cluster nodes."
  echo ""
  echo "--enablePortworx: Create the Portworx storage class only."
  echo "--pgBackupLocalStorage: Default is true. If true, a local-storage PV will be created to store Postgres Backups. If set to only, this will be the only PV that gets created."
  echo "--path: You can optionally provide the (base) PATH used on nodes to store the PV data (defaults to /mnt/local-storage/storage/watson/assistant)"
  echo "        PV are then created as a subdirectories at \${PATH}/\${RELEASE_NAME}/\${VOLUME} (where VOLUMEs are like mongodb-80gi-1)"
  echo "--release: You can optionally specify the name of the release for which the PVs are created. (defaults to timestamp in a format: YYYY-MM-DD--HH-mm)"
  echo "--tmp: The tmp dir to use. Defaults to /tmp"
  echo "--force: Specify the force option to force the creation of the data dirs. You will be prompted to confirm you want to delete an existing dir."
  echo "--cli: The cli to use, can be oc or kubectl. Default is oc"
  echo "--label: The label(s) used to select which nodes to create the local-volume dirs on. If not provided you may be asked for a label iteractively."
  echo "         consider using e.g., --label node-role.kubernetes.io/worker=true"
  echo "           or                 --label node-role.kubernetes.io/compute=true"
  echo "           or                 --label beta.kubernetes.io/arch=amd64"
  echo ""
  echo "--nodes Specifies to which nodes the PV will be bounded"
  echo "    After the --nodes parameters a list of 5 comma separated node names to be used for PVs has to be provided;"
  echo "    If the --nodes parameter is not provided, 5 nodes are randomly selected from nodes having specified label."
  echo ""
  echo "    Considerations for DEV clusters having less then 5 nodes."
  echo "      In such a case you have to provide the list of 5 nodes as a parameter, but you can specify a node multiple times in the list."
  echo "        e.g., --nodes node1,node2,node1,node2"
  echo "      Notice that for such a cluster you have to set --values global.podAntiAffinity=Disable"
  echo ""
  echo "    If --nodes is specified, the scipt will bound PVs using this schema:"
  echo "      PV type  | node1                               | node2                               | node3                               | node4                              | node5"
  echo "     ----------+-------------------------------------+-------------------------------------+-------------------------------------+------------------------------------+------------------------------------"
  echo "      mongodb  | wa-\${RELEASE_NAME}-mongodb-80gi-1  | wa-\${RELEASE_NAME}-mongodb-80gi-2  | wa-\${RELEASE_NAME}-mongodb-80gi-3  |                                    |"
  echo "      etcd     | wa-\${RELEASE_NAME}-etcd-10gi-1     | wa-\${RELEASE_NAME}-etcd-10gi-2     | wa-\${RELEASE_NAME}-etcd-10gi-3     | wa-\${RELEASE_NAME}-etcd-10gi-4    | wa-\${RELEASE_NAME}-etcd-10gi-5"
  echo "      postgres | wa-\${RELEASE_NAME}-postgres-10gi-1 | wa-\${RELEASE_NAME}-postgres-10gi-2 | wa-\${RELEASE_NAME}-postgres-10gi-3 |                                    |"
  echo "      minio    | wa-\${RELEASE_NAME}-minio-5gi-1     | wa-\${RELEASE_NAME}-mini0-5gi-2     | wa-\${RELEASE_NAME}-minio-5gi-3     | wa-\${RELEASE_NAME}-minio-5gi-4    |"
  echo "      backup   | wa-\${RELEASE_NAME}-backup-1gi-1    |                                     |                                     |                                    |"
  echo ""
  echo "--nodesForDatastore: If specified can override the nodes to be used for particular datastore. Can be specified multiple times for different DATASTORES."
  echo "    Expects 2 parameters: DATASTORE - datastore for which the nodes (of PVs) are specified. Supported datastores: ${spec_pv_types[@]}"
  echo "      Comma separated nodes list, must be at least of length 3 except minio which requires 4 nodes and etcd which requires 5 nodes."
  echo "           e.g., node1,node2,node3 means: first PV will be bounded to node1, second PV will be bounded to node2, ..."
  echo "  If you wish completely specify the nodes for each datastore use: "
  echo "    --nodesForDatastore mongodb node1,node2,node3 --nodesForDatastore etcd node4,node5,node6 --nodesForDatastore postgres node7,node8,node9 --nodesForDatastore minio node10,node11,node12,node13"
  echo "    Notice that there is no need to use different nodes for different datastores (as in the example above), but we suggest not to reuse nodes for a single datastores if not required by cluster size."
  echo ""
  echo "--help: Displays this help message."
  echo ""
  echo "----------------------------------------------------------------------------------"
  echo "This script can be used to create local-volume PV's for POC environments in ICP4D or to create a Portworx Storage Class."
  echo ""
  echo "To create local volumes, the script should be run from a machine that has ssh access to all the nodes in your ICP4D development environment."
  echo
}

# Specifies types of datastores and PV properties for given datastore
declare -a spec_pv_types
declare -A def_pv_types

type="mongodb"
spec_pv_types=("${type}")
def_pv_types["${type},count"]=3
def_pv_types["${type},size"]="80Gi"
def_pv_types["${type},nodes"]=""

type="etcd"
spec_pv_types=("${spec_pv_types[@]}" "${type}")
def_pv_types["${type},count"]=5
def_pv_types["${type},size"]="10Gi"
def_pv_types["${type},nodes"]=""

type="postgres"
spec_pv_types=("${spec_pv_types[@]}" "${type}")
def_pv_types["${type},count"]=3
def_pv_types["${type},size"]="10Gi"
def_pv_types["${type},nodes"]=""

type="minio"
spec_pv_types=("${spec_pv_types[@]}" "${type}")
def_pv_types["${type},count"]=4
def_pv_types["${type},size"]="5Gi"
def_pv_types["${type},nodes"]=""

type="backup"
spec_pv_types=("${spec_pv_types[@]}" "${type}")
def_pv_types["${type},count"]=1
def_pv_types["${type},size"]="1Gi"
def_pv_types["${type},nodes"]=""

function isInArray() {
  local VALUE="$1"
  shift
  while (( $# > 0 )); do
    local element=$1
    shift
    if [ "${VALUE}" = "${element}" ] ; then
      return 0
    fi
  done
  return 1
}

portworx() {
  echo "**********************************************************"
  echo "Enabling Portworx"
  echo "  Creating $tmpDir/portworx-assistant.yaml"
  cat<<END>$tmpDir/portworx-assistant.yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: portworx-assistant
provisioner: kubernetes.io/portworx-volume
parameters:
   repl: "3"
   priority_io: "high"
   snap_interval: "0"
   io_profile: "db"
END

  echo "  Applying $tmpDir/portworx-assistant.yaml"
  $CLI apply -f $tmpDir/portworx-assistant.yaml || die "ERROR: Portworx Storage Class creation failed"
  echo "**********************************************************"
  echo ""
}

######################
# Get OC Version
#
# Work out the OC version using the selected CLI
#   For oc we can use oc version
#   For kubectl we need to use kubectl version
#   These commands return completely different output
######################

function getVersion {
  if [ "$CLI" == "oc" ]; then
    # RC will be 0 for Openshift v3 and 1 for v4
    oc version | grep "openshift v3." >/dev/null 2>&1
    RC=$?
    if [ "$RC" == "0" ]; then
      echo "3"
    else
      echo "4"
    fi
  else
    # Kubernetes server minor version will be 11 for OpenShift v3 and 14 for OpenShift v14
    minor=$(kubectl version | grep "Server Version" | grep -o -E '[0-9]+' | sed -n 2p)
    if [ "$minor" == "11" ]; then
      echo "3"
    else
      echo "4"
    fi
  fi
}

#############################
# Processing command-line parameters
#############################
while (( $# > 0 )); do
  case "$1" in
    --enablePortworx )
      #Create Portworx storage class and exit
      enable_portworx=true
      ;;
    --pgBackupLocalStorage )
      if [[ $2 == -* ]] || [[ $2 == "" ]]; then
        die "ERROR: pgBackupLocalStorage argument has no value"
      fi
      shift
      pgBackupLocalStorage="$1"
      if [ "$pgBackupLocalStorage" == "only" ]; then
        AFFINITY_MINIMUM_NODE_COUNT=1
      elif [ "$pgBackupLocalStorage" != "true" ] && [ "$pgBackupLocalStorage" != "false" ]; then
        die "ERROR: pgBackupLocalStorage argument can be true, false or only."
      fi
      ;;
    -p | --p | --path )
      if [[ $2 == -* ]] || [[ $2 == "" ]]; then
        die "ERROR: Path argument has no value"
      fi
      shift
      LOCAL_PATH="$1"
      ;;
    -r | --r | --release )
      if [[ $2 == -* ]] || [[ $2 == "" ]]; then
        die "ERROR: --release argument has no value"
      fi
      shift
      RELEASE="$1"
      ;;
    -l | --l | --label )
      if [[ $2 == -* ]] || [[ $2 == "" ]]; then
        die "ERROR: Label argument has no value"
      fi
      shift
      LABEL="$1"
      ;;
    --force )
      force_dir_creation="true"
      ;;
    --tmp )
      if [[ $2 == -* ]] || [[ $2 == "" ]]; then
        die "Error: You must specify a directory."
      fi
      shift
      tmpDir="$1"
      ;;
    -c | --c | --cli )
      option=${2:-}
      if [[ $option == -* ]] || [[ $option == "" ]]; then
        die "ERROR: --cli argument has no value"
      fi
      shift
      USER_CLI="$1"
      if [ "$USER_CLI" != "kubectl" ] && [ "$USER_CLI" != "oc" ]; then
        die "Error: You must specify oc or kubectl with the --cli arg."
      fi
      ;;
    -n | --na | --nodeAffinities )
      # Undocummented but left here for backward compatibility
      if (( $# > 1 )); then
        if [[ $2 != -* ]] && [[ $2 != "" ]]; then
          AFFINITIES_NODES="$( echo "$2" | tr "," " ")"
          AFFINITIES_NODES_COUNT=$(echo "$AFFINITIES_NODES" | wc -w)
          if (( $AFFINITIES_NODES_COUNT < 5 )); then
            die "ERROR: You specified $AFFINITIES_NODES_COUNT nodes, you must specify a minimum of $AFFINITY_MINIMUM_NODE_COUNT nodes"
          fi
          shift
        fi
      fi
      ;;
    --nodes )
      option=${2:-}
      if [[ $option == -* ]] || [[ $option == "" ]]; then
        die "ERROR: --nodes argument expects a list of 5 nodes names where to create the volumes"
      fi
      shift
      AFFINITIES_NODES="$( echo "$1" | tr "," " ")"
      AFFINITIES_NODES_COUNT=$(echo "$AFFINITIES_NODES" | wc -w)
      if (( $AFFINITIES_NODES_COUNT < 5 )); then
        die "ERROR: You specified $AFFINITIES_NODES_COUNT nodes, you must specify a minimum of $AFFINITY_MINIMUM_NODE_COUNT nodes"
      fi
      ;;
    --nodesForDatastore )
      if (( $# < 3 )); then
        die "ERROR: --nodesForDatastore argument needs exactly 2 parameters - DATASTORE (possible DATASTORE types: ${spec_pv_types[@]}) and nodesList"
      fi
      type="$2"
      if isInArray "${type}" "${spec_pv_types[@]}" ; then
        node_list="$3"
        nodes_count="$( echo "${node_list}" | tr ',' $'\n' | wc -l)"
        if [ "${nodes_count}" -lt "${def_pv_types["${type},count"]}" ] ; then
          die "ERROR: --nodesForDatastore ${type} required you specify at least ${def_pv_types["${type},count"]} (comma separated) node names, but you provided only ${nodes_count}."
        fi
        def_pv_types["${type},count"]="${nodes_count}"
        def_pv_types["${type},nodes"]="$( echo "${node_list}" | tr ',' ' ')"
      else
        die "ERROR: --nodesForDatastore invalid DATASTORE parameter. Got \"${type}\" but permitted values are (${spec_pv_types[@]})"
      fi
      shift
      shift
      ;;
    -h | --h | --help )
      showHelp
      exit 2
      ;;
    * | -* )
      echo "Unknown option: $1"
      exit 99
      ;;
  esac
  shift
done

##################
# Checking for CLI
##################
if [ -z "$USER_CLI" ]; then
  # User didn't specify a CLI so try to use oc, then kubectl.
  if ! which oc >/dev/null; then
    echo "WARNING: oc command not found, checking for kubectl command..."
    echo ""
    if ! which kubectl >/dev/null; then
      die "ERROR: kubectl command not found. Ensure that you have oc or kubectl installed and on your PATH."
    fi
    CLI=oc
  fi
else
  # User specified a CLI, check we can use it
  CLI=$USER_CLI
  if ! which $CLI >/dev/null; then
    die "ERROR: $CLI command not found. Ensure that you have $CLI installed and on your PATH."
  fi
fi

#################################################################
# Start of main script
#
# Test connection
# If --enablePortworx specified, create Portworx storage class and exit
# Get a list of (worker) nodes
# Select/check node are correctly labeled.
# Generate configuration for each PV
#
# For each PV
#   ssh into each node and create a dir for each PV
#   Render the templates
#   Apply the templates
#
# Clean the tmp dir
#################################################################

if [ ! -d $tmpDir ]; then
  die "ERROR: Dir $tmpDir doesn't exist. You must specify an existing dir."
fi

#Use a unique dir beneath $tmpDir
tmpDir="${tmpDir}/$(basename "$0").$(date +%s)"
tmpFile=$tmpDir/nodes.out

mkdir -p $tmpDir

#################
# Test connection
#################
if ! $CLI get nodes >/dev/null 2>&1 ; then
  die "ERROR: Can't connect to kubernetes. Check you are logged into your cluster."
fi

################
# Get OC Version
################
OCVERSION=$(getVersion)

echo "Found OpenShift v${OCVERSION}"
echo ""

#Set vars based on OpenShift version
if [ "$OCVERSION" == "4" ]; then
  SSH_USER="core"
  USE_SUDO="sudo"
else
  SSH_USER="root"
  USE_SUDO=""
fi

###############################
# Create Portworx storage class
###############################
if $enable_portworx; then
  portworx
  exit 0
fi

#######################
# Build a list of nodes
#######################
echo "TMP dir = $tmpDir"
echo "Node Directory = ${LOCAL_PATH}/${RELEASE}"

LABEL_ARG=""
if [ "$LABEL" != "" ]; then
  echo "Node Label(s) = $LABEL"
  echo ""
  LABEL_ARG="-l ${LABEL}"
elif [ -n "${AFFINITIES_NODES}" ] ; then
  LABEL_ARG="" # Nodes already specified, any labels specification will be ignored
else
  echo "Node Label(s) = no label specified"
  echo ""
  echo "Retrieving all nodes and labels..."
  $CLI get nodes --no-headers --show-labels |
    while read name junk junk junk junk labels; do echo ""; echo Labels for Node $name; echo "------------------"; echo $labels | tr ',' '\n'; done
  echo ""
  read -p "Please enter comma seperated label(s) (if empty \"beta.kubernetes.io/arch=amd64\" will be used as default): " response
  if [ -z "$response" ]; then
    response="beta.kubernetes.io/arch=amd64"
  fi
  LABEL=${response}
  LABEL_ARG="-l ${LABEL}"
fi

echo ""
echo "Fetching nodes using: $CLI get nodes $LABEL_ARG"
$CLI get nodes $LABEL_ARG --no-headers | cut -f1 -d " " > $tmpFile

nodeCount=$(cat $tmpFile | wc -l)

if [[ $nodeCount -eq 0 ]]; then
  die "ERROR: no nodes were found that matched label $LABEL_ARG"
fi

if [ -z "${AFFINITIES_NODES}" ] && (( $nodeCount < $AFFINITY_MINIMUM_NODE_COUNT )); then
  die "ERROR: The minimum number of nodes required for affinity is $AFFINITY_MINIMUM_NODE_COUNT. Only $nodeCount nodes matched label $LABEL_ARG"
fi
NODES="$(cat "${tmpFile}" | tr $'\n' ' ')"

# Now we have a list of nodes where PV can be placed
# Based on nodeAffinity parameter we decide if we create the PV on all these node
#   or if we bound the PV to some nodes from this list


#######################
# If NodeAffinities --> selecting node, build a list of nodes
#######################

# Helper function from list on nodes (parameter 1, each node on separate line), it randomly selects n (parameter 2) noded.
function selectNodes() {
  local ALL_NODES="$1"
  local COUNT="$2"
  local SELECTED_NODES="$(echo "${ALL_NODES}" | shuf | head -n ${COUNT})"
  echo "${SELECTED_NODES}"
}

# Checks if given node name (1st parameter) is in the list of nodes (2nd parameter, each node on separate line)
function isNodeInNodeList() {
  local NODE_TO_TEST="$1"
  local ALL_NODES="$2"
  local NODE=""
  for NODE in ${ALL_NODES} ; do
    if [ "${NODE_TO_TEST}" = "${NODE}" ] ; then
      return 0
    fi
  done
  return 1
}


# Affinity nodes not specified picking nodes from the node list
if [ -z "${AFFINITIES_NODES}" ] ; then
  AFFINITIES_NODES="$(selectNodes "$(cat "${tmpFile}")" $AFFINITY_MINIMUM_NODE_COUNT | tr $'\n' ' ')"
  echo "Chosen nodes for PVs: ${AFFINITIES_NODES}"
fi

# Checking if provided nodes has required label (i.e., are in the labels list)
for AFFINITY_NODE in ${AFFINITIES_NODES} ; do
    if isNodeInNodeList "${AFFINITY_NODE}" "${NODES}" ; then
      continue
    else
      echo "ERROR: Invalid configuration: In --nodes you specified node \"${AFFINITY_NODE}\" but the node does not exist or does not have required label ${LABEL}"
      exit 1
    fi
done

# Setting nodes per datastores if missing
for PV_TYPE in "${spec_pv_types[@]}" ; do
  # Select a nodes fr  PV f given type in case they are not already specified
  if [ -z "${def_pv_types["${PV_TYPE},nodes"]}" ] ; then
    def_pv_types["${PV_TYPE},nodes"]="$( echo "${AFFINITIES_NODES}" | tr ' ' $'\n' | head -n "${def_pv_types["${PV_TYPE},count"]}" | tr $'\n' ' ' )"
  fi
  for AFFINITY_NODE in ${def_pv_types["${PV_TYPE},nodes"]} ; do
    if isNodeInNodeList "${AFFINITY_NODE}" "${NODES}" ; then
      continue
    else
      echo "ERROR: Invalid configuration: In --nodesForDatastore ${PV_TYPE} parameter there is specified node \"${AFFINITY_NODE}\" but the node does not exist or do not have required label ${LABEL}"
      exit 1
    fi
  done
done


#########################################
# Generate configuration for each PV
#########################################

declare -a pv_names # Keys to associative array specifying each PV
declare -A pv_spec
pv_names=( "first_will_be_deleted" )

for PV_TYPE in "${spec_pv_types[@]}" ; do
  if ([ "$pgBackupLocalStorage" == "only" ] && [ "$PV_TYPE" != "backup" ]) || ([ "$pgBackupLocalStorage" == "false" ] && [ "$PV_TYPE" == "backup" ]); then
    echo "Skipping $PV_TYPE as pgBackupLocalStorage is set to $pgBackupLocalStorage"
  else
    for idx in `seq 1 ${def_pv_types["${PV_TYPE},count"]}` ; do
      VOLUME="${PV_TYPE}-$( echo "${def_pv_types["${PV_TYPE},size"]}" | tr '[:upper:]' '[:lower:]' )-${idx}"
      pv_names=("${pv_names[@]}" "${VOLUME}")
      pv_spec["${VOLUME},name"]="wa-${RELEASE}-${VOLUME}"
      pv_spec["${VOLUME},node_path"]="${LOCAL_PATH}/${RELEASE}/${VOLUME}"
      pv_spec["${VOLUME},size"]="${def_pv_types["${PV_TYPE},size"]}"
      pv_spec["${VOLUME},label"]="dedication: wa-${RELEASE}-${PV_TYPE}"

      declare -a pv_nodes=( ${def_pv_types["${PV_TYPE},nodes"]} )
      idx1=$(( idx - 1 ))
      pv_node="${pv_nodes[idx1]}"

     pv_spec["${VOLUME},node"]="${pv_node}"
     pv_spec["${VOLUME},node_label"]="${LABEL}"
    done
  fi
done
# removing first element
pv_names=("${pv_names[@]:1}")

# Create PV of local storage type + on selected worker(s) it creates the directory
# Parameter the PV_NAME, key in the pv_spec arrays
function createPV() {
  local pv_name="$1"

  echo ""
  local NAME="${pv_spec["${pv_name},name"]}"
  echo "Creating PV: ${NAME}"
  local NODE_PATH="${pv_spec["${pv_name},node_path"]}"
  echo "  directory on node(s): ${NODE_PATH}"
  local LABEL="${pv_spec["${pv_name},label"]}"
  echo "  PV label: ${LABEL}"
  echo "  PV label: release: ${RELEASE}"
  local SIZE="${pv_spec["${pv_name},size"]}"
  echo "  size: ${SIZE}"
  local NODE_LABEL="${pv_spec["${pv_name},node_label"]}"
  if [ -n "${NODE_LABEL}" ] ; then
    echo "  node label: ${NODE_LABEL}"
  fi
  local NODE="${pv_spec["${pv_name},node"]}"

  echo "*************** Checking nodes for existing data directories"
  #Check the node for an existing dir
  RC=0
  set +e
  ssh $SSH_ARGS $SSH_USER@${NODE} "ls ${NODE_PATH} >/dev/null 2>&1"
  RC=$?
  set -e

  if [ "$RC" == "0" ]; then
    #RC is 0 which means we found the dir already exists
    if $force_dir_creation; then
      # the user specified the force option, confirm they want to delete the dir
      read -r -p "Are you sure you want to delete ${NODE_PATH} on node ${NODE}? [y/N] " response
      case "$response" in
        [yY][eE][sS]|[yY])
          ssh $SSH_ARGS $SSH_USER@${NODE} rm -fr ${NODE_PATH} && echo "${NODE_PATH} on node ${NODE} has been deleted"
          ;;
        *)
          echo "Exiting - found ${NODE_PATH} on node ${NODE} and user responded not to delete."
          exit 1
          ;;
      esac
    else
      # the user didn't specify the force option, fail if the data directory exists
      echo "Exiting - found ${NODE_PATH} on node ${NODE}. To delete this directory and recreate it, please specify the --force option."
      exit 1
    fi
  fi

  echo "  directory will be created on node: ${NODE}"
  echo ssh $SSH_ARGS $SSH_USER@${NODE} ${USE_SUDO} mkdir -p "${NODE_PATH}"
       ssh $SSH_ARGS $SSH_USER@${NODE} ${USE_SUDO} mkdir -p "${NODE_PATH}"

  cat << EOF >"$tmpDir/${pv_name}.yaml"
apiVersion: v1
kind: PersistentVolume
metadata:
  finalizers:
  - kubernetes.io/pv-protection
  name: "${NAME}"
  labels:
     ${LABEL}
     release: "${RELEASE}"
spec:
  capacity:
    storage: ${SIZE}
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  local:
    path: "${NODE_PATH}"
EOF
  cat << EOF >>"$tmpDir/${pv_name}.yaml"
  nodeAffinity:
    required:
      nodeSelectorTerms:
EOF
  if [ -n "${NODE_LABEL}" ] ; then
    echo "      - matchExpressions:"              >>"$tmpDir/${pv_name}.yaml"
    echo "        - key: \"${NODE_LABEL%=*}\""    >>"$tmpDir/${pv_name}.yaml"
    if [ "${NODE_LABEL##*=}" != "${NODE_LABEL}" ] ; then
      echo "          operator: In"               >>"$tmpDir/${pv_name}.yaml"
      echo "          values:"                    >>"$tmpDir/${pv_name}.yaml"
      echo "          - \"${NODE_LABEL##*=}\""    >>"$tmpDir/${pv_name}.yaml"
    else
      echo "          operator: Exists"           >>"$tmpDir/${pv_name}.yaml"
    fi
  fi

  echo "      - matchExpressions:"              >>"$tmpDir/${pv_name}.yaml"
  echo "        - key: kubernetes.io/hostname"  >>"$tmpDir/${pv_name}.yaml"
  echo "          operator: In"                 >>"$tmpDir/${pv_name}.yaml"
  echo "          values:"                      >>"$tmpDir/${pv_name}.yaml"
  echo "          - \"${NODE}\""                >>"$tmpDir/${pv_name}.yaml"

  #cat "$tmpDir/${pv_name}.yaml"
  #$CLI apply -f "$tmpDir/${pv_name}.yaml" --dry-run
  $CLI apply -f "$tmpDir/${pv_name}.yaml"
}


for pv_name in "${pv_names[@]}" ; do
  createPV "${pv_name}"
done


echo
echo
echo "*************** Dumping directories on nodes"
echo "* Note: not all nodes will have directory populated since each PV is bounded to a single node."

for NODE in ${NODES} ; do
  echo "${NODE} - content of the ${LOCAL_PATH}/${RELEASE}/ directory:"
  ssh $SSH_ARGS $SSH_USER@${NODE} ls -la "${LOCAL_PATH}/${RELEASE}/" 2>/dev/null || true
done

echo "*************** Creating $baseDir/wa-persistence.yaml. Use this values file during helm install (to instruct WA to use created volumes)"
if [ "$pgBackupLocalStorage" != "only" ]; then
cat <<END >wa-persistence.yaml
cos:
 minio:
  persistence:
   useDynamicProvisioning: false
   selector:
    label: "dedication"
    value: "wa-${RELEASE}-minio"
etcd:
 config:
  persistence:
   useDynamicProvisioning: false
  dataPVC:
   selector:
    label: "dedication"
    value: "wa-${RELEASE}-etcd"
mongodb:
 config:
  persistentVolume:
   useDynamicProvisioning: false
  selector:
   label: "dedication"
   value: "wa-${RELEASE}-mongodb"
postgres:
 config:
  persistence:
   useDynamicProvisioning: false
  dataPVC:
   selector:
    label: "dedication"
    value: "wa-${RELEASE}-postgres"
END
fi
if [ "$pgBackupLocalStorage" == "true" ]; then
cat <<END >>wa-persistence.yaml
 backup:
  persistence:
   useDynamicProvisioning: false
  dataPVC:
   selector:
    label: "dedication"
    value: "wa-${RELEASE}-backup"
END
fi
if [ "$pgBackupLocalStorage" == "only" ]; then
cat <<END >wa-persistence.yaml
postgres:
 backup:
  persistence:
   useDynamicProvisioning: false
  dataPVC:
   selector:
    label: "dedication"
    value: "wa-${RELEASE}-backup"
END
fi
