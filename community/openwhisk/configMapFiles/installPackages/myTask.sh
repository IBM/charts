# Licensed to the Apache Software Foundation (ASF) under one or more contributor
# license agreements; and to You under the Apache License, Version 2.0.

export OPENWHISK_HOME=/openwhisk

export PROVIDER_DB_URL=$PROVIDER_DB_PROTOCOL://$PROVIDER_DB_USERNAME:$PROVIDER_DB_PASSWORD@$PROVIDER_DB_HOST:$PROVIDER_DB_PORT

#####
# Install Route Mgmt Support
#####

# Clone openwhisk repo to get installRouteMgmt.sh and core/routemgmt
git clone https://github.com/apache/incubator-openwhisk openwhisk

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
    ./installRouteMgmt.sh $WHISK_AUTH $WHISK_API_HOST $WHISK_SYSTEM_NAMESPACE /usr/local/bin/wsk
popd


#####
# Install the OpenWhisk Catalog
#####
git clone https://github.com/apache/incubator-openwhisk-catalog openwhisk-catalog

pushd openwhisk-catalog/packages
    ./installCatalog.sh $WHISK_AUTH $WHISK_API_HOST /usr/local/bin/wsk
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
    cd /
    git clone https://github.com/apache/incubator-openwhisk-package-alarms.git

    pushd /incubator-openwhisk-package-alarms
        ./installCatalog.sh $WHISK_AUTH $WHISK_API_HOST $PROVIDER_DB_URL $ALARM_DB_PREFIX $WHISK_API_HOST
    popd
fi


#####
# Install the catalog for the Cloudant provider
#####

if [ "$OW_INSTALL_CLOUDANT_PROVIDER" == "yes" ]; then
    cd /
    git clone https://github.com/apache/incubator-openwhisk-package-cloudant.git

    pushd /incubator-openwhisk-package-cloudant
        ./installCatalog.sh $WHISK_AUTH $WHISK_API_HOST $PROVIDER_DB_URL $CLOUDANT_DB_PREFIX $WHISK_API_HOST
    popd
fi


#####
# Install the catalog for the Kafka provider
#####

if [ "$OW_INSTALL_KAFKA_PROVIDER" == "yes" ]; then
    cd /
    git clone https://github.com/apache/incubator-openwhisk-package-kafka.git

    pushd /incubator-openwhisk-package-kafka
        ./installKafka.sh $WHISK_AUTH $WHISK_API_HOST $PROVIDER_DB_URL $KAFKA_DB_PREFIX $WHISK_API_HOST
        ./installCatalog.sh $WHISK_AUTH $WHISK_API_HOST $PROVIDER_DB_URL $KAFKA_DB_PREFIX $WHISK_API_HOST
    popd
fi

