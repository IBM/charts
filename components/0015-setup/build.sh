#!/bin/bash
# To make the 0015-setup helm chart

CUR_DIR=$(cd $(dirname $0); pwd 2>/dev/null)
PKG_NAME="0015-setup:1.0.0"
PKG_DIR=${PKG_NAME}
docker images -a | grep "0*" | awk '{print $3}' | xargs docker rmi -f || true
mkdir images
cd images
#Pull Images for packaging
echo "Pull Images for packaging"
sshpass -p d4t4z3n% scp zenuser@birepo-build.svl.ibm.com:/var/www/bi/zen/icp4d-builds/1.2.1.0/x86_64/modules/images/zen-service-broker.tar.gz .
sshpass -p d4t4z3n% scp zenuser@birepo-build.svl.ibm.com:/var/www/bi/zen/icp4d-builds/1.2.1.0/x86_64/modules/images/icp4data-nginx-repo_v1.tar.gz .


cd $WORKSPACE/icp4data-base-charts/charts/

rm -rf 0005-boot
rm -rf 0010-infra
rm -rf 0020-zen-base
rm -rf 0030-admindash
rm -rf 0040-dsx-base
rm -rf 0050-jupyter-py36
sed -i 's/icp4data-setup/0015-setup/' $WORKSPACE/icp4data-base-charts/charts/0015-setup/Chart.yaml

# Build now
echo "Making the chart"
cd ${CUR_DIR}
cd ..
curl -H "X-JFrog-Art-Api:${ARTIFACTORY_PASSWORD}" -O "https://na.artifactory.swg-devops.com/artifactory/hyc-dsxl-build-generic-local/icp_helm/helm-v2.9.1-linux-amd64.tar.gz"
tar xzvf helm-v2.9.1-linux-amd64.tar.gz
${CUR_DIR}/../linux-amd64/helm init --client-only
#${CUR_DIR}/../linux-amd64/helm repo add --username ${ARTIFACTORY_EMAIL} --password ${ARTIFACTORY_PASSWORD} icpdata https://na.artifactory.swg-devops.com/artifactory/hyc-icp-data-helm-virtual
${CUR_DIR}/../linux-amd64/helm package -u 0015-setup


cd ..
rm -rf 0015-setup
mkdir ${PKG_DIR}
mkdir -p ${PKG_DIR}/charts
echo "check pwd"
pwd

mv charts/0015-setup-*.tgz ${PKG_DIR}/charts
mv ${WORKSPACE}/images ${PKG_DIR}
touch icp4d-override.yaml
touch icp4d-metadata.yaml
mv icp4d-override.yaml ${PKG_DIR}
mv icp4d-metadata.yaml ${PKG_DIR}



tar -cvf ${WORKSPACE}/0015-setup-v1.0.0.tar ${PKG_DIR}

cd ${WORKSPACE}

mkdir $BUILD_NUMBER

cp 0015-setup-v1.0.0.tar $BUILD_NUMBER

if [[ ${PUSH_TO_FILESERVER} = 'TRUE' ]]; then
  echo "uploading artifacts to the file server"
    sshpass -p d4t4z3n% scp -r -oStrictHostKeyChecking=no $BUILD_NUMBER zenuser@birepo-build.svl.ibm.com:/var/www/bi/zen/icp4d-builds/1.2.1.1/x86_64/modules/base/0015-setup/
    sshpass -p d4t4z3n% ssh zenuser@birepo-build.svl.ibm.com "ln -sfn /var/www/bi/zen/icp4d-builds/1.2.1.1/x86_64/modules/base/0015-setup/$BUILD_NUMBER /var/www/bi/zen/icp4d-builds/1.2.1.1/x86_64/modules/base/0015-setup/0015-setup.latest"
fi
exit $?
