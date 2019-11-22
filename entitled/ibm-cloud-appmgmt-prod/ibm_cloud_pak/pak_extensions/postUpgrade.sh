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
numOfArgs=$#

usage() {
    echo "Use $0 after upgrading from ICAM 2019.2.0 to ICAM 2019.2.1. It performs various housekeeping tasks, like deleting inactive kafka topics and inactive config service data."
    echo
    echo "Example usage of $0 with an ICAM installation with release-name of 'my-icam-release' and namespace of 'icam-ns'."
    echo
    echo "$0 --releaseName ibmcloudappmgmt --namespace default"
    exit 0
}

parse_args() {
    ARGC=$#
    if [ $ARGC == 0 ] ; then
	      usage
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
		"--RELEASENAME")     #
			release_name=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--NAMESPACE")     #
			namespace=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--HELP")	#
			usage
            exit 1 ;;

		*)
			echo "Argument \"${PRE_FORMAT_ARG}\" not known. Exiting.\n"
			usage
            exit 1 ;;
    esac
done
}


verifyReleaseAndNamespace(){
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

waitForComp(){
    # component
    comp=$1
    numContainers=$2
    echo "Waiting for $comp to come ready."
    local counter=0
    while true; do
	ready=$(kubectl get pods -n ${namespace} | grep ${release_name}-${comp} -m 1 | grep -v Terminating | grep Running | awk '{print $2}')
	if [[ "${ready}" == "${numContainers}/${numContainers}" ]]; then
	   echo "$comp is ready."
           break;
        else
            echo "Waiting for $comp: ${ready}."
            sleep 5;
            ((counter++))
            
            # It will wait for 10 minutes; but it should be ready well before then
            if [ ${counter} -eq 120 ]; then
               echo "Error: $comp did not come ready within 10 minutes."
               exit 1
            fi
        fi
    done
}

deleteMongoService(){
    echo "Deleting the MongoDB service data from the config service."
    
    # get a config pod; this will get the first config pod it sees, if there are more than one
    configPod=`kubectl get pods -n ${namespace} | grep ${release_name}-config -m 1 | grep Running | awk '{print $1}'`

    # Get-config-service-ports ingredients:
    # get all services
    # grep for those with ${release_name}-config
    # get the field with the port numbers
    # first pass of sed strips the https port
    # second pass of sed strips the /TCP
    # only thing that's left is the http port
    configPort=`kubectl -n ${namespace} get service | grep ${release_name}-config | awk '{print $5}' | sed -e 's/\,.*$//g' -e 's_/TCP__'`

    # get config service ip
    configIP=`kubectl -n ${namespace} get service | grep ${release_name}-config | awk '{print $3}'`

    # Curl command to see if the Mongo service data exists in config
    checkSvcStr="curl -s -o /dev/null -w '%{http_code}' -H 'Content-Type: application/json' -X GET 'http://${configIP}:${configPort}/1.0/systemconfig/services/com.ibm.tivoli.ccm.mongo/'"

    # Curl command to delete the Mongo service data in config
    deleteSvcStr="curl -s -o /dev/null -w '%{http_code}' -X DELETE 'http://${configIP}:${configPort}/1.0/systemconfig/services/com.ibm.tivoli.ccm.mongo/'"

    doesMongoServiceExistHTTP=$(kubectl exec ${configPod} -n ${namespace} -- bash -c "$checkSvcStr")

    if [ $doesMongoServiceExistHTTP -eq 200 ]; then
	echo "Mongo service exists. Deleting it."
	deleteMongoServiceHTTP=$(kubectl exec ${configPod} -n ${namespace} -- bash -c "$deleteSvcStr")
        if [ $deleteMongoServiceHTTP -eq 204 ]; then
	    echo "Successfully deleted Mongo service."
        else
	    echo "The Mongo service data exists in the config service, but we weren't able to delete it. To delete it yourself, first get the name of one of the config pods by executing\: \'kubectl get pods -n ${namespace} \| grep ${release_name}-config\' and assign it to \$CONFIGPOD."
	    echo "Then get the config service IP address and http port via \'kubectl get svc -n ${namespace}\'. Write the two values to a file for reference."
	    echo "Then, exec into the config pod via \'kubectl -n ${namespace} exec -it \$CONFIGPOD bash\'."
	    echo "Finally, issue the following command from inside the pod, replacing CONFIGSVCIP and CONFIGSVCPORT with the two values from earlier\:"
	    echo "curl -X DELETE \'http://CONFIGSVCIP:CONFIGSVCPORT/1.0/systemconfig/services/com.ibm.tivoli.ccm.mongo/\'"
	fi
    elif [ $doesMongoServiceExistHTTP -eq 404 ]; then
	echo "The Mongo service data does not exist in the config service. The most likely cause is that it was deleted by a previous run of this script."
    else
	echo "We can't verify that the Mongo service data exists or doesn't exist in the config service. Please ensure that config is running, and re-execute the script."
    fi
}

deleteKafkaTopics(){
    echo "Deleting kafka topics."
    # make array consisting of topics
    # iterate through array with
    kafkaTopics=('aar.middleware.json' 
		 'aar.network.http.json'
		 'aar.realuser.browser.json'
		 'aar.synthetic.json')

    for kafka_topic in "${kafkaTopics[@]}"; do
	kafkaTopicStr="/opt/kafka/bin/kafka-topics.sh --delete --topic ${kafka_topic} --zookeeper \$ZOOKEEPER_URL"
	topicDeletionResult=$(kubectl exec ${release_name}-kafka-0 -c ${release_name}-kafka -n ops-am -- bash -c "$kafkaTopicStr")
	wasTopicDeleted=$(echo $topicDeletionResult | grep "marked for deletion")
	if [[ "${wasTopicDeleted}" ]]; then
	    echo "$kafka_topic was successfully marked for deletion."
	else
	    echo "$kafka_topic could not be marked for deletion. The most likely cause is that it was deleted by a previous run of this script."
	fi
    done
}

deleteMongoSecrets(){
    mongoCredsSecret="${release_name}-mongodb-creds-secret"
    mongoKeyfileSecret="${release_name}-mongodb-keyfile-secret"
    secretArr=( "${mongoCredsSecret}" "${mongoKeyfileSecret}" )
    # delete secrets if they exist
    for secret in "${secretArr[@]}"; do
	kubectl get secrets -n ${namespace} | grep "${secret}"
	result=$?
	if [ $result -eq 0 ]; then
	    echo "${secret} found; deleting it."
	    kubectl delete secret ${secret} -n ${namespace}
	    result=$?
	    if [ $result -eq 0 ]; then
		echo "Successfully deleted ${secret}"
	    else
		echo "${secret} exists, but we couldn't delete it. Please check the secrets in the ${namespace} namespace and delete ${secret} manually. This is for house-keeping purposes only."
	    fi
	fi
    done
}

main(){
    if [ $numOfArgs -ne 4 ]; then
	usage
    else
	echo "####################################"
	verifyReleaseAndNamespace
	echo
	echo "####################################"
	waitForComp config 1
	echo
	echo "####################################"
	deleteMongoService
	echo
	echo "####################################"
	deleteKafkaTopics
	echo
	echo "####################################"
	deleteMongoSecrets
	echo
	echo "Post-Upgrade clean-up complete."
    fi
}
parse_args "$@"
main
