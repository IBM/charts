#!/bin/bash

dataplane_name=$1
dataplane_nginx_url=$2
micro_service_url=$3
dataplane_manager_endpoint=$4
dataplane_manager_svc_url="$micro_service_url/$dataplane_manager_endpoint"
helmbased_svc_endpoint=$5
helmbased_svc_url="$micro_service_url/$helmbased_svc_endpoint"

nfsPath=$6
nfsServer=$7

nginx_url=$8
script_path=$9
namespace=${10}
nginx_container_port=${11}

cleanup_script_path=${12}
cleanup_conf_path=${13}

registered=1

    exec_cmd()
    {
        CMD=$1
        eval $CMD
        if [ $? -ne 0 ]
        then
            echo "Error : failed to execute the command: $CMD"
        fi
    }

end=$((SECONDS+240))
while [ $SECONDS -lt $end ]; do
    response=$(curl -s -k -w "%{http_code}"  $dataplane_manager_svc_url?overwrite=true -X GET -H "Content-Type: application/json")
    dataplane_response_code=${response: -3}

    if [[ "$dataplane_response_code" == "200" ]]
    then
        if [[ $(echo $response | grep "external_dataplane_URL" | wc -l) -ge 1 ]]
        then
            echo "Found registered dataplane"
            registered=0
            break
        fi
    else
        echo "Failed to get data plane details"
        sleep 10s
    fi
done

if [[ $registered -eq 1 ]]
then
    end=$((SECONDS+240))

    while [ $SECONDS -lt $end ]; do
      dataplane_payload="{\"name\":\"$dataplane_name\",\"external_dataplane_URL\":\"$dataplane_nginx_url.$namespace.svc.cluster.local:$nginx_container_port\"}"

      response=$(curl -s -k -w "%{http_code}"  $dataplane_manager_svc_url?overwrite=true -X POST -H "Content-Type: application/json" -d "$dataplane_payload")

      echo "dataplane registered, response: $response"
      dataplane_response_code=${response: -3}
      if [[ $(echo $response | grep "Active" | wc -l) -ge 1 ]]
      then
          echo "Found registered dataplane"
          flag=0
          break
      else
          echo "Fail to register data plane, response: $response"
          sleep 15s
          flag=1
      fi
    done

    if [[ $flag -eq 1 ]]
    then
        echo "Failed to register data plane $dataplane_name"
        exit 1
    fi
fi

no_of_calls=30

bash $script_path/cache-of-templates-dataplane-details.sh $dataplane_manager_svc_url $dataplane_name $no_of_calls

python $script_path/create_kernel.py $nginx_url $no_of_calls

if [[ $? -ne 0 ]]
then
    echo "Failed to create kernel"
    exit 1
fi

touch /tmp/_SUCCESS

# Added kernel & cleanup in this script, even though we have cronjobs for that
# Because if cluster do not have enough resource to schedule new pods cronjob won't work.
# Since this pod will be always running it will purge idle kernels/jobs.

time_in_min=$(cat $cleanup_conf_path/idleshutdown.config | python -c 'import json,sys;obj=json.load(sys.stdin);print(obj["spark"]["idleTimeBeforeShutdown"]);')
idle_time_before_shutdown=$((time_in_min*60))

while true
do
    echo "================================ Kernel Cleanup ======================================"
    echo "There are no kernels in 'Active' state under instance 26e20bc3ea214bf5928541decd18d40f"
    exec_cmd "python $cleanup_script_path/purge_idle_failed_kernel.py $micro_service_url/instance_manager/v1/instance $nginx_url/ae $micro_service_url/ae/v1 $cleanup_conf_path/idleshutdown.config"
    echo "======================================================================================"
    echo "================================ Job Cleanup ========================================="
    exec_cmd "python $cleanup_script_path/cleanup-spark-jobs.py $micro_service_url/instance_manager/v1/instance $nginx_url/ae $micro_service_url/jobService/v2 $cleanup_conf_path/idleshutdown.config"
    echo "======================================================================================"
    sleep ${idle_time_before_shutdown}s
done