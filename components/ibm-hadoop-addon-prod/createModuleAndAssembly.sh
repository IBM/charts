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
  PKG_NAME="ibm-hadoop-addon-prod"

  chart_md5sum=`md5sum ${CUR_DIR}/../ibm-hadoop-addon-prod-*.tgz|cut -d " " -f1`

  list=$(ls ${WORKSPACE}/ws-v2-base-charts/charts/images | sed 's/.tar.gz//')

  docker login --username=${ARTIFACT_USER} --password=${ARTIFACT_PASS}  hyc-cp4d-team-wsl-docker-local.artifactory.swg-devops.com

  for item in $list; do
    repo=$(echo $item | sed 's/_/ /' | awk {'print $1'})
    tag=$(echo $item | sed 's/_/ /' | awk {'print $2'})
    dsx_requisite_image_tag=""
    if [[ $repo = "privatecloud-utils-api" ]]; then
      utils_api_image_tag=$tag
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
  "utils_api_image_tag": "${utils_api_image_tag}"
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
  if [ $ARCH = "x86_64" ]; then
    moduleFolder="${WORKSPACE}/3.0.${BUILD_NUMBER}/modules/hadoop-addon/x86_64"
  elif [ $ARCH = "ppc64le" ]; then
    moduleFolder="${WORKSPACE}/3.0.${BUILD_NUMBER}/modules/hadoop-addon/ppc64le"
  fi

  mkdir -p ${moduleFolder}/3.0.${BUILD_NUMBER}
  cp module-main.yaml  ${moduleFolder}/3.0.${BUILD_NUMBER}/main.yaml
  cp ${CUR_DIR}/../ibm-hadoop-addon-prod-*.tgz ${moduleFolder}/3.0.${BUILD_NUMBER}

  touch versions.yaml
  echo "versions:" >> versions.yaml
  echo "  - 3.0.${BUILD_NUMBER}" >> versions.yaml
  cp versions.yaml ${moduleFolder}

  ls -all  ${moduleFolder}/3.0.${BUILD_NUMBER}

}

function createAssembly() {

  #create the module folder
  date
  createModule

  echo "## createModuleMainFile: entry"

  mkdir -p ${BASE_DIR}/assembly

  cd ${BASE_DIR}/assembly

  ARCH=$(uname -m)

  cat <<EOT > data_$ARCH.json
{
  "build_num": "${BUILD_NUMBER}",
  "arch": "${ARCH}"
}
EOT

  cat data_$ARCH.json
  install_required_tools
  generate_file_from_template ${CUR_DIR}/manifest/assembly-main.yaml.j2  ${BASE_DIR}/assembly
  generate_file_from_template ${CUR_DIR}/manifest/server.yaml.j2  ${BASE_DIR}/assembly
  cp ${CUR_DIR}/manifest/assembly-main.yaml .
  cp ${CUR_DIR}/manifest/server.yaml .
  rm data_$ARCH.json
  echo "-------assembly-main.yaml---"
  cat assembly-main.yaml
  echo "-------end assembly-main.yaml---"

  #create the assembly folder
  if [ $ARCH = "x86_64" ]; then
    assemblyFolder="${WORKSPACE}/3.0.${BUILD_NUMBER}/assembly/hadoop-addon/x86_64"
  elif [ $ARCH = "ppc64le" ]; then
    assemblyFolder="${WORKSPACE}/3.0.${BUILD_NUMBER}/assembly/hadoop-addon/ppc64le"
  fi

  ## the 3.0.1 builds starts with the 36 buiild no of hadoop module helm chart
  mkdir -p ${assemblyFolder}/3.0.136

  cp assembly-main.yaml  ${assemblyFolder}/3.0.136/main.yaml

  #create server.yaml
  cp server.yaml ${WORKSPACE}/3.0.${BUILD_NUMBER}

  cp ${CUR_DIR}/manifest/override.yaml ${assemblyFolder}/3.0.136/override.yaml

  #create server.yaml
  touch versions.yaml
  echo "assembly: ${ARCH}" >> versions.yaml
  echo "versions:" >> versions.yaml
  echo "  - 3.0.136" >> versions.yaml
  cp versions.yaml ${assemblyFolder}

  ls -all  ${assemblyFolder}/3.0.136

  cd ${WORKSPACE}
  if [[ ${PUSH_TO_FILESERVER} = 'TRUE' ]]; then
    echo "uploading artifacts to the file server icpfs1.svl.ibm.com"
    hadoopaddonFolder="/pool1/data1/zen/cp4d-builds/3.0.1/dev/components/hadoop-addon/"
    sshpass -p $fileServerPassword scp -r -o StrictHostKeyChecking=no 3.0.${BUILD_NUMBER} build@icpfs1.svl.ibm.com:${hadoopaddonFolder}
    ##remove the latest and symlink to the newfolder
    sshpass -p $fileServerPassword ssh build@icpfs1.svl.ibm.com "cd ${hadoopaddonFolder} && rm -rf latest && ln -s 3.0.${BUILD_NUMBER} latest"
  fi
}

date
createAssembly

echo "## DONE ##"
