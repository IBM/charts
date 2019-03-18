#!/bin/bash
#
#Licensed Materials - Property of IBM
#5737-E67
#(C) Copyright IBM Corporation 2016-2019 All Rights Reserved.
#US Government Users Restricted Rights - Use, duplication or
#disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
for pod in $(kubectl get pods -n services -l release=cam -o custom-columns=NAME:.metadata.name --no-headers | grep -v bpd); do
  VERSION=$(kubectl exec -n services $pod -- cat /usr/src/app/VERSION)
  echo $VERSION   ${pod}
done
