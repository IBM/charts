#!/bin/sh

#*===================================================================
#*  Licensed Materials - Property of IBM
#*   5737-E67
#*  IBM Cloud Cost and Asset Management
#*  (C) Copyright IBM Corporation 2018 All Rights Reserved.
#*  US Government Users Restricted Rights - Use, duplication or
#*  disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#*===================================================================

# This shell script creates kubernetes secrets for CORE
# Variables section

create=false
delete=false
recreate=false
delete_namespace=false
properties_file=''
couchdb_username="admin"

BASEDIR="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
SCRIPTSDIR=$(dirname $BASEDIR)
RESDIR=$(dirname $SCRIPTSDIR)'/resources'
LOGSDIR=$SCRIPTSDIR'/logs'
CERTDIR="$RESDIR"'/cert'
log_file=$LOGSDIR'/log_'$(date +%F_%H%M%S)'.log'
icp_ca_certificate="$CERTDIR"

RED='\033[0;31m'
NC='\033[0m' # No Color

if ! [ -d $LOGSDIR ] ;then
    mkdir $LOGSDIR
fi

usage()
{
    echo "Usage: sh prePlatform.sh -c|-d|-r -f <properties_file> [-h] "
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
    if ! ( kubectl get namespaces  2>&1  | grep -iq "${core_namespace}") then
        kubectl create namespace "${core_namespace}" 2> /dev/null
    fi

    # 1. create myregistrykey secrets
    kubectl create secret docker-registry myregistrykey --docker-server="${docker_server}" --docker-username="${docker_username}" --docker-password="${docker_password}" --docker-email="${docker_email}" -n "${core_namespace}" 2> /dev/null

    # 2. create couchdb secrets
    kubectl create secret generic couchdb-creds --from-literal="couchdb.username=$couchdb_username" --from-literal="couchdb.password=$couchdb_password" -n "${core_namespace}" 2> /dev/null

    # 3. create mongodb secrets
    kubectl create secret generic mongodb-creds --from-literal="mongodb.username=$mongodb_username" --from-literal="mongodb.url=$mongodb_url" --from-literal="mongodb.password=$mongodb_password" -n "${core_namespace}" 2> /dev/null

    # 4. create apigateway blueid secrets
    kubectl create secret generic apigateway-blueid-creds --from-literal="clientID=$blue_ID" --from-literal="clientSecret=$blue_secret" -n "${core_namespace}" 2> /dev/null

    # 5. create core vault secrets
    kubectl create secret generic core-vault --from-literal="vault.hcl=$vault_hcl" -n "${core_namespace}" 2> /dev/null

    # 6. create gravitant certificates
    kubectl create secret generic  grav-certificates --from-file="grav.crt=$gravitant_certificate" --from-file="grav.key=$gravitant_key" -n "${core_namespace}" 2> /dev/null

    # 7. create gravitant tls secrets
    kubectl create secret tls  grav-tls --cert="$gravitant_certificate" --key="$gravitant_key" -n "${core_namespace}" 2> /dev/null

    # 8. create vault encrypt secrets
    kubectl create secret generic vault-encrypt-key --from-literal="vault.encryptkey=$vault_encryption_key" -n "${core_namespace}" 2> /dev/null

    # 9. create s3 secrets
    kubectl create secret generic s3 --from-literal="s3.url=$s3_url" --from-literal="s3.access_key_id=$s3_access_key_id"  --from-literal="s3.secret_access_key=$s3_access_key_secret"  --from-literal="encryption_passphrase=$s3_encryption_passphrase" -n "${core_namespace}" 2> /dev/null

    # 10 create rabbitmq-creds secrets
    kubectl create secret generic rabbitmq-creds --from-literal="rabbitmq.username=$rabbitmq_username" --from-literal="rabbitmq.password=$rabbitmq_password" -n "${core_namespace}" 2> /dev/null
   
    # 11 Creating config map for getting ICP certificate. 
    kubectl create configmap ca-config --from-file="$icp_ca_certificate" -n "${core_namespace}" 2> /dev/null
    echo "All secrets are created."
}

delete()
{
    kubectl delete secrets "myregistrykey" -n "${core_namespace}"  2> /dev/null
    kubectl delete secrets "couchdb-creds" -n "${core_namespace}" 2> /dev/null
    kubectl delete secrets "mongodb-creds" -n "${core_namespace}" 2> /dev/null
    kubectl delete secrets "apigateway-blueid-creds" -n "${core_namespace}" 2> /dev/null
    kubectl delete secrets "core-vault" -n "${core_namespace}" 2> /dev/null
    kubectl delete secrets "grav-certificates" -n "${core_namespace}" 2> /dev/null
    kubectl delete secrets "grav-tls" -n "${core_namespace}" 2> /dev/null
    kubectl delete secrets "vault-encrypt-key" -n "${core_namespace}" 2> /dev/null
    kubectl delete secrets "s3" -n "${core_namespace}" 2> /dev/null
    kubectl delete secrets "rabbitmq-creds" -n "${core_namespace}" 2> /dev/null
    echo "All secrets are deleted."
}

delete_namespace()
{
	kubectl delete namespace ${core_namespace} 2> /dev/null
	echo "${core_namespace} namespace deleted."
}

validate_property_file()
{
    . "$RESDIR/$properties_file"

    # checking user input in properties file
    msg=false
    key_msg="Initialisation incomplete. Enter property values : "

    if [ -z "$docker_server" ]; then
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

    if [ -z "$core_namespace" ]; then
        key_msg="$key_msg core_namespace"
        msg=true
    fi

    if [ -z "$couchdb_password" ]; then
        key_msg="$key_msg couchdb_password"
        msg=true
    fi

    if [ -z "$mongodb_username" ]; then
        key_msg="$key_msg mongodb_username"
        msg=true
    fi
    
    if [ -z "$mongodb_password" ]; then
        key_msg="$key_msg mongodb_password"
        msg=true
    fi

    if [ -z "$blue_ID" ]; then
        key_msg="$key_msg blue_ID"
        msg=true
    fi

    if [ -z "$blue_secret" ]; then
        key_msg="$key_msg blue_secret"
        msg=true
    fi

    if [ -z "$gravitant_certificate" ]; then
        key_msg="$key_msg gravitant_certificate"
        msg=true
    fi

    if [ -z "$gravitant_key" ]; then
        key_msg="$key_msg gravitant_key"
        msg=true
    fi

    if [ -z "$vault_encryption_key" ]; then
        key_msg="$key_msg vault_encryption_key"
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
    
    if [ -z "$rabbitmq_username" ]; then
        key_msg="$key_msg rabbitmq_username"
        msg=true
    fi

    if [ -z "$rabbitmq_password" ]; then
        key_msg="$key_msg rabbitmq_password"
        msg=true
    fi

    if [ "$msg" = true ] ; then
        echo | tee -a "$log_file"
        echo "$key_msg" | tee -a "$log_file"
        exit
    fi
    
    
    mongodb_url="mongodb://$mongodb_username:$mongodb_password@mongodb:27017"
    gravitant_certificate=$CERTDIR/$gravitant_certificate
    gravitant_key=$CERTDIR/$gravitant_key
    icp_ca_certificate=$icp_ca_certificate/$icp_certificate

    if ! [ -f "$icp_ca_certificate" ]; then
        echo "File $icp_ca_certificate not found, skipping secret creation" | tee -a "$log_file"
        exit
    fi

    if ! [ -f "$gravitant_certificate" ]; then
        echo "File $gravitant_certificate not found, skipping secret creation" | tee -a "$log_file"
        exit
    fi

    if ! [ -f "$gravitant_key" ]; then
        echo "File $gravitant_key not found, skipping secret creation" | tee -a "$log_file"
        exit
    fi

    vault_hcl="storage \"couchdb\" {
    endpoint = \"http://couchdb:5984/vault-db\"
    username = \"$couchdb_username\"
    password = \"$couchdb_password\"
    }
    listener \"tcp\" {
    address  = \"0.0.0.0:8200\"
    tls_cert_file = \"/etc/certs/grav.crt\"
    tls_key_file  = \"/etc/certs/grav.key\"
    }
    disable_mlock = false"
}



if [ "$#" -eq 0 ]; then
    usage | tee -a "$log_file"
    exit 1
fi

while [ "$1" != "" ]; do
    case $1 in
        -c | --create )             create=true
                                    ;;
	-n | --delete_namespace )   delete_namespace=true
				    ;;
        -d | --delete )             delete=true
                                    ;;
        -r | --recreate )           recreate=true
                                    ;;
        -f | --file )               shift
                                    properties_file=$1
                                    ;;
        -h | --help )               usage | tee -a "$log_file"
                                    exit 1
                                    ;;
        * )                         usage | tee -a "$log_file"
                                    exit 1
    esac
    shift
done

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

if ! [ "$properties_file" ]  ;then
    echo "${RED}Properties file is mandatory${NC}" | tee -a "$log_file"
    usage | tee -a "$log_file"
    exit 1
fi

if ! [ -s "$RESDIR/$properties_file" ] ; then
    echo "${RED}Couldnot find properties file '$properties_file' in $RESDIR directory or its emtpy, Please verify and rerun again.${NC}" | tee -a "$log_file"
    exit 1
fi

validate_property_file ||  exit 1

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

if $delete_namespace ; then
    delete_namespace | tee -a "$log_file"
fi
