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
# This script can be used to create local-volume PV's for POC
# environments in ICP4D.
#
# It is provided as is and should not be used on Production
# ICP4D environments.
#
# It should be run from a machine that has ssh access to all the
# nodes in your ICP4D development environment.
#
# Usage: createLocalPV.sh [--path PATH] [--label LABEL] [--help]
#
# You can optionally provide the path used on each node to store
# the PV data and the label(s) to use when selecting the nodes.
#
#################################################################

#################################################################
# You may wish to customise the script by changing these
# variables from their defaults
#################################################################
# You can change the user to ssh into each node here, default is root.
SSH_USER="root"
# You can specify ssh args you want to use here, for example if you need to provide an ssh certificate
SSH_ARGS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

# Create a Unique Identifier for the PV's
ID=$(date +%Y-%m-%d--%H-%M)
# The location on each node to store the actual PV data
LOCAL_PATH="/mnt/local-storage/storage/watson/speech"
# The node labels to use when selecting which nodes to create local-volume directories on.
# If no label is specified, all the nodes / labels will be listed as options.
LABEL=""

# Directory to store temporary files
tmpDir=/tmp/createLocalVolumePV.$$
mkdir -p $tmpDir
# Temporary file, deleted at the end of the script
tmpFile=$tmpDir/nodes.out
#################################################################
# End of variables
#################################################################

function die() {
    echo "$@" 1>&2
    exit 99
}

function help() {
    echo "$(basename $0)"
    echo "  -p, --path                     ... path within the k8 node where the PV data will be stored [${LOCAL_PATH}]"
    echo "  -l, --label                    ... the k8 label(s) used to select which k8 nodes to create the local-volume dirs on. If not specified, the available nodes and labels will be displayed for you"
    echo "  -h, --help                     ... show this help"
}

while (( $# > 0 )); do
  case "$1" in
    -p | --p | --path )
      if [[ $2 == -* ]] || [[ $2 == "" ]]; then
        die "ERROR: Path argument has no value"
      fi
      shift
      LOCAL_PATH="$1"
      ;;
    -l | --l | --label )
      if [[ $2 == -* ]] || [[ $2 == "" ]]; then
        die "ERROR: Label argument has no value"
      fi
      shift
      LABEL="$1"
      ;;
    -h | --h | --help )
      help
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
# Create a local storage class if doesn't exist
# Get a list of worker nodes
# ssh into each node and create a dir for each PV
# Generate templates for each size of PV
# Render the templates
# Apply the templates
# Clean the tmp dir
#################################################################

#################
# Test connection
#################
kubectl get nodes >/dev/null 2>&1
if [ $? -ne 0 ]
then
    die "ERROR: Can't connect to kubernetes. Check you are logged into OpenShift (oc whoami)."
fi

############################
# Create local storage class
############################
if kubectl get storageclass -o custom-columns=NAME:.metadata.name --no-headers | grep -q "local-storage-local"; then
    echo "Storage class local-storage-local already exists"
else
    echo "Local storage class doesn't exist. Creating it"
    cat <<EOF | kubectl apply -f -
    kind: StorageClass
    apiVersion: storage.k8s.io/v1
    metadata:
      name: local-storage-local
    provisioner: kubernetes.io/no-provisioner
    volumeBindingMode: WaitForFirstConsumer
EOF
fi

#######################
# Build a list of nodes
#######################
echo "TMP dir = $tmpDir"
echo "Node Directory = $LOCAL_PATH"
if [ "$LABEL" != "" ]; then
    echo "Node Label(s) = $LABEL"
    echo ""
    response=$LABEL
else
    echo "Node Label(s) = no label specified"
    echo ""
    echo "Retrieving all nodes and labels..."
    kubectl get nodes --no-headers --show-labels |
        while read name junk junk junk junk labels; do echo ""; echo Labels for Node $name; echo "------------------"; echo $labels | tr ',' '\n'; done
    echo ""
    read -p "Please enter comma seperated label(s) (type 'all' to select all nodes): " response
fi

LABEL_ARG=""
if [ "$response" != "all" ]; then
    LABEL_ARG="-l $response"
fi

echo ""
echo "Fetching nodes using: kubectl get nodes $LABEL_ARG"
kubectl get nodes $LABEL_ARG --no-headers | cut -f1 -d " " > $tmpFile

nodeCount=$(cat $tmpFile | wc -l)

if [[ $nodeCount -eq 0 ]]; then
    die "ERROR: no nodes were found that matched label $LABEL_ARG"
fi

echo ""
echo "Processing $nodeCount node(s):"

###########################################
# On each node:
#   Create 3 dirs for PV's of size 5GB
#   Create 3 dirs for PV's of size 10GB
#   Create 6 dirs for PV's of size 200GB
###########################################
echo ""
echo "Creating directories on nodes under $LOCAL_PATH"

while read -u10 node; do
    echo ""
    echo "Processing node $node"
    ssh $SSH_ARGS $SSH_USER@$node /bin/bash << EOF
for i in 1 2 3; do mkdir -vp "$LOCAL_PATH"/pv_5gb-speech"-${ID}"-\${i}; done
for i in 1 2 3; do mkdir -vp "$LOCAL_PATH"/pv_10gb-speech"-${ID}"-\${i}; done
for i in 1 2 3 4 5 6; do mkdir -vp "$LOCAL_PATH"/pv_200gb-speech"-${ID}"-\${i}; done
EOF
done 10< $tmpFile

##########################
# Create PV yaml templates
##########################
for size in 5 10 200; do
  cat << EOF > $tmpDir/pv_${size}_template.tpl
apiVersion: v1
kind: PersistentVolume
metadata:
  finalizers:
  - kubernetes.io/pv-protection
  name: local-storage-local-pv-${size}gb-speech-__ID__-__CNT__
  labels:
    id: ${ID}
spec:
  capacity:
    storage: ${size}Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage-local
  local:
    path: $LOCAL_PATH/pv_${size}gb-speech-__ID__-__CNT__
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - __NODE__
EOF
done

# put the list of nodes into an array
mapfile -t nodeArray < $tmpFile

#########################
# Create:
#   3 5GB PV's
#   3 10GB PV's
#   6 200GB PV's
#########################
mkdir -p $tmpDir/rendered

i=0 # we wont reset this index so the PVs are more evenly distributed across all the nodes (we do not want to favor the first nodes in the array)
for CNT in 1 2 3; do
  n=${nodeArray[i%$nodeCount]}
  i=$((i+1))
  cat $tmpDir/pv_5_template.tpl | sed "s#__CNT__#${CNT}#g" | sed "s#__ID__#${ID}#g" | sed "s#__NODE__#${n}#g" > $tmpDir/rendered/pv_5gb_${CNT}.yaml
done

for CNT in 1 2 3; do
  n=${nodeArray[i%$nodeCount]}
  i=$((i+1))
  cat $tmpDir/pv_10_template.tpl | sed "s#__CNT__#${CNT}#g" | sed "s#__ID__#${ID}#g" | sed "s#__NODE__#${n}#g" > $tmpDir/rendered/pv_10gb_${CNT}.yaml
done

for CNT in 1 2 3 4 5 6; do
  n=${nodeArray[i%$nodeCount]}
  i=$((i+1))
  cat $tmpDir/pv_200_template.tpl | sed "s#__CNT__#${CNT}#g" | sed "s#__ID__#${ID}#g" | sed "s#__NODE__#${n}#g" > $tmpDir/rendered/pv_200gb_${CNT}.yaml
done

echo ""
echo "Creating PVs"

kubectl apply -f $tmpDir/rendered

rm -fr $tmpDir
