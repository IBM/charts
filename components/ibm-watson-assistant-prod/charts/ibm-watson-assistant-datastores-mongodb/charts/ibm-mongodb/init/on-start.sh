#!/usr/bin/env bash
replica_set="$REPLICA_SET"
script_name=${0##*/}

if [[ "$AUTH" == "true" ]]; then
    admin_user="$ADMIN_USER"
    admin_password="$ADMIN_PASSWORD"
    admin_creds=(-u "$admin_user" -p "$admin_password")
    if [[ "$METRICS" == "true" ]]; then
        metrics_user="$METRICS_USER"
        metrics_password="$METRICS_PASSWORD"
        monitor_creds=(-u "$monitor_user" -p "$admin_password")
    fi
    auth_args=(--auth --keyFile=/data/configdb/key.txt)
fi

if [[ -n "$WIREDTIGER_CACHE_SIZE_GB" ]]; then
    perf_args=(--wiredTigerCacheSizeGB="$WIREDTIGER_CACHE_SIZE_GB")
fi

if [[ -n "$OPLOG_SIZE_MB" ]]; then
    perf_args+=(--oplogSize="$OPLOG_SIZE_MB")
fi

function log() {
    local msg="$1"
    local timestamp
    timestamp=$(date --iso-8601=ns)
    echo "[$timestamp] [$script_name] $msg" >> /home/mongodb/work-dir/log.txt
}

function shutdown_mongo() {
    if [[ $# -eq 1 ]]; then
        args="timeoutSecs: $1"
    else
        args='force: true'
    fi
    log "Shutting down MongoDB ($args)..."
    mongo admin "${admin_creds[@]}" "${ssl_args[@]}" --eval "db.shutdownServer({$args})"
}

my_hostname=$(hostname)
log "Bootstrapping MongoDB replica set member: $my_hostname"

log "Reading standard input..."
while read -ra line; do
    if [[ "${line}" == *"${my_hostname}"* ]]; then
        service_name="$line"
        continue
    fi
    peers=("${peers[@]}" "$line")
done

# Generate the ca cert
ca_crt=/data/configdb/tls.crt
if [ -f "$ca_crt"  ]; then
    log "Generating certificate"
    ca_key=/data/configdb/tls.key
    pem=/home/mongodb/work-dir/mongo.pem
    ssl_args=(--ssl --sslCAFile "$ca_crt" --sslPEMKeyFile "$pem")

# Move into /home/mongodb/work-dir
pushd /home/mongodb/work-dir

cat >openssl.cnf <<EOL
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = $(echo -n "$my_hostname" | sed s/-[0-9]*$//)
DNS.2 = $my_hostname
DNS.3 = $service_name
DNS.4 = localhost
DNS.5 = 127.0.0.1
EOL

    # Generate the certs
    openssl genrsa -out mongo.key 2048
    openssl req -new -key mongo.key -out mongo.csr -subj "/CN=$my_hostname" -config openssl.cnf
    openssl x509 -req -in mongo.csr \
        -CA "$ca_crt" -CAkey "$ca_key" -CAcreateserial \
        -out mongo.crt -days 3650 -extensions v3_req -extfile openssl.cnf

    rm mongo.csr
    cat mongo.crt mongo.key > $pem
    rm mongo.key mongo.crt
fi


log "Peers: ${peers[*]}"

log "Starting a MongoDB instance..."
mongod --config /data/configdb/mongod.conf --dbpath=/data/db --replSet="$replica_set" --port=27017 "${auth_args[@]}" "${perf_args[@]}" --bind_ip=0.0.0.0 >> /home/mongodb/work-dir/log.txt 2>&1 &

log "Waiting for MongoDB to be ready..."
until mongo "${ssl_args[@]}" --eval "db.adminCommand('ping')"; do
    log "Retrying..."
    sleep 2
done

log "Initialized."

# try to find a master and add yourself to its replica set.
for peer in "${peers[@]}"; do
    if mongo admin --host "$peer" "${admin_creds[@]}" "${ssl_args[@]}" --eval "rs.isMaster()" | grep '"ismaster" : true'; then
        log "Found master: $peer"
        log "Adding myself ($service_name) to replica set..."
        OUTPUT=$(mongo admin --host "$peer" "${admin_creds[@]}" "${ssl_args[@]}" --eval "rs.add('$service_name')" 2>&1)
        EXIT_CODE=$?
        # Seen outputs:
        # Expected output:
        #    { "ok": 1 } 
        # Failed to add replica set --> fail and wait for init container restart for retry.
        # { "ok" : 0, "code": 74, "errmsg" : "Quorum check failed because not enough voting nodes responded; required 2 but only the following 1 voting nodes responded: ....
        #
        # Failed because already added --> ignore. This seems to be restart of this container and the replica set (pod) is already added
        # { "ok" : 0, "code": 103, "errmsg" : "Found two member configurations with same host field, members.1.host == members.2.host ...
        echo "${OUTPUT}" >>/home/mongodb/work-dir/log.txt
        
        if [ "_${EXIT_CODE}" != "_0" ] ||  echo "${OUTPUT}" | grep "Quorum check failed because not enough voting nodes responded" ; then
          log "Failed to add replica set. Exiting"
          exit 1
        fi
        
        sleep 3

        log 'Waiting for replica to reach SECONDARY state...'
        until printf '.'  && [[ $(mongo admin "${admin_creds[@]}" "${ssl_args[@]}" --quiet --eval "rs.status().myState") == '2' ]]; do
            sleep 1
        done

        log '✓ Replica reached SECONDARY state.'

        shutdown_mongo "60"
        log "Good bye."
        exit 0
    fi
done

# else initiate a replica set with yourself.
if mongo "${ssl_args[@]}" --eval "rs.status()" | grep "no replset config has been received"; then
    log "Initiating a new replica set with myself ($service_name)..."
    mongo "${ssl_args[@]}" --eval "rs.initiate({'_id': '$replica_set', 'members': [{'_id': 0, 'host': '$service_name'}]})"

    sleep 3

    log 'Waiting for replica to reach PRIMARY state...'
    until printf '.'  && [[ $(mongo "${ssl_args[@]}" --quiet --eval "rs.status().myState") == '1' ]]; do
        sleep 1
    done

    log '✓ Replica reached PRIMARY state.'

    if [[ "$AUTH" == "true" ]]; then
        log "Creating admin user..."
        mongo admin "${ssl_args[@]}" --eval "db.createUser({user: '$admin_user', pwd: '$admin_password', roles: [ 'root' ]})"
        if [[ "$METRICS" == "true" ]]; then
            log "Creating cluterMonitor user..."
            mongo admin "${ssl_args[@]}" --eval "db.auth('$admin_user', '$admin_password'); db.createUser({user: '$metrics_user', pwd: '$metrics_password', roles: [{role: 'clusterMonitor', db: 'admin'}, {role: 'read', db: 'local'}]})"
        fi
    fi

    log "Done."
fi

shutdown_mongo
log "Good bye."
