# Licensed to the Apache Software Foundation (ASF) under one or more contributor
# license agreements; and to You under the Apache License, Version 2.0.

export OPENWHISK_HOME=/openwhisk

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

# Run installRouteMgmt.sh
pushd $OPENWHISK_HOME/ansible/roles/routemgmt/files
    ./installRouteMgmt.sh $WHISK_AUTH $WHISK_API_HOST_NAME $WHISK_NAMESPACE /usr/local/bin/wsk
popd
