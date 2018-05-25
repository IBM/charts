# /bin/sh
#
#Licensed Materials - Property of IBM
#5737-E67
#(C) Copyright IBM Corporation 2016, 2018 All Rights Reserved.
#US Government Users Restricted Rights - Use, duplication or
#disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#

# Save the current replica counts, so that we can start the same number later
# Protect against overwritting the counts if stop is run more than once in a row.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
some_stopped=$(kubectl get -n services deploy -l release=cam -o custom-columns=NAME:.metadata.name,DESIRED:spec.replicas --no-headers | grep 0)
if [ -n "$some_stopped" -a -f "saved_replicas.txt" ]; then
  echo 'At least one pod is already stopped and a saved_replicas.txt file already exists; will not overwrite'
else
  kubectl get -n services deploy -l release=cam -o custom-columns=NAME:.metadata.name,DESIRED:spec.replicas --no-headers > $DIR/saved_replicas.txt
fi

# Set the field separator to newline so the loop will process a full line at a time
IFS=$'\n'
for deployment in $(kubectl get deployments -n services -l release=cam -o custom-columns=NAME:.metadata.name,DESIRED:spec.replicas --no-headers); do
  name=$(echo $deployment | awk '{print $1}')
  count=$(echo $deployment | awk '{print $2}')
  if [ $count == 0 ]; then
    echo "$name already stopped"
  else   
    echo "Stopping $name"
    kubectl scale -n services deployment $name --replicas=0 1>/dev/null &
  fi
done

# Wait for all CAM pods to terminate
pods=$(kubectl get -n services -l release=cam pod -o name)
while [ "${pods}" ]; do
        echo 'Waiting for pods to terminate'
        kubectl get -n services -l release=cam pod
        sleep 2
        pods=$(kubectl get -n services -l release=cam pod -o name)
done
echo "All pods terminated"
