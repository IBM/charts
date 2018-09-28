#!/bin/bash
#
# This script will change the admin and camuser passwords
#
date
echo "mongodb_changepasswords.sh starting"

MONGODB_PASSWORD_NEW=$1

# Current info (MONGO_INITDB_ROOT_USERNAME, MONGO_INITDB_ROOT_PASSWORD) should already be set as env vars in the container
if [ -z "${MONGO_INITDB_ROOT_USERNAME}" ] || [ -z "${MONGO_INITDB_ROOT_PASSWORD}" ] || [ -z "${MONGODB_PASSWORD_NEW}" ]; then
  echo "MongoDB - Error, no password change, possibly new password is not passed in."
  exit 1
fi

echo "Changing passwords for mongo users..."

# Set defaults if other vars are not set
MONGODB_DATABASE=${MONGODB_DATABASE:-cam}
MONGODB_USERNAME=${MONGODB_USERNAME:-camuser}
MONGODB_PASSWORD=${MONGODB_PASSWORD:-$MONGO_INITDB_ROOT_PASSWORD}

# Change admin password
mongo admin --host localhost -u $MONGO_INITDB_ROOT_USERNAME -p $MONGO_INITDB_ROOT_PASSWORD --eval "db.changeUserPassword('$MONGO_INITDB_ROOT_USERNAME', '$MONGODB_PASSWORD_NEW');"

if [ $? -ne 0 ]; then
  echo "Unable to change admin password, exiting with ERROR"
  exit 1
fi
echo "MongoDB - Successfully changed admin password"

# Change cam user password
mongo admin --host localhost -u $MONGO_INITDB_ROOT_USERNAME -p $MONGODB_PASSWORD_NEW --eval "db=db.getSiblingDB('$MONGODB_DATABASE');db.changeUserPassword('$MONGODB_USERNAME', '$MONGODB_PASSWORD_NEW');"

if [ $? -ne 0 ]; then
  echo "MongoDB - Unable to change cam user password, exiting with ERROR"
  exit 1
fi
echo "MongoDB - Successfully changed cam user password"

echo "MongoDB - Password changes all successful"
exit 0
