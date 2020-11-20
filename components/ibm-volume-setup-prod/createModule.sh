#!/bin/bash -xe
#
# IBM Confidential
#
# OCO Source Materials
# 5737-C49, 5737-B37
#
# (c) Copyright IBM Corp. 2020
#
# The source code for this program is not published or otherwise divested of
# its trade secrets, irrespective of what has been deposited with the U.S.
# Copyright Office.
#
set -e

CUR_DIR=$(cd $(dirname $0); pwd 2>/dev/null)
echo "CUR_DIR : ${CUR_DIR}"
BASE_DIR=${CUR_DIR}/../..

. ${CUR_DIR}/../../../devtest-helpers/utils/common.sh

function createModule() {
  echo "## createModuleMainFile: entry"

  mkdir -p ${BASE_DIR}/module

  cd ${BASE_DIR}/module

  ARCH=$(uname -m)
  PKG_NAME="ibm-volume-setup-prod"

  chart_md5sum=`md5sum ${CUR_DIR}/../ibm-volume-setup-prod-*.tgz|cut -d " " -f1`

  list=$(ls ${WORKSPACE}/ws-v2-base-charts/charts/images | sed 's/.tar.gz//')

  docker login --username=${ARTIFACT_USER} --password=${ARTIFACT_PASS}  hyc-cp4d-team-wsl-docker-local.artifactory.swg-devops.com

  for item in $list; do
    repo=$(echo $item | sed 's/_/ /' | awk {'print $1'})
    tag=$(echo $item | sed 's/_/ /' | awk {'print $2'})
    dsx_requisite_image_tag=""
    if [[ $repo = "dsx-requisite" ]]; then
      dsx_requisite_image_tag=$tag
    fi

    echo "Using $repo:$tag"

    docker load -i ${WORKSPACE}/ws-v2-base-charts/charts/images/$item.tar.gz
    docker tag  $repo:$tag hyc-cp4d-team-wsl-docker-local.artifactory.swg-devops.com/$repo:$tag
    docker push hyc-cp4d-team-wsl-docker-local.artifactory.swg-devops.com/$repo:$tag

  done

  cat <<EOT > data_$ARCH.json
{
  "build_num": "${BUILD_NUMBER}",
  "chart_md5sum": "${chart_md5sum}",
  "dsx_requisite_image_tag": "${dsx_requisite_image_tag}"
}
EOT

  cat data_$ARCH.json
  install_required_tools
  generate_file_from_template ${CUR_DIR}/manifest/module-main.yaml.j2  ${BASE_DIR}/module
  cp ${CUR_DIR}/manifest/module-main.yaml .
  rm data_$ARCH.json
  echo "-------module-main.yaml---"
  cat module-main.yaml
  echo "-------end module-main.yaml---"

  #create the module folder
  mkdir -p ${WORKSPACE}/3.0.${BUILD_NUMBER}

  cp module-main.yaml  ${WORKSPACE}/3.0.${BUILD_NUMBER}/main.yaml

  cp ${CUR_DIR}/../ibm-volume-setup-prod-*.tgz ${WORKSPACE}/3.0.${BUILD_NUMBER}

  ls -all  ${WORKSPACE}/3.0.${BUILD_NUMBER}

}

date
createModule

echo "## DONE ##"
