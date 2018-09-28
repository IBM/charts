#!/bin/bash
#
#Licensed Materials - Property of IBM
#5737-E67
#(C) Copyright IBM Corporation 2016, 2018 All Rights Reserved.
#US Government Users Restricted Rights - Use, duplication or
#disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#

NAMESPACE=services

# Determine helm release name for CAM; auto-detected by default, but can be overriden by user
if [ $1 ]; then
  foundCam=$(helm list $1 --tls | grep ibm-cam )
  if [ -n "$foundCam" ]; then
    camRelease=$1
  else 
    echo "Error: Specified helm release is not found, or is not a CAM release"
    exit 1;
  fi
else
  camRelease=$(helm list --tls | grep ibm-cam | awk '{ print $1 }')
fi

if [ -n "$camRelease" ]; then
  echo "Stopping CAM release: $camRelease"
else
  echo "Error: Unable to find CAM release"
  exit 1;
fi

# Save the current replica counts, so that we can start the same number later
# Protect against overwritting the counts if stop is run more than once in a row.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
some_stopped=$(kubectl get -n $NAMESPACE deploy -l release=$camRelease -o custom-columns=NAME:.metadata.name,DESIRED:spec.replicas --no-headers | grep 0)
if [ -n "$some_stopped" -a -f "saved_replicas.txt" ]; then
  echo 'At least one pod is already stopped and a saved_replicas.txt file already exists; will not overwrite'
else
  kubectl get -n $NAMESPACE deploy -l release=$camRelease -o custom-columns=NAME:.metadata.name,DESIRED:spec.replicas --no-headers > $DIR/saved_replicas.txt
fi

# Set the field separator to newline so the loop will process a full line at a time
IFS=$'\n'
for deployment in $(kubectl get deployments -n $NAMESPACE -l release=$camRelease -o custom-columns=NAME:.metadata.name,DESIRED:spec.replicas --no-headers); do
  name=$(echo $deployment | awk '{print $1}')
  count=$(echo $deployment | awk '{print $2}')
  if [ $count == 0 ]; then
    echo "$name already stopped"
  else   
    echo "Stopping $name"
    kubectl scale -n $NAMESPACE deployment $name --replicas=0 1>/dev/null &
  fi
done

# Wait for all CAM pods to terminate
pods=$(kubectl get -n $NAMESPACE -l release=$camRelease pod -o name)
while [ "${pods}" ]; do
        echo 'Waiting for pods to terminate'
        kubectl get -n $NAMESPACE -l release=$camRelease pod
        sleep 2
        pods=$(kubectl get -n $NAMESPACE -l release=$camRelease pod -o name)
done
echo "All pods terminated"
