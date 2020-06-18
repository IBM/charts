#!/bin/bash

echo "$mongo_cert" > /tmp/mongo_cert.crt
set +e
echo "Checking MongoDB connection"
until mongo --ssl --sslAllowInvalidCertificates --sslCAFile=/tmp/mongo_cert.crt --authenticationDatabase=admin "$mongo_url" --eval "rs.slaveOk();print(\"waited for connection\")"
do
  echo "Waiting until MongoDB is available"
  sleep 60
done
set -e
echo "MongoDB appears to be up"
rm -f /tmp/mongo_cert.crt

exit 0
