#!/bin/bash -e

#################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2020. All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################

# *******************************************************************************
# NAME: preInstall_secrets.sh
# DESCRIPTION: Script to create Guardium Insights secrets before installation.
# Requires input CSV: preInstall_secretList.csv.
# *******************************************************************************

# Enforce POSIX shell mode for better compatibility.
set -o posix

# Support bash version 3+
if [ "X$BASH_VERSINFO" == "X" ] ||  [ ${BASH_VERSINFO[0]} -lt 3 ]; then
        echo "ERROR: bash version >= 3 required. Exiting."
        exit 1
fi

# Globals
SECRET_LABELS='{"metadata":{"labels":{"app":"ibm-guardium-insights","project":"insights"}}}'
TMP_DIR="/tmp/$(basename $0).$$.tmp" && mkdir $TMP_DIR
LOG_FILE=$TMP_DIR/preInstall_secrets.log

# TODO: Handle the removal of randAlphaNum from Helm Charts. Jira INS-5225

# Begin shell function definitions.
#-----------------------------------------------
usage() {
# TODO: Document backing up secrets.
cat <<USAGETEXT
IBM Guardium Insights : Secrets pre-install script.
NOTE: You should be logged into your OpenShift environment before you attempt to run this script.
Usage: /path/to/preInstall_secrets.sh -i /path/to/preinstall_secretList.csv -n <namespace> -o [true|false]
   where:
        -i <preinstall_secretList.csv> : path to csv for generating secrets. Required.
        -n <NAMESPACE> : OCP namespace (project) in which to create secrets. Required.
        -o <overwrite>: either "true" OR "false" on whether to overwrite existing secrets. Required.
        -h Print this help/usage message.
USAGETEXT
echo "Example invocation: ./$(basename "$0") -i ./preInstall_secretList.csv -n samplenamespace -o true"
echo "" |tee -a $LOG_FILE
}
#-----------------------------------------------
validate_prereqs() {

        # Check for all required commands, including kubectl.
        for CMD in openssl ssh-keygen base64 cat echo grep awk rm tr cut kubectl ; do
                CMD_BN=$(basename $CMD)
                set +e
                command -v $CMD >/dev/null
                if [ "X$?" != "X0" ]; then
                        echo "ERROR: Pre-requisite command $CMD_BN not found. Exiting." |tee -a $LOG_FILE
                        exit 1
                else
                        set -e
                fi
        done

        # Support only kubectl v1.16 and above (i.e. OCP 4.3+)
        set +e
        KubeMajorVer=$(kubectl version --client=true -o yaml |grep major |awk -F'"' '{print $2}')
        KubeMinorVer=$(kubectl version --client=true -o yaml |grep minor |awk -F'"' '{print $2}')
        set -e

        if [ "X$KubeMajorVer" == "X1" ] ; then
                if [  $KubeMinorVer -ge  16  ] ; then
                        echo "Found supported kubectl client version: v$KubeMajorVer.$KubeMinorVer" |tee -a $LOG_FILE
                        echo "" |tee -a $LOG_FILE
                else
                        echo "Found kubectl client version: v$KubeMajorVer.$KubeMinorVer"  |tee -a $LOG_FILE
                        echo "ERROR: This script requires atleast kubectl v1.16. Exiting." |tee -a $LOG_FILE
                        exit 1
                fi
        fi
        set -e
}
#-----------------------------------------------
validate_namespace() {
        NAMESPACE="$1"

        set +e
        ns=$(kubectl get namespace $NAMESPACE -o name 2>/dev/null)
        if [ "X$ns" != "Xnamespace/$NAMESPACE" ]; then
                echo "ERROR: Invalid namespace: $NAMESPACE" |tee -a $LOG_FILE
                exit 1
        else
                set -e
        fi
        set -e
}
#-----------------------------------------------
process_input_file() {
        echo "Starting to process file: $INPUT_FILE." |tee -a $LOG_FILE
        echo "" |tee -a $LOG_FILE

        grep -v '^#' < $INPUT_FILE | {
                while IFS= read -r CURRENT_LINE; do
                        process_one_line $CURRENT_LINE
                done
        }
        echo "Completed processing file: $INPUT_FILE." |tee -a $LOG_FILE
        echo "" |tee -a $LOG_FILE
}
#-----------------------------------------------
process_one_line() {
        INPUT_LINE="$1"

        SECRET_TYPE=$(echo $INPUT_LINE | cut -f1 -d,)
        if [ "X$SECRET_TYPE" == "X" ]; then
                echo "ERROR: Could not parse input line: $1. Exiting." |tee -a $LOG_FILE
                exit 1
        fi

        SECRET_NAME=$(echo $INPUT_LINE | cut -f2 -d,)
        if [ "X$SECRET_NAME" == "X" ]; then
                echo "ERROR: Missing Secret name in input line: $1. Exiting." |tee -a $LOG_FILE
                exit 1
        fi

        CRED_NAME=$(echo $INPUT_LINE | cut -f3 -d,)
        if [ "X$CRED_NAME" == "X" ]; then
                echo "ERROR: Missing Credential name for secret: $SECRET_NAME. Exiting." |tee -a $LOG_FILE
                exit 1
        fi

        CRED_OPTION=$(echo $INPUT_LINE | cut -f4 -d,)
        if [ "X$CRED_OPTION" == "X" ]; then
                echo "ERROR: Missing Credential option for secret: $SECRET_NAME. Exiting." |tee -a $LOG_FILE
                exit 1
        fi


        if [ "X$SECRET_TYPE" == "Xverbatim" ]; then
                generate_verbatim_secret $SECRET_NAME $CRED_NAME $CRED_OPTION

        elif [ "X$SECRET_TYPE" == "Xalphanumeric" ]; then
                generate_alphanumeric_secret $SECRET_NAME $CRED_NAME $CRED_OPTION

        elif [ "X$SECRET_TYPE" == "Xssh-keygen" ]; then
                generate_sshkeypair_secret $SECRET_NAME $CRED_NAME $CRED_OPTION

        elif [ "X$SECRET_TYPE" == "Xdb2secret" ]; then
                # Prefix release-name (same as GI namespace-name) to DB2 subchart secrets.
                generate_alphanumeric_secret "$NAMESPACE-$SECRET_NAME" $CRED_NAME $CRED_OPTION

        else
                # Catch-all. Should not be reached.
                echo "ERROR: Unknown secret type: $SECRET_TYPE in input file $INPUT_FILE, line: $INPUT_LINE.  Exiting." |tee -a $LOG_FILE
                exit 1
        fi
}
#-----------------------------------------------
update_labels() {
        SecretName="$1"

        echo "Updating labels for secret: $SecretName." |tee -a $LOG_FILE
        set +e
        kubectl patch secret $SecretName --type merge -n $NAMESPACE --patch "$SECRET_LABELS" 2>&1>> $LOG_FILE
        if [ "X$?" == "X0" ]; then
                set -e
                echo "Updated  labels for secret: $SecretName." |tee -a $LOG_FILE
                echo "" |tee -a $LOG_FILE
        else
                echo "ERROR: Applying labels to secret $SecretName failed. Exiting." |tee -a $LOG_FILE
                exit 1
        fi
        set -e
}
#-----------------------------------------------
generate_verbatim_secret() {

        SecretName="$1"
        CredName="$2"
        CredVerbatimPlain="$3"
        CredVerbatim=$(printf $CredVerbatimPlain | base64 | tr -d '\n')

        set +e
        kubectl get secret $SecretName -n $NAMESPACE -o name  > /dev/null 2>&1
        GetSecretRC=$?
        set -e

        if [ "X$GetSecretRC" != "X0" ]; then

                echo "Verbatim Secret $SecretName not found. Creating secret." |tee -a $LOG_FILE
                kubectl create secret generic $SecretName -n $NAMESPACE --from-literal=$CredName=$CredVerbatimPlain 2>&1|tee -a $LOG_FILE
                echo "Created verbatim secret: $SecretName in namespace: $NAMESPACE." |tee -a $LOG_FILE

                unset CredVerbatimPlain CredVerbatim
                update_labels $SecretName

        elif [ "X$GetSecretRC" == "X0" ]; then
                echo "Verbatim Secret: $SecretName was found." |tee -a $LOG_FILE

                set +e
                CredVal=$(kubectl get secret $SecretName -n $NAMESPACE -o jsonpath='{.data.'$CredName'}')
                GetCredRC=$?
                set -e

                if [ "X$GetCredRC" == "X0" ] && [ "X$CredVal" == "X" ]; then
                        echo "Data $CredName was not found in secret: $SecretName." |tee -a $LOG_FILE

                        echo "Adding verbatim data: $CredName to secret: $SecretName" |tee -a $LOG_FILE
                        kubectl patch secret $SecretName --type merge -n $NAMESPACE -p '{"data":{"'$CredName'":"'$CredVerbatim'"}}'  2>&1>> $LOG_FILE
                        echo "Added  verbatim data: $CredName to secret: $SecretName" |tee -a $LOG_FILE

                        unset CredVerbatimPlain CredVerbatim CredVal
                        update_labels $SecretName

                elif [ "X$GetCredRC" == "X0" ] && [ "X$CredVal" != "X" ] && [ "X$OVERWRITE" == "Xyes" ]; then
                        echo "Data $CredName was found in secret: $SecretName, replacing." |tee -a $LOG_FILE

                        echo "Replacing verbatim data: $CredName in secret: $SecretName." |tee -a $LOG_FILE
                        kubectl patch secret $SecretName --type merge -n $NAMESPACE -p '{"data":{"'$CredName'":"'$CredVerbatim'"}}'  2>&1>> $LOG_FILE
                        echo "Replaced  verbatim data: $CredName in secret: $SecretName." |tee -a $LOG_FILE

                        unset CredVerbatimPlain CredVerbatim CredVal
                        update_labels $SecretName

                else # Skip.
                        echo "Skipping data: $CredName found in secret: $SecretName." |tee -a $LOG_FILE
                fi
        else
                # Catch-all. Should not be reached.
                set -e
                unset CredVerbatimPlain CredVerbatim CredVal
                echo "ERROR: Something went wrong patching verbatim secret: $SecretName. Exiting." |tee -a $LOG_FILE
                exit 1
        fi
        set -e

}
#-----------------------------------------------
generate_alphanumeric_secret() {
        SecretName=$1
        CredName=$2
        CredLength=$3

        # Basic sanity checks.
        if   [ $CredLength -lt 1 ] ; then
                echo "ERROR: Credential request should be atleast 1 or more. (got: $CredLength). Exiting." |tee -a $LOG_FILE
                exit 1
        elif [ $CredLength -gt 512 ]; then
                echo "ERROR: Credential request too long: $CredLength (max: 512) Exiting." |tee -a $LOG_FILE
                exit 1
        fi

        # Generate a string that kubectl can use.
        CredAlphaNumPlain=$(openssl rand -base64 1024 | tr -d [:space:] | tr -d [:punct:] | cut -c1-$CredLength )
        CredAlphaNum=$(printf $CredAlphaNumPlain | base64 | tr -d '\n')

        set +e
        # Check if the secret exists.
        kubectl get secret $SecretName -n $NAMESPACE -o name  > /dev/null 2>&1
        GetSecretRC=$?
        set -e

        if [ "X$GetSecretRC" != "X0" ]; then

                echo "Alphanumeric Secret $SecretName not found. Creating secret." |tee -a $LOG_FILE
                kubectl create secret generic $SecretName -n $NAMESPACE --from-literal=$CredName=$CredAlphaNumPlain 2>&1|tee -a $LOG_FILE
                echo "Created alphanumeric secret: $SecretName in namespace: $NAMESPACE." |tee -a $LOG_FILE

                unset CredAlphaNumPlain CredAlphaNum
                update_labels $SecretName

        elif [ "X$GetSecretRC" == "X0" ]; then
                echo "Alphanumeric Secret: $SecretName was found." |tee -a $LOG_FILE
                set +e
                CredVal=$(kubectl get secret $SecretName -n $NAMESPACE -o jsonpath='{.data.'$CredName'}')
                GetCredRC=$?
                set -e

                if [ "X$GetCredRC" == "X0" ] && [ "X$CredVal" == "X" ]; then
                        echo "Data $CredName was not found in secret: $SecretName." |tee -a $LOG_FILE

                        echo "Adding alphanumeric data: $CredName to secret: $SecretName." |tee -a $LOG_FILE
                        kubectl patch secret $SecretName --type merge -n $NAMESPACE -p '{"data":{"'$CredName'":"'$CredAlphaNum'"}}' 2>&1>> $LOG_FILE
                        echo "Added  alphanumeric data: $CredName to secret: $SecretName." |tee -a $LOG_FILE

                        unset CredAlphaNumPlain CredAlphaNum CredVal
                        update_labels $SecretName

                elif [ "X$GetCredRC" == "X0" ] && [ "X$CredVal" != "X" ] && [ "X$OVERWRITE" == "Xyes" ]; then
                        echo "Data $CredName was found in secret: $SecretName, replacing." |tee -a $LOG_FILE

                        echo "Replacing alphanumeric data: $CredName in secret: $SecretName." |tee -a $LOG_FILE
                        kubectl patch secret $SecretName --type merge -n $NAMESPACE -p '{"data":{"'$CredName'":"'$CredAlphaNum'"}}' 2>&1>> $LOG_FILE
                        echo "Replaced  alphanumeric data: $CredName in secret: $SecretName." |tee -a $LOG_FILE

                        unset CredAlphaNumPlain CredAlphaNum CredVal
                        update_labels $SecretName

                else # Skip.
                        echo "Skipping data: $CredName found in secret: $SecretName." |tee -a $LOG_FILE

                fi
        else
                # Catch-all. Should not be reached.
                echo "ERROR: Something went wrong patching secret: $SecretName. Exiting." |tee -a $LOG_FILE
                exit 1

        fi
        set -e
}
#-----------------------------------------------
generate_sshkeypair_secret() {
        SecretName=$1
        CredName=$2
        CredOptions=$3

        if   [ "X$CredOptions" = "Xrsa-2048" ]; then NumBits=2048
        elif [ "X$CredOptions" = "Xrsa-3072" ]; then NumBits=3072
        elif [ "X$CredOptions" = "Xrsa-4096" ]; then NumBits=4096
        else
                echo "Error retrieving data for ssh keypair secret $SecretName from input file $INPUT_FILE." |tee -a $LOG_FILE
                echo "Keypair for $SecretName has unsupported number of bits specified: $CredOptions." |tee -a $LOG_FILE
                echo "Only three values: rsa-2048, rsa-3072 and rsa-4096, are currently supported. Exiting." |tee -a $LOG_FILE
                exit 1
        fi

        echo "Preparing new keypair with key size: $NumBits for secret: $SecretName." |tee -a $LOG_FILE
        set +e

        echo -e 'y\n' | ssh-keygen -q -m PEM -t rsa -b $NumBits -N "" -f $TMP_DIR/$CredName  2>&1>> $LOG_FILE
        RunCmdRC=$? ; if [ "X$RunCmdRC" != "X0" ]; then echo "ERROR: Something went wrong while running the ssh-keygen system command. Exiting." |tee -a $LOG_FILE ; exit 1 ; fi

        GenPubKeyB64=$(cat $TMP_DIR/$CredName.pub | base64 |tr -d '\n') && rm -f $TMP_DIR/$CredName.pub
        RunCmdRC=$? ; if [ "X$RunCmdRC" != "X0" ]; then echo "ERROR: Something went wrong while building Public Key. Exiting." |tee -a $LOG_FILE ; exit 1 ; fi

        GenPriKeyB64=$(cat $TMP_DIR/$CredName     | base64 |tr -d '\n') && rm -f $TMP_DIR/$CredName
        RunCmdRC=$? ; if [ "X$RunCmdRC" != "X0" ]; then echo "ERROR: Something went wrong while building Private Key. Exiting." |tee -a $LOG_FILE ; exit 1 ; fi

        # Check if the named secret exists in the specified namespace.
        kubectl get secret $SecretName -n $NAMESPACE -o name  > /dev/null 2>&1
        GetSecretRC=$?
        set -e

        if [ "X$GetSecretRC" != "X0" ]; then

                echo "SSH Keypair Secret $SecretName not found. Creating secret." |tee -a $LOG_FILE
                kubectl create secret generic $SecretName -n $NAMESPACE 2>&1|tee -a $LOG_FILE
                echo "Created SSH Keypair secret: $SecretName in namespace: $NAMESPACE." |tee -a $LOG_FILE

                echo "Adding Private Key to secret: $SecretName." |tee -a $LOG_FILE
                kubectl patch secret $SecretName --type merge -n $NAMESPACE -p '{"data":{"'$CredName'":"'$GenPriKeyB64'"}}' 2>&1>> $LOG_FILE
                echo "Added  Private Key to secret: $SecretName." |tee -a $LOG_FILE

                echo "Adding Public Key  to secret: $SecretName." |tee -a $LOG_FILE
                kubectl patch secret $SecretName --type merge -n $NAMESPACE -p '{"data":{"'$CredName.pub'":"'$GenPubKeyB64'"}}' 2>&1>> $LOG_FILE
                echo "Added  Public Key  to secret: $SecretName." |tee -a $LOG_FILE

                update_labels $SecretName

        elif [ "X$GetSecretRC" == "X0" ]; then
                echo "SSH Keypair Secret named: $SecretName was found." |tee -a $LOG_FILE

                set +e
                CredValPub=$(kubectl get secret $SecretName -n $NAMESPACE -o jsonpath='{.data.'$CredName'\.pub}')
                GetCredPubRC=$?
                CredValPri=$(kubectl get secret $SecretName -n $NAMESPACE -o jsonpath='{.data.'$CredName'}')
                GetCredPriRC=$?
                set -e

                if [ "X$GetCredPubRC" == "X0" ] && [ "X$GetCredPriRC" == "X0" ] && [ "X$CredValPub" == "X" ] && [ "X$CredValPri" == "X" ] ; then
                        echo "Data $CredName was not found in secret: $SecretName." |tee -a $LOG_FILE

                        echo "Adding Private Key to secret: $SecretName." |tee -a $LOG_FILE
                        kubectl patch secret $SecretName --type merge -n $NAMESPACE -p '{"data":{"'$CredName'":"'$GenPriKeyB64'"}}' 2>&1>> $LOG_FILE
                        echo "Added  Private Key to secret: $SecretName." |tee -a $LOG_FILE

                        echo "Adding Public Key  to secret: $SecretName." |tee -a $LOG_FILE
                        kubectl patch secret $SecretName --type merge -n $NAMESPACE -p '{"data":{"'$CredName.pub'":"'$GenPubKeyB64'"}}' 2>&1>> $LOG_FILE
                        echo "Added  Public Key  to secret: $SecretName." |tee -a $LOG_FILE

                        update_labels $SecretName


                elif [ "X$GetCredPubRC" == "X0" ] && [ "X$GetCredPriRC" == "X0" ] && [ "X$CredValPri" != "X" ] && [ "X$CredValPub" != "X" ] && [ "X$OVERWRITE" == "Xyes" ]; then
                        echo "Data $CredName was found in secret: $SecretName, replacing." |tee -a $LOG_FILE

                        echo "Replacing Private Key in secret: $SecretName." |tee -a $LOG_FILE
                        kubectl patch secret $SecretName --type merge -n $NAMESPACE -p '{"data":{"'$CredName'":"'$GenPriKeyB64'"}}' 2>&1>> $LOG_FILE
                        echo "Replaced  Private Key in secret: $SecretName." |tee -a $LOG_FILE

                        echo "Replacing Public Key in secret: $SecretName." |tee -a $LOG_FILE
                        kubectl patch secret $SecretName --type merge -n $NAMESPACE -p '{"data":{"'$CredName.pub'":"'$GenPubKeyB64'"}}' 2>&1>> $LOG_FILE
                        echo "Replaced  Public Key in secret: $SecretName." |tee -a $LOG_FILE
                        update_labels $SecretName


                elif [ "X$GetCredPubRC" == "X0" ] && [ "X$GetCredPriRC" == "X0" ] && [ "X$CredValPri" == "X" ] && [ "X$CredValPub" != "X" ] ; then
                        # echo "Complete keypair for $CredName was not found in secret: $SecretName, replacing." |tee -a $LOG_FILE
                        echo "Overwrite was NOT set but only Public Key data was found. Overwriting secret with new data pair." |tee -a $LOG_FILE

                        echo "Replacing Private Key to secret: $SecretName." |tee -a $LOG_FILE
                        kubectl patch secret $SecretName --type merge -n $NAMESPACE -p '{"data":{"'$CredName'":"'$GenPriKeyB64'"}}' 2>&1>> $LOG_FILE
                        echo "Replaced  Private Key to secret: $SecretName." |tee -a $LOG_FILE

                        echo "Replacing Public Key in secret: $SecretName." |tee -a $LOG_FILE
                        kubectl patch secret $SecretName --type merge -n $NAMESPACE -p '{"data":{"'$CredName.pub'":"'$GenPubKeyB64'"}}' 2>&1>> $LOG_FILE
                        echo "Replaced  Public Key in secret: $SecretName." |tee -a $LOG_FILE

                        update_labels $SecretName


                elif [ "X$GetCredPubRC" == "X0" ] && [ "X$GetCredPriRC" == "X0" ] && [ "X$CredValPri" != "X" ] && [ "X$CredValPub" == "X" ]; then
                        #echo "Complete keypair for $CredName was not found in secret: $SecretName, overwriting." |tee -a $LOG_FILE
                        echo "Overwrite was NOT set but only Private Key data was found. Overwriting secret with new data pair." |tee -a $LOG_FILE

                        echo "Replacing Private Key in secret: $SecretName." |tee -a $LOG_FILE
                        kubectl patch secret $SecretName --type merge -n $NAMESPACE -p '{"data":{"'$CredName'":"'$GenPriKeyB64'"}}' 2>&1>> $LOG_FILE
                        echo "Replaced  Private Key in secret: $SecretName." |tee -a $LOG_FILE

                        echo "Replacing Public Key in secret: $SecretName." |tee -a $LOG_FILE
                        kubectl patch secret $SecretName --type merge -n $NAMESPACE -p '{"data":{"'$CredName.pub'":"'$GenPubKeyB64'"}}' 2>&1>> $LOG_FILE
                        echo "Replaced  Public Key in secret: $SecretName." |tee -a $LOG_FILE

                        update_labels $SecretName


                # Forcefully overwrite into existing secret when overwriting has been enabled.
                elif [ "X$GetSecretRC" == "X0" ] && [ "X$OVERWRITE" == "Xyes" ] ; then

                        echo "Replacing Private Key in secret: $SecretName." |tee -a $LOG_FILE
                        kubectl patch secret $SecretName --type merge -n $NAMESPACE -p '{"data":{"'$CredName'":"'$GenPriKeyB64'"}}' 2>&1>> $LOG_FILE
                        echo "Replaced  Private Key in secret: $SecretName." |tee -a $LOG_FILE

                        echo "Replacing Public Key in secret: $SecretName." |tee -a $LOG_FILE
                        kubectl patch secret $SecretName --type merge -n $NAMESPACE -p '{"data":{"'$CredName.pub'":"'$GenPubKeyB64'"}}' 2>&1>> $LOG_FILE
                        echo "Replaced  Public Key in secret: $SecretName." |tee -a $LOG_FILE

                        update_labels $SecretName

                else # Skip.
                        set -e
                        unset GenPriKeyB64 GenPubKeyB64  CredValPri CredValPub
                        echo "Skipping data: $CredName found in secret: $SecretName." |tee -a $LOG_FILE
                fi
        else
                # Catch-all. Should not be reached.
                unset GenPriKeyB64 GenPubKeyB64 CredValPri CredValPub
                echo "ERROR: Something went wrong patching ssh-keypair secret: $SecretName. Exiting" |tee -a $LOG_FILE
                exit 1

        fi
        set -e
}
#-----------------------------------------------

# Start.

echo "--------------------------------------------------------------" |tee -a $LOG_FILE
echo "Script started on: $(date)" |tee -a $LOG_FILE
echo "on host: $(hostname)" |tee -a $LOG_FILE
echo "by user: $(whoami) " |tee -a $LOG_FILE
echo "" |tee -a $LOG_FILE
echo "Output is being appended to log file:" |tee -a $LOG_FILE
echo " $LOG_FILE" |tee -a $LOG_FILE
echo "" |tee -a $LOG_FILE

# Begin parsing options.

while getopts 'i:n:o:h' OPTION; do
        case "$OPTION" in
        i)
                INPUT_FILE=$OPTARG
                echo "The input file was specified as: " |tee -a $LOG_FILE
                echo "$INPUT_FILE." |tee -a $LOG_FILE
                echo "" |tee -a $LOG_FILE
                if [ "X$INPUT_FILE" = "X" ]; then
                        echo "ERROR: The input file wasn't provided. Exiting." |tee -a $LOG_FILE
                        exit 1
                fi
                ;;
        n)
                NAMESPACE="$OPTARG"
                echo "Working with secrets in namespace: $NAMESPACE" |tee -a $LOG_FILE
                echo "" |tee -a $LOG_FILE
                ;;
        o)
                OVERWRITE="$OPTARG"
                ;;
        h)
                usage
                exit 0
                ;;
        ?)
                echo "ERROR: Unrecognized option." |tee -a $LOG_FILE
                usage
                exit 1
                ;;
        esac
done

if [ "X$OPTIND" != "X7" ]; then
        echo "ERROR: Unexpected number of options." |tee -a $LOG_FILE
        usage
        exit 1
fi

# Done parsing args.
shift "$(($OPTIND - 1))"

# Check for whether to overwrite existing secrets
if [ "X$OVERWRITE" == "Xtrue" ] ; then
        OVERWRITE=yes
elif [ "X$OVERWRITE" == "Xfalse" ] ; then
        OVERWRITE=no
else
        # Do not overwrite by default.
        OVERWRITE=no
fi

echo "Overwrite existing secrets mode: $OVERWRITE" |tee -a $LOG_FILE
echo "--------------------------------------------------------------" |tee -a $LOG_FILE
echo "Starting: IBM Guardium Insights: Secrets Pre-Install script." |tee -a $LOG_FILE

validate_prereqs
validate_namespace $NAMESPACE
process_input_file

echo "Completed: IBM Guardium Insights : Secrets Pre-Install script." |tee -a $LOG_FILE
echo "--------------------------------------------------------------" |tee -a $LOG_FILE
exit 0

# Fin.
