#!/bin/bash
###############################################################################
# Licensed Materials - Property of IBM.
# Copyright IBM Corporation 2018, 2019. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
# Contributors:
#  IBM Corporation - initial API and implementation
###############################################################################

test -n "$DEBUG" && set -x

INITIALIZE() {
instance_name="ibmcloudappmgmt"
default_release="ibmcloudappmgmt"
release_name=""
namespace="default"
timestamp=`date +"20%y%m%d%H%M"`
log_file="/tmp/config.ibmcloudappmgmt.${timestamp}.log"
tenantID=$(uuidgen)
}
PRINT_MESSAGE() {
	echo -ne "$@" | tee -a ${log_file}
}

### Since 18.4.0 customer will go to ICP Catalog UI to select Service Plan, create Service Instance, and launch ICAM UI.
### The only task in post installation scripts is to registry OIDC provider.
###
### So that --instanceName parameter and CREATE_SERVICEINSTANCE(), DISPLAY_DASHBOARD() functions are not necessary any more

USAGE() {
  echo "Use this script to perform post IBM Cloud AppMgmt install tasks that require admin permissions."
  echo "Flags: $0 "
  echo "   --releaseName <name>             Release name, default of ${default_release}"
  echo "   --namespace <name>               Namespace, default of ${namespace}"
  echo "   --instanceName <name>            Name for the serviceinstance, default of ${instance_name}"
  echo
  echo "   [ --advanced ]                   Choose Advanced offering ( omit this parameter will chose Base offering )"
  echo "   [ --noLog  ]                     Do not log to ${log_file}"
  echo "   [ --tenantID <UUID> ]            The TenantID of the new serviceinstance, default is random"
  echo
  echo "example: for Base offering"
  echo
  echo "$0 --releaseName ${default_release} --instanceName ${instance_name} --namespace ${namespace}"
  echo
  echo "example: for Advanced offering"
  echo
  echo "$0 --releaseName ${default_release} --instanceName ${instance_name} --namespace ${namespace} --advanced" 
  echo
  exit 0

}
PARSE_ARGS() {
ARGC=$#
if [ $ARGC == 0 ] ; then
          USAGE
        exit
fi
while [ $ARGC != 0 ] ; do
	if [ "$1" == "-n" ] || [ "$1" == "-N" ] ; then
		ARG="-N"
	else
		ARG=`echo $1 | tr .[a-z]. .[A-Z].`
	fi
	case $ARG in
    "--ADVANCED")	#
  	    advanced="true"; shift 1; ARGC=$(($ARGC-1)) ;;
    "--ADVANCE")	#
			  advanced="true"; shift 1; ARGC=$(($ARGC-1)) ;;
    "--INSTANCENAME")       #
        instance_name=$2; shift 2; ARGC=$(($ARGC-2)) ;;
    "--RELEASENAME")	#
			  release_name=$2; shift 2; ARGC=$(($ARGC-2)) ;;
    "--TENANTID")   #
        tenantID=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--NAMESPACE")	#
			namespace=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--NOLOG")	#
			log_file="/dev/null"; shift 1; ARGC=$(($ARGC-1)) ;;
		"--HELP")	#
			USAGE
            exit 1 ;;
		*)
			PRINT_MESSAGE "Argument \"$ARG\" not known, exiting...\n"
			USAGE
            exit 1 ;;
    esac
done
}

GET_RELEASE_NAME() {
if [ -z "${release_name}" ] ; then
	release_name=`helm list --tls | grep 'ibm-cloud-appmgmt' | awk '{ print $1 }'`
fi
if [ -z "${release_name}" ] ; then
	PRINT_MESSAGE "Error, missing required flag \"-releaseName <name>\".  Please rerun the script.\n\n"
	USAGE
else
	PRINT_MESSAGE "Identified release name from helm: \"${release_name}\"\n"
fi

}
WAIT_FOR_SERVICES() {
PRINT_MESSAGE "`date` Checking if all pods have become ready. This could take ~10 minutes after the initial helm install.\n"
unready_pods_count=99
wait_counter=0
ready_pods_count=0
max_retries=30
num_retries=0
while [[ ${unready_pods_count} -gt 0 ]] || [[ ${ready_pods_count} -eq '0' ]] ; do
	if [[ ${num_retries} -gt ${max_retries} ]] ; then
	    echo "ICAM pods did not come ready after ${max_retries} minutes"
	    exit 1
    fi
    ((num_retries++))
	header_printed=0
	wait_counter=$((${wait_counter}+1))
	unready_pods_count=0
	ready_pods_count=0
	states=`kubectl get pods -l release=${release_name} -n ${namespace} -o wide | grep ${release_name} | awk '{ print $1","$2","$3","$4","$5","$6","$7 }'`
	for state in ${states} ; do
		pod=`echo $state | cut -d ',' -f 1`
		pod_ready_state=`echo $state | cut -d ',' -f 2`
		pod_ready=`echo ${pod_ready_state} | cut -d '/' -f 1`
		pod_ready_total=`echo ${pod_ready_state} | cut -d '/' -f 2`
		pod_status=`echo $state | cut -d ',' -f 3`
		pod_restarts=`echo $state | cut -d ',' -f 4`
		pod_age=`echo $state | cut -d ',' -f 5`
		pod_kubernetes_ip=`echo $state | cut -d ',' -f 6`
		pod_node_ip=`echo $state | cut -d ',' -f 7`
		#if [ ${pod_ready} != ${pod_ready_total} ] ; then
                if ([ "${pod_status}" != "Running" ] && [ "${pod_status}" != "Completed" ]) || ([ ${pod_ready} != ${pod_ready_total} ] && [ "${pod_status}" == "Running" ]) ; then
			if [ ${header_printed} -eq 0 ] ; then
				string=`printf "  %-65s %5s %25s   %10s %10s %15s %20s" POD READY STATUS RESTARTS AGE IP NODE`
				PRINT_MESSAGE "${string}\n"
				header_printed=1
			fi
			string=`printf "  %-65s   %1s/%1s %25s   %10s %10s %15s %20s" ${pod} ${pod_ready} ${pod_ready_total} ${pod_status} ${pod_restarts} ${pod_age} ${pod_kubernetes_ip} ${pod_node_ip}`
			PRINT_MESSAGE "${string}\n"
			unready_pods_count=$(($unready_pods_count+1))
		else
			ready_pods_count=$(($ready_pods_count+1))
		fi
	done
	if [[ ${unready_pods_count} -gt 0 ]] || [[ ${ready_pods_count} -eq '0' ]] ; then
		PRINT_MESSAGE "`date` There are ${unready_pods_count} unready pods and ${ready_pods_count} ready pods in release ${release_name} and namespace ${namespace}. This could take ~10 minutes after the initial helm install. Waiting 60 seconds for pods to become ready.\n"
		sleep 60
		PRINT_MESSAGE "\n"
	fi
done
PRINT_MESSAGE "`date` All ${ready_pods_count} pods in release ${release_name} and namespace ${namespace} are ready. \n"
}
OIDC_REGISTRATION() {
PRINT_MESSAGE "`date` Registering OIDC\n"
#kubectl exec -n ${namespace} -t `kubectl get pods -l release=${release_name} -n ${namespace} | grep "${release_name}-ibm-cem-cem-users" | grep "Running" | head -n 1 | awk '{print $1}'` bash -- "/etc/oidc/oidc_reg.sh" "`echo $(kubectl get secret platform-oidc-credentials -o yaml -n kube-system | grep OAUTH2_CLIENT_REGISTRATION_SECRET: | awk '{print $2}')`" 2>&1 | tee -a ${log_file}

OAUTH2_CLIENT_REGISTRATION_SECRET=$(kubectl get secret platform-oidc-credentials -n kube-system --template={{.data.OAUTH2_CLIENT_REGISTRATION_SECRET}})

if [ -z "${OAUTH2_CLIENT_REGISTRATION_SECRET}" ]; then
    PRINT_MESSAGE "`date` Error, ICP secret platform-oidc-credentials is not found ... \n" 2>&1 | tee -a ${log_file}
    PRINT_MESSAGE "`date` Cannot registry OIDC provider \n" 2>&1 | tee -a ${log_file}
    exit 1
else
    PRINT_MESSAGE "`date` ICP secret platform-oidc-credentials is found \n"
fi

## icp 2.1.0.3 put 'pods/xxx' in '-o name' while icp 3.1 put 'pod/xxx'
CEM_USER_POD=$(kubectl get po -n ${namespace} -o name |grep ${release_name}-ibm-cem-cem-users | awk -F '/' '{print $2}' | head -1)

if [ -z "${CEM_USER_POD}" ]; then
    PRINT_MESSAGE "`date` Error, ${release_name}-ibm-cem-cem-users Pod is not found in namespace ${namespace} ... \n"  2>&1 | tee -a ${log_file}
    PRINT_MESSAGE "`date` Cannot registry OIDC provider \n" 2>&1 | tee -a ${log_file}
    exit 1
else
    PRINT_MESSAGE "`date` ${CEM_USER_POD} is found \n"
fi

kubectl exec -n ${namespace} -t ${CEM_USER_POD} bash -- "/etc/oidc/oidc_reg.sh" "${OAUTH2_CLIENT_REGISTRATION_SECRET}" 2>&1 | tee -a ${log_file}
#Catch oidc_reg.sh error and exit
error_code=${PIPESTATUS[0]}
if [ ${error_code} -ne 0 ] ; then
    echo "ERROR ${error_code}, exiting." | tee -a ${log_file}
    exit ${PIPESTATUS[0]}
fi

PRINT_MESSAGE echo "`date` Done registering OIDC\n\n"
}


CREATE_SERVICEINSTANCE() {
    offering=base
    if [ "$advanced" == "true" ]; then
        offering=advanced
    fi

    cat > /tmp/${release_name}-serviceinstance.yaml <<EOF
apiVersion: servicecatalog.k8s.io/v1beta1
kind: ServiceInstance
metadata:
 name: ${instance_name}
 labels:
  release: ${release_name}
spec:
 clusterServiceClassExternalName: ibm-cloud-appmgmt
 clusterServicePlanExternalName: ${offering}
 externalID: ${tenantID}
EOF
    PRINT_MESSAGE "`date` Creating serviceinstance ${instance_name} in namespace ${namespace}\n"
    cat /tmp/${release_name}-serviceinstance.yaml
    kubectl create -f /tmp/${release_name}-serviceinstance.yaml --namespace=${namespace} 2>&1 | tee -a ${log_file}
    sleep 1

    PRINT_MESSAGE "`date` Done creating serviceinstance ${instance_name}\n\n"
}

DISPLAY_DASHBOARD() {
    dashboard=""
    while [ -z "${dashboard}" ] ; do
        dashboard=`kubectl describe serviceinstance ${instance_name} --namespace=${namespace} | grep Dashboard | awk '{ print $3 }'`
        if [ -z "${dashboard}" ] ; then
            PRINT_MESSAGE "`date` Waiting for dashboard to become ready\n"
            sleep 10
        fi
    done
    PRINT_MESSAGE "\n"
    PRINT_MESSAGE "Please access the IBM Cloud App Management dashboard at ${dashboard}\n\n"
}

MAIN() {
GET_RELEASE_NAME
WAIT_FOR_SERVICES
OIDC_REGISTRATION
CREATE_SERVICEINSTANCE
DISPLAY_DASHBOARD
}

INITIALIZE
PARSE_ARGS "$@"
MAIN
