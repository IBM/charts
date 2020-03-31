#!/bin/bash -e
  
echo "Running helm install tests for the dev Chart"

/tmp/helm install stable/ibm-ace-server-dev --name dev-3-1-0 --tls --dry-run --set Release.name=random || echo "Test pass";  #fail

/tmp/helm install stable/ibm-ace-server-dev --name dev-3-1-0 --tls --dry-run --set license=accept --set Values.dataPVC.storageClassName=random  --set Values.persistence.enabled=false || echo "Test pass"; #Fail

/tmp/helm install stable/ibm-ace-server-dev --name dev-3-1-0 --tls --dry-run --set license=accept --set contentServerURL="https://randomurl/v1/directories/randomstring\randomstring" || echo "Test pass"; #Fail

/tmp/helm install stable/ibm-ace-server-dev --name dev-3-1-0 --tls --dry-run --set license=accept --set persistence.useDynamicProvisioning=true --set persistence.enabled=false || echo "Test pass"; #Fail

/tmp/helm install stable/ibm-ace-server-dev --name dev-3-1-0 --tls --dry-run --set license=accept --set integrationServer.keystoreKeyNames="random keystore" || echo "Test pass"; #Fail

/tmp/helm install stable/ibm-ace-server-dev --name dev-3-1-0 --tls --dry-run --set license=accept --set integrationServer.truststoreCertNames="random truststore" || echo "Test pass"; #Fail

/tmp/helm install stable/ibm-ace-server-dev --name dev-3-1-0 --tls --dry-run --set license=accept || echo "Test pass"; #Fail

/tmp/helm install stable/ibm-ace-server-dev --name dev-3-1-0 --tls --dry-run --set license=accept --set persistence.enabled=true --set dataPVC.storageClassName="Random Storage class name"
