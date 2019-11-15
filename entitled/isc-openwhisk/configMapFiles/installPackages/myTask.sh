#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

export OPENWHISK_HOME=/openwhisk

export PROVIDER_DB_URL=$PROVIDER_DB_PROTOCOL://$PROVIDER_DB_USERNAME:$PROVIDER_DB_PASSWORD@$PROVIDER_DB_HOST:$PROVIDER_DB_PORT

#####
# Install Route Mgmt Support
#####

# Clone openwhisk repo to get installRouteMgmt.sh and core/routemgmt
git clone https://github.com/apache/incubator-openwhisk openwhisk
pushd openwhisk
    git checkout $OW_GIT_TAG_OPENWHISK
    rm -f /openwhisk/ansible/files/auth.guest /openwhisk/ansible/files/auth.whisk.system
popd

# Setup env for installRouteMgmt.sh
if [ "$WHISK_API_GATEWAY_USER" ]; then
    export GW_USER=$WHISK_API_GATEWAY_USER
else
    export GW_USER=' '
fi
if [ "$WHISK_API_GATEWAY_PASSWORD" ]; then
    export GW_PWD=$WHISK_API_GATEWAY_PASSWORD
else
    export GW_PWD=' '
fi
if [ "$WHISK_API_GATEWAY_HOST_V2" ]; then
    export GW_HOST_V2=$WHISK_API_GATEWAY_HOST_V2
else
    echo "Must provide a value for WHISK_API_GATEWAY_HOST_V2"
    exit 1
fi

pushd $OPENWHISK_HOME/ansible/roles/routemgmt/files
    # This operation is unreliable in a TravisCI environment (for unknown reasons),
    # so try multiple times before giving up.
    PASSED=false
    TRIES=0
    until $PASSED || [ $TRIES -eq 10 ]; do
        if ./installRouteMgmt.sh $WHISK_AUTH $WHISK_API_HOST $WHISK_SYSTEM_NAMESPACE /usr/local/bin/wsk; then
            PASSED=true
            echo "Successfully deployed routemgmt package"
        else
            echo "Failed to deploy routemgmt package; will pause, uninstall, and try again"
            let TRIES=TRIES+1
            sleep 10
            ./uninstallRouteMgmt.sh $WHISK_AUTH $WHISK_API_HOST $WHISK_SYSTEM_NAMESPACE /usr/local/bin/wsk;
        fi
    done
    if ! $PASSED; then
        echo "Giving up after 10 failed attempts to install the routemgmt package"
        exit 1
    fi
popd

cd /tmp

#####
# Install the OpenWhisk Catalog
#####
git clone https://github.com/apache/incubator-openwhisk-catalog openwhisk-catalog
pushd openwhisk-catalog
    git checkout $OW_GIT_TAG_OPENWHISK_CATALOG
popd

pushd openwhisk-catalog/packages
    ./installCatalog.sh $WHISK_AUTH $WHISK_API_HOST /usr/local/bin/wsk || exit 1
popd


#####
# Install catalogs for each enabled Event Provider
#####

# UGH: installCatalog.sh for the providers hardwires that it wants $OPENWHISK_HOME/bin/wsk
cp /usr/local/bin/wsk $OPENWHISK_HOME/bin/wsk


#####
# Install the catalog for the Alarm provider
#####

if [ "$OW_INSTALL_ALARM_PROVIDER" == "yes" ]; then
    # cd /
    cd /tmp
    git clone https://github.com/apache/incubator-openwhisk-package-alarms.git

    pushd /tmp/incubator-openwhisk-package-alarms
        git checkout $OW_GIT_TAG_OPENWHISK_PACKAGE_ALARMS
        ./installCatalog.sh $WHISK_AUTH $WHISK_API_HOST $PROVIDER_DB_URL $ALARM_DB_PREFIX $WHISK_API_HOST || exit 1
    popd
fi


#####
# Install the catalog for the Cloudant provider
#####

if [ "$OW_INSTALL_CLOUDANT_PROVIDER" == "yes" ]; then
    # cd /
    cd /tmp
    git clone https://github.com/apache/incubator-openwhisk-package-cloudant.git

    pushd /tmp/incubator-openwhisk-package-cloudant
        git checkout $OW_GIT_TAG_OPENWHISK_PACKAGE_CLOUDANT
        ./installCatalog.sh $WHISK_AUTH $WHISK_API_HOST $PROVIDER_DB_URL $CLOUDANT_DB_PREFIX $WHISK_API_HOST || exit 1
    popd
fi


#####
# Install the catalog for the Kafka provider
#####

if [ "$OW_INSTALL_KAFKA_PROVIDER" == "yes" ]; then
    # cd /
    cd /tmp
    git clone https://github.com/apache/incubator-openwhisk-package-kafka.git

    pushd /tmp/incubator-openwhisk-package-kafka
        git checkout $OW_GIT_TAG_OPENWHISK_PACKAGE_KAFKA
        ./installKafka.sh $WHISK_AUTH $WHISK_API_HOST $PROVIDER_DB_URL $KAFKA_DB_PREFIX $WHISK_API_HOST || exit 1
        ./installCatalog.sh $WHISK_AUTH $WHISK_API_HOST $PROVIDER_DB_URL $KAFKA_DB_PREFIX $WHISK_API_HOST || exit 1
    popd
fi

