# /bin/sh
#
#Licensed Materials - Property of IBM
#5737-E67
#(C) Copyright IBM Corporation 2016, 2018 All Rights Reserved.
#US Government Users Restricted Rights - Use, duplication or
#disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#

# Read any saved replica count values generated from the stop command
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -f $DIR/saved_replicas.txt ]; then
  echo "Using saved replica counts in $DIR/saved_replicas.txt"
  deployments=$(cat $DIR/saved_replicas.txt)
else
  echo 'Unable to find saved replica counts; will default to a value of 1'
  deployments=$(kubectl get deployments -n services -l release=cam -o custom-columns=NAME:.metadata.name)
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
  kubectl scale -n services deployment $name --replicas=$count 1>/dev/null &
done

# Wait for all pods to start
echo "Waiting for pods to be in Running state"
sleep 15

pods=$(kubectl -n services get -l release=cam pods --no-headers | grep Running -v)
while [ "${pods}" ]; do
  echo "Waiting for pods to be in Running state"
  kubectl -n services get -l release=cam pod
  sleep 5
  pods=$(kubectl -n services get -l release=cam pods --no-headers | grep Running -v)
done
echo "All pods Running"
