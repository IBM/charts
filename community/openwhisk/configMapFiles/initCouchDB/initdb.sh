# Licensed to the Apache Software Foundation (ASF) under one or more contributor
# license agreements; and to You under the Apache License, Version 2.0.

# Clone OpenWhisk to get the ansible playbooks needed to initialize CouchDB
git clone https://github.com/apache/incubator-openwhisk /openwhisk
pushd /openwhisk
    git checkout $OW_GIT_TAG_OPENWHISK
popd

# Copy the secrets whisk.auth.guest and whisk.auth.system into the cloned tree
# overwriting the default values we cloned from git
cp -f /etc/whisk-auth/guest /openwhisk/ansible/files/auth.guest
cp -f /etc/whisk-auth/system /openwhisk/ansible/files/auth.whisk.system

# generate db_local.ini so the ansible jobs know how to access the database
pushd /openwhisk/ansible
    ansible-playbook -i environments/local setup.yml
    ansible-playbook -i environments/local couchdb.yml --tags ini \
                     -e db_prefix=$DB_PREFIX \
                     -e db_host=$DB_HOST \
                     -e db_username=$COUCHDB_USER \
                     -e db_password=$COUCHDB_PASSWORD \
                     -e db_port=$DB_PORT \
                     -e openwhisk_home=/openwhisk
popd

# Wait for CouchDB to be available before starting to configure it
until $( curl --output /dev/null --silent $DB_PROTOCOL://$DB_HOST:$DB_PORT/_utils ); do
    echo "waiting for CouchDB to be available"
    sleep 2
done

# Enable single node mode (this also creates the system databases)
echo "Enabling single node cluster"
curl --silent -X POST -H "Content-Type: application/json" $DB_PROTOCOL://$COUCHDB_USER:$COUCHDB_PASSWORD@$DB_HOST:$DB_PORT/_cluster_setup -d '{"action": "enable_single_node"}'

# disable reduce limits on views
echo "Disabling reduce limits on views"
curl --silent -X PUT $DB_PROTOCOL://$COUCHDB_USER:$COUCHDB_PASSWORD@$DB_HOST:$DB_PORT/_node/couchdb@$NODENAME/_config/query_server_config/reduce_limit -d '"false"'


# initialize the DB tables for OpenWhisk
pushd /openwhisk/ansible
    ansible-playbook -i environments/local initdb.yml \
                     -e db_prefix=$DB_PREFIX \
                     -e db_host=$DB_HOST \
                     -e db_username=$COUCHDB_USER \
                     -e db_password=$COUCHDB_PASSWORD \
                     -e db_port=$DB_PORT \
                     -e openwhisk_home=/openwhisk

    ansible-playbook -i environments/local wipe.yml \
                     -e db_prefix=$DB_PREFIX \
                     -e db_host=$DB_HOST \
                     -e db_username=$COUCHDB_USER \
                     -e db_password=$COUCHDB_PASSWORD \
                     -e db_port=$DB_PORT \
                     -e openwhisk_home=/openwhisk
popd

echo "Creating ow_kube_couchdb_initialized_marker database"
curl --silent -X PUT $DB_PROTOCOL://$COUCHDB_USER:$COUCHDB_PASSWORD@$DB_HOST:$DB_PORT/ow_kube_couchdb_initialized_marker

echo "successfully initialized CouchDB for OpenWhisk"
