#!/bin/bash
#
# Licensed Materials - Property of IBM
#
# 5737-H33
#
# (C) Copyright IBM Corp. 2018  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.

TARGET_SECRET_NAME=$1

######################################################
# Build up the arguments for the kubectl command
######################################################

SECRET_ARGS=

if [ -s ./mqsc.txt ]; then
  SECRET_ARGS="${SECRET_ARGS} --from-file=mqsc=./mqsc.txt"
fi

if [ -s ./keystorePassword.txt ]; then
  SECRET_ARGS="${SECRET_ARGS} --from-file=keystorePassword=./keystorePassword.txt"
fi

for keyfile in `ls ./keystore-*.key`; do
  if [ -s "${keyfile}" ]; then
    if [ ! -s ./keystorePassword.txt ]; then
      echo "No keystore password defined"
      exit 1
    fi

    filename=$(basename ${keyfile})
    alias=$(echo ${filename} | sed -r 's/keystore-(.*)\.key$/\1/')
    certfile=./keystore-${alias}.crt
    passphrasefile=./keystore-${alias}.pass

    if [ ! -s ${certfile} ]; then
      echo "Certificate file ${certfile} not found."
      exit 1
    fi

    SECRET_ARGS="${SECRET_ARGS} --from-file=keystoreKey-${alias}=${keyfile}"
    SECRET_ARGS="${SECRET_ARGS} --from-file=keystoreCert-${alias}=${certfile}"

    if [ -s "${passphrasefile}" ]; then
      SECRET_ARGS="${SECRET_ARGS} --from-file=keystorePass-${alias}=${passphrasefile}"
    fi
  fi
done

if [ -s ./truststorePassword.txt ]; then
  SECRET_ARGS="${SECRET_ARGS} --from-file=truststorePassword=./truststorePassword.txt"
fi

for certfile in `ls ./truststore-*.crt`; do
  if [ -s "${certfile}" ]; then
    if [ ! -s ./truststorePassword.txt ]; then
      echo "No truststore password defined"
      exit 1
    fi

    filename=$(basename ${certfile})
    alias=$(echo ${filename} | sed -r 's/truststore-(.*)\.crt$/\1/')

    SECRET_ARGS="${SECRET_ARGS} --from-file=truststoreCert-${alias}=${certfile}"
  fi
done

if [ -s ./odbc.ini ]; then
  SECRET_ARGS="${SECRET_ARGS} --from-file=odbcini=./odbc.ini"
fi

if [ -s ./policy.xml ]; then
  SECRET_ARGS="${SECRET_ARGS} --from-file=policy=./policy.xml "
fi

if [ -s ./policyDescriptor.xml ]; then
  SECRET_ARGS="${SECRET_ARGS} --from-file=policyDescriptor=./policyDescriptor.xml "
fi

if [ -s ./serverconf.yaml ]; then
  SECRET_ARGS="${SECRET_ARGS} --from-file=serverconf=./serverconf.yaml "
fi

if [ -s ./setdbparms.txt ]; then
  SECRET_ARGS="${SECRET_ARGS} --from-file=setdbparms=./setdbparms.txt "
fi

if [ -s ./extensions.zip ]; then
  SECRET_ARGS="${SECRET_ARGS} --from-file=extensions=./extensions.zip "
fi

if [ -s ./switch.json ]; then
  SECRET_ARGS="${SECRET_ARGS} --from-file=switch=./switch.json "
fi

if [ -s ./agentx.json ]; then
  SECRET_ARGS="${SECRET_ARGS} --from-file=agentx=./agentx.json "
fi

if [ -s ./agentp.json ]; then
  SECRET_ARGS="${SECRET_ARGS} --from-file=agentp=./agentp.json "
fi

if [ -s ./agentc.json ]; then
  SECRET_ARGS="${SECRET_ARGS} --from-file=agentc=./agentc.json "
fi

if [ -s ./credentials.yaml ]; then
  SECRET_ARGS="${SECRET_ARGS} --from-file=credentials=./credentials.yaml"
fi

######################################################
# Create the Kubernetes secret resource
######################################################

echo "Creating secret"
echo "kubectl create secret generic ${TARGET_SECRET_NAME}${SECRET_ARGS}"
kubectl create secret generic ${TARGET_SECRET_NAME}${SECRET_ARGS}
