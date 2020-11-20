#!/bin/bash

kubectl_retry(){
cmd=$1
count=$2
while [[ $count -gt 0 ]]
do
    echo "count $count"
    eval $cmd
    exit_code=$?
    echo "exit_code : $exit_code"
    if [ $exit_code -eq 0 ]
    then
       return 0
    fi
    count=$(($count - 1))
    return $exit_code
done
}

#--------------------------
# Main
#--------------------------

pod_list=$(./tmp/kubectl get pods | egrep "(spark-history-deployment-*)|((jkg-deployment|spark-worker|spark-master).*-.*-.*-.*-.*)" | grep -i Terminating | awk '{ print $1}')

if [[ $pod_list ]]
then
    for i in {1..3}
    do
        kubectl_retry "./tmp/kubectl delete pod --grace-period=0 --force $pod_list" 3
    done
else
    echo "There are not pods stuck in terminating state"
fi
exit 0
