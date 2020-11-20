#!/bin/bash
secret_list=$(./tmp/kubectl get secrets | egrep "(spark-hb).*" | awk '{ print $1}')
if [[ $secret_list ]]
then
 echo $secret_list
 echo "Deleting above secrets"
 ./tmp/kubectl delete secrets $secret_list
 exit_code=$?
 echo "exit_code : $exit_code"
 if [ $exit_code -ne 0 ]
 then
	exit 1
 fi
else
 echo "There are no secrets for cleanup"
fi
configMap_list=$(./tmp/kubectl get configmap | egrep "(spark-hb).*" | awk '{ print $1}')
if [[ $configMap_list ]]
then
 echo $configMap_list
 echo "Deleting above configMaps"
 ./tmp/kubectl delete configmap $configMap_list
 exit_code=$?
 echo "exit_code : $exit_code"
 if [ $exit_code -ne 0 ]
 then
	exit 1
 fi
else
echo "There are no configmap for cleanup"
fi
exit 0