#!/bin/bash -e
  
echo "Running helm install tests for the icp4i-prod Chart"

/tmp/helm install stable/ibm-ace-dashboard-icp4i-prod --name icp4i-prod-3-0-0 --tls --dry-run --set Release.name=random || echo "Test pass";  #fail

/tmp/helm install stable/ibm-ace-dashboard-icp4i-prod --name icp4i-prod-3-0-0 --tls --dry-run --set license=accept --set license=accept || echo "Test pass"; #Fail

/tmp/helm install stable/ibm-ace-dashboard-icp4i-prod --name icp4i-prod-3-0-0 --tls --dry-run --set license=accept --set tls.hostname="https://randomurl/v1/directories/randomstring\randomstring" || echo "Test pass"; #Fail

/tmp/helm install stable/ibm-ace-dashboard-icp4i-prod --name icp4i-prod-3-0-0 --tls --dry-run --set license=accept --set persistence.storageClassName="random value" --set persistence.enabled=false --set tls.hostname="randomurl/v1/directories/randomstring\randomstring" || echo "Test pass"; #Fail

/tmp/helm install stable/ibm-ace-dashboard-icp4i-prod --name icp4i-prod-3-0-0 --tls --dry-run --set license=accept --set persistence.enabled=true --set dataPVC.storageClassName="Random Storage class name" || echo "Test pass"; #Fail

/tmp/helm install stable/ibm-ace-dashboard-icp4i-prod --name icp4i-prod-3-0-0 --tls --dry-run --set license=accept --set persistence.storageClassName="random value" --set persistence.enabled=false --set tls.hostname="https://randomurl/v1/directories/randomstring\randomstring" || echo "Test pass"; #Fail

/tmp/helm install stable/ibm-ace-dashboard-icp4i-prod --name icp4i-prod-3-0-0 --tls --dry-run --set license=accept --set persistence.storageClassName="random value" --set tls.hostname="randomurl/v1/directories/randomstring\randomstring"
