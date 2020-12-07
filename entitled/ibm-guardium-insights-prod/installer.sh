#!/bin/bash
#################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2020. All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################

set -e

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# list of options for the installer script
OPTION_LIST=(n: h: l: i: o: y:)

# lists the labels for the corresponding options in the OPTIONS_LIST
declare -a OPTION_LABEL
OPTION_LABEL=(
  'IBM Guardium Insights Namespace (also used as Helm Release Name)'
  'global.insights.ingress.hostName'
  'global.licenseAccept (true/false)'
  'global.image.repository'
  'OverrideYaml Filename'
  'global.insights.licenseType'
)

# lists the description for the corresponding options in the OPTIONS_LIST
declare -a OPTION_DESCRIPTION
OPTION_DESCRIPTION=(
  'IBM Security Guardium Insights Openshift namespace (this value must be 10 or fewer characters and it is the same value as is used for the Helm Release).'
  'Ingress user interface access (for example, insight.apps.new-coral.plum-sofa.com).'
  'Review the license files (LICENSE_en, LICENSE_notices and LICENSE_non_ibm_license) within the licenses/Licenses/L-TESX-XXXXXX folder and specify true to agree to them them. If you specify false, the installation will not proceed. This parameter is not case-sensitive.'
  'Image registry from which images will be pulled. Specify "cp.icr.io/cp/ibm-guardium-insights" to pull from the IBM Entitled Registry. Otherwise, use a private docker registry or OpenShift internal registry (`image-registry.openshift-image-registry.svc:5000/<insights openshift namespace>`). Both cases require the images to be pushed manually.'
  'Override YAML (examples include values-small.yaml, values-med.yaml, and values-xxx.yaml)'
  'This is the license that you accept corresponding to the version of Guardium Insights you wish install. Select the version by selecting the corresponding license in the 'licenses/Licenses' folder (for example, L-TESX-XXXXXX).'
)

# lists the values for the corresponding options in the OPTIONS_LIST
declare -a OPTION_VALUE

while getopts "${OPTION_LIST[*]}" OPTION;
do
  for i in "${!OPTION_LIST[@]}"; do
    if [[ "${OPTION_LIST[$i]}" = "${OPTION}:" ]]; then
      OPTION_VALUE[$i]=$OPTARG
      echo "The ${OPTION_LABEL["$i"]} is ${OPTION_VALUE["$i"]}"
    fi
  done
done

OPTIONS_LENGTH=$(( $# / 2))

if [[ ${OPTIONS_LENGTH} -ne 0 ]] && [[ ${OPTIONS_LENGTH} -ne ${#OPTION_VALUE[@]} ]]; then
  echo "Mandatory command line options are not provided."
  for i in "${!OPTION_LIST[@]}"; do
    echo  -e "- ${OPTION_LIST[i]} \t ${OPTION_LABEL[i]}"
  done
  echo "e.g     $0 -n sample-ns -h samplehostname -l true -i sample-registry.default.sample:9999/sample -o values-small.yaml -y L-TESX-XXXXXX"
  exit 1
fi

shift "$(($OPTIND -1))"

for i in "${!OPTION_LIST[@]}"; do
  if [[ -z ${OPTION_VALUE[$i]} ]]; then
    echo "Missing ${OPTION_LABEL["$i"]}"
    echo "${OPTION_DESCRIPTION["$i"]}"
    [ "${OPTION_LABEL["$i"]}" == "Advance Helm Options for Guardium Insights (optional)" ] && continue
    read -t 300 -p "Enter the ${OPTION_LABEL["$i"]}: "
    OPTION_VALUE[$i]=${REPLY}
    echo "The ${OPTION_LABEL["$i"]} is '${OPTION_VALUE["$i"]}'"
    OPTION_WERE_MISSING=1
  fi
done

if [ "X${OPTION_VALUE[2]}" != 'Xtrue' ]; then
  echo "License must be evaluated as: true"
  exit 1
fi

if [[ ! -z ${OPTION_WERE_MISSING} ]]; then
  echo "#####IBM Guardium Insights Installation: Continue?#####"
  for i in "${!OPTION_LIST[@]}"; do
      echo "The ${OPTION_LABEL["$i"]} is ${OPTION_VALUE["$i"]}"
  done
  read -t 300 -p "Do you wish to proceed with these parameters ?(y/n)";
  if [[ ${REPLY} != "y" && ${REPLY} != "Y" ]]; then
    echo "Exiting script - user chose to abort"
    exit 1
  fi
fi

# map license values to product annotation files
declare -a LICENSE_LIST
LICENSE_LIST=(
  'L-TESX-BTCSA5'
  'L-TESX-BTCS8Z'
  'L-TESX-BTCS75'
)

METERING_ANNOTATIONS_DIR="${BASEDIR}/product_annotations"
declare -a PRODUCT_FILE_LIST
PRODUCT_FILE_LIST=(
  'isgi-standard.yaml'
  'isgi-zos.yaml'
  'isgi-cp4s.yaml'
)

METERING_ANNOTATIONS_FILE_CHOICE=""

# License Type option
for license_index in ${!LICENSE_LIST[@]}; do
  if [[ "X${OPTION_VALUE[5]}" == "X${LICENSE_LIST[$license_index]}" ]]; then
    METERING_ANNOTATIONS_FILE_CHOICE=${PRODUCT_FILE_LIST[$license_index]}

    # cat file, grep for productName, xargs to trim quotes
    PRODUCT_CHOICE_NAME=$(cat ${METERING_ANNOTATIONS_DIR}/${METERING_ANNOTATIONS_FILE_CHOICE} | grep productName | xargs | cut -d ':' -f2 | xargs)
    echo "${PRODUCT_CHOICE_NAME} selected"
  fi
done

if [[ -z METERING_ANNOTATIONS_FILE_CHOICE ]]; then
  echo "License Type must be selected from one of the values in the licenses folder."
  exit 1
fi

# Validate namespaces
if [[ -z `oc get namespace  ${OPTION_VALUE[0]} --ignore-not-found` ]] ; then
  echo "Namespace '${OPTION_VALUE[0]}' not found, it must be the same prepared by preInstall.sh."
  exit 1
fi

# Validate that the insights pull secret exists and that it at least contains the input registry option. This check also
# helps determine if install is using the proper namespace as we should find this secret.
configInSecret=`oc get secret insights-pull-secret -n ${OPTION_VALUE[0]} --ignore-not-found --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode`
if [[ -z ${configInSecret} ]]; then
  echo "The required image pull secret (insights-pull-secret) does not exist in namespace '${OPTION_VALUE[0]}'. Ensure this is the namespace used in preInstall.sh and it successfully completed."
  exit 1
fi
if [[ ${configInSecret} != *"${OPTION_VALUE[3]}"* ]]; then
  echo "The input image registry '${OPTION_VALUE[3]}' was not found in the image pull secret (insights-pull-secret) created by preInstall.sh."
  exit 1
fi

# Initialize helm_opt_list
helm_opt_list=""

# Load helm_options properties. The user can specify storage class values along with any helm values.
# We'll specifically look for storage class values and validate their existence on the target cluster.
storageClassCheckFail="false"
storageClassEmpty="false"
if [ -f "${BASEDIR}/helm_options" ]; then
  while IFS= read -r line
  do
    if ! [[ "$line" =~ ^[[:space:]]*# ]] ; then  # exclude comments
      property=`echo $line | cut -d "=" -f1`     # extract property on lhs of =
      if [[ -n $property ]] ; then               # if found a property
        value=`echo $line | cut -d "=" -f2 | tr -d \'\" | tr -d '\n'` # extract rhs of = w/o the quotes
        if [[ ! -z $value ]] ; then              # if value is not empty
          # if the property is of type storageClass, validate its existence
          if [[ $property = *'storageClass'* ]]; then
            if [[ -z `oc get storageclass  ${value} --ignore-not-found` ]] ; then
              echo "The storage class '${value}' defined in the property file 'helm_options' does not exist on the target cluster."
              storageClassCheckFail="true"       # set flag storageClass does not exist
            fi
          fi
        elif [[ $property = *'storageClass'* ]]; then
          echo "The storage class '${value}' defined in the property file 'helm_options' has an empty value."
          storageClassEmpty="true"               # found a storageClass property with empty value
        fi
        helm_options+=("$line")                  # set the helm options, we include empty values
      fi
    fi
  done < "$(dirname $0)"/helm_options
  helm_opt_list=$(echo "${helm_options[@]/#/--set }" | sed -e "s/['\"]//g")
  helm_opt_list="${helm_opt_list}"
fi
# Echo storage class failure or warning, exit on a failure
if [ "${storageClassCheckFail}" == "true" ] ; then
  echo "One or more storage class values set in the property file 'helm_options' do not exist."
  exit 1
fi
if [ "${storageClassEmpty}" == "true" ] ; then
  echo "One or more storage class properties have an empty value in 'helm_options' file. Please specify a value or remove these entries from helm_options if the values are in the helm values.yaml file."
  exit 1
fi

######################### Installation ###############################
echo "#####IBM Guardium Insights Installation: Helm Install#####"

# switch to guardium insights project
oc project ${OPTION_VALUE[0]}

echo "Running:"
echo "helm install --namespace ${OPTION_VALUE[0]} -n=${OPTION_VALUE[0]} --tls -f ${BASEDIR}/values.yaml -f ${BASEDIR}/${OPTION_VALUE[4]} -f ${METERING_ANNOTATIONS_DIR}/${METERING_ANNOTATIONS_FILE_CHOICE} --set global.insights.licenseAccept=${OPTION_VALUE[2]} --set global.license=${OPTION_VALUE[2]} --set global.image.repository=${OPTION_VALUE[3]} --set global.imageRegistry=${OPTION_VALUE[3]} --set global.insights.ingress.hostName=${OPTION_VALUE[1]} ${helm_opt_list} ${BASEDIR}"

# Install the chart
helm install \
    --namespace ${OPTION_VALUE[0]} \
    -n=${OPTION_VALUE[0]} \
    --tls \
    -f ${BASEDIR}/values.yaml \
    -f ${BASEDIR}/${OPTION_VALUE[4]} \
    -f ${METERING_ANNOTATIONS_DIR}/${METERING_ANNOTATIONS_FILE_CHOICE} \
    --set global.insights.licenseAccept=${OPTION_VALUE[2]} \
    --set global.license=${OPTION_VALUE[2]} \
    --set global.image.repository=${OPTION_VALUE[3]} \
    --set global.imageRegistry=${OPTION_VALUE[3]} \
    --set global.insights.ingress.hostName=${OPTION_VALUE[1]} \
    --set ibm-db2u.ldap.ldap_server="${OPTION_VALUE[0]}-ibm-db2u-db2u-ldap" \
    --set global.insights.licenseType=${OPTION_VALUE[5]} \
    ${helm_opt_list} \
    ${BASEDIR}

# Handle errors from helm install
if [[ $? -ne 0 ]]; then
  echo "Guardium Insights Install failed, please delete all jobs in this namespace before attempting a re-run of the helm command above"
  exit 1
fi

echo "#####IBM Guardium Insights Installation: Complete#####"
