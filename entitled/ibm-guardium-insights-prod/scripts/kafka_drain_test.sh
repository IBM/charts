#!/bin/bash

#################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2020. All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################

while [[ $# -gt 0 ]]; do
  case $1 in
    -n)
      RELEASE_NAME="$2"
      echo "The RELEASE_NAME is $2"
      shift 2
      ;;
    -v)
      VERBOSE="true"
      echo "Running with verbose output."
      shift 1
      ;;
    ?)
      echo '-invalid option-'
      exit 1
      ;;
  esac
done

if [ ! "$RELEASE_NAME" ]
then
    echo "Mandatory command line options are not provided
    -n      RELEASE_NAME
    e.g     ./$(basename "$0") -n insights"
    echo "You can also run with verbose output to see all topic statistics
    e.g.    ./$(basename "$0") -n insights -v"
    exit 1
fi

set -e

port=`oc get po -o yaml $RELEASE_NAME-kafka-0 | grep containerPort | awk '{print $3}'`
TMP=`mktemp`

FOUND=1
MAX_ATTEMPT=5
CURRENT_ATTEMPT=0
while [[ "X$FOUND" == "X1" ]]; do
FOUND=0
rm $TMP
echo ""
echo "Capturing topics"
oc exec -i $RELEASE_NAME-kafka-0 -- /bin/bash -c "/opt/bitnami/kafka/bin/kafka-consumer-groups.sh --bootstrap-server localhost:$port --describe --all-groups" >> $TMP

#Search for the lag, it should either be - or 0
echo "Checking for Lag"
while read line; do
if [[ -n $(echo $line | grep "GROUP") ]]; then continue; fi
if [[ -z $line ]]; then continue; fi
if [[ "X"`echo $line | awk '{print $6}'` != 'X-' ]] && [[ "X"`echo $line | awk '{print $6}'` != 'X0' ]]; then
echo "Consumer Group " `echo $line | awk '{print $1}'` " - Topic " `echo $line | awk '{print $2}'` "lag is gt than 0:";
echo $line | awk '{print $6}'
FOUND=1;
# Print all findings if verbose output enabled, else only print errors
elif [[ "$VERBOSE" == "true" ]]; then
  echo "Consumer Group " `echo $line | awk '{print $1}'` " - Topic " `echo $line | awk '{print $2}'` " lag is 0"
fi;
done < $TMP
if [[ "X$FOUND" == "X1" ]]; then
  CURRENT_ATTEMPT=$(( $CURRENT_ATTEMPT + 1 ))
  echo "System is not drained"
  if [[ $CURRENT_ATTEMPT -ge $MAX_ATTEMPT ]]; then
    echo "Maximum attempts ($MAX_ATTEMPT) have elapsed, stopping now."
    break
  else
    echo "Sleeping 10 seconds"
    sleep 10
  fi
else
  echo "Kafka system is drained"
fi
done
