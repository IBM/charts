#!/bin/bash

# Exit when failures occur (including unset variables)
set -o errexit
set -o nounset
set -o pipefail

# Verify pre-req environment
command -v kubectl > /dev/null 2>&1 || { echo "kubectl pre-req is missing."; exit 1; }

while test $# -gt 0; do
        [[ $1 =~ ^-c|--chartrelease$ ]] && { chartRelease="$2"; shift 2; continue; };
        echo "Parameter not recognized: $1, ignored"
        shift
done
: "${chartRelease:="default"}"

function check_for_pod { 
	RESULT=1	
	for (( TRIES=0; TRIES<=50; TRIES++ ))
	do	  
	  echo "waiting for pod '$1'..."
	  if kubectl get pods | grep $1 | grep $2 | grep $3; then
	    RESULT=0
	    break	   
	  fi
	  sleep 5
	done
	if [ $RESULT -eq 1 ]; then
		echo "FAIL: the pod '$1' is not ok:"
		kubectl get pods | grep $1 || true
	fi
	return $RESULT	
}

# Verify Pod created
echo "checking for pods in chart release '$chartRelease'"
check_for_pod dd-scenario-api Running 1/1
check_for_pod dd-scenario-ui Running 1/1
check_for_pod dd-cognitive Running 1/1
check_for_pod dd-init Completed 0/1

echo "SUCCESS - Pods are ok in '$chartRelease'"
exit 0

