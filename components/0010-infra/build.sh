#!/bin/bash
# To make the Data Refinery helm chart
#
set -e
CUR_DIR=$(cd $(dirname $0); pwd 2>/dev/null)
PKG_NAME="0010-infra"
PKG_TAG=$(awk '{for(i=1;i<=NF;i++) if ($i=="version:") print $(i+1)}' ${CUR_DIR}/Chart.yaml)
#PKG_NAME="dashboard"
#PKG_TAG="0.1.0"
CONFIG_FILE="infra"
CONFIG_FILE_PATH="${CUR_DIR}/../../../InstallAndGo/config_files/${CONFIG_FILE}.txt"
PKG_DIR=${PKG_NAME}
TMP_DIR="${WORKSPACE}/tmp/untarLoadPush"
ARCH=$(uname -m)

# Function to untar the service tar.gz and load the image and push
# Parameter is the tar file name, must be an absolute path
function untar_load_push() {
    local filename="$(basename $1)"
    local dirname="$(dirname $1)"
    local svcname="$(echo ${filename} | cut -d. -f1)"
    local diruntar="${dirname}/${svcname}-artifact"
    echo "Service ${svcname} Untaring ${filename}"

    local cmd="tar -zxvf ${1} -C ${dirname}"
    echo "$cmd"
    eval "$cmd"

    if [[ ! -d "${diruntar}" ]]; then
        echo "Directory ${diruntar} does not exist"
        exit 1
    fi

    imgs=($(ls ${diruntar} |  grep 'tar.gz$' ))
    previousDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    cd ${diruntar}
    for cur_img in ${imgs[@]}; do
        echo "Removing localhost:5000/ prefix for ${cur_img}"
        python ${CUR_DIR}/../../remove_image_prefix.py ./${cur_img} "localhost:5000/"
        mv ./${cur_img::-7}/${cur_img} ${CUR_DIR}/../images/${cur_img}
    done
    cd ${previousDir}
}


# Make sure docker client does exist
which docker

# Copy service to the directory - This script is checked out by the jenkins job from InstallAndGo
echo "Updating the images"

CUR_DIR_2="${WORKSPACE}/InstallAndGo/build/"
cd ${CUR_DIR_2}
SETTING_FILE_PATH="${CUR_DIR_2}/../config_files/settings.sh"

rm -rf ../config_files

mkdir -p ${CUR_DIR_2}/../config_files


mkdir -p ${CUR_DIR}/../InstallAndGo/config_files
echo "#Service||Repo||Branch||Namespace||Jenkins||Jenkins Branch Name||project build machine||path" > ${CONFIG_FILE_PATH}
echo "redis-repo||PrivateCloud/redis-repo||zen-modularization||ibm-private-cloud||DSXL-Trigger-redis-repo||BR:redisRepoBranch||9.30.4.45||.." >> ${CONFIG_FILE_PATH}
echo "usermgmt||PrivateCloud/usermgmt||zen-modularization||ibm-private-cloud||DSXL-Trigger-usermgmt||BR:usermgmtBranch||9.30.4.45||.." >> ${CONFIG_FILE_PATH}
echo "influxdb-alpine||PrivateCloud/DSX-Docker-Images||zen-modularization||ibm-private-cloud||DSXL-influxdb-alpine||BR:DSX_DOCKER_IMAGES_BRANCH||9.30.4.45||.." >> ${CONFIG_FILE_PATH}

cat << EOF > ${SETTING_FILE_PATH}
#!/bin/bash
DEFAULT_JENKINS_DIR=/zpool1/disk1
EOF

# get the tar files
${CUR_DIR}/../../../InstallAndGo/build/copyServices.sh ${CONFIG_FILE} "../icp4data-base-charts/charts/services"
if [[ $? -ne 0 ]]
then
    echo "Build fail, cannot get build artifact"
    exit 1
fi
cd ${CUR_DIR}

# Handling each service
mkdir -p ${CUR_DIR}/../images
mkdir -p ${TMP_DIR}

files=($(ls ${CUR_DIR}/../services))
for cur_file in ${files[@]}; do
    # Depends on the jobs output, we allow only 5 jobs at a time
    while [[ 1 ]]; do
        [[ $(jobs -rp | wc -l) -lt 5 ]] && break
        sleep 5
    done

    out=$(mktemp -p ${TMP_DIR} dsx.out.XXXXXXXXXXXX)
    untar_load_push ${CUR_DIR}/../services/${cur_file} > ${out} 2>&1 &

done
wait

cd ${CUR_DIR}/../services
wget http://birepo-build.svl.ibm.com/zen/icp4d-builds/2.1.0.1/x86_64/modules/images/zenmetastoredb/zenmetastoredb.latest/zen-metastoredb-v2.5.0.0.tar.gz
zenmetastoredbimages=(
    "zen-metastoredb-v2.5.0.0.tar.gz"
)
for cur_img in ${zenmetastoredbimages[@]}; do
      echo "Removing localhost:5000/ prefix for ${cur_img}"
      python ${CUR_DIR}/../../remove_image_prefix.py ./${cur_img} "localhost:5000/"
      mv ./${cur_img::-7}/${cur_img} ${CUR_DIR}/../images/${cur_img}
done

# Do clean up none images in background as we do not care result
docker image prune -f &

# Update the values.yaml for the image version according to image .tar.gz file name

sh ${CUR_DIR}/update_value_yaml.sh
[[ $? -ne 0 ]] && exit 1

rm -rf  ${CUR_DIR}/update_value_yaml.sh ${CUR_DIR}/build.sh
# Build now
echo "Make the chart now"
cd ${CUR_DIR}
cd ..
curl -H "X-JFrog-Art-Api:${ARTIFACTORY_PASSWORD}" -O "https://na.artifactory.swg-devops.com/artifactory/hyc-dsxl-build-generic-local/icp_helm/helm-v2.9.1-linux-amd64.tar.gz"
tar xzvf helm-v2.9.1-linux-amd64.tar.gz
${CUR_DIR}/../linux-amd64/helm init --client-only
#${CUR_DIR}/../linux-amd64/helm repo add --username ${ARTIFACTORY_EMAIL} --password ${ARTIFACTORY_PASSWORD} icpdata https://na.artifactory.swg-devops.com/artifactory/hyc-icp-data-helm-virtual
${CUR_DIR}/../linux-amd64/helm package -u 0010-infra

rm -rf 0010-infra
mkdir ${PKG_DIR}
mkdir -p ${PKG_DIR}/charts
mv 0010-infra-*.tgz ${PKG_DIR}/charts
mv images ${PKG_DIR}
touch icp4d-override.yaml
touch icp4d-metadata.yaml
mv icp4d-override.yaml ${PKG_DIR}
mv icp4d-metadata.yaml ${PKG_DIR}

tar -cvf ${WORKSPACE}/0010-infra.tar ${PKG_DIR}
cd ${WORKSPACE}

#symlinking build to latest on fileserver
#sshpass -p "d4t4z3n%" ssh zenuser@birepo-build.svl.ibm.com "ln -sfn /var/www/bi/zen/icp4d-builds/${VERSION}/x86_64/modules/base/0010-infra/$BUILD_NUMBER /var/www/bi/zen/icp4d-builds/${VERSION}/x86_64/modules/base/0010-infra/0010-infra.latest"

exit $?
