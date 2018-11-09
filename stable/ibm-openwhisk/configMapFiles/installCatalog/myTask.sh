# Licensed to the Apache Software Foundation (ASF) under one or more contributor
# license agreements; and to You under the Apache License, Version 2.0.

# TODO: fix upstream: installCatalog.sh requires OPENWHISK_HOME set, but doesn't actually need it to be valid
export OPENWHISK_HOME=/openwhisk

# Clone openwhisk-catalog
git clone https://github.com/apache/incubator-openwhisk-catalog openwhisk-catalog

# Run installCatalog.sh
pushd openwhisk-catalog/packages
  ./installCatalog.sh $WHISK_AUTH $WHISK_API_HOST_NAME /usr/local/bin/wsk
popd
