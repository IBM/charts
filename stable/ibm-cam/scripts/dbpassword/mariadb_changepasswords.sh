#!/bin/bash
#
# This script will change the root and user passwords
#
date
echo "mariadb_changepasswords.sh starting"

PASSWORD_NEW=$1

# Current info (MYSQL_USER, MYSQL_PASSWORDK, MYSQL_ROOT_PASSWORD) should already be set as env vars in the container
if [ -z "${MYSQL_USER}" ] || [ -z "${MYSQL_PASSWORD}" ] || [ -z "${MYSQL_ROOT_PASSWORD}" ] || [ -z "${PASSWORD_NEW}" ]; then
  echo "MariaDB - Error, no password change, possibly new password is not passed in."
  exit 1
fi

echo "Changing passwords for mariadb users..."

# Change root password
mysqladmin -u root -p$MYSQL_ROOT_PASSWORD password $PASSWORD_NEW

if [ $? -ne 0 ]; then
    echo "Unable to change mariadb root password, exiting with ERROR"
    exit -1
fi
echo "Successfully changed mariadb root password"

# Change user password
mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -e "set password=password('${PASSWORD_NEW}');"

if [ $? -ne 0 ]; then
    echo "Unable to change mariadb user password, exiting with ERROR"
    exit -1
fi
echo "Successfully changed mariadb user password"

echo "MariaDB password changes all successful"
exit 0