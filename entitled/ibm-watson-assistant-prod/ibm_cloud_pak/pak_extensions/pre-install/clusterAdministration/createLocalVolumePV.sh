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
# This script can be used to create local-volume PV's for POC environments in ICP4D.
#
# It is provided as is and should not be used on Production ICP4D environments.
#
# It should be run from a machine that has ssh access to all the nodes in your ICP4D development environment.
#
# Usage: createLocalVolumePV.sh [--path PATH]  [--release RELEASE_NAME]  [--label LABEL] [--nodeAffinities [node1,node2,node3,node4]] [--nodesForDatastore DATASTORE node1,node2,...,node_n] [--help]
#
# You can optionally provide the (base) path used on (each) nodes to store the PV data (defaults to /mnt/local-storage/storage/watson/assistant)
#    actual PV are then created as a subdirectories at ${PATH}/${RELEASE_NAME}/${VOLUME} (where VOLUME are like mongodb-80gi-1)
# You can optionally provide the release name for which you create the PV              (defaults to timestamp in a format: YYYY-MM-DD--HH-mm)
# You can optionally specify the label(s) to use when selecting the nodes. If not provided you may be asked for a label iteractively.
#                        consider using e.g., --label node-role.kubernetes.io/worker=true"
#                        or                   --label beta.kubernetes.io/arch=amd64"
#
#
# You can optionally specify that the PV should be bounded to specified nodes using (--nodeAffinities) - Recommended.
#     After --nodeAffinity you can provide 4 comma separated node names to be used for PVs;
#            if not provided, 4 nodes are randomly selected from nodes having specified label.
#
# Considerations for DEV clusters having less then 4 nodes.
#    In such a case you have to provide the list of 4 nodes as a parameter, but you can specify a node multiple times in the list.
#      e.g., --nodeAffinities node1,node2,node1,node2
#    Notice that for such a cluster you have to set --values global.podAntiAffinity=Disable
#
# The scipt will bound PVs using this schema:
#    PV type  | node1                              | node2                              | node3                              | node4
#   ----------+------------------------------------+------------------------------------+------------------------------------+------------------------------------
#    mongodb  | wa-${RELEASE_NAME}-mongodb-80gi-1  | wa-${RELEASE_NAME}-mongodb-80gi-2  | wa-${RELEASE_NAME}-mongodb-80gi-3  |
#    etcd     | wa-${RELEASE_NAME}-etcd-10gi-1     | wa-${RELEASE_NAME}-etcd-10gi-2     | wa-${RELEASE_NAME}-etcd-10gi-3     |
#    postgres | wa-${RELEASE_NAME}-postgres-10gi-1 | wa-${RELEASE_NAME}-postgres-10gi-2 | wa-${RELEASE_NAME}-postgres-10gi-3 |
#    minio    | wa-${RELEASE_NAME}-minio-5gi-1     | wa-${RELEASE_NAME}-mini0-5gi-2     | wa-${RELEASE_NAME}-minio-5gi-3     | wa-${RELEASE_NAME}-minio-5gi-4
#
# You can optionally overrides nodes used by the PV of particular datastore using --nodesForDatastore. Can be specified multiple times.
#  Requires --nodeAffinities to be enabled to take action.
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
# You can change the user to ssh into each node here, default is root.
SSH_USER="root"
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
tmpDir=/tmp/createLocalVolumePV.$$
mkdir -p $tmpDir
# Temporary file, deleted at the end of the script
tmpFile=$tmpDir/nodes.out


NODE_AFFINITIES_ENABLED=false # Specifies if node affinities are enabled or disabled
declare AFFINITIES_NODES=""   # Space separated list of nodes for node affinities (default if not provided for particular PV type)

#################################################################
# End of variables
#################################################################

function die() {
  echo "$@" 1>&2

  exit 99
}

function showHelp() {
  echo "Usage createLocalVolumePV.sh [--path PATH] [--release RELEASE_NAME] [--label LABEL] [--nodeAffinities [node1,node2,node3,node4]] [--nodesForDatastore DATASTORE node1,node2,...,node_n] [--help]"
  echo "Script creates local-storage persistent volumes on cluster nodes."
  echo ""
  echo "--path: You can optionally provide the (base) path used on nodes to store the PV data (defaults to /mnt/local-storage/storage/watson/assistant)"
  echo "          PV are then created as a subdirectories at \${PATH}/\${RELEASE_NAME}/\${VOLUME} (where VOLUMEs are like mongodb-80gi-1)"
  echo "--release: You can optionally specify the name of the release for which the PVs are created. (defaults to timestamp in a format: YYYY-MM-DD--HH-mm)"
  echo "            consider using e.g., --label node-role.kubernetes.io/worker=true"
  echo "--label: The label(s) used to select which nodes to create the local-volume dirs on. If not provided you may be asked for a label iteractively."
  echo "         consider using e.g., --label node-role.kubernetes.io/worker=true"
  echo "           or                 --label beta.kubernetes.io/arch=amd64"
  echo ""
  echo "--nodeAffinities: If specified PV will be bounded to specified some node. (recommended)"
  echo "    After --nodeAffinity you can optinally provide a list of 4 comma separated node names to be used for PVs;"
  echo "            if node names are not provided, 4 nodes are randomly selected from nodes having specified label."
  echo ""
  echo "    Considerations for DEV clusters having less then 4 nodes."
  echo "      In such a case you have to provide the list of 4 nodes as a parameter, but you can specify a node multiple times in the list."
  echo "        e.g., --nodeAffinities node1,node2,node1,node2"
  echo "      Notice that for such a cluster you have to set --values global.podAntiAffinity=Disable"
  echo ""
  echo "    If --nodeAffinities is specified, the scipt will bound PVs using this schema:"
  echo "      PV type  | node1                              | node2                              | node3                              | node4"
  echo "     ----------+------------------------------------+------------------------------------+------------------------------------+------------------------------------"
  echo "      mongodb  | wa-\${RELEASE_NAME}-mongodb-80gi-1  | wa-\${RELEASE_NAME}-mongodb-80gi-2  | wa-\${RELEASE_NAME}-mongodb-80gi-3  | "
  echo "      etcd     | wa-\${RELEASE_NAME}-etcd-10gi-1     | wa-\${RELEASE_NAME}-etcd-10gi-2     | wa-\${RELEASE_NAME}-etcd-10gi-3     |"
  echo "      postgres | wa-\${RELEASE_NAME}-postgres-10gi-1 | wa-\${RELEASE_NAME}-postgres-10gi-2 | wa-\${RELEASE_NAME}-postgres-10gi-3 |"
  echo "      minio    | wa-\${RELEASE_NAME}-minio-5gi-1     | wa-\${RELEASE_NAME}-mini0-5gi-2     | wa-\${RELEASE_NAME}-minio-5gi-3     | wa-\${RELEASE_NAME}-minio-5gi-4"
  echo ""
  echo "--nodesForDatastore: If specified can override the nodes to be used for particular datastore. Can be specified multiple times for different DATASTORES."
  echo "    Expects 2 parameters: DATASTORE - datastore for which the nodes (of PVs) are specified. Supported datastores: ${spec_pv_types[@]}"
  echo "      Comma separated nodes list, must be at least of length 3 except minio which requires 4 nodes."
  echo "           e.g., node1,node2,node3 means: first PV will be bounded to node1, second PV will be bounded to node2, ..."
  echo "  If you wish completely specify the nodes for each datastore use: "
  echo "    --nodeAffinities --nodesForDatastore mongodb node1,node2,node3 --nodesForDatastore etcd node4,node5,node6 --nodesForDatastore postgres node7,node8,node9 --nodesForDatastore minio node10,node11,node12,node13"
  echo "    Notice that there is no need to use different nodes for different datastores (as in the example above), but we suggest not to reuse nodes for a single datastores if not required by cluster size."
  echo ""
  echo "--help: Displays this help message."
  echo ""
  echo "----------------------------------------------------------------------------------"
  echo "This script can be used to create local-volume PV's for POC environments in ICP4D."
  echo "Script is provided as is and should not be used on Production ICP4D environments."
  echo ""
  echo "It should be run from a machine that has ssh access to all the nodes in your ICP4D development environment."
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
def_pv_types["${type},count"]=3
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


#############################
# Processing command-line parameters
#############################
while (( $# > 0 )); do
  case "$1" in
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
    -n | --na | --nodeAffinities )
      NODE_AFFINITIES_ENABLED=true
      if (( $# > 1 )); then
        if [[ $2 != -* ]] && [[ $2 != "" ]]; then
          AFFINITIES_NODES="$( echo "$2" | tr "," " ")"
          shift
        fi
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

#################################################################
# Start of main script
#
# Test connection
# Get a list of (worker) nodes
# If nodeAffinities
#    select/check node are correctly labeled.
# Generate configuration for each PV
#
# For each PV
#   ssh into each node and create a dir for each PV
#   Render the templates
#   Apply the templates
#
# Clean the tmp dir
#################################################################

#################
# Test connection
#################
if ! kubectl get nodes >/dev/null 2>&1 ; then
  die "ERROR: Can't connect to kubernetes. Check you are logged into OpenShift (oc whoami)."
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
elif [ "true" = "${NODE_AFFINITIES_ENABLED}" ] ; then
  # No label specified but nodeAffinities enabled
  if [ -z "${AFFINITIES_NODES}" ] ; then
    echo "WARNING: Node affinities are enabled and no default nodes provided as well as no label on nodes --> PV will be scheduled on randomly selected nodes (e.g., which can be e.g., master nodes)"
  fi
  LABEL_ARG="" # Selecting all nodes but not setting any labels as PV will have nodeAffitity for a node --> valid PV
else
  echo "Node Label(s) = no label specified"
  echo ""
  echo "Retrieving all nodes and labels..."
  kubectl get nodes --no-headers --show-labels |
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
echo "Fetching nodes using: kubectl get nodes $LABEL_ARG"
kubectl get nodes $LABEL_ARG --no-headers | cut -f1 -d " " > $tmpFile

nodeCount=$(cat $tmpFile | wc -l)

if [[ $nodeCount -eq 0 ]]; then
  die "ERROR: no nodes were found that matched label $LABEL_ARG"
fi
NODES="$(cat "${tmpFile}" | tr $'\n' ' ')"

# Now we have a list of nodes where PV can be places
# Based on nodeAffinity parameter we decide if we create the PV on all these node
#   or if we bound the PV to some nodes from this list


#######################
# If NodeAffinities --> selecting noded, duild a list of nodes
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

if [ "true" = "${NODE_AFFINITIES_ENABLED}" ] ; then
  if [ -z "${AFFINITIES_NODES}" ] ; then
    AFFINITIES_NODES="$(selectNodes "$(cat "${tmpFile}")" 4 | tr $'\n' ' ')"
    echo "Choosed nodes for PVs: ${AFFINITIES_NODES}"
  fi

  # Checking if provided nodes has required label (i.e., are in the labels list)
  for AFFINITY_NODE in ${AFFINITIES_NODES} ; do
      if isNodeInNodeList "${AFFINITY_NODE}" "${NODES}" ; then
        continue
      else
        echo "ERROR: Invalid configuration: In --nodeAffinities you specified node \"${AFFINITY_NODE}\" but the node does not exist or does not have required label ${LABEL}"
        exit 1
      fi
  done

  # Setting nodes per datastores if missing
  for PV_TYPE in "${spec_pv_types[@]}" ; do
    # Select a nodes fr  PV f given type in case they are not already specified
    if [ -z "${def_pv_types["${PV_TYPE},nodes"]}" ] ; then
      def_pv_types["${PV_TYPE},nodes"]="$( echo "${AFFINITIES_NODES}" | tr ' ' $'\n' | head -n "${def_pv_types["${type},count"]}" | tr $'\n' ' ' )"
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


else
  echo "PV will be places onto $nodeCount node(s):"
  for NODE in ${NODES} ; do
       echo "    ${NODE}"
  done
fi

#########################################
# Generate configuration for each PV
#########################################

declare -a pv_names # Kes tp associative array specifying each PV
declare -A pv_spec
pv_names=( "first_will_be_deleted" )

for PV_TYPE in "${spec_pv_types[@]}" ; do
  for idx in `seq 1 ${def_pv_types["${PV_TYPE},count"]}` ; do
    VOLUME="${PV_TYPE}-$( echo "${def_pv_types["${PV_TYPE},size"]}" | tr '[:upper:]' '[:lower:]' )-${idx}"
    pv_names=("${pv_names[@]}" "${VOLUME}")
    pv_spec["${VOLUME},name"]="wa-${RELEASE}-${VOLUME}"
    pv_spec["${VOLUME},node_path"]="${LOCAL_PATH}/${RELEASE}/${VOLUME}"
    pv_spec["${VOLUME},size"]="${def_pv_types["${PV_TYPE},size"]}"
    pv_spec["${VOLUME},label"]="dedication: wa-${RELEASE}-${PV_TYPE}"

    if [ "true" = "${NODE_AFFINITIES_ENABLED}" ] ; then
      declare -a pv_nodes=( ${def_pv_types["${PV_TYPE},nodes"]} )
      idx1=$(( idx - 1 ))
      pv_node="${pv_nodes[idx1]}"

      pv_spec["${VOLUME},nodes"]="${pv_node}"
      pv_spec["${VOLUME},affinity_nodes"]="${pv_node}"
    else
      pv_spec["${VOLUME},nodes"]="$(cat $tmpFile | tr $'\n' ' ')"
      pv_spec["${VOLUME},affinity_nodes"]=""
    fi
   pv_spec["${VOLUME},node_label"]="${LABEL}"
  done
done
# removimng first element
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
  local NODES_AFFINITY="${pv_spec["${pv_name},affinity_nodes"]}"
  local NODES_LABEL="${pv_spec["${pv_name},node_label"]}"
  if [ -n "${NODES_LABEL}" ] ; then
    echo "  node label: ${NODES_LABEL}"
  fi
  local NODES="${pv_spec["${pv_name},nodes"]}"
  echo "  directory will be created on node(s): ${NODES}"


  for NODE in ${NODES} ; do
     echo ssh $SSH_ARGS $SSH_USER@${NODE} mkdir -p "${NODE_PATH}"
          ssh $SSH_ARGS $SSH_USER@${NODE} mkdir -p "${NODE_PATH}"
  done


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
  if [ -n "${NODES_LABEL}" -o -n "${NODES_AFFINITY}" ] ; then
    cat << EOF >>"$tmpDir/${pv_name}.yaml"
  nodeAffinity:
    required:
      nodeSelectorTerms:
EOF
  fi
  if [ -n "${NODES_LABEL}" ] ; then
    echo "      - matchExpressions:"              >>"$tmpDir/${pv_name}.yaml"
    echo "        - key: \"${NODES_LABEL%=*}\""   >>"$tmpDir/${pv_name}.yaml"
    if [ "${NODES_LABEL##*=}" != "${NODES_LABEL}" ] ; then
      echo "          operator: In"               >>"$tmpDir/${pv_name}.yaml"
      echo "          values:"                    >>"$tmpDir/${pv_name}.yaml"
      echo "          - \"${NODES_LABEL##*=}\""   >>"$tmpDir/${pv_name}.yaml"
    else
      echo "          operator: Exists"           >>"$tmpDir/${pv_name}.yaml"
    fi
  fi
  if [ -n "${NODES_AFFINITY}" ] ; then
    echo "      - matchExpressions:"              >>"$tmpDir/${pv_name}.yaml"
    echo "        - key: kubernetes.io/hostname"  >>"$tmpDir/${pv_name}.yaml"
    echo "          operator: In"                 >>"$tmpDir/${pv_name}.yaml"
    echo "          values:"                      >>"$tmpDir/${pv_name}.yaml"
    for NODE in ${NODES_AFFINITY} ; do
      echo "          - \"${NODE}\""              >>"$tmpDir/${pv_name}.yaml"
    done
  fi

  #cat "$tmpDir/${pv_name}.yaml"
  #kubectl apply -f "$tmpDir/${pv_name}.yaml" --dry-run
  kubectl apply -f "$tmpDir/${pv_name}.yaml"
}


for pv_name in "${pv_names[@]}" ; do
  createPV "${pv_name}"
done


echo
echo
echo "*************** Dumping directories on nodes"
if [ "true" = "${NODE_AFFINITIES_ENABLED}" ] ; then
  echo "* Note: not all nodes will have directory populated since  not all nodes may have some PV bounded."
fi
for NODE in ${NODES} ; do
  echo "${NODE} - content of the ${LOCAL_PATH}/${RELEASE}/ directory:"
  ssh $SSH_ARGS $SSH_USER@${NODE} ls -la "${LOCAL_PATH}/${RELEASE}/" 2>/dev/null || true
done

rm -fr $tmpDir
