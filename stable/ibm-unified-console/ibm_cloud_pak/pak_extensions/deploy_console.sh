#!/bin/bash

function check_helm() {   

    local client_version
    local server_version

    helm list  >>/dev/null 2>&1
    if [ $? -ne 0 ];then
        echo "Error: could not find tiller."
        exit 1
    fi

    printf "==> Getting the helm Server version\n"
    server_version=$( helm version $TLS_OPTION | grep Server | cut -d ':' -f 3 | sed -e 's/, GitCommit//g' | sed -e 's/"//g' )
    printf "<== helm Server version is obtained\n\n"

    printf "==> Getting the helm Client version\n"
    client_version=$( helm version $TLS_OPTION | grep Client | cut -d ':' -f 3 | sed -e 's/, GitCommit//g' | sed -e 's/"//g' )
    printf "<== helm Client version is obtained\n\n"
    echo "${client_version}"
    echo "${server_version}"

    printf "==> Comparing the Server and Client version\n"

    if [[ "${server_version}" == *"${client_version}"* ]]; then
      printf "<== Versions match\n\n"
    else
      printf "<== Versions do not match.  Exiting\n\n"
      exit 99
    fi

    printf "==> Checking the Server and Client version\n"
    version_array=(${client_version//./ })
    if [[ "${version_array[0]}"X != "v2"X ]]; then
      printf "This chart does not support the version of the helm.\n"
      exit 99
    fi
       
      if [[ ${version_array[1]} -lt 14  ]]; then
      printf "This chart does not support the version of the helm.\n"
      exit 99
    fi
}


SCRIPT_PATH=$( cd "$(dirname "$0")" ; pwd -P )
CHART="../../"
parse_command_line_arguments () {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --console-release-name )
                shift
                CONSOLE_RELEASE_NAME=$1
                ;;
            --db-release-name )
                shift
                DB_RELEASE_NAME=$1
                ;;
            --image-secret-name )
                shift
                IMAGE_SECRET_NAME=$1
                ;;
            --tls )
                TLS_OPTION="--tls"
                ;;
            * )
                echo "ERROR: $1 is an unrecognized argument"
                exit 1
        esac
        shift
    done
}

parse_command_line_arguments $*
install_args=""



if [[ -z $DB_RELEASE_NAME ]]; then
  echo "Must provide db release name"
  exit 1
fi

if [[ -z $CONSOLE_RELEASE_NAME ]]; then
  echo "Must provide release name"
  exit 1
fi

#Check the helm 
check_helm

VALUES_FILE="$SCRIPT_PATH/values-standalone-console.yaml"

#Check the db release
Db2HelmReleaseExists=$(helm list --deployed -q $TLS_OPTION |grep "$DB_RELEASE_NAME")
 
if [[ -z $Db2HelmReleaseExists ]]; then
  echo "Error: Could not find deployed Db2 release"
  exit 1
fi

#Check the namespace
NAMESPACE=""
if [[ "$(helm ls $TLS_OPTION|grep NAMESPACE |awk -F "[\t]" '{print $7}')"X == "NAMESPACEX" ]];then
  NAMESPACE=$(helm list $TLS_OPTION |grep "$DB_RELEASE_NAME" |awk -F "[\t]" '{print $7}')
elif [[ "$(helm ls $TLS_OPTION|grep NAMESPACE |awk -F "[\t]" '{print $6}')"X == "NAMESPACEX" ]];then
  NAMESPACE=$(helm list $TLS_OPTION |grep "$DB_RELEASE_NAME" |awk -F "[\t]" '{print $6}')
else
  NAMESPACE=$(helm list $TLS_OPTION |grep "$DB_RELEASE_NAME" |awk -F "[\t]" '{print $2}')
fi

if [[ -z $NAMESPACE ]]; then
  echo "Error: Could not find NAMESPACE"
  exit 1
fi

#Build args
install_args="${install_args} --set configMapName=$DB_RELEASE_NAME-db2u-uc-config"
install_args="${install_args} --set dataServer.ldap.rootPwdSecretName=$DB_RELEASE_NAME-db2u-ldap"
install_args="${install_args} --set dataServer.metadb.pwdSecretName=$DB_RELEASE_NAME-db2u-instance"

##Set pvc 
pvcName=$(oc describe statefulset $DB_RELEASE_NAME-db2u -n $NAMESPACE |grep -A2 metavol |grep ClaimName|awk '{print $2}')
if [[ -z $pvcName ]]; then
  pvcName=$(oc describe statefulset $DB_RELEASE_NAME-db2u -n $NAMESPACE |grep -A2 $DB_RELEASE_NAME-db2u-sqllib-shared |grep ClaimName|awk '{print $2}')
fi

if [[ -n $pvcName ]]; then
  install_args="${install_args} --set dataServer.sharedPVC.name=$pvcName"
fi

if [[ -n $IMAGE_SECRET_NAME ]]; then
  install_args="${install_args} --set global.image.secretName=$IMAGE_SECRET_NAME"
fi

#Deploy CONSOLE
helm install \
 ${install_args} \
 -f $VALUES_FILE \
 --name $CONSOLE_RELEASE_NAME   \
 --namespace $NAMESPACE ${CHART} $TLS_OPTION

#Create route
if [[ "${CONSOLE_RELEASE_NAME}"X  == "$(oc get route -n $NAMESPACE 2>>/dev/null |awk '{print $1}' |grep $CONSOLE_RELEASE_NAME)"X ]]; then
  oc delete route $CONSOLE_RELEASE_NAME -n $NAMESPACE;
fi

oc create route passthrough $CONSOLE_RELEASE_NAME --service=$CONSOLE_RELEASE_NAME-ibm-unified-console-ui -n $NAMESPACE
echo "Console url is: https://$(oc get route -n $NAMESPACE|grep $CONSOLE_RELEASE_NAME |awk '{print $2}')"
