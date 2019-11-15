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

# Clone OpenWhisk to get the ansible playbooks needed to initialize CouchDB
git clone https://github.com/apache/incubator-openwhisk /openwhisk
pushd /openwhisk
    git checkout $OW_GIT_TAG_OPENWHISK
popd

# Install the secrets whisk.auth.guest and whisk.auth.system into the cloned tree
# after removing the defaults inherited from the checkout of openwhisk
rm -f /openwhisk/ansible/files/auth.guest /openwhisk/ansible/files/auth.whisk.system
cp -f /etc/whisk-auth/guest /openwhisk/ansible/files/auth.guest
cp -f /etc/whisk-auth/system /openwhisk/ansible/files/auth.whisk.system

# Sanity check: all subjects must have unique keys
if cmp -s /openwhisk/ansible/files/auth.guest /openwhisk/ansible/files/auth.whisk.system; then
    echo "FATAL ERROR: unable to initialize the OpenWhisk subjects database."
    echo "Cannot use identical keys for whisk.auth.system and whisk.auth.guest."
    exit 1
fi

# generate db_local.ini so the ansible jobs know how to access the database
pushd /openwhisk/ansible
    ansible-playbook -i environments/local setup.yml
    ansible-playbook -i environments/local couchdb.yml --tags ini \
                     -e db_prefix=$DB_PREFIX \
                     -e db_protocol=$DB_PROTOCOL \
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
curl --silent -X POST -H "Content-Type: application/json" -u "$COUCHDB_USER:$COUCHDB_PASSWORD" $DB_PROTOCOL://$DB_HOST:$DB_PORT/_cluster_setup -d '{"action": "enable_single_node"}' || exit 1

# disable reduce limits on views
echo "Disabling reduce limits on views"
curl --silent -X PUT -u "$COUCHDB_USER:$COUCHDB_PASSWORD" $DB_PROTOCOL://$DB_HOST:$DB_PORT/_node/couchdb@$NODENAME/_config/query_server_config/reduce_limit -d '"false"' || exit 1


# initialize the DB tables for OpenWhisk
pushd /openwhisk/ansible
    ansible-playbook -i environments/local initdb.yml \
                     -e db_prefix=$DB_PREFIX \
                     -e db_protocol=$DB_PROTOCOL \
                     -e db_host=$DB_HOST \
                     -e db_username=$COUCHDB_USER \
                     -e db_password=$COUCHDB_PASSWORD \
                     -e db_port=$DB_PORT \
                     -e openwhisk_home=/openwhisk

    ansible-playbook -i environments/local wipe.yml \
                     -e db_prefix=$DB_PREFIX \
                     -e db_protocol=$DB_PROTOCOL \
                     -e db_host=$DB_HOST \
                     -e db_username=$COUCHDB_USER \
                     -e db_password=$COUCHDB_PASSWORD \
                     -e db_port=$DB_PORT \
                     -e openwhisk_home=/openwhisk
popd

echo "Creating ow_kube_couchdb_initialized_marker database"
curl --silent -X PUT -u "$COUCHDB_USER:$COUCHDB_PASSWORD" $DB_PROTOCOL://$DB_HOST:$DB_PORT/ow_kube_couchdb_initialized_marker || exit 1

echo "successfully initialized CouchDB for OpenWhisk"
