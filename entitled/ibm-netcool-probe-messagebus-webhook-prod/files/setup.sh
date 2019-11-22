#!/usr/bin/env bash

##########
# Parameters
#
# -d The shared directory
# -h Host name for alias
# -s Kubernetes Secret name for reference.
#
##########

# Exit when failures occur (including unset variables)
set -o errexit
set -o nounset
set -o pipefail

# Process parameters notify of any unexpected
while test $# -gt 0; do
	[[ $1 =~ ^-d|--shareddir$ ]] && { SHARED_DIR="$2"; shift 2; continue; };
    [[ $1 =~ ^-h|--hostname$ ]] && { hostname="$2"; shift 2; continue; };
    [[ $1 =~ ^-s|--secretName$ ]] && { secretName="$2"; shift 2; continue; };
    echo "Parameter not recognized: $1, ignored"
    shift
done
: "${SHARED_DIR:="/home/netcool/etc"}" 
: "${hostname:="localhost"}" 
: "${secretName:="secretName"}" 

echo $SHARED_DIR && cd $SHARED_DIR
SERVER_CERT_FILE=/home/server.crt
SERVER_CERT_FILENAME=$(basename $SERVER_CERT_FILE)
KEYSTORE_PASS_FILE=/home/keystorepassword.txt
KEYSTORE_PASS=$(cat $KEYSTORE_PASS_FILE)
KEYSTORE_PASS_FILENAME=$(basename $KEYSTORE_PASS_FILE)

# Pre-req check
if [ ! -f $KEYSTORE_PASS_FILE ]; then
    echo "Error: Could not find \"$KEYSTORE_PASS_FILE\" key in Secret ($secretName)."
    echo "Please ensure the secret contains \"$KEYSTORE_PASS_FILENAME\" and \"$SERVER_CERT_FILENAME\"."
    echo "The \"$KEYSTORE_PASS_FILENAME\" key should contain the key store password, and \"$SERVER_CERT_FILENAME\" key should contain the remote server certificate."
    exit 1;
fi

if [ ! -f $SERVER_CERT_FILE ]; then
    echo "Error: Could not find \"$SERVER_CERT_FILE\" key in Secret ($secretName)."
    echo "Please ensure the secret contains \"$KEYSTORE_PASS_FILENAME\" and \"$SERVER_CERT_FILENAME\"."
    echo "The \"$KEYSTORE_PASS_FILENAME\" key should contain the key store password, and \"$SERVER_CERT_FILENAME\" key should contain the remote server certificate."
    exit 1;
fi

# Encrypt keystore password
$OMNIHOME/bin/nco_keygen -o $SHARED_DIR/keyFile
ENCRYPTED_PASS=$($OMNIHOME/bin/nco_aes_crypt -c AES -k $SHARED_DIR/keyFile $KEYSTORE_PASS)

# Generate keystore.
JRE_PATH=$(find /opt/IBM/tivoli/netcool -type d -name "jre64*")
KEYTOOL=$JRE_PATH/jre/bin/keytool
if [ -f keystore.jks ]; then
    # Keystore exist.
    echo "Checking certificate with alias=$hostname in existing keystore."
    $KEYTOOL -list -keystore keystore.jks -alias $hostname -storepass $KEYSTORE_PASS
    if [ $? -eq 0  ] ; then
        echo "Certificate already exists in keystore. Skip certificate import."
    else
        echo "Importing certificate with alias=$hostname into keystore."
        $KEYTOOL -import -trustcacerts -alias $hostname \
            -file $SERVER_CERT_FILE \
            -storetype jks -keystore keystore.jks -storepass $KEYSTORE_PASS \
            -noprompt
    fi
else
    echo "Importing certificate with alias=$hostname into keystore."
    $KEYTOOL -import -trustcacerts -alias $hostname \
        -file /home/server.crt \
        -storetype jks -keystore keystore.jks -storepass $KEYSTORE_PASS \
        -noprompt
fi

# Create override props file with the following properties.
cat /opt/IBM/tivoli/netcool/omnibus/probes/linux2x86/message_bus.props > $SHARED_DIR/message_bus.props 
echo "KeyStorePassword  : '$ENCRYPTED_PASS'" >> $SHARED_DIR/message_bus.props 
echo "KeyStore  : '$SHARED_DIR/keystore.jks'" >> $SHARED_DIR/message_bus.props
echo "ConfigKeyFile  : '$SHARED_DIR/keyFile'" >> $SHARED_DIR/message_bus.props