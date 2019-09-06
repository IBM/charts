#!/bin/bash
#
#Licensed Materials - Property of IBM
#5737-E67
#(C) Copyright IBM Corporation 2016-2019 All Rights Reserved.
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
  echo "Starting CAM release: $camRelease"
else
  echo "Error: Unable to find CAM release"
  exit 1;
fi

# Start deployments
# Read any saved replica count values generated from the stop command
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -f $DIR/saved_replicas.txt ]; then
  echo "Using saved replica counts in $DIR/saved_replicas.txt"
  deployments=$(cat $DIR/saved_replicas.txt)
else
  echo 'Unable to find saved replica counts; will default to a value of 1'
  deployments=$(kubectl get deployments -n $NAMESPACE -l release=$camRelease -o custom-columns=NAME:.metadata.name)
fi

# Set internal field separator to newline, so we loop over each line in the output
IFS=$'\n'
for deployment in $deployments; do
  name=$(echo $deployment | awk '{print $1}')
  count=$(echo $deployment | awk '{print $2}')
  if [ -z "$count" ]; then
    count=1
  fi
  if [ $count == 0 ]; then
    echo 'Saved value of count was zero, will use 1 instead'
    count=1
  fi
  echo "Starting $name with replica count of $count"
  kubectl scale -n $NAMESPACE deployment $name --replicas=$count 1>/dev/null &
done

# Start statefulsets
if [ -f $DIR/statefulset_saved_replicas.txt ]; then
  echo "Using saved replica counts in $DIR/statefulset_saved_replicas.txt"
  statefulsets=$(cat $DIR/statefulset_saved_replicas.txt)
else
  echo 'Unable to find saved replica counts; will default to a value of 1'
  statefulsets=$(kubectl get statefulsets -n $NAMESPACE -l release=$camRelease -o custom-columns=NAME:.metadata.name)
fi

# Set internal field separator to newline, so we loop over each line in the output
IFS=$'\n'
for statefulset in $statefulsets; do
  name=$(echo $statefulset | awk '{print $1}')
  count=$(echo $statefulset | awk '{print $2}')
  if [ -z "$count" ]; then
    count=1
  fi
  if [ $count == 0 ]; then
    echo 'Saved value of count was zero, will use 1 instead'
    count=1
  fi
  echo "Starting $name with replica count of $count"
  kubectl scale -n $NAMESPACE statefulset $name --replicas=$count 1>/dev/null &
done

# Wait for all pods to start
echo "Waiting for pods to be in Running state"
sleep 15

pods=$(kubectl -n $NAMESPACE get -l release=$camRelease pods --no-headers | grep Running -v)
while [ "${pods}" ]; do
  echo "Waiting for pods to be in Running state"
  kubectl -n $NAMESPACE get -l release=$camRelease pod
  sleep 5
  pods=$(kubectl -n $NAMESPACE get -l release=$camRelease pods --no-headers | grep Running -v)
done
echo "All pods Running"
