#!/bin/sh

#*===================================================================
#*  Licensed Materials - Property of IBM
#*   5737-E67
#*  IBM Cloud Cost and Asset Management
#*  (C) Copyright IBM Corporation 2018 All Rights Reserved.
#*  US Government Users Restricted Rights - Use, duplication or
#*  disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#*===================================================================

# This shell script creates kubernetes secrets for CAM


# Variables section

create=false
delete=false
delete_namespace=false
recreate=false
properties_file=''

docker_server=""
docker_username=""
docker_password=""
docker_email=""
core_namespace=""
cam_namespace=""
rabbitmq_username=""
rabbitmq_password=""
keystore_password=""
mysql_username=""
mysql_password=""
slack_URL=""
s3_url=""
s3_access_key_id=""
s3_access_key_secret=""
s3_encryption_passphrase=""

BASEDIR="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
SCRIPTSDIR=$(dirname $BASEDIR)
RESDIR=$(dirname $SCRIPTSDIR)'/resources'
CERTDIR="$RESDIR"'/cert'
LOGSDIR=$SCRIPTSDIR'/logs'
log_file=$LOGSDIR'/log_'$(date +%F_%H%M%S)'.log'

RED='\033[0;31m'
NC='\033[0m' # No Color

if ! [ -d $LOGSDIR ] ;then
    mkdir $LOGSDIR
fi

usage()
{
    echo "Usage: sh preCCAM.sh -c|-d|-r -f <properties_file> [-h] "
    echo ""
    echo "Options:"
    echo "  -h/--help     : print this help message. "
    echo "  -f/--file     : <properties file name>"
    echo "                          eg., \"-f pre_install_core.properties\" "
    echo ""
    echo "  -c/--create   : create the secrets; will not overwrite existing secrets. "
    echo "  -r/--recreate : create or overwrite the secrets. "
    echo "  -d/--delete   : delete the secrets. "
    echo
    echo "${RED}NOTE: 1.Either of create, recreate and delete can be true, more than one mode is not supported.${NC}"
    echo "${RED}      2.All the config files should be under 'resources/cert/' directory and the properties file should be under 'resources/' directory.${NC}"
}

create()
{
    if ! ( kubectl get namespaces  2>&1  | grep -iq "${cam_namespace}") then
        kubectl create namespace "${cam_namespace}" 2> /dev/null
    fi

    # 1. create myregistrykey secrets
    kubectl create secret docker-registry myregistrykey --docker-server="${docker_server}" --docker-username="${docker_username}" --docker-password="${docker_password}" --docker-email="${docker_email}" -n "${cam_namespace}" 2> /dev/null

    # 2. create rabbitmq-creds secrets
    kubectl create secret generic rabbitmq-creds --from-literal="rabbitmq.username=$rabbitmq_username" --from-literal="rabbitmq.password=$rabbitmq_password" -n "${cam_namespace}" 2> /dev/null

    # 3. create keystore secrets
    kubectl create secret generic keystore-password  --from-literal="password=$keystore_password" -n "${cam_namespace}" 2> /dev/null

    # 4. create gravitant certificates, key secrets
    kubectl create secret generic  grav-certificates --from-file="grav.crt=$gravitant_certificate" --from-file="grav.key=$gravitant_key" --from-file="cm.keystore=$cm_keystore" --from-file="maria_dev.crt=$maria_dev_certificate"  --from-file="maria_dev.key=$maria_dev_key" --from-file="rootca.pem=$rootCA_pem" -n "${cam_namespace}" 2> /dev/null

    # 5. create gravitant tls certificates, key secrets
    kubectl create secret tls grav-tls --cert="$gravitant_certificate" --key="$gravitant_key" -n "${cam_namespace}" 2> /dev/null

    # 6. mariadb secrets
    kubectl create secret generic  mariadb-rootpem --from-file="rootCA.pem=$rootCA_pem" -n "${cam_namespace}" 2> /dev/null

    # 7. s3 credentials
    kubectl create secret generic s3 --from-literal="s3.url=$s3_url" --from-literal="s3.access_key_id=$s3_access_key_id"  --from-literal="s3.secret_access_key=$s3_access_key_secret"  --from-literal="encryption_passphrase=$s3_encryption_passphrase" -n "${cam_namespace}" 2> /dev/null

    # 8. mysql username
    kubectl create secret generic mysql-username --from-literal="mysql.username=$mysql_username" -n "${cam_namespace}" 2> /dev/null

    # 9. mysql password
    kubectl create secret generic mysql-password --from-literal="mysql.key=$mysql_password" -n "${cam_namespace}" 2> /dev/null

    # 10. slack_URL
    kubectl create secret generic slack-hooks --from-literal="slackURL=$slack_URL" -n "${cam_namespace}" 2> /dev/null

    echo "All secrets are created."
}

delete()
{
    kubectl delete secrets "myregistrykey" -n "${cam_namespace}" 2> /dev/null
    kubectl delete secrets "rabbitmq-creds" -n "${cam_namespace}" 2> /dev/null
    kubectl delete secrets "keystore-password" -n "${cam_namespace}" 2> /dev/null
    kubectl delete secrets "grav-certificates" -n "${cam_namespace}" 2> /dev/null
    kubectl delete secrets "grav-tls" -n "${cam_namespace}" 2> /dev/null
    kubectl delete secrets "mariadb-rootpem" -n "${cam_namespace}" 2> /dev/null
    kubectl delete secrets "s3" -n "${cam_namespace}" 2> /dev/null
    kubectl delete secrets "mysql-username" -n "${cam_namespace}" 2> /dev/null
    kubectl delete secrets "mysql-password" -n "${cam_namespace}" 2> /dev/null
    kubectl delete secrets "slack-hooks" -n "${cam_namespace}" 2> /dev/null
    echo "All secrets are deleted."
}

delete_namespace()
{
    kubectl delete namespace "${cam_namespace}" 2> /dev/null
    echo "${cam_namespace} namespace deleted."
}

validate_property_file()
{
    . "$RESDIR/$properties_file"

    # checking user input in properties file
    msg=false
    key_msg="Initialisation incomplete. Enter property values : "

    if [ -z "$docker_server" ] ;then
	key_msg="$key_msg docker_server"
	msg=true
    fi

    if [ -z "$docker_username" ]; then
        key_msg="$key_msg docker_username"
        msg=true
    fi

    if [ -z "$docker_password" ]; then
        key_msg="$key_msg docker_password"
        msg=true
    fi

    if [ -z "$docker_email" ]; then
        key_msg="$key_msg docker_email"
        msg=true
    fi

    if [ -z "$cam_namespace" ]; then
        key_msg="$key_msg cam_namespace"
        msg=true
    fi

    if [ -z "$rabbitmq_username" ]; then
        key_msg="$key_msg rabbitmq_username"
        msg=true
    fi

    if [ -z "$rabbitmq_password" ]; then
        key_msg="$key_msg rabbitmq_password"
        msg=true
    fi

    if [ -z "$keystore_password" ]; then
        key_msg="$key_msg keystore_password"
        msg=true
    fi

    if [ -z "$gravitant_certificate" ];  then
        key_msg="$key_msg gravitant_certificate"
        msg=true
    fi

    if [ -z "$gravitant_key" ]; then
        key_msg="$key_msg gravitant_key"
        msg=true
    fi

    if [ -z "$cm_keystore" ]; then
        key_msg="$key_msg cm_keystore"
        msg=true
    fi

    if [ -z "$maria_dev_certificate" ]; then
        key_msg="$key_msg maria_dev_certificate"
        msg=true
    fi

    if [ -z "$maria_dev_key" ]; then
        key_msg="$key_msg maria_dev_key"
        msg=true
    fi

    if [ -z "$rootCA_pem" ]; then
        key_msg="$key_msg rootCA_pem"
        msg=true
    fi

    if [ -z "$s3_url" ]; then
        key_msg="$key_msg s3_url"
        msg=true
    fi

    if [ -z "$s3_access_key_id" ]; then
        key_msg="$key_msg s3_access_key_id"
        msg=true
    fi

    if [ -z "$s3_access_key_secret" ]; then
        key_msg="$key_msg s3_access_key_secret"
        msg=true
    fi

    if [ -z "$s3_encryption_passphrase" ]; then
        key_msg="$key_msg s3_encryption_passphrase"
        msg=true
    fi

    if [ -z "$slack_URL" ]; then
      key_msg="$key_msgslack_URL"
      msg=true
    fi

    if [ -z "$mysql_username" ]; then
        key_msg="$key_msg mysql_username"
        msg=true
    fi

    if [ -z "$mysql_password" ]; then
        key_msg="$key_msg mysql_password"
        msg=true
    fi

    if [ "$msg" = true ] ; then
        echo
        echo "$key_msg"
        echo
        exit 1
    fi

    key_msg="Initialisation incomplete.  "

    gravitant_certificate=$CERTDIR/$gravitant_certificate;
    gravitant_key=$CERTDIR/$gravitant_key;
    cm_keystore=$CERTDIR/$cm_keystore;
    maria_dev_certificate=$CERTDIR/$maria_dev_certificate;
    maria_dev_key=$CERTDIR/$maria_dev_key;
    rootCA_pem=$CERTDIR/$rootCA_pem;

    if ! [ -f "$gravitant_certificate" ]; then
        echo "$key_msg File $gravitant_certificate not found." | tee -a "$log_file"
        exit 1
    fi

    if ! [ -f "$gravitant_key" ]; then
        echo "$key_msg File $gravitant_key not found." | tee -a "$log_file"
        exit 1
    fi

    if ! [ -f "$cm_keystore" ]; then
        echo "$key_msg File $cm_keystore not found." | tee -a "$log_file"
        exit 1
    fi

    if ! [ -f "$maria_dev_certificate" ]; then
        echo "$key_msg File $maria_dev_certificate not found." | tee -a "$log_file"
        exit 1
    fi

    if ! [ -f "$maria_dev_key" ]; then
        echo "$key_msg File $maria_dev_key not found." | tee -a "$log_file"
        exit 1
    fi

    if ! [ -f "$rootCA_pem" ]; then
        echo "$key_msg File $rootCA_pem not found." | tee -a "$log_file"
        exit 1
    fi
}

if [ "$#" -eq 0 ]; then
    usage | tee -a "$log_file"
    exit 1
fi

while [ "$1" != "" ]; do
    case $1 in
        -c | --create )             create=true
                                    ;;
        -d | --delete )             delete=true
                                    ;;
	-n | --delete_namespace )   delete_namespace=true
                                    ;;
        -r | --recreate )           recreate=true
                                    ;;
        -f | --file )               shift
                                    properties_file=$1
                                    ;;
        -h | --help )               usage | tee -a "$log_file"
                                    exit 1
                                    ;;
        * )                         usage
                                    exit 1
    esac
    shift
done

if ! [ "$properties_file" ]  ;then
    echo "${RED}Properties file is mandatory${NC}" | tee -a "$log_file"
    usage | tee -a "$log_file"
    exit 1
fi

if ! [ -s "$RESDIR/$properties_file" ] ; then
    echo "${RED}Could not find properties file '$properties_file' in $RESDIR directory or its emtpy, Please verify and rerun again.${NC}" | tee -a "$log_file"
    exit 1
fi

validate_property_file || exit 1

#not_running_pods=$(kubectl get pods -n "${core_namespace}" --no-headers 2> /dev/null | awk '{if($3!="Running" &&  $3!="Completed") print($3)}' | wc -l)
pods_count=$(kubectl get pods -n "${core_namespace}" --no-headers 2> /dev/null | awk '{print($3)}' | wc -l)

if ! ($delete_namespace || $delete) ; then

	if !  $(helm list --tls | grep -iq "Deployed.*$core_namespace"); then
	    echo "${RED}IBM Cloud Management Platform not deployed, please verify and rerun again${NC}" | tee -a "$log_file"
            exit 1
	elif [ $pods_count -eq 0 ] ; then
   	    echo "${RED}IBM Cloud Management Platform deployed, but no pods are running , please verify and rerun again${NC}"  | tee -a "$log_file"
            exit 1
	fi
fi

if $create && $delete && $recreate && $delete_namespace ; then
    echo "${RED}Please try again with one of create, delete, delete namespace or recreate modes, all 4 modes cant be provided at once  ${NC}" | tee -a "$log_file"
    exit 1
fi

if ! $create && ! $delete && ! $recreate && ! $delete_namespace ; then
    echo "${RED}Either of create, delete, delete namespace or recreate mode is mandatory, Please try with any one mode ${NC}" | tee -a "$log_file"
    exit
fi

if ( $create && $delete) || ( $create && $recreate ) || ( $delete && $recreate ); then
    echo "${RED}Any one of the create, delete and recreate can be provided at once, Please retry with any one mode ${NC}" | tee -a "$log_file"
    exit 1
fi

if $create ; then
    create | tee -a "$log_file"
fi

if $delete ; then
    delete  | tee -a "$log_file"
fi

if $recreate; then
    delete | tee -a "$log_file"
    create | tee -a "$log_file"
fi

if $delete_namespace; then
    delete_namespace | tee -a "$log_file"
fi
