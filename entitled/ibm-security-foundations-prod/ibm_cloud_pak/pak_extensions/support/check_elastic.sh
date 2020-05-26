#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2018.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################
#

pass=$(kubectl get secret isc-cases-elastic-ibm-dba-ek-creds -o jsonpath='{.data.elasticsearch-password}'|base64 --decode)
user=$(kubectl get secret isc-cases-elastic-ibm-dba-ek-creds -o jsonpath='{.data.elasticsearch-username}'|base64 --decode)
creds=$(kubectl get deploy ibm-dba-ek-isc-cases-elastic-ibm-dba-ek-client -o yaml | grep Basic | sed -e 's/^.*Basic //' | base64 --decode)
if [ "X$user:$pass" != "X$creds" ]; then
  echo "ERROR: Client credentials mismatch"
  echo "ERROR: from secret: $user:$pass"
  echo "ERROR: From client: $creds"
else
  echo "OK: Client credentials match secret"
fi

echo "INFO: Checking encrypted secret"
encr=$(kubectl get secret isc-cases-elastic-odcfg -o yaml |\
   grep internal_users.yml: | sed -e 's/^.*: //' | base64 --decode |\
   grep -A 2 admin: | grep hash: | sed -e 's/^.*: //')
if [ "X$encr" == "X" ]; then
  echo "ERROR: Encrypted password not set"
else
  echo "OK: encrypted secret is ok"
fi

echo "INFO: Checking data pod"
dpass=$(kubectl exec ibm-dba-ek-isc-cases-elastic-ibm-dba-ek-data-0 -- \
  grep -A 2 admin: /usr/share/elasticsearch/init-security-config/internal_users.yml |\
  grep hash: | sed -e 's/^.*: //')
if [ "X$dpass" != "X$encr" ]; then
  echo "ERROR: Encrypted password doesnt match data pod one"
  echo "ERROR: Encrypted: $encr"
  echo "ERROR: Data pod: $dpass"
else
  echo "OK: master pod ok"
fi

echo "INFO: Checking master pod"
mpass=$(kubectl exec ibm-dba-ek-isc-cases-elastic-ibm-dba-ek-master-0 -- \
  grep -A 2 admin: /usr/share/elasticsearch/init-security-config/internal_users.yml |\
  grep hash: | sed -e 's/^.*: //')
if [ "X$mpass" != "X$encr" ]; then
  echo "ERROR: Encrypted password doesnt match master pod one"
  echo "ERROR: Encrypted: $encr"
  echo "ERROR: Master pod: $mpass"
else
  echo "OK: master pod ok"
fi

exit 0
