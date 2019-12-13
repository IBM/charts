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

CALLER=$_
set -o pipefail
test -n "$DEBUG" && set -x

DIR=`dirname $0`
#echo ${DIR}/lib
test -e ${DIR}/../yaml || mkdir ${DIR}/../yaml

source ${DIR}/lib/cloud-vars.sh
source ${DIR}/lib/utils.sh

USAGE() {
       echo "Usage $0"
       echo "Use this script to perform preparation tasks that require admin permissions before IBM Cloud AppMgmt is installed."
       echo
       echo "  *Required flags"
       echo "    --accept                               Accept license agreement(s)"
       echo "    --https                                Install with HTTPS enabled (HTTPS is always enabled in Advanced offering)"
       echo "    --advanced                             Install as ADVANCED offering (omit this parameter will install as Base offering)"
       echo "    --releaseName <name>                   Release name (default is ${release_name})"
       echo "    --masterAddress <IP|FQDN>              IP address or fully qualified domain name (FQDN) for the ICP Master. This is used for logging into ICP."
       echo "                                           In a highly available environment, this would be the FQDN of the HAProxy or load balancer for ICP."	   
       echo "    --masterPort <int>                     The port of the ICP master. On OpenShift the default port is 443, which will need to be specified here. (default is ${global_masterPort})"
       echo "    --ingressPort <int>                    The ingress port used to access the ICP console. (default is ${global_ingressPort})"
       echo "    --proxyIP <IP>                         IP address for ICP Proxy."
       echo "                                             In a highly available environment, this would be the IP address of the HAProxy or load balancer for ICP."
       echo "    --proxyFQDN <FQDN>                     Fully qualified domain name (FQDN) for the ICP Proxy."
       echo "                                             In a highly available environment, this would be the FQDN of the HAProxy or load balancer for ICP."
       echo "    --namespace <name>                     Namespace (default is ${namespace})"
       echo "    --clusterCAdomain <name>               ICP cluster domain name, default is ${cluster_CA_domain_default}"
       echo
       echo "  *Optional - Email setup: "
       echo "    --emailtype <smtp|api>                 Type of email, either smtp or api"
       echo "    --emailfrom <emailAddress>             Email address to show on sent mail as from"
       echo "    --smtphost <hostname>                  SMTP hostname"
       echo "    --smtpport <port>                      SMTP port"
       echo "    --smtpuser <user>                      SMTP user"
       echo "    --smtppass <password>                  SMTP password"
       echo "    --smtpauth <true|false>                User authentication required for SMTP connection (default is ${ibmcemprod_email_smtpauth})"
       echo "    --smtprejectunauthorized <true|false>  Set this to false to allow self signed certificates when connecting via TLS, true enforces TLS authorization checking (default is ${ibmcemprod_email_smtprejectunauthorized})"
       echo "    --apikey <key>                         API key file"
       echo
       echo "  *Optional - High availability and horizontal scale settings"
       echo "    --minReplicasHPAs <int>                The minimum number of replicas for each deployment, controlled by HPAs"
       echo "    --maxReplicasHPAs <int>                The maximum number of replicas for each deployment, controlled by HPAs"
       echo "    --kafkaClusterSize <int>               The number of Kafka replicas (the replication factor for Kafka topics will be set to this value, up to a max of 3)"
       echo "    --zookeeperClusterSize <int>           The number of Zookeeper replicas (all Zookeeper data is replicated to all zookeeper nodes)"
       echo "    --couchdbClusterSize <int>             The number of CouchDB replicas (the CouchDB data data replication defaults to 3, even if the cluster has 1 or 2 nodes)"
       echo "    --datalayerClusterSize <int>           The number of Datalayer replicas (the datalayer relies on Kafka and internal jobs for handling data replication)"
       echo "    --elasticsearchClusterSize <int>       The number of Elasticsearch replicas (the number of replica shards is determined from the number of Elasticsearch instances)"
       echo "    --redisServerReplicas <int>            The number of redis server replicas. Defaults to 1"
       echo "    --cassandraClusterSize <int>           The number of Cassandra replicas (the replication factor for Cassandra keyspaces will be set to this value, up to a max of 3)"
       echo "    --cassandraUsername <string>           The username Cassandra will use. You must use a username other than 'cassandra'. If left unset, the default cassandra credentials will be used."
       echo
       echo "  *Optional - Other"
       echo "    --metricSummarization <string>         Enables or disables metric summarization. Set to 'true' or 'false'. Defaults to 'false' if not specified."

       echo "    --repositoryPort <int>                 The port of the image repository. On OpenShift the default port is 5000, which will need to be specified here. (default is ${repository_port}) "
       echo "    --metricC8Rep <replication_string>     The replication string for the metric data (default is \"{'class':'SimpleStrategy','replication_factor':X}\", where X is the cassandraClusterSize up to 2)"
       echo "    --openttC8Rep <int>                    The replication factor for the Open Transaction Tracking data (default is to match cassandraClusterSize up to 2)"
       echo "    --metricKafkaRep <int>                 The replication factor for the metric Kafka data (default is to match kafkaClusterSize up to 2)"
       # Set in the CEM yaml
       #echo "    --CouchDbNumReplicas <int>          The replication factor for the CouchDB data (default is 3)"
       echo "    --useTLSCertsJob  <true|false>         Enables or disables creating Ingress TLS Certificates using Kubernetes Job.  Set to 'true' or 'false'. Defaults to 'false' if not specified."
       echo
       echo "Example of install a Base offering with HTTP communication enabled:"
       echo "$0 --accept --releasename ${default_release} --namespace ${namespace} --masteraddress x.xx.xx.xx --proxyip x.xx.xx.xx --proxyfqdn proxy.example.com --clustercadomain mycluster.icp --cassandraUsername \$myCassandraUsername"
       echo
       echo "Example of install a Base offering with HTTPS communication enabled:"
       echo "$0 --accept --releasename ${default_release} --namespace ${namespace} --masteraddress x.xx.xx.xx --proxyip x.xx.xx.xx --proxyfqdn proxy.example.com --clustercadomain mycluster.icp --https --cassandraUsername \$myCassandraUsername"
       echo
       echo "Example of install an Advanced offering with HTTPS enabled:"
       echo "$0 --accept --releasename ${default_release} --namespace ${namespace} --masteraddress x.xx.xx.xx --proxyip x.xx.xx.xx --proxyfqdn proxy.example.com --clustercadomain mycluster.icp --advanced --cassandraUsername \$myCassandraUsername"
       echo
       echo "Example of install an Advanced offering with HTTPS enabled, using high availability:"
       echo "$0 --accept --releasename ${default_release} --namespace ${namespace} --masteraddress haproxy.example.com --proxyip x.xx.xx.xx --proxyfqdn haproxy.example.com --clustercadomain mycluster.icp --advanced --minreplicashpas 2  --maxreplicashpas 3 --kafkaclustersize 3 --zookeeperclustersize 3 --couchdbclustersize 3 --datalayerclustersize 3 --cassandraclustersize 3 --cassandraUsername \$myCassandraUsername"

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
		"--HTTPS")	#
			https="true"; shift 1; ARGC=$(($ARGC-1)) ;;
		"--ADVANCED")	#
			advanced="true"; shift 1; ARGC=$(($ARGC-1)) ;;
		"--ADVANCE")	#
			advanced="true"; shift 1; ARGC=$(($ARGC-1)) ;;
		"--RELEASENAME")	#
			release_name=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--MASTERADDRESS")	#
			global_masterIP=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--MASTERIP")	# Deprecated for MASTERADDRESS
			global_masterIP=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--MASTERPORT")	#
			global_masterPort=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--INGRESSPORT")	#
			global_ingressPort=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--REPOSITORYPORT")	#
			repository_port=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--PROXYIP")	#
			global_proxyIP=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--PROXYFQDN")	#
			global_ingress_domain=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--PROXYHOSTNAME")	# Deprecated for PROXYFQDN
			global_ingress_domain=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--CLUSTERCADOMAIN")  #
			cluster_CA_domain=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--NAMESPACE")	#
			namespace=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--EMAILTYPE")  #
			ibmcemprod_email_type=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--EMAILFROM")  #
			ibmcemprod_email_mail=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--SMTPHOST")   #
			ibmcemprod_email_smtphost=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--SMTPPORT")   #
			ibmcemprod_email_smtpport=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--SMTPUSER")   #
			ibmcemprod_email_smtpuser=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--SMTPPASS")   #
			ibmcemprod_email_smtppassword=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--SMTPAUTH")   #
			ibmcemprod_email_smtpauth="true"; shift 1; ARGC=$(($ARGC-1)) ;;
		"--SMTPREJECTUNAUTHORIZED")   #
			ibmcemprod_email_smtprejectunauthorized="true"; shift 1; ARGC=$(($ARGC-1)) ;;
		"--APIKEY")     #
			ibmcemprod_email_apikey=$2; shift 2; ARGC=$(($ARGC-2)) ;;
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
		"--METRICKAFKAREP")     #
			metricKafkaRep=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--METRICC8REP")     #
			metricC8Rep=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--METRICSUMMARIZATION")
			metricSummarization=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--OPENTTC8REP")     #
			openttC8Rep=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--KAFKACLUSTERSIZE")     #
			kafka_clustersize=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--ZOOKEEPERCLUSTERSIZE")     #
			zookeeper_clustersize=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--COUCHDBCLUSTERSIZE")     #
			couchdb_clustersize=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--COUCHDBNUMREPLICAS")     #
			couchdb_numReplicas=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--DATALAYERCLUSTERSIZE")     #
			datalayer_clustersize=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--ELASTICSEARCHCLUSTERSIZE")     #
			elasticsearch_clustersize=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--REDISSERVERREPLICAS")     #
			redisServerReplicas=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--USETLSCERTSJOB")     #
			useTLSCertsJob=$2 ; shift 2; ARGC=$(($ARGC-2)) ;;
		"--HELP")	#
			USAGE
            exit 1 ;;

		*)
			PRINT_MESSAGE "Argument \"${PRE_FORMAT_ARG}\" not known. Exiting.\n"
			USAGE
            exit 1 ;;
    esac
done
}


WRITE_VALUES() {
    PRINT_MESSAGE

    # setting variables in one place
    product_name="IBM Cloud App Management"
    if [ "$advanced" == "true" ]; then
	product_name="${product_name} Advanced"
    fi

    global_image_repository="${cluster_CA_domain}:${repository_port}/${namespace}"

    values_file=./${release_name}.values.yaml

    # writing to the file

cat > ${values_file} <<EOF
global:
  imageNamePrefix: ""
  masterIP: ${global_masterIP}
  masterPort: ${global_masterPort}
  proxyIP: ${global_proxyIP}
  ingress:
    port: ${global_ingressPort}
    domain: "${global_ingress_domain}"
    tlsSecret: "${server_secret}"
    clientSecret: "${client_secret}"
  icammcm:
    ingress:
      tlsSecret: ""
      clientSecret: ""
  image:
    repository: "${global_image_repository}"
  sidecar:
    imageGroup: ""
EOF

# under global
if [ $license_agreement_accepted == "true" ]; then
cat >> ${values_file} <<EOF
  license: accept
EOF
fi

# under global
if [ -n "${global_minreplicashpas}" ] ; then
cat >> ${values_file} <<EOF
  minReplicasHPAs: ${global_minreplicashpas}
EOF
fi

# under global
if [ -n "${global_maxreplicashpas}" ] ; then
cat >> ${values_file} <<EOF
  maxReplicasHPAs: ${global_maxreplicashpas}
EOF
fi

# under global
if [ -n "${zookeeper_clustersize}" ] ; then
cat >> ${values_file} <<EOF
  zookeeper:
    clusterSize: ${zookeeper_clustersize}
EOF
fi

# under global
if [[ -n "${kafka_clustersize}" ]] || [[ -n "${metricKafkaRep}" ]] ; then
cat >> ${values_file} <<EOF
  kafka:
EOF
fi

# under global.kafka
if [ -n "${kafka_clustersize}" ] ; then
cat >> ${values_file} <<EOF
    clusterSize: ${kafka_clustersize}
EOF
fi

# under global.kafka
if [ -n "${metricKafkaRep}" ] ; then
cat >> ${values_file} <<EOF
    replication:
      metrics: ${metricKafkaRep}
EOF
fi

# under global
if [ -n "${metricSummarization}" ] ; then
cat >> ${values_file} <<EOF
  metric:
    summary:
      enabled: ${metricSummarization}
EOF
else
cat >> ${values_file} <<EOF
  metric:
    summary:
      enabled: false
EOF
fi

# get the stuff that's in the overrides.yaml generated
# by the prepare-pv.sh script
cat ${DIR}/../yaml/${storage_size_file} >> ${values_file}

# under global
if [ -n "${cassandra_clustersize}" ] ; then
cat >> ${values_file} <<EOF
  cassandraNodeReplicas: ${cassandra_clustersize}
EOF
	if [ ${cassandra_clustersize} -gt 1 ] ; then
cat >> ${values_file} <<EOF
  cassandra:
    superuserRole: true
EOF
	fi
fi

# under global
if [ -n "${elasticsearch_clustersize}" ] ; then
cat >> ${values_file} <<EOF
  elasticsearch:
    replicaCount: ${elasticsearch_clustersize}
EOF
fi

# under global
if [ -n "${metricC8Rep}" ] ; then
cat >> ${values_file} <<EOF
  metricC8Rep: "${metricC8Rep}"
EOF
fi

# under global
if [ -n "${openttC8Rep}" ] ; then
cat >> ${values_file} <<EOF
  openttC8Rep: ${openttC8Rep}
EOF
fi

# under global
if [ -n "${openttC8Rep}" ] ; then
cat >> ${values_file} <<EOF
  openttC8Rep: ${openttC8Rep}
EOF
fi

# top level
if [ -n "${redisServerReplicas}" ]; then
    cat >> ${values_file} <<EOF
ibmRedis:
  replicas:
    servers: ${redisServerReplicas}
EOF
fi

# top level
if [ $license_agreement_accepted == "true" ]; then
cat >> ${values_file} <<EOF
ibm-cloud-appmgmt-prod:
  license: accept
ibm-cem:
  license: "accept"
  productName: "${product_name}"
EOF
fi

# under ibm-cem
if [[ -n "${couchdb_clustersize}" ]] || [[ -n "${couchdb_numReplicas}" ]] || [[ -n "${couchdb_numShards}" ]] ; then
cat >> ${values_file} <<EOF
  couchdb:
EOF
fi

# under ibm-cem.couchdb
if [ -n "${couchdb_clustersize}" ] ; then
cat >> ${values_file} <<EOF
    clusterSize: ${couchdb_clustersize}
EOF
fi
# under ibm-cem.couchdb
if [ -n "${couchdb_numReplicas}" ] ; then
cat >> ${values_file} <<EOF
    numReplicas: ${couchdb_numReplicas}
EOF
fi

# under ibm-cem.couchdb
if [ -n "${couchdb_numShards}" ] ; then
cat >> ${values_file} <<EOF
    numShards: ${couchdb_numShards}
EOF
fi

# under ibm-cem
if [ -n "${datalayer_clustersize}" ] ; then
cat >> ${values_file} <<EOF
  datalayer:
    clusterSize: ${datalayer_clustersize}
EOF
fi

# under ibm-cem
if [ "${ibmcemprod_email_type}" == "smtp" ] ; then
cat >> ${values_file} <<EOF
  email:
    type: "${ibmcemprod_email_type}"
    smtphost: "${ibmcemprod_email_smtphost}"
    smtpport: "${ibmcemprod_email_smtpport}"
    smtpuser: "${ibmcemprod_email_smtpuser}"
    smtppassword: "${ibmcemprod_email_smtppassword}"
	smtpauth: "${ibmcemprod_email_smtpauth}"
	smtprejectunauthorized: "${ibmcemprod_email_smtprejectunauthorized}"
    mail: "${ibmcemprod_email_mail}"
EOF

elif [ "${ibmcemprod_email_type}" == "api" ] ; then
cat >> ${values_file} <<EOF
  email:
    type: "${ibmcemprod_email_type}"
    apikey: "${ibmcemprod_email_apikey}"
    mail: "${ibmcemprod_email_mail}"
EOF
fi

# top level
if [ "$advanced" == "true" ]; then
cat >> ${values_file} <<EOF
tags:
  advanced: true
EOF
else
cat >> ${values_file} <<EOF
tags:
  advanced: false
EOF
fi

# top level
if [ "${createTLSCerts}" == "true" ]; then
cat >> ${values_file} <<EOF
createTLSCerts: true
EOF
fi

PRINT_MESSAGE "Generated ${values_file}\n"
PRINT_MESSAGE "-----\n"
cat ${values_file} 2>&1 | tee -a ${log_file}
PRINT_MESSAGE "-----\n\n"
}

WRITE_CLUSTER_IMAGE_POLICY() {
    policy_file=./${namespace}-${release_name}-image-policy.yaml
    cat >${policy_file} <<EOF
apiVersion: securityenforcement.admission.cloud.ibm.com/v1beta1
kind: ClusterImagePolicy
metadata:
  name: ${namespace}-${release_name}-image-policy
  labels:
    release: ${release_name}
spec:
   repositories:
    - name: "${global_image_repository}/*"
      policy:
        trust:
          enabled: false
        va:
          enabled: false
EOF

    PRINT_MESSAGE "Generated ${values_file}\n"
    PRINT_MESSAGE "-----\n"
    cat ${policy_file} 2>&1 | tee -a ${log_file}
    PRINT_MESSAGE "-----\n\n"

}

CLOUD_APPMGMT_HELM_INSTALL() {
if [ -n "${skip_helm_install}" ] ; then
	PRINT_MESSAGE "`date` Skipping helm chart install due to skipHelmInstall flag.\n"
else

    HELM_INSTALL_CMD="helm install ${helm_chart_file} --tls -n ${release_name} --values ${values_file} --namespace ${namespace} ${set_flag}"
    helm_install="true"
	if [ -n "${helm_install}" ] ; then
		PRINT_MESSAGE "`date` ${HELM_INSTALL_CMD}\n"
		if [ -n "${run}" ] ; then
			${HELM_INSTALL_CMD} 2>&1 | tee -a ${log_file}
			TESTRESULTS_EXIT $? "${HELM_INSTALL_CMD}"
			PRINT_MESSAGE "\n"
		else
			PRINT_MESSAGE "Skipping helm install due to test flag.\n"
		fi
	fi
	PRINT_MESSAGE "\n"
	#sleep 10
	#WAIT_FOR_SERVICES
fi
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

CASSANDRA_CREDENTIALS(){
    echo "Creating the cassandra-auth-secret with the user provided credentials"
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
	echo "Please provide your cassandraPassword: "
	read -s cassandraPassword
    # if the user didn't provide the cassandra username, use the defaults for both
    else
	echo "No cassandraUsername or cassandraPassword was provided. Using the default username and password. This is insecure."
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
    echo "Successfully created ${release_name}-cassandra-auth-secret with user provided credentials"
else
    echo "Could not create ${release_name}-cassandra-auth-secret. Please ensure that you have provided the correct releaseName and namespace, and that the cassandra username consists of only alphanumeric characters."
    exit 1
fi

}


HTTPS() {
    server_secret=icam-ingress-tls
    client_secret=icam-ingress-client
    certificate_archive=icam-ingress-artifacts
    if [[ -z "${useTLSCertsJob}" || ${useTLSCertsJob} == "false" ]]; then
        createTLSCerts=false
        ${DIR}/lib/make-ca-cert-icam.sh ${global_ingress_domain} ${release_name} ${namespace} ${server_secret} ${client_secret} ${certificate_archive}
    else 
        createTLSCerts=true
    fi
}

SET_METRIC_REPLICATION() {

if [ -z "${metricKafkaRep}" ] ; then
	if [ -n "${kafka_clustersize}" ] ; then
		if [ ${kafka_clustersize} -gt 2 ] ; then
			metricKafkaRep=2
		else
			metricKafkaRep=${metricKafkaRep}
		fi
	else
		metricKafkaRep=1
	fi

fi

if [ -z "${metricC8Rep}" ] ; then
	if [ -n "${cassandra_clustersize}" ] ; then
		if [ ${cassandra_clustersize} -gt 2 ] ; then
			metricC8RepNumber=2
		else
			metricC8RepNumber=${cassandra_clustersize}
		fi
	else
		metricC8RepNumber=1
	fi
	metricC8Rep="{'class':'SimpleStrategy','replication_factor':${metricC8RepNumber}}"

fi

if [ -z "${openttC8RepC8Rep}" ] ; then
	if [ -n "${cassandra_clustersize}" ] ; then
		if [ ${cassandra_clustersize} -gt 2 ] ; then
			openttC8Rep=2
		else
			openttC8Rep=${cassandra_clustersize}
		fi
	else
		openttC8Rep=1
	fi
fi

}

MAIN() {
PRINT_MESSAGE "Welcome to IBM Cloud App Management. \n"
PRINT_MESSAGE "For more information, please visit http://ibm.biz/app-mgmt-kc \n\n"

if [ ! -e ${DIR}/../yaml/config.storage.txt ]; then

    echo "Persistent Volumes are not defined. Please run prepare-pv.sh in advance."
    exit 1
fi

LICENSE_AGREEMENT
CASSANDRA_CREDENTIALS
HTTPS
SET_METRIC_REPLICATION
WRITE_VALUES
WRITE_CLUSTER_IMAGE_POLICY
}

INITIALIZE
PARSE_ARGS "$@"

MAIN
