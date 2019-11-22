#!/usr/bin/env bash
########################################################################
#
# Licensed Materials - Property of IBM
#
# 5725-Q09
#
# (C) Copyright IBM Corp. 2019. All Rights Reserved
#
# US Government Users Restricted Rights - Use, duplication or disclosure 
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
# Netcool/OMNIbus Integrations
#
########################################################################

# Exit when failures occur (including unset variables)
set -o errexit
set -o pipefail
set -o nounset

# Script Directory
scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

while test $# -gt 0; do
    [[ $1 =~ ^-h|--help$ ]] && { showUsage="true"; shift 1; continue; };
    [[ $1 =~ ^-c|--config$ ]] && { configFile="$2"; shift 2; continue; };
    [[ $1 =~ ^--clean$ ]] && { CLEAN_START_OVERRIDE="true"; shift 1; continue; };
    [[ $1 =~ ^--debug$ ]] && { DEBUG_MODE="true"; shift 1; continue; };
    echo "Parameter not recognized: $1, ignored"
    shift
done

# Set defaults if unset.
: "${showUsage:="false"}"
: "${configFile:=""}"
: "${CONTAINER_SHARED_DIR:="/tmp/workspace"}"
: "${GENERATED_DIRNAME:="generated"}"
: "${CLIENT_KDB_FILENAME:="omni.kdb"}"
: "${CLEAN_START_OVERRIDE:=""}"
: "${DEBUG_MODE:=""}"

if [[ "$DEBUG_MODE" == "true" ]]; then
    echo "Enable trace mode."
    set -o xtrace
fi

function usage() {
    # Prints usage message
    cat <<HELP_USAGE

    $0  [--config <config file>]

    -h, --help              Prints this help message.
    -c, --config            Specifies the script configuration file path. Defaults to "./create-noi-secret.config"
    --clean                 Runs in clean mode. Deletes files in temporary directory and delete existing secret
                            set in SECRET_NAME parameter.
    --debug                 Runs in trace mode enabled. (set -o xtrace)

HELP_USAGE
}

function showHelp() {
    # Show usage message
    if [[ "$showUsage" == "true" ]]; then
        usage
        exit 0
    fi
}

function checkPrereq() {
    # Check configuration and prerequisites.
    echo "Running prerequisite checks ..."
    # Verify pre-req environment of kubectl exists
    command -v kubectl > /dev/null 2>&1 || { echo "kubectl pre-req is missing."; exit 1; }
    command -v docker > /dev/null 2>&1 || { echo "docker pre-req is missing."; exit 1; }

    local error=false

    configFilePath=""
    if [ -z "$configFile" ]; then
        configFile="create-noi-secret.config"
        configFilePath=$scriptDir/$configFile
        if [[ ! -f "$configFilePath" ]]; then
            echo "ERROR: Unable to find script configuration file: \"$configFile\" in current directory."
            usage
            exit 1
        fi
    else
        if [[ ! -f "$configFile" ]]; then
            echo "ERROR: Unable to find script configuration file: \"$configFile\"."
            usage
            exit 1
        fi
        configFilePath=$configFile
    fi

    echo "Loading configuration file: \"$configFilePath\"."
    source $configFilePath

    if [[ "$CLEAN_START_OVERRIDE" == "true" ]]; then
        CLEAN_START=$CLEAN_START_OVERRIDE
    fi

    if [[ "$CLEAN_START" == "true" ]]; then
        echo "CLEAN_START=\"$CLEAN_START\". Running in clean mode."
    fi

    if [ -z "${SECRET_NAME}" ]; then
        echo "ERROR: \"SECRET_NAME\" unset. Please specify a secret name that should be used."
        echo -e "\tYou can also set CEM Gateway chart release name as the prefix. For example: \"<release-name>-objserv-secret\""
        error=true
    else
        # Check if secret already exists
        output=$(kubectl get secret $SECRET_NAME --namespace $NAMESPACE --ignore-not-found=true)
        if [[ -n "$(echo $output | grep $SECRET_NAME)" ]]; then

            if [[ "$CLEAN_START" == "true" ]]; then
                echo "Deleting existing $SECRET_NAME"
                kubectl delete secret --namespace $NAMESPACE $SECRET_NAME
            else
                echo "Error: Secret $SECRET_NAME already exists in $NAMESPACE namespace."
                echo "Please delete the secret or use a different SECRET_NAME name."
                error=true
                exit 1
            fi
        fi
    fi

    if [ -z "${IMAGE_NAME}" ]; then
        echo "ERROR: \"IMAGE_NAME\" unset. Please specify the CEM Gateway image name."
        error=true
    else
        echo "Checking $IMAGE_NAME exists in local file system."
        if [[ -z "$(docker images $IMAGE_NAME -q)" ]]; then
            echo "WARNING: \"$IMAGE_NAME\" is not found in local file system."
            echo -e "\tPlease pull the image to your local file system first."
        fi
    fi


    if [[ -d "${TEMP_DIR}" ]] && [[ -n "$(ls ${TEMP_DIR})" ]]; then
        if [[ "$CLEAN_START" == "true" ]]; then
            echo "Cleaning up \"$TEMP_DIR\""
            rm -rf $TEMP_DIR
            mkdir -p $TEMP_DIR
        else
            echo "ERROR: There are existing files in \"$TEMP_DIR\" temporary directory. Exiting to avoid overwriting directory content."
            echo "Please specify a different temporary directory or clean up the \"$TEMP_DIR\" directory."
            error=true
        fi
    fi

    if [[ "$TLS_ENABLED" == "true" ]]; then
        if [ -z "$NOI_RELEASE_NAME" ]; then
            echo "ERROR: \"NOI_RELEASE_NAME\" unset. Please specify the NOI helm release name."
            error=true
        fi
        
        if [ -z "$NOI_NAMESPACE" ]; then 
            echo "ERROR: \"NOI_NAMESPACE\" unset. Please specify the NOI release namespace."
            error=true
        fi

        if [ -z "${NOI_TLS_SECRET_NAME}" ]; then
            echo "ERROR: Please specify the name of the TLS secret containing the TLS certificates in PEM format (tls.crt and tls.key)."
            error=true
        fi

        # Check NOI TLS Proxy secret
        echo "Check if \"$NOI_TLS_SECRET_NAME\" secret exists."
        kubectl get secret --namespace $NOI_NAMESPACE $NOI_TLS_SECRET_NAME || { noi_secret_found=false; }
        if [[ "${noi_secret_found:-}" == "false" ]]; then
            echo "Can't get  secret/$NOI_TLS_SECRET_NAME in \"$NOI_NAMESPACE\" namespace."
            echo "Please ensure that NOI release is installed and the TLS Proxy secret exists."
            error=true
        fi
    fi

    if [ -z "${KEY_DATABASE_PASSWORD}" ]; then
        echo "ERROR: \"KEY_DATABASE_PASSWORD\" unset. Please specify a key database password."
        error=true
    fi

    if [ -z "${AUTH_USERNAME}" ]; then
        echo "ERROR: \"AUTH_USERNAME\" unset. Please specify the username to authenticate with the object server."
        error=true
    fi

    if [ -z "${AUTH_PASSWORD}" ]; then
        echo "ERROR: \"AUTH_PASSWORD\" unset. Please specify the password to authenticate with the object server."
        error=true
    fi
    
    # Finally, exit if error.
    if [[ "$error" == "true" ]]; then
        echo ""
        echo "Some required parameters are unset. Please review the configuration file."
        exit 1
    fi
}

function createTemporaryDirectory() {

    if [[ ! -d "$TEMP_DIR" ]]; then
        mkdir -p $TEMP_DIR
        echo "Temporary directory created: \"$TEMP_DIR\""
    fi
}

function createKeyFile() {
    ## Key file needed for GW to run
    CLIENT_KEY_PATH=$TEMP_DIR/$GENERATED_DIRNAME
    CLIENT_KEY_FILE=encryption.keyfile
    KEY_FILE=$CLIENT_KEY_PATH/$CLIENT_KEY_FILE
    
    if [[ ! -f "$KEY_FILE" ]]; then
        local length=256
        echo "Creating new key file $KEY_FILE with $length length (in bits)."

        docker run -e LICENSE=accept \
        -e NCHOME=/opt/IBM/tivoli/netcool \
        --entrypoint /bin/bash -it \
        -v $TEMP_DIR:$CONTAINER_SHARED_DIR "$IMAGE_NAME" \
        -c "\$NCHOME/omnibus/bin/nco_keygen \
        -o $CONTAINER_SHARED_DIR/generated/$CLIENT_KEY_FILE \
        -l $length"
    fi
}

function setGeneratedDirectoryName(){
    GENERATED_DIR=$TEMP_DIR/$GENERATED_DIRNAME
    mkdir -p $GENERATED_DIR
    echo "\"generated\" sub-directory created: \"$GENERATED_DIR\""
}


function encryptPassword(){
    local keyFile=${1:-}
    local password=${2:-}

    outfile=$CONTAINER_SHARED_DIR/$GENERATED_DIRNAME/password.txt

    echo "Encrypting password to $outfile"
    docker run -e LICENSE=accept \
        -e NCHOME=/opt/IBM/tivoli/netcool \
        --entrypoint /bin/bash -it \
        -v $TEMP_DIR:$CONTAINER_SHARED_DIR \
        "$IMAGE_NAME" \
        -c "\$NCHOME/omnibus/bin/nco_aes_crypt -c AES_FIPS \
            -k $keyFile -o $outfile $password"
}

function getTLSCertFromSecret(){
    # Get the TLS cert files from the NETCOOL_TLS_SECRET
    CERTS_DIR=$TEMP_DIR/certs
    if [ ! -d $CERTS_DIR ]; then
        mkdir -p $CERTS_DIR 
    fi

    kubectl get secret \
        --namespace $NOI_NAMESPACE \
        $NOI_TLS_SECRET_NAME \
        -o json | grep tls.crt | cut -d : -f2 | cut -d '"' -f2 | base64 --decode > $CERTS_DIR/tls.crt
    
    if [ -s $CERTS_DIR/tls.crt ]; then
        echo "tls.crt file downloaded from $NOI_TLS_SECRET_NAME"
    else
        echo "ERROR: Unable to get tls.crt file from $NOI_TLS_SECRET_NAME"
    fi

    kubectl get secret \
        --namespace $NOI_NAMESPACE \
        $NOI_TLS_SECRET_NAME \
        -o json | grep tls.key | cut -d : -f2 | cut -d '"' -f2 | base64 --decode > $CERTS_DIR/tls.key

    if [ -s $CERTS_DIR/tls.key ]; then
        echo "tls.key file downloaded from $NOI_TLS_SECRET_NAME"
    else
        echo "ERROR: Unable to get tls.key file from $NOI_TLS_SECRET_NAME"
    fi
}

function createKeyDB() {
    local dbPath=$1
    local dbPass=${2:-}
    local dbExpiry=${3:-365}

    arg=" -keydb -create -db $dbPath"
    if [[ -n ${dbPass} ]]; then
        arg="$arg -pw $dbPass"
    fi
    arg="$arg -type cms -stash -expire $dbExpiry"

    echo "Creating new Key database file"
    docker run -e LICENSE=accept \
        -e NCHOME=/opt/IBM/tivoli/netcool \
        --entrypoint /bin/bash -it \
        -v $TEMP_DIR:$CONTAINER_SHARED_DIR \
        "$IMAGE_NAME" \
        -c "\$NCHOME/bin/nc_gskcmd $arg"
}


function addTLSCert() {
    # Function to add SSL keys in PEM (.crt) format
    local certsDir=${1:-}
    local tlsCertFileName=${2:-tls.crt}
    local tlsKeyFileName=${3:-tls.key}
    local caCertFileName=${4:-ca.crt}
    local dbPass=${5:-}

    local tlsCertFile=$certsDir/$tlsCertFileName
    local tlsKeyFile=$certsDir/$tlsKeyFileName
    local tlsPKCS12FileName=noi.p12
    local tlsPKCS12File=$certsDir/$tlsPKCS12FileName
    local passwd=$KEY_DATABASE_PASSWORD

    local CLIENT_KEYS_DIR=$CONTAINER_SHARED_DIR/generated

    echo "Creating Key DB file \"$CLIENT_KEYS_DIR/$CLIENT_KDB_FILENAME\"."
    if [[ ! -f "$CLIENT_KEYS_DIR/$CLIENT_KDB_FILENAME" ]]; then
        createKeyDB $CLIENT_KEYS_DIR/$CLIENT_KDB_FILENAME $KEY_DATABASE_PASSWORD ${EXPIRE_TIME:-}
    else
        echo "Key DB file $CLIENT_KEYS_DIR/$CLIENT_KDB_FILENAME already exists. Skip create."
    fi

    echo "Converting $tlsCertFileName file into PKCS12 format."
    openssl pkcs12 -export \
    -in $tlsCertFile \
        -inkey $tlsKeyFile \
        -out $tlsPKCS12File \
        -name "NOI" \
        -passout pass:$passwd
    
    echo "Adding read permission to tlsKeyFile file for consumption."
    chmod +r $tlsPKCS12File

    echo "Adding PKCS12 certificate file."
    docker run -e LICENSE=accept \
        -e NCHOME=/opt/IBM/tivoli/netcool \
        --entrypoint /bin/bash -it \
        -v $TEMP_DIR:$CONTAINER_SHARED_DIR \
        "$IMAGE_NAME" \
        -c "\$NCHOME/bin/nc_gskcmd -cert \
        -import -db $CONTAINER_SHARED_DIR/certs/$tlsPKCS12FileName \
        -pw $dbPass \
        -target $CLIENT_KEYS_DIR/$CLIENT_KDB_FILENAME"
}

function listCert(){
    echo "Listing keys in $TEMP_DIR/generated/$CLIENT_KDB_FILENAME."
    docker run -e LICENSE=accept \
        -e NCHOME=/opt/IBM/tivoli/netcool \
        --entrypoint /bin/bash -it \
        -v $TEMP_DIR:$CONTAINER_SHARED_DIR \
        "$IMAGE_NAME" \
        -c "\$NCHOME/bin/nc_gskcmd -cert -list \
        -db $CONTAINER_SHARED_DIR/generated/$CLIENT_KDB_FILENAME \
        -pw $KEY_DATABASE_PASSWORD"
}

function createNetcoolSecret() {
    echo "Creating secret $SECRET_NAME ..."
    kubectl create secret generic --namespace $NAMESPACE $SECRET_NAME \
    --from-literal=AuthUserName=$AUTH_USERNAME \
    --from-file=AuthPassword=$TEMP_DIR/generated/password.txt \
    --from-file=encryption.keyfile=$TEMP_DIR/$ENCRYPTION_KEYFILE \
    --from-file=omni.kdb=$TEMP_DIR/generated/omni.kdb \
    --from-file=omni.sth=$TEMP_DIR/generated/omni.sth

    kubectl describe secret --namespace $NAMESPACE $SECRET_NAME
}

function changeDirectoryPermission() {
    local dirName=${1:-}

    if [ -d $dirName ]; then
        echo "Making $dirName directory and its sub-directories writable by anyone for container to write files."
        chmod -R 777 $dirName
    else
        echo "Directory $dirName doesn't exists."
    fi
}

function main() {
    ## MAIN ##
    showHelp
    checkPrereq
    setGeneratedDirectoryName
    createTemporaryDirectory
    changeDirectoryPermission "$TEMP_DIR"
    

    if [[ -n "$ENCRYPTION_KEYFILE" ]] && [[ -f "$ENCRYPTION_KEYFILE" ]]; then
        echo "Using existing key file: $ENCRYPTION_KEYFILE"
        cp $ENCRYPTION_KEYFILE $TEMP_DIR
    else
        createKeyFile
        mv $TEMP_DIR/generated/$ENCRYPTION_KEYFILE $TEMP_DIR
    fi
    
    ENCRYPTION_KEYFILE_EFFECTIVE=$CONTAINER_SHARED_DIR/$ENCRYPTION_KEYFILE
    encryptPassword $ENCRYPTION_KEYFILE_EFFECTIVE $AUTH_PASSWORD

    if [[ "$TLS_ENABLED" == "true" ]]; then
        # Get the TLS cert files from secret
        getTLSCertFromSecret
        addTLSCert "$CERTS_DIR" "tls.crt" "tls.key" "" "$KEY_DATABASE_PASSWORD"
        listCert
    fi

    createNetcoolSecret

    echo
    echo "Done! - Remember to clean up the temporary directory \"$TEMP_DIR\"."
    echo
}

# Run main function
main
