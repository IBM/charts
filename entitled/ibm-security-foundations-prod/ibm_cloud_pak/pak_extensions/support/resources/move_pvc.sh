#!/bin/bash
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corporation 2016, 2020. All Rights Reserved.
# US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
# This script patches the PV associated with a PVC to retain the data in the PV even when the
# PVC is deleted

function usage()
{
  echo "This command moves a PVC definition from one namespace to another"
  echo ""
  echo "Syntax: move_pvc [-fromnamespace namespacename] -tonamespace namespacename pvcName"
  echo "WHERE:"
  echo "  fromnamespace: specifies the source namespace where the PVC is currently found.  "
  echo "                 If not specified it is assumed that the PVC is in the cirrent namespace."
  echo "    tonamespace: the name of the namespace to which the PVC is to be moved"
  echo "The user must already be logged into the clutser using the oc command line and have cluster admin authotity "
  echo ""
}

base_dir="$(cd $(dirname $0) && pwd)"

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -fromnamespace)
    FROMNAMESPACE="$2"
    shift # past argument
    shift # past value
    ;;
    -tonamespace)
    TONAMESPACE="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    if [ -z $PVC ]; then
      PVC=$1
    else
      usage
      exit
    fi
    shift # past argument
    ;;
esac
done

if [ -z $FROMNAMESPACE ]; then
  FROMNAMESPACE=$(oc project -q)
fi

echo "PVC " $PVC " from " $FROMNAMESPACE " to " $TONAMESPACE

if [ -z $PVC ]; then
  usage
  exit
fi

oc get namespace $FROMNAMESPACE >/dev/null
if [ $? -ne 0 ]
then
  echo "Namespace " $FROMNAMESPACE " not found"
  exit 1
fi
oc get namespace $TONAMESPACE >/dev/null
if [ $? -ne 0 ]
then
  echo "Namespace " $TONAMESPACE " not found"
  exit 1
fi
PV=$(oc get pvc $PVC -n $FROMNAMESPACE  -o=jsonpath='{.spec.volumeName}')
if [ $? -ne 0 ]
then
  echo "PVC " $PVC " in namespace " $FROMNAMESPACE " not found"
  exit 1
fi

PV=$(oc get pvc $PVC -n $FROMNAMESPACE  -o=jsonpath='{.spec.volumeName}')
PVCSTGCLASS=$(oc get pvc $PVC -n $FROMNAMESPACE  -o=jsonpath='{.spec.storageClassName}')
PVCSTORAGE=$(oc get pvc $PVC -n $FROMNAMESPACE  -o=jsonpath='{.spec.resources.requests.storage}')

echo Moving PVC $PVC from $FROMNAMEPACE to $TONAMESPACE
echo Storage Class $PVCSTGCLASS with storage request $PVCSTORAGE and volume $PV in $TONAMESPACE

chmod +x "$base_dir"/patch_pv_retain.sh
"$base_dir"/patch_pv_retain.sh $PVC -n $FROMNAMESPACE
if [ $? -ne 0 ]
then
  exit 1
fi
oc delete pod cp4s-toolbox 2>/dev/null
oc delete pvc $PVC -n $FROMNAMESPACE --wait=false
oc patch pvc $PVC -n $FROMNAMESPACE -p '{"metadata":{"finalizers":null}}' 2>/dev/null
oc patch pv $PV --type json -p='[{"op": "remove", "path": "/spec/claimRef"}]'
oc annotate pv $PV volume.beta.kubernetes.io/storage-class-
cat <<EOF | oc apply -n $TONAMESPACE -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: $PVC
  namespace: $TONAMESPACE
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: $PVCSTORAGE
  storageClassName: $PVCSTGCLASS
  volumeName: $PV
EOF
if [ $? -ne 0 ]
then
  exit 1
fi
sleep 5
PVC_UID=$(oc -n $TONAMESPACE get pvc $PVC -o jsonpath="{.metadata.uid}")
oc patch pv $PV --type json -p='[{"op": "add", "path": "/spec/claimRef", "value": {"name":'$PVC', "namespace": '$TONAMESPACE', "uid": '$PVC_UID'}}]'
