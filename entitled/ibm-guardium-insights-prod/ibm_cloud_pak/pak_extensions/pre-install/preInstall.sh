#!/bin/bash
#################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2019, 2020. All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################
set -e

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOP_BASEDIR="$BASEDIR/../../../"

#Define number of mandatory and optional parameters. When --registry is Openshift internal registry, --registry-user and --registry-pwd are optional and we will adjust the mandatory parameter during validation
TOTAL_MANDATORY_PARAM=8
TOTAL_OPTIONAL_PARAMS=4

#------------------------  Common functions ------------------------
function example {
    echo "Example - Deployment with IBM Entitled Registry or Enterprise's Secured Registry:-"
    echo -e "$0 [-n | --i-namespace VAL] [-a | --icp-authadmin  VAL] [-p | --icp-authpawd  VAL] [-h |--host-datanodes  VAL] [-t | --taint-datanodes  VAL]\
 [-i | --registry  VAL] [-w | --registry-user  VAL] [-x | --registry-pwd  VAL] {[-s | --secret-replace  VAL] [-k | --ingress-keystore  VAL] [-f | --ingress-cert VAL] [-c | --ingress-ca VAL]}"
    echo -e "\nExample - Deployment with OpenShift Internal Registry:-"
    echo -e "$0 [-n | --i-namespace VAL] [-a | --icp-authadmin  VAL] [-p | --icp-authpawd  VAL] [-h |--host-datanodes  VAL] [-t | --taint-datanodes  VAL]\
 [-i | --registry  VAL] {[-s | --secret-replace  VAL] [-k | --ingress-keystore  VAL] [-f | --ingress-cert VAL] [-c | --ingress-ca VAL]}"
}

function usage {
    echo -e "Usage : $0 MANDATORY PARAMETERS [OPTIONAL PARAMETERS]"
}

function showHelp {
  usage
    echo -e "MANDATORY PARAMETERS:"
    echo -e "  -n | --i-namespace      : IBM Security Guardium Insights Openshift namespace (this value must be 10 or fewer characters and it is the same value as is used for the Helm Release)."
    echo -e "  -a | --icp-authadmin    : IBM Cloud Platform Common Services admin user."
    echo -e "  -p | --icp-authpwd      : IBM Cloud Platform Common Services admin users password."
    echo -e "  -h | --host-datanodes   : Hostpath of the data node or nodes (comma delimited)."
    echo -e "  -t | --taint-datanodes  : If you specify 'true', data nodes will be tainted and dedicated for data service usage. If you specify 'false', tainting will be skipped (do not use 'false' to skip tainting for production deployments)."
    echo -e "  -i | --registry         : Image registry from which the images will be pulled. Specify 'cp.icr.io/cp/ibm-guardium-insights' to pull from the IBM Entitled Registry. Otherwise, specify a private docker registry or OpenShift internal registry (image-registry.openshift-image-registry.svc:5000/<insights openshift namespace>). Both cases require the images to be pushed manually."
    echo -e "  -w | --registry-user    : Image registry authentication user. If this is the IBM Entitled Registry, the user should be 'cp'. Mandatory for IBM Entitled Registry, Optional for Openshift Internal registry."
    echo -e "  -x | --registry-pwd     : Image registry authentication password or API key. Mandatory for IBM Entitled Registry, Optional for Openshift Internal registry."

    echo -e "OPTIONAL PARAMETERS:"
    echo -e "  -s | --secret-replace   : Force replace existing secrets (true/false). By default, this is 'false'. This option supports special scenario to get data reused with existing secret."
    echo -e "  -k | --ingress-keystore : If you will supply a custom Ingress [Recommended], provide the path to its key file. If you do not include this, a default of 'none' will be assumed (this is not recommended)."
    echo -e "  -f | --ingress-cert     : If you will supply a custom Ingress [Recommended], provide the path to its cert file. If you do not include this, a default of 'none' will be assumed (this is not recommended)."
    echo -e "  -c | --ingress-ca       : If you will supply a custom Ingress [Recommended], provide the path to its certificate authority (CA) file. If you do not include this, a default of 'none' will be assumed (this is not recommended)."
    echo -e "  -help | --help          : Prints this help\n"

  example
}

#Basic validation of inputs
function validateInputs() {
   validateInputs=true
   if [ "${#INSIGHTS_NAMESPACE}" -gt 10 ] ; then
      echo "Invalid value '${INSIGHTS_NAMESPACE}' for parameter '-n  | --i-namespace'; contains more than 10 character length, please make it up to 10"
      validateInputs=false
   fi
   #Validate data nodes
   for node in $(echo $DATA_NODES | sed "s/,/ /g")
   do
      if [[ -z `oc get nodes  ${node} --ignore-not-found` ]] ; then
         echo "Invalid value '${node}' for parameter '-h | --host-datanodes'; please enter a valid OpenShift node"
         validateInputs=false
      fi
   done
   #Validate taint data nodes, cekcing valid values are not there in the variable
   if ! [[ "$TAINT_DATA_NODES" =~ ^(true|false)$ ]]; then
      echo "Invalid value '${TAINT_DATA_NODES}' for parameter '-t | --taint-datanodes'; only 'true' or 'false' is supported"
      validateInputs=false
   fi
   #Validate registry
   if [ -n "${internalRegistry}" ] ; then
      if [[ ! ${REGISTRY} = *"/${INSIGHTS_NAMESPACE}"* ]] ; then
         echo "Invalid value '${REGISTRY}' for parameter '-i | --registry'; Insight namespace '/${INSIGHTS_NAMESPACE}' not in the path."
         validateInputs=false
      fi
   fi
   #validate secret force replace
   if ! [[ "$SECRET_FORCEREPLACE" =~ ^(true|false)$ ]]; then
      echo "Invalid value '${SECRET_FORCEREPLACE}' for parameter '-s | --secret-replace'; only 'true' or 'false' is supported"
      validateInputs=false
   fi
   #Show help when validation fails and exit
   if [ "${validateInputs}" == "false" ] ; then
      echo "ERROR : One or more parameters are invalid"
      exit 1
   fi
}
#------------------------  End of Common functions ------------------------

#------------------------  show help when script executes with no paramter ------------------------
if [ "$#" -lt 1 ] ; then
   showHelp
   exit 1
fi

#------------------------  Set values from parameters passsed  ------------------------
margsPassed=0 #Initialize mandatory parameter counter
oargsPassed=0 #Initialize optional parameter counter

REGISTRY_USER="none" #Set default value
REGISTRY_PWD="none" #Set default value
SECRET_FORCEREPLACE="false" #Set default value
INGRESS_KEYFILE="none" #Set default value
INGRESS_CERTFILE="none" #Set default value
INGRESS_CAFILE="none" #Set default value

while [ "${1}" != "" ];
do
   case ${1} in
   -n  | --i-namespace  )
                             shift
                             INSIGHTS_NAMESPACE=${1}
                             #set mandatory argument counter for validation
                             margsPassed=$((${margsPassed} + 1))
                             ;;
   -a | --icp-authadmin )
                             shift
                             AUTH_ADMINUSER=${1}
                             #set mandatory argument counter for validation
                             margsPassed=$((${margsPassed} + 1))
                             ;;
   -p | --icp-authpwd )
                             shift
                             #Hide password when running in bash debug mode (bash -x)
                             if [[ $- =~ x ]]; then debug=1; set +x; fi
                             AUTH_ADMINPWD=${1}
                             if [[ $debug == 1 ]] ; then set -x ; fi
                             #set mandatory argument counter for validation
                             margsPassed=$((${margsPassed} + 1))
                             ;;
   -h | --host-datanodes)
                             shift
                             DATA_NODES=${1}
                             #set mandatory argument counter for validation
                             margsPassed=$((${margsPassed} + 1))
                             ;;
   -t | --taint-datanodes )  shift
                             TAINT_DATA_NODES=${1}
                             #set mandatory argument counter for validation
                             margsPassed=$((${margsPassed} + 1))
                             ;;
   -i | --registry )
                             shift
                             REGISTRY=${1}
                             #set mandatory argument counter for validation
                             margsPassed=$((${margsPassed} + 1))
                             #Set falg when input is OpenShift internal registry
                             if [[ ${REGISTRY} = 'image-registry.openshift-image-registry.svc'* ]] ; then
                                internalRegistry="true"
                             fi
                             ;;
   -w | --registry-user )
                             shift
                             REGISTRY_USER=${1}
                             #When input registry is internal, don't count mandatory parameter
                             if [[ ${REGISTRY} = 'image-registry.openshift-image-registry.svc'* ]] ; then
                                internalRegistry="true"
                             else
                                margsPassed=$((${margsPassed} + 1))
                             fi
                             ;;
   -x | --registry-pwd )
                             shift
                             #Hide password when running in bash debug mode (bash -x)
                             if [[ $- =~ x ]]; then debug=1; set +x; fi
                             REGISTRY_PWD=${1}
                             if [[ $debug == 1 ]] ; then echo "REGISTRY_PWD=[hidden]"; set -x ; fi
                             #When input registry is internal, don't count mandatory parameter
                             if [[ ${REGISTRY} = 'image-registry.openshift-image-registry.svc'* ]] ; then
                                internalRegistry="true"
                             else
                                margsPassed=$((${margsPassed} + 1))
                             fi
                             ;;
   -s | --secret-replace )
                             shift
                             SECRET_FORCEREPLACE=${1}
                             #set Optional argument counter for validation
                             oargsPassed=$((${oargsPassed} + 1))
                             ;;
   -k | --ingress-keystore ) shift
                             INGRESS_KEYFILE=${1}
                             #set Optional argument counter for validation
                             oargsPassed=$((${oargsPassed} + 1))
                             ;;
   -f | --ingress-cert )
                             shift
                             INGRESS_CERTFILE=${1}
                             #set Optional argument counter for validation
                             oargsPassed=$((${oargsPassed} + 1))
                             ;;
   -c | --ingress-ca )
                             shift
                             INGRESS_CAFILE=${1}
                             #set Optional argument counter for validation
                             oargsPassed=$((${oargsPassed} + 1))
                             ;;
   -help   | --help )
                             showHelp
                             exit
                             ;;
   *)
                             echo "ERROR : Unknown option"
                             usage
                             example
						     exit 1 # error
                             ;;
   esac
   shift
done

#------------------------  Validate number of mandatory parameters ------------------------
if [ -n "${internalRegistry}" ] ; then
   #The number of mandatory arguments reduces to ($TOTAL_MANDATORY_PARAM - 2)
   #The --registry-user and --registry-pwd arguments are not mandatory in this case
   TOTAL_MANDATORY_PARAM=$((${TOTAL_MANDATORY_PARAM} - 2))
fi
if [ ${margsPassed} -lt ${TOTAL_MANDATORY_PARAM} ] ; then
   echo "ERROR : One or more mandatory parameters missing"
   showHelp
   exit 1
elif [ ${oargsPassed} -lt ${TOTAL_OPTIONAL_PARAMS} ] ; then
   echo "Warning : One or more optional parameters not passed, default values will be used"
fi

#####################################################################################################
#    Main Execution start here
#####################################################################################################
#Validate inputs
validateInputs

#------------------------ pre-Install Guardium Insights ------------------------
echo "#####IBM Guardium Insights Pre-installation: Starting Preparation#####"
#------------------------ Ensure in the correct namespace ------------------------
#oc project ${INSIGHTS_NAMESPACE} || { oc create namespace ${INSIGHTS_NAMESPACE};}
if [[ -z `oc get namespace  ${INSIGHTS_NAMESPACE} --ignore-not-found` ]] ; then
   oc create namespace ${INSIGHTS_NAMESPACE}
fi
oc project ${INSIGHTS_NAMESPACE}

#------------------------ Label and Taint data node(s) ------------------------
hostpath_datanodes=`echo ${DATA_NODES} | sed -e 's#,# #g'`
oc label node ${hostpath_datanodes} icp4data=database-db2wh --overwrite=true
if [ "X${TAINT_DATA_NODES}" != 'Xfalse' ]; then
  oc adm taint node ${hostpath_datanodes} icp4data=database-db2wh:NoSchedule --overwrite
#   kubectl drain ${hostpath_datanodes} --ignore-daemonsets --delete-local-data
#   kubectl uncordon ${hostpath_datanodes}
else
  echo "Skipping data node(s) tainting."
fi
if [[ $? -ne 0 ]]; then
  echo "There was a problem running: oc label node ${hostpath_datanodes}"
  echo "Please ensure that the list of nodes exist on the cluster"
  exit 1
fi

#---- Fix .helmignore at the top to get below the 1MB problem in etcd storage ----
pushd $TOP_BASEDIR 2>&1 >/dev/null
if [[ `grep external .helmignore | wc -l` -eq 0 ]]; then
cat << EOF >> .helmignore
*.sh
licenses
scripts
README.md
ibm_cloud_pak
LICENSE
ibm_cloud_pak/manifest.yaml
EOF
fi
popd 2>&1 >/dev/null

#------------------------ Cluster pre-requistes ------------------------
pushd $BASEDIR/clusterAdministration/ 2>&1 >/dev/null
./createSecurityClusterPrereqs.sh
popd 2>&1 >/dev/null
pushd $BASEDIR/dependenciesSetup/ 2>&1 >/dev/null
./setupPreReq.sh
popd 2>&1 >/dev/null

echo "#####IBM Guardium Insights Pre-installation: Preparation of SCCs and SAs#####"
#------------------------  SA, SCC, Role, Role binding for Db2 ------------------------
if [[ -n `oc get sa db2u --ignore-not-found -n ${INSIGHTS_NAMESPACE}` ]] && [[ -n `oc get scc db2wh-scc --ignore-not-found ` ]] ; then
  oc adm policy remove-scc-from-user db2wh-scc system:serviceaccount:${INSIGHTS_NAMESPACE}:db2u || true
fi
oc delete rolebinding ibm-db2warehouse-rolebinding --ignore-not-found -n ${INSIGHTS_NAMESPACE}
oc delete role ibm-db2warehouse-role --ignore-not-found -n ${INSIGHTS_NAMESPACE}
oc delete scc db2wh-scc --ignore-not-found
oc delete sa db2u --ignore-not-found -n ${INSIGHTS_NAMESPACE}
pushd ${TOP_BASEDIR}/charts/ibm-db2u/ibm_cloud_pak/pak_extensions/ 2>&1 >/dev/null
./pre-install/clusterAdministration/createSecurityClusterPrereqs.sh
./pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh ${INSIGHTS_NAMESPACE}
popd 2>&1 >/dev/null
#------------------------  SA and preparation for other servuces ------------------------
oc delete sa insights-sequencersa --ignore-not-found -n ${INSIGHTS_NAMESPACE}
oc create sa insights-sequencersa -n ${INSIGHTS_NAMESPACE}
oc adm policy add-role-to-user cert-manager-ibm-cert-manager system:serviceaccount:${INSIGHTS_NAMESPACE}:insights-sequencersa
oc delete sa insights-credutilsa --ignore-not-found -n ${INSIGHTS_NAMESPACE}
oc create sa insights-credutilsa -n ${INSIGHTS_NAMESPACE}
oc delete sa insights-sa --ignore-not-found -n ${INSIGHTS_NAMESPACE}
oc create sa insights-sa -n ${INSIGHTS_NAMESPACE}
oc adm policy add-scc-to-user ibm-restricted-scc system:serviceaccount:${INSIGHTS_NAMESPACE}:insights-sa
oc adm policy add-scc-to-user ibm-restricted-scc system:serviceaccount:${INSIGHTS_NAMESPACE}:insights-sequencersa
if [[ -n `oc get sa bitnami-sa --ignore-not-found -n ${INSIGHTS_NAMESPACE}` ]] && [[ -n `oc get scc ibm-privileged-scc --ignore-not-found ` ]] ; then
   oc adm policy remove-scc-from-user ibm-privileged-scc system:serviceaccount:${INSIGHTS_NAMESPACE}:bitnami-sa || true
fi
oc delete sa bitnami-sa --ignore-not-found  -n ${INSIGHTS_NAMESPACE}
oc create sa bitnami-sa -n ${INSIGHTS_NAMESPACE}
oc adm policy add-scc-to-user ibm-privileged-scc system:serviceaccount:${INSIGHTS_NAMESPACE}:bitnami-sa

#------------------------ Create registry pull secret and link for db2u sa------------------------
registryPullSecret="insights-pull-secret"
#Hide password when running in bash debug mode (bash -x)
if [[ $- =~ x ]]; then debug=1; set +x; fi
${BASEDIR}/../support/registryPullSecret.sh "${INSIGHTS_NAMESPACE}" "${REGISTRY}" "${REGISTRY_USER}" "${REGISTRY_PWD}"
if [[ $debug == 1 ]] ; then set -x ; fi
oc secrets link db2u ${registryPullSecret} --for=pull -n ${INSIGHTS_NAMESPACE}

#------------------------  Create ICP auth secret ------------------------
AuthAdminSecret="insights-ics-authadmin"
oc delete secret "${AuthAdminSecret}" --ignore-not-found  -n ${INSIGHTS_NAMESPACE}
echo "Creating Insights ics auth admin secret in '${INSIGHTS_NAMESPACE}' namespace"
#Hide password when running in bash debug mode (bash -x)
if [[ $- =~ x ]]; then debug=1; set +x; fi
oc create secret generic "${AuthAdminSecret}"  -n  "${INSIGHTS_NAMESPACE}" --from-literal=_AUTH_ADMIN_USER="${AUTH_ADMINUSER}" --from-literal=_AUTH_ADMIN_CREDENTIAL="${AUTH_ADMINPWD}"
if [[ $debug == 1 ]] ; then set -x ; fi

#------------------------  Ingres Certificate Recreation ------------------------
echo "#####IBM Guardium Insights Pre-installation: Ingress Certificate Recreation#####"
pushd $BASEDIR/certCreation 2>&1 >/dev/null
./certCreation.sh ${INSIGHTS_NAMESPACE} ${SECRET_FORCEREPLACE} ${INGRESS_KEYFILE} ${INGRESS_CERTFILE} ${INGRESS_CAFILE}
popd 2>&1 >/dev/null

#------------------------  Guardium Insights Secret Creation ------------------------
echo "#####IBM Guardium Insights Pre-installation: Secret Creation#####"
pushd $BASEDIR/ 2>&1 >/dev/null
./preInstall_secrets.sh -i ./preInstall_secretList.csv -n ${INSIGHTS_NAMESPACE} -o ${SECRET_FORCEREPLACE}
popd 2>&1 >/dev/null
