#!/bin/bash
#
#Licensed Materials - Property of IBM
#5737-E67
#(C) Copyright IBM Corporation 2016, 2018 All Rights Reserved.
#US Government Users Restricted Rights - Use, duplication or
#disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#

usage() {
          echo "Usage: $0 [ -e ] [ -d ] [ -m ] [ -s ] [ -n ] [ -r ] [ -c ]" 1>&2;
          echo "  -e = new encryption password for CAM (Backup your mongodb prior to using this)" 1>&2;
          echo "  -d = new mongodb password for CAM (Backup your mongodb prior to using this - only applies to bundled mongodb)" 1>&2;
          echo "  -m = new mariadb password (Backup your mariadb prior to using this - only applies to bundled mariadb)" 1>&2;
          echo "  -s = name of CAM secret (default is cam-secure-values-secret)" 1>&2;
          echo "  -n = namespace for CAM (default is services)" 1>&2;
          echo "  -r = helm release name for CAM" 1>&2;
          echo "  -c = migration loop count to override the default timeout (count = 300 by default)" 1>&2;
          exit 1;
        }

while getopts ":e:d:m:s:n:r:c:" opt; do
  case ${opt} in
    e)
      NEW_ENCRYPTION_PASSWORD=$OPTARG
      ;;
    d)
      NEW_MONGODB_PASSWORD=$OPTARG
      ;;
    m)
      NEW_MARIADB_PASSWORD=$OPTARG
      ;;
    s)
      CAM_SECRET=$OPTARG
      ;;
    n)
      NAMESPACE=$OPTARG
      ;;
    r)
      HELM_RELEASE=$OPTARG
      ;;
    c)
      echo "-c was triggered! parameter is $OPTARG" >&2
      MONITOR_COUNT=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      exit 1
      ;;
    :)
      echo "Invalid Option: -$OPTARG requires an argument" 1>&2
      usage
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))


CHANGE_ENCRYPTION=false
if [ -n "$NEW_ENCRYPTION_PASSWORD" ]; then
  CHANGE_ENCRYPTION=true
fi

CHANGE_MONGODB=false
if [ -n "$NEW_MONGODB_PASSWORD" ]; then
  CHANGE_MONGODB=true
fi

CHANGE_MARIADB=false
if [ -n "$NEW_MARIADB_PASSWORD" ]; then
  CHANGE_MARIADB=true
fi

CAM_SECRET=${CAM_SECRET:-cam-secure-values-secret}

NAMESPACE=${NAMESPACE:-services}

MONITOR_COUNT=${MONITOR_COUNT:-300} # Default to 300 if not specified with -c.  300 x ~10 seconds = 50 mins before timeout



#
# Constants
#
MIGRATION_SECRET=cam-cipher-migration-secret

DEPLOYMENT_IAAS=cam-iaas
DEPLOYMENT_PT=cam-provider-terraform
DEPLOYMENT_MONGODB=cam-mongo
DEPLOYMENT_MARIADB=cam-bpd-mariadb
DEPLOYMENT_REDIS=redis


#
# Validations
#
# Check that the cam secret exists
kubectl -n $NAMESPACE get secret $CAM_SECRET
if [ $? -ne 0 ]; then
  echo "Unable to find CAM secret: $CAM_SECRET in namespace $NAMESPACE, unable to perform password migration."
  usage
  exit 1
fi


# Check for numeric value for MONITOR_COUNT
if [ "$MONITOR_COUNT" -eq "$MONITOR_COUNT" ]; then
  echo ""
else
  echo "-c must be an int value"
  usage
  exit 1
fi


base64 --version > /dev/null
if [ $? -ne 0 ]; then
  echo "Error, base64 utility is not available, unable to run password migration."
  exit 1;
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ $HELM_RELEASE ]; then
  foundCam=$(helm list $HELM_RELEASE --tls | grep ibm-cam )
  if [ -n "$foundCam" ]; then
    camRelease=$HELM_RELEASE
  else
    echo "Error: Specified helm release is not found, or is not a CAM release"
    usage
    exit 1
  fi
else
  camRelease=$(helm list --tls | grep ibm-cam | awk '{ print $1 }')
fi

if [ -n "$camRelease" ]; then
  echo ""
  echo "Starting password migration for CAM release: $camRelease in namespace: $NAMESPACE ..."
  echo ""
else
  echo "Error: Unable to find CAM release"
  usage
  exit 1
fi


# Check if mongo, mariadb and redis are bundled or not
BUNDLED_MONGODB=true
BUNDLED_MARIADB=true
BUNDLED_REDIS=true

kubectl -n $NAMESPACE get deploy -l release=$camRelease -l name=$DEPLOYMENT_MONGODB | grep -q $DEPLOYMENT_MONGODB
if [ $? -ne 0 ]; then
  BUNDLED_MONGODB=false
fi
echo "MongoDB bundled: $BUNDLED_MONGODB"

kubectl -n $NAMESPACE get deploy -l release=$camRelease -l name=$DEPLOYMENT_MARIADB | grep -q $DEPLOYMENT_MARIADB
if [ $? -ne 0 ]; then
  BUNDLED_MARIADB=false
fi
echo "MariaDB bundled: $BUNDLED_MARIADB"

kubectl -n $NAMESPACE get deploy -l release=$camRelease -l name=$DEPLOYMENT_REDIS | grep -q $DEPLOYMENT_REDIS
if [ $? -ne 0 ]; then
  BUNDLED_REDIS=false
fi
echo "Redis bundled: $BUNDLED_REDIS"


#
# Figure out which parts we will do and display
#
echo ""
echo "##################################################"
echo "Password migration Steps to perform: "
echo ""
if [ "$CHANGE_ENCRYPTION" = true ]; then
  echo "Will perform encryption password change"
fi

if [ "$CHANGE_MONGODB" = true ]; then
  if [ "$BUNDLED_MONGODB" = true ]; then
    echo "Will perform mongodb password change"
  else
    # Only perform the change if mongodb was bundled
    CHANGE_MONGODB=false
    echo "Not performing mongodb password change as mongodb is external."
  fi
fi

if [ "$CHANGE_MARIADB" = true ]; then
  if [ "$BUNDLED_MARIADB" = true ]; then
    echo "Will perform mariadb password change"
  else
    # Only perform the change if mariadb was bundled
    CHANGE_MARIADB=false
    echo "Not performing mariadb password change as mariadb is external."
  fi
fi

if [ "$CHANGE_ENCRYPTION" = false ] && [ "$CHANGE_MONGODB" = false ] && [ "$CHANGE_MARIADB" = false ]; then
  echo ""
  echo "No passwords to change, exiting."
  usage
  exit 1
fi
echo "##################################################"
echo ""

#
# STOP CAM if it is running
#
CAMRUNNING_BEFOREMIGRATION=false

runningPods=$(kubectl -n $NAMESPACE get pod -l release=$camRelease -o name)
if [ -n "$runningPods" ]; then
  CAMRUNNING_BEFOREMIGRATION=true

  echo "CAM pods are running, stopping before starting password migration ..."

  # Stop CAM
  $DIR/stopCAM.sh $camRelease
  if [ "$?" -ne 0 ]; then
    echo "Error: unable to stop CAM"
    exit 1;
  fi
fi


#
# Save existing secrets before any migration
#
if [ "$CHANGE_ENCRYPTION" = true ]; then
  CURRENT_ENCRYPTION_SECRET_BASE64=$(kubectl -n $NAMESPACE get secret $CAM_SECRET -o yaml | grep "encryptionPassword:" | awk '{print $2}')
  if [ -z "$CURRENT_ENCRYPTION_SECRET_BASE64" ]; then
    echo "Error, unable to get current encryption secret before migration"
    exit 1
  fi
fi

if [ "$CHANGE_MONGODB" = true ]; then
  CURRENT_MONGODB_URL_BASE64=$(kubectl -n $NAMESPACE get secret $CAM_SECRET -o yaml | grep "mongoDbUrl:" | awk '{print $2}')
  if [ -z "$CURRENT_MONGODB_URL_BASE64" ]; then
    echo "Error, unable to get current mongoDbUrl before migration"
    exit 1
  fi
  CURRENT_MONGODB_PASSWORD_BASE64=$(kubectl -n $NAMESPACE get secret $CAM_SECRET -o yaml | grep "mongoDbPassword:" | awk '{print $2}')
  if [ -z "$CURRENT_MONGODB_PASSWORD_BASE64" ]; then
    echo "Error, unable to get current mongoDbPassword before migration"
    exit 1
  fi
fi

# secret will be set only if mariadb is bundled
if [ "$CHANGE_MARIADB" = true ]; then
  CURRENT_MARIADB_PASSWORD_BASE64=$(kubectl -n $NAMESPACE get secret $CAM_SECRET -o yaml | grep "mariaDbPassword:" | awk '{print $2}')
  if [ -z "$CURRENT_MARIADB_PASSWORD_BASE64" ]; then
    echo "Error, unable to get current mariaDbPassword before migration"
    exit 1
  fi
fi

migration_secret_rollback() {
  if [ "$CHANGE_ENCRYPTION" = true ]; then
    echo "Rolling back secret $MIGRATION_SECRET ..."
    kubectl -n $NAMESPACE patch secret $MIGRATION_SECRET -p "{\"data\": {\"newpassword\": \"\", \"timestampfile\": \"\"}}"
  fi
}

#
# Rollback if failure
#  - Rollback migration secret
#  - Stop CAM
rollback1() {
  migration_secret_rollback
  $DIR/stopCAM.sh $camRelease
}

secret_rollback() {
  if [ "$CHANGE_ENCRYPTION" = true ]; then
    echo "Rolling back secret encryptionPassword ..."
    kubectl -n $NAMESPACE patch secret $CAM_SECRET -p "{\"data\": {\"encryptionPassword\": \"$CURRENT_ENCRYPTION_SECRET_BASE64\"}}"
  fi

  if [ "$CHANGE_MONGODB" = true ]; then
    echo "Rolling back secret mongoDbUrl ..."
    kubectl -n $NAMESPACE patch secret $CAM_SECRET -p "{\"data\": {\"mongoDbUrl\": \"$CURRENT_MONGODB_URL_BASE64\", \"mongoDbPassword\": \"$CURRENT_MONGODB_PASSWORD_BASE64\"}}"
  fi

  if [ "$CHANGE_MARIADB" = true ]; then
    echo "Rolling back secret mariaDbPassword ..."
    kubectl -n $NAMESPACE patch secret $CAM_SECRET -p "{\"data\": {\"mariaDbPassword\": \"$CURRENT_MARIADB_PASSWORD_BASE64\"}}"
  fi
}

#
# Rollback if failure (after changing secrets to new password)
# - Rollback migration secret
# - Rollback other secrets too
# - Stop CAM
#
rollback2() {
  migration_secret_rollback
  secret_rollback
  $DIR/stopCAM.sh $camRelease
}


if [ "$CHANGE_ENCRYPTION" = true ]; then
  DATESTR=$(date +"%Y-%m-%d-%H-%M-%S")
  TIMESTAMPFILENAME="/var/camlog/cipherMigration-$DATESTR"
  echo "timestampfilename for cipher migration is $TIMESTAMPFILENAME"
  TIMESTAMPFILENAMEBASE64=$(echo -n "$TIMESTAMPFILENAME" | base64)

  NEW_ENCRYPTION_PASSWORD_BASE64=$(echo -n "$NEW_ENCRYPTION_PASSWORD" | base64)
  kubectl -n $NAMESPACE patch secret $MIGRATION_SECRET -p "{\"data\": {\"newpassword\": \"$NEW_ENCRYPTION_PASSWORD_BASE64\", \"timestampfile\": \"$TIMESTAMPFILENAMEBASE64\"}}"
  if [ $? -ne 0 ]; then
    echo "Error, unable to update secret before migration"
    exit 1
  fi

  # Need mongo up to run these migrations
  if [ "$BUNDLED_MONGODB" = true ]; then
    echo "Starting bundled mongo container ..."
    kubectl scale -n $NAMESPACE deployment $DEPLOYMENT_MONGODB --replicas=1
    if [ $? -ne 0 ]; then
      echo "Error, unable to start bundled mongo container before migration. Exiting."
      rollback1
      exit 1
    fi
    sleep 30
  fi

  # Need redis up to run these migrations
  if [ "$BUNDLED_REDIS" = true ]; then
    echo "Starting bundled redis container ..."
    kubectl scale -n $NAMESPACE deployment $DEPLOYMENT_REDIS --replicas=1
    if [ $? -ne 0 ]; then
      echo "Error, unable to start bundled redis container before migration. Exiting."
      rollback1
      exit 1
    fi
    sleep 20
  fi

  # start iaas to run cipher migration
  echo "Starting iaas container in cipher migration mode ..."
  kubectl scale -n $NAMESPACE deployment $DEPLOYMENT_IAAS --replicas=1

  # start p-t to run cipher migration
  echo "Starting provider-terraform in cipher migration mode ..."
  kubectl scale -n $NAMESPACE deployment $DEPLOYMENT_PT --replicas=1

  sleep 20

  # Get pod ids
  iaaspod=$(kubectl -n $NAMESPACE get pod -l release=$camRelease | grep $DEPLOYMENT_IAAS | awk '{print $1}')
  ptpod=$(kubectl -n $NAMESPACE get pod -l release=$camRelease | grep $DEPLOYMENT_PT | awk '{print $1}')

  if [ -z "$iaaspod" ] || [ -z "$ptpod" ]; then
    echo "Error, Unable to start iaas or provider-terraform in cipher migration mode. Exiting password migration."
    rollback1
    echo "Error, Password migration failed.  Restoring mongodb from a backup will be required."
    exit 1
  fi

  # Loop (with timeout) and use curl to check on ciphermigration status for p-t and iaas
  count=0
  iaasstatus="IN_PROGRESS"
  ptstatus="IN_PROGRESS"
  while [ "$count" -lt "$MONITOR_COUNT" ] && [ "$iaasstatus" = "IN_PROGRESS" -o "$ptstatus" = "IN_PROGRESS" ]; do
    count=$((count+1))
    sleep 10

    if [ "$iaasstatus" = "IN_PROGRESS" ]; then
      echo "Monitoring iaas migration ..."
      iaascheck=$(kubectl -n $NAMESPACE exec -ti $iaaspod -- curl -G http://localhost:4000/api/v1/ciphermigration)
      echo " IaaS - check: $iaascheck"
      case "$iaascheck" in
        *SUCCESS*)
          iaasstatus="SUCCESS"
          ;;
        *FAILED*)
          iaasstatus="FAILED"
          ;;
      esac
    fi

    if [ "$ptstatus" = "IN_PROGRESS" ]; then
      echo "Monitoring provider-terraform migration ..."
      ptcheck=$(kubectl -n $NAMESPACE exec -ti $ptpod -- curl -G http://localhost:7000/api/ciphermigration)
      echo " PT - check: $ptcheck"
      case "$ptcheck" in
        *SUCCESS*)
          ptstatus="SUCCESS"
          ;;
        *FAILED*)
          ptstatus="FAILED"
          ;;
      esac
    fi

    echo "iaas status is currently: $iaasstatus"
    echo "pt status is currently: $ptstatus"
  done

  if [ "$iaasstatus" != "SUCCESS" ] || [ "$ptstatus" != "SUCCESS" ]; then
    echo "Error, migration for iaas or provider-terraform failed or did not complete on time. Exiting password migration."
    rollback1
    echo "Error, Password migration failed or did not complete on time.  Restoring mongodb from a backup will be required."
    exit 1
  fi

  echo "Stopping pods after successful iaas and provider-terraform cipher migration ..."
  $DIR/stopCAM.sh $camRelease
  if [ "$?" -ne 0 ]; then
    echo "Error: unable to stop CAM"
    rollback1
    echo "Error during password migration.  Restoring mongodb from a backup will be required."
    exit 1;
  fi

  # Rollback migration secret so subsequent starts will not attempt to migrate
  migration_secret_rollback

  # Update secrets to the new password
  echo "Updating secret encryptionPassword to new password..."
  kubectl -n $NAMESPACE patch secret $CAM_SECRET -p "{\"data\": {\"encryptionPassword\": \"$NEW_ENCRYPTION_PASSWORD_BASE64\"}}"
  if [ $? -ne 0 ]; then
    echo "Unable to update encryptionPassword new password, exiting"
    rollback1
    echo "Error, Password migration failed.  Restoring mongodb (and mariadb if bundled) from a backup will be required."
    exit 1
  fi
  echo "Secret encryptionPassword successfully updated"
fi


#
# migrate mongodb passwords - need to start mongodb pod
#
if [ "$CHANGE_MONGODB" = true ]; then
  echo "Starting mongodb container before changing passwords ..."
  kubectl scale -n $NAMESPACE deployment $DEPLOYMENT_MONGODB --replicas=1
  sleep 10

  mongodbpod=$(kubectl -n $NAMESPACE get pod -l release=$camRelease | grep $DEPLOYMENT_MONGODB | awk '{print $1}')

  if [ -z "$mongodbpod" ]; then
    echo "Error, Unable to start mongodb pod to change password. Exiting password migration."
    rollback1
    echo "Error, Password migration failed.  Restoring mongodb from a backup will be required."
    exit 1
  fi
fi

#
# migrate mariadb passwords - need to start mariadb pod
#
if [ "$CHANGE_MARIADB" = true ]; then
  echo "Starting mariadb container before changing passwords ..."
  kubectl scale -n $NAMESPACE deployment $DEPLOYMENT_MARIADB --replicas=1
  sleep 10

  mariadbpod=$(kubectl -n $NAMESPACE get pod -l release=$camRelease | grep $DEPLOYMENT_MARIADB | awk '{print $1}')

  if [ -z "$mariadbpod" ]; then
    echo "Error, Unable to start mariadb pod to change password. Exiting password migration."
    rollback1
    echo "Error, Password migration failed.  Restoring mongodb from a backup will be required if encryption pwd was changed."
    exit 1
  fi
fi

if [ "$CHANGE_MONGODB" = true ] || [ "$CHANGE_MARIADB" = true ]; then
  # wait for the pods we started to come up
  pods=$(kubectl -n $NAMESPACE get -l release=$camRelease pods --no-headers | grep Running -v)
  while [ "${pods}" ]; do
    echo "Waiting for db pod(s) to be in Running state"
    kubectl -n $NAMESPACE get -l release=$camRelease pod
    sleep 5
    pods=$(kubectl -n $NAMESPACE get -l release=$camRelease pods --no-headers | grep Running -v)
  done
  echo "db pod(s) for migration Running"
fi

if [ "$CHANGE_MONGODB" = true ]; then
  echo "Changing passwords of mongodb ..."
  kubectl -n $NAMESPACE cp dbpassword/mongodb_changepasswords.sh $mongodbpod:/tmp/mongodb_changepasswords.sh
  kubectl -n $NAMESPACE exec -ti $mongodbpod /tmp/mongodb_changepasswords.sh $NEW_MONGODB_PASSWORD
  if [ $? -ne 0 ]; then
    echo "Error, unable to change mongodb passwords, exiting"
    rollback1
    echo "Error, Password migration failed.  Restoring mongodb from a backup will be required."
    exit 1
  fi

  echo "Updating secret mongoDbUrl and mongoDbPassword ..."
  NEW_MONGODB_PASSWORD_BASE64=$(echo -n "$NEW_MONGODB_PASSWORD" | base64)
  NEW_MONGODB_URL_BASE64=$(echo -n "mongodb://camuser:$NEW_MONGODB_PASSWORD@cam-mongo:27017/cam" | base64)
  kubectl -n $NAMESPACE patch secret $CAM_SECRET -p "{\"data\": {\"mongoDbUrl\": \"$NEW_MONGODB_URL_BASE64\", \"mongoDbPassword\": \"$NEW_MONGODB_PASSWORD_BASE64\"}}"
  if [ $? -ne 0 ]; then
    echo "Unable to update mongoDbUrl or mongoDbPassword to new password, exiting"
    rollback2
    echo "Error, Password migration failed.  Restoring mongodb from a backup will be required."
    exit 1
  fi
  echo "Secrets mongoDbUrl and mongoDbPassword successfully updated"
fi

if [ "$CHANGE_MARIADB" = true ]; then
  echo "Changing passwords of mariadb ..."
  kubectl -n $NAMESPACE cp dbpassword/mariadb_changepasswords.sh $mariadbpod:/tmp/mariadb_changepasswords.sh
  kubectl -n $NAMESPACE exec -ti $mariadbpod /tmp/mariadb_changepasswords.sh $NEW_MARIADB_PASSWORD
  if [ $? -ne 0 ]; then
    echo "Error, unable to change mariadb passwords, exiting"
    rollback2
    echo "Error, Password migration failed.  Restoring mariadb (and mongodb if encryption or mongo password was changed) from a backup will be required."
    exit 1
  fi

  echo "Updating secret mariaDbPassword ..."
  NEW_MARIADB_PASSWORD_BASE64=$(echo -n "$NEW_MARIADB_PASSWORD" | base64)
  kubectl -n $NAMESPACE patch secret $CAM_SECRET -p "{\"data\": {\"mariaDbPassword\": \"$NEW_MARIADB_PASSWORD_BASE64\"}}"
  if [ $? -ne 0 ]; then
    echo "Unable to update mariaDbPassword to new password, exiting"
    rollback2
    echo "Error, Password migration failed.  Restoring mariadb (and mongodb if encryption or mongo password was changed) from a backup will be required."
    exit 1
  fi
  echo "Secret mariaDbPassword successfully updated"
fi

if [ "$CHANGE_MONGODB" = true ] || [ "$CHANGE_MARIADB" = true ]; then
  echo "Stopping db pod(s) after successful migration"
  $DIR/stopCAM.sh $camRelease
fi


if [ "$CAMRUNNING_BEFOREMIGRATION" = true ]; then
  echo "Starting CAM after successful password migration"
  $DIR/startCAM.sh $camRelease
fi

echo "Password migration completed successfully."
exit 0
