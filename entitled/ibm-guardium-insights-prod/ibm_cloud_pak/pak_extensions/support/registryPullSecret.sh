#!/bin/bash
# **************************************************************
#
# IBM Confidential
#
# OCO Source Materials
#
# 5737-L66
#
# (C) Copyright IBM Corp. 2019, 2020
#
# The source code for this program is not published or otherwise
# divested of its trade secrets, irrespective of what has been
# deposited with the U.S. Copyright Office.
#
# **************************************************************

NAMESPACE="$1"
REGISTRY="$2"
REGISTRY_USER="$3"
REGISTRY_PWD="$4"

function showHelp() {
   echo -e "Usage: $0 NAMESPACE REGISTRY REGISTRY_USER REGISTRY_PWD"
   echo -e "\tNAMESPACE     - Openshift namespace where registry pull secret to be created[IBM Guardium Insights namespace]."
   echo -e "\tREGISTRY      - Image registry from which images will be pulled. Provide 'cp.icr.io/cp/ibm-guardium-insights' to pull from IBM entitled registry"
   echo -e "\tREGISTRY_USER - The user to authenticate registry; If this is for IBM entitled registry, the user should be 'cp'."
   echo -e "\tREGISTRY_PWD  - The password or API key to authenticate the registry."

   echo -e "\nWhen using Openshift's internal registry, REGISTRY_USER and REGISTRY_PWD are optional; system will use serviceaccount details."

   echo -e "\nExample for IBM Entitled registry - $0 <insights namespace> cp.icr.io/cp/ibm-guardium-insights cp <Entitlement key>"
   echo -e "\nExample for Enterprise's Secured Registry - $0 <insights namespace> sample-registry.local/repo <registry-user> <registry-password>"
   echo -e "\nExample for internal registry - $0 <insights namespace> image-registry.openshift-image-registry.svc:5000/<insights namespace>"
}

#Check for number of parameter passed
if [ "$#" -lt 2 ]; then
   echo "Missing parameters"
   showHelp
   exit 1
elif [ "$#" -eq 2 ] && [[ ! ${REGISTRY} = 'image-registry.openshift-image-registry.svc'* ]] ; then
   internalRegistry="false"
   echo "ERROR : Parameters 'REGISTRY_USER' and 'REGISTRY_PWD' missing."
   showHelp
   exit 1
elif [ "$#" -eq 2 ] && [[ ${REGISTRY} = 'image-registry.openshift-image-registry.svc'* ]] ; then
   internalRegistry="true"
elif [ "$#" -gt 2 ] && [ "$#" -lt 5 ] && [[  ${REGISTRY} = 'image-registry.openshift-image-registry.svc'* ]] ; then
   internalRegistry="true"
elif [ "$#" -gt 2 ] && [ "$#" -eq 3 ] && [[ !  ${REGISTRY} = 'image-registry.openshift-image-registry.svc'* ]] ; then
   internalRegistry="false"
   echo "ERROR : Parameter REGISTRY_PWD' missing."
   showHelp
   exit 1
elif
   [ "$#" -gt 2 ] && [ "$#" -lt 5 ] ; then
   internalRegistry="false"
else
   echo "ERROR : Unknown parameters."
   showHelp
   exit 1
fi

#Validate namepace found
if [[ -z `oc get namespace ${NAMESPACE} --ignore-not-found` ]] ; then
  echo "ERROR : The namespace '${NAMESPACE}' not found."
  exit 1
fi


registryPullSecret="insights-pull-secret"
#Clean registryPullSecret if aready present
oc delete secret "${registryPullSecret}" --ignore-not-found  -n ${NAMESPACE}

#For external registry such as IBM entitled registry, create pull secret using user supplied values
if [ ${internalRegistry} == "false" ] ; then
   echo "Creating registry pull secret in '${NAMESPACE}' namespace for external registry"
   oc create secret docker-registry "${registryPullSecret}"  -n  "${NAMESPACE}" --docker-server="${REGISTRY}" --docker-username="${REGISTRY_USER}" --docker-password="${REGISTRY_PWD}"
fi

#For Openshift internal registry, create registry pull secret using service account and its image pull secret
if [ ${internalRegistry} == "true" ] ; then
   saForInternalImagePullSecret="default"
   saImagePullSecrets=`oc get sa ${saForInternalImagePullSecret} -o jsonpath='{..imagePullSecrets[*].name}' -n ${NAMESPACE}`
   for saImagePullSecret in ${saImagePullSecrets}; do
       if [[ ${saImagePullSecret} = *'dockercfg'* ]] ; then
          inernalImagePullSecret=${saImagePullSecret}
       fi
   done
   internalImagePullSecretPwd=`oc get secret $inernalImagePullSecret -o jsonpath='{..metadata.annotations.openshift\.io/token-secret\.value}' -n ${NAMESPACE}`
   echo "Creating registry pull secret in '${NAMESPACE}' namespace for internal registry"
   oc create secret docker-registry "${registryPullSecret}"  -n  "${NAMESPACE}" --docker-server="${REGISTRY}" --docker-username="${saForInternalImagePullSecret}" --docker-password="${internalImagePullSecretPwd}"
fi
