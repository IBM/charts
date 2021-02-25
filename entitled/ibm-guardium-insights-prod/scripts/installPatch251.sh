#!/bin/bash
#################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2020. All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################

# /*******************************************************************************
#  * NAME: installPatch251
#  * DESCRIPTION: Script to install patch v2.5.1 using helm upgrade
#  * AUTHOR: Talgat Ryshmanov talgat.ryshmanov@ibm.com
#  *******************************************************************************/


BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR/..

# list of options for the installer script
OPTION_LIST=(n:)

# lists the labels for the corresponding options in the OPTIONS_LIST
declare -a OPTION_LABEL
OPTION_LABEL=(
  'IBM Guardium Insights Namespace (also used as Helm Release Name)'
)

# lists the description for the corresponding options in the OPTIONS_LIST
declare -a OPTION_DESCRIPTION
OPTION_DESCRIPTION=(
  'IBM Security Guardium Insights Openshift namespace (this value must be 10 or fewer characters and it is the same value as is used for the Helm Release).'
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

if [[ ${OPTIONS_LENGTH} -ne 0 ]] && [[ ${OPTIONS_LENGTH} -ne ${#OPTION_VALUE[@]} ]]; then
  echo "Mandatory command line options are not provided"
  for i in "${!OPTION_LIST[@]}"; do
    echo  -e "- ${OPTION_LIST[i]} \t ${OPTION_LABEL[i]}"
  done
  echo "e.g     $0 -n sample "
  exit 1
fi

for i in "${!OPTION_LIST[@]}"; do
  if [[ -z ${OPTION_VALUE[$i]} ]]; then
    echo "Missing ${OPTION_LABEL["$i"]}."
    echo "${OPTION_DESCRIPTION["$i"]}"
    echo "Enter the ${OPTION_LABEL["$i"]}: "
    read;
    OPTION_VALUE[$i]=${REPLY}
    echo "The ${OPTION_LABEL["$i"]} is ${OPTION_VALUE["$i"]}"
    OPTION_WERE_MISSING=1
  fi
done

if [[ ! -z ${OPTION_WERE_MISSING} ]]; then
  echo "#####IBM Guardium Insights Patch Upgrade: Continue?#####"
  for i in "${!OPTION_LIST[@]}"; do
      # [ "${OPTION_LABEL["$i"]}" == global.insights.icp.authPassword ] && continue
      echo "The ${OPTION_LABEL["$i"]} is: ${OPTION_VALUE["$i"]}"
  done
  echo "Do you wish to proceed with these parameters ?(y/n)"
  read;
  if [[ ${REPLY} != "y" && ${REPLY} != "Y" ]]; then
    echo "Exiting script - user chose to abort"
    exit 1
  fi
fi

if [[ `grep licenses .helmignore | wc -l` -eq 0 ]]; then
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

REVISION=$(helm list --tls | grep -e "^${OPTION_VALUE[0]}" | awk '{print $2}' )
echo "You current revision is: $REVISION Please remember this value"

######################### Installation ###############################
echo "#####IBM Guardium Insights Patch Upgrade: Patch v2.5.1 Install#####"

oc project ${OPTION_VALUE[0]}

echo "helm upgrade -i ${OPTION_VALUE[0]} --namespace ${OPTION_VALUE[0]} --debug --tls --reuse-values --timeout 1800 ."
helm upgrade -i ${OPTION_VALUE[0]} --namespace ${OPTION_VALUE[0]} --debug --tls --reuse-values --timeout 1800 .

if [[ $? -ne 0 ]]; then
  echo "Guardium Insights Patch Upgrade failed, please execute: helm rollback --tls ${OPTION_VALUE[0]} $REVISION to return to the previous version "
  exit 1
fi

echo "#####IBM Guardium Insights Patch Upgrade: Complete#####"

