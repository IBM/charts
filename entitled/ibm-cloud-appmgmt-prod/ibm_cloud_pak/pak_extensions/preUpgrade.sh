#!/bin/bash
###############################################################################
# Licensed Materials - Property of IBM.
# Copyright IBM Corporation 2019. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
# Contributors:
#  IBM Corporation - initial API and implementation
###############################################################################

CALLER=$_
set -o pipefail
test -n "$DEBUG" && set -x

DIR=`dirname $0`

source ${DIR}/lib/cloud-vars.sh
source ${DIR}/lib/utils.sh


USAGE() {
       echo "Use $0 before upgrading from ICAM 2019.2.0 to ICAM 2019.2.1. "
       echo
       echo "  *Required flags"
       echo "    --accept                               Accept license agreement(s)"
       echo "    --releaseName <name>                   Release name (default is ${release_name})"
       echo "    --namespace <name>                     Namespace (default is ${namespace})"
       echo
       echo "  *Optional - High availability and horizontal scale settings"
       echo "    --minReplicasHPAs <int>                The minimum number of replicas for each deployment, controlled by HPAs"
       echo "    --maxReplicasHPAs <int>                The maximum number of replicas for each deployment, controlled by HPAs"
       echo "    --kafkaClusterSize <int>               The number of Kafka replicas (the replication factor for Kafka topics will be set to this value, up to a max of 3)"
       echo "    --zookeeperClusterSize <int>           The number of Zookeeper replicas (all Zookeeper data is replicated to all zookeeper nodes)" 
       echo "    --couchdbClusterSize <int>             The number of CouchDB replicas (the CouchDB data data replication defaults to 3, even if the cluster has 1 or 2 nodes)"
       echo "    --datalayerClusterSize <int>           The number of Datalayer replicas (the datalayer relies on Kafka and internal jobs for handling data replication)"
       echo "    --cassandraClusterSize <int>           The number of Cassandra replicas (the replication factor for Cassandra keyspaces will be set to this value, up to a max of 3)"
       echo "    --cassandraUsername <string>           The username Cassandra will use. If left unset, the default cassandra credentials will be used."
       echo "    --metricC8Rep <replication_string>     The replication string for the metric data (default is \"{'class':'SimpleStrategy','replication_factor':X}\", where X is the cassandraClusterSize up to 2)"
       echo "    --openttC8Rep <int>                    The replication factor for the Open Transaction Tracking data (default is to match cassandraClusterSize up to 2)"
       echo "    --metricKafkaRep <int>                 The replication factor for the metric Kafka data (default is to match kafkaClusterSize up to 2)"
       echo  	   
       echo "Example usage of $0:"
       echo "$0 --releaseName ibmcloudappmgmt --namespace default --cassandraUsername myUser"
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
		PRE_FORMAT_ARG=$1
		ARG=`echo $1 | tr .[a-z]. .[A-Z].`
	fi
	case $ARG in
		"--ACCEPT")     #
			license_agreement_accepted="true" ; shift 1; ARGC=$(($ARGC-1)) ;;	
		"--RELEASENAME")     #
			release_name=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--NAMESPACE")     #
			namespace=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--MINREPLICASHPAS")     #
			global_minreplicashpas=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--MAXREPLICASHPAS")     #
			global_maxreplicashpas=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--CASSANDRACLUSTERSIZE")     #
			cassandra_clustersize=$2; shift 2; ARGC=$(($ARGC-2)) ;;			
		"--CASSANDRAUSERNAME")     #
			cassandraUsername=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--CASSANDRAPASSWORD")     #
			cassandraPassword=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--KAFKACLUSTERSIZE")     #
			kafka_clustersize=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--ZOOKEEPERCLUSTERSIZE")     #
			zookeeper_clustersize=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--COUCHDBCLUSTERSIZE")     #
			couchdb_clustersize=$2; shift 2; ARGC=$(($ARGC-2)) ;;			
		"--DATALAYERCLUSTERSIZE")     #
			datalayer_clustersize=$2; shift 2; ARGC=$(($ARGC-2)) ;;	
		"--METRICKAFKAREP")     #
			metricKafkaRep=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--METRICC8REP")     #
			metricC8Rep=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--OPENTTC8REP")     #
			openttC8Rep=$2; shift 2; ARGC=$(($ARGC-2)) ;;			
		"--HELP")	#
			USAGE
            exit 1 ;;

		*)
			echo "Argument \"${PRE_FORMAT_ARG}\" not known. Exiting.\n"
			usage
            exit 1 ;;
    esac
done
}

VERIFY_RELEASE_AND_NAMESPACE(){
    echo "Verifying that there are pods associated with $release_name and $namespace"
    kubectl get pods -l release=${release_name} -n ${namespace} -o json | grep config > /dev/null
    areTherePods=$?
    if [ $areTherePods -eq 1 ]; then
	echo "The releaseName \"${release_name}\" or the namespace \"${namespace}\" does not have any resources associated with it. Please ensure that the releaseName and namespace are correct and rerun the script."
	exit 1
    else
	echo "Resources associated with releaseName: ${release_name} and namespace ${namespace} found."
    fi
}

CASSANDRA_CREDENTIALS(){
    cassandraSecret="${release_name}-cassandra-auth-secret"
    # delete cassandra secret if it exists
    kubectl get secrets -n ${namespace} | grep "${cassandraSecret}"
    result=$?
    if [ $result -eq 0 ]; then
	echo "Old cassandra secret found; deleting it."
	kubectl delete secret ${cassandraSecret} -n ${namespace}
	result=$?
	if [ $result -eq 0 ]; then
	    echo "Successfully deleted cassandra secret"
	else
	    echo "The old cassandra secret exists, but we couldn't delete it."
	    exit 1
	fi
    fi
    
    # if the user was sneaky and provided both, do nothing
    if [[ -n "${cassandraPassword}" ]] && [[ -n "${cassandraUsername}" ]]; then
	echo "User provided cassandraPassword via commandline call. This is insecure."
    elif [[ -n "${cassandraUsername}" ]] && [[ -z "${cassandraPassword}" ]]; then
    # if the user provided the username, ask for the password discretely
	echo "Please provide the cassandraPassword: "
	read -s cassandraPassword
    # if the user didn't provide the cassandra username, use the defaults for both
    else
	echo "Using default cassandra credentias. This is insecure and not recommended."
	cassandraUsername=cassandra
	cassandraPassword=cassandra
    fi
    # base64 encode the credentials the user gave us
    b64cassandraUser=$(echo -n ${cassandraUsername} | base64)
    b64cassandraPass=$(echo -n ${cassandraPassword} | base64)
    
    # create new secret
    cat > ${release_name}-cassandra-auth-secret.json <<EOF
{
    "apiVersion": "v1",
    "data": {
        "username": "${b64cassandraUser}",
        "password": "${b64cassandraPass}"
    },
    "kind": "Secret",
    "metadata": {
        "labels": {
            "app": "cassandra",
            "chart": "ibm-cloud-appmgmt-prod",
            "heritage": "user-provided",
            "release": "${release_name}"
        },
        "name": "${release_name}-cassandra-auth-secret",
        "namespace": "${namespace}"
    },
    "type": "Opaque"
}
EOF
kubectl create -f ${release_name}-cassandra-auth-secret.json -n ${namespace}
result=$?
rm ${release_name}-cassandra-auth-secret.json
if [ $result -eq 0 ]; then
    echo "Successfully created ${release_name}-cassandra-auth-secret."
else
    echo "Could not create ${release_name}-cassandra-auth-secret. Please re-execute the script; ensure that you have provided the correct releaseName and namespace, and that the cassandra username consists of alphanumeric characters."
    exit 1
fi
    
}



WRITE_VALUES() {

values_file=./${release_name}.2019.2.1.values.yaml
cat > ${values_file} <<EOF
global:
EOF

if [ $license_agreement_accepted == "true" ]; then
cat >> ${values_file} <<EOF
  license: accept
EOF
fi

if [ -n "${global_minreplicashpas}" ] ; then
cat >> ${values_file} <<EOF
  minReplicasHPAs: ${global_minreplicashpas}
EOF
fi

if [ -n "${global_maxreplicashpas}" ] ; then
cat >> ${values_file} <<EOF
  maxReplicasHPAs: ${global_maxreplicashpas}
EOF
fi


if [ -n "${zookeeper_clustersize}" ] ; then
cat >> ${values_file} <<EOF
  zookeeper:
    clusterSize: ${zookeeper_clustersize}
EOF
fi

if [[ -n "${kafka_clustersize}" ]] || [[ -n "${metricKafkaRep}" ]] ; then
cat >> ${values_file} <<EOF
  kafka:
EOF
fi
if [ -n "${kafka_clustersize}" ] ; then
cat >> ${values_file} <<EOF
    clusterSize: ${kafka_clustersize}
EOF
fi
if [ -n "${metricKafkaRep}" ] ; then
cat >> ${values_file} <<EOF
    replication:
      metrics: ${metricKafkaRep}
EOF
fi

if [ -n "${cassandra_clustersize}" ] ; then
cat >> ${values_file} <<EOF
  cassandraNodeReplicas: ${cassandra_clustersize}
EOF
fi

if [ -n "${metricC8Rep}" ] ; then
cat >> ${values_file} <<EOF
  metricC8Rep: "${metricC8Rep}"
EOF
fi

if [ -n "${openttC8Rep}" ] ; then
cat >> ${values_file} <<EOF
  openttC8Rep: ${openttC8Rep}
EOF
fi


if [ $license_agreement_accepted == "true" ]; then
cat >> ${values_file} <<EOF
ibm-cloud-appmgmt-prod:
  license: accept
ibm-cem:
  license: "accept"
EOF
fi

if [ $license_agreement_accepted != "true" ]; then
cat >> ${values_file} <<EOF
ibm-cem:
EOF
fi

if [ -n "${couchdb_clustersize}" ] ; then
cat >> ${values_file} <<EOF
  couchdb:
    clusterSize: ${couchdb_clustersize}
EOF
fi

if [ -n "${datalayer_clustersize}" ] ; then
cat >> ${values_file} <<EOF
  datalayer:
    clusterSize: ${datalayer_clustersize}
EOF
fi



PRINT_MESSAGE "Generated ${values_file}\n"
PRINT_MESSAGE "-----\n"
cat ${values_file} 2>&1 | tee -a ${log_file}
PRINT_MESSAGE "-----\n\n"
}
LICENSE_AGREEMENT() {
if [ -z "${license_agreement_accepted}" ] ; then
	if [ -n "${prompts}" ] ; then
		ASK_YES_NO_QUESTION "Do you accept the license agreement(s) found in the ibm-cloud-appmgmt-prod/LICENSES directory [ 1-accept or 2-decline ]? "
		if [ $? -eq '1' ] ; then
			PRINT_MESSAGE "License agreement was declined. Installation has been aborted."\n""
			exit 2
		else
			license_agreement_accepted="true"
		fi
		PRINT_MESSAGE "\n"
	else
		PRINT_MESSAGE "Please accept the license agreement(s) by running with the \"--accept\" flag. Exiting.\n"
		exit 1
	fi
fi
}
DETERMINE_KEYSPACE_REPLICATION() {

if [ -z "${metricKafkaRep}" ] ; then
	if [ -n "${kafka_clustersize}" ] ; then
		if [ ${kafka_clustersize} -gt 2 ] ; then
			metricKafkaRep=2
		else
			metricKafkaRep=${metricKafkaRep}
		fi
	fi

fi

if [ -z "${metricC8Rep}" ] ; then
	if [ -n "${cassandra_clustersize}" ] ; then
		if [ ${cassandra_clustersize} -gt 2 ] ; then
			metricC8RepNumber=2
		else
			metricC8RepNumber=${cassandra_clustersize}
		fi
		metricC8Rep="{'class':'SimpleStrategy','replication_factor':${metricC8RepNumber}}"
	fi
fi

if [ -z "${openttC8RepC8Rep}" ] ; then
	if [ -n "${cassandra_clustersize}" ] ; then
		if [ ${cassandra_clustersize} -gt 2 ] ; then
			openttC8Rep=2
		else
			openttC8Rep=${cassandra_clustersize}
		fi
	fi
fi

}


MAIN() {
PRINT_MESSAGE "Welcome to IBM Cloud App Management. \n"
PRINT_MESSAGE "For more information, please visit http://ibm.biz/app-mgmt-kc \n\n"


LICENSE_AGREEMENT
VERIFY_RELEASE_AND_NAMESPACE
if [ -n "${cassandraUsername}" ] ; then
	CASSANDRA_CREDENTIALS
fi
DETERMINE_KEYSPACE_REPLICATION
WRITE_VALUES
}

INITIALIZE
PARSE_ARGS "$@"
MAIN
