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


if [ "$#" -lt 1 ]; then
  echo "Usage: $0 ICP4D_NAMESPACE (Where ICP4D is installed)"
  exit 1
fi

namespace=$1

# This is necessary because SSL is required in CPD versions 2.5 and above
kubectl -n $namespace exec zen-metastoredb-0 \
-- bash -c "cp -r /certs/ /tmp/ && chmod -R 0700 /tmp/certs/"

kubectl -n $namespace exec zen-metastoredb-0 \
-- sh /cockroach/cockroach.sh sql  \
-e "DELETE FROM zen.service_instances WHERE deleted_at IS NOT NULL RETURNING id;" \
--host='zen-metastoredb-0.zen-metastoredb' --certs-dir='/tmp/certs'

if [ $? -eq 0 ]; then
  exit 0
else
  exit 1
fi