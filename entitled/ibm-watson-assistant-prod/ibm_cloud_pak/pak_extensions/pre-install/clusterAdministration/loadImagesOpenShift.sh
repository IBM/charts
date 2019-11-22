#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2019.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################
#
# This script can be used to load the images from a PPA archive
# into OpenShift.
#
# It is provided as is.
#
# It should be run from a machine that has successfully
# run a docker login command for the OpenShift docker registry. 
#
# Usage: loadImages.sh --namespace NAMESPACE [--path PATH] [--registry REGISTRY] [--help]
#
#################################################################

#################################################################
# You may wish to customise the script by changing these
# variables from their defaults
#################################################################
# The location on each node to store the actual PV data
ARCHIVE_PATH="."

# The OpenShift namespace (project) to add to the docker url 
NAMESPACE=""

# The OpenShift docker registry url
REGISTRY="docker-registry.default.svc:5000"

# Directory to store temporary files
tmpDir=/tmp/loadImages.$$
mkdir -vp $tmpDir
#################################################################
# End of variables
#################################################################

function die() {
  echo "$@" 1>&2

  exit 99
}

function showHelp() {
  echo "Usage loadImages.sh --namespace NAMESPACE [--path PATH] [--registry REGISTRY] [--help]"
  echo ""
  echo "--namespace: You must provide a namespace."
  echo "--path: Defaults to current dir. You can optionally provide the path to the extracted PPA archive."
  echo "--registry: Defaults to docker-registry.default.svc:5000. You can optionally provide an alternative docker url."
  echo "--help: Displays this help message."
}

while (( $# > 0 )); do
  case "$1" in
    -p | --p | --path )
      if [[ $2 == -* ]] || [[ $2 == "" ]]; then
        die "ERROR: Path argument has no value"
      fi
      shift
      ARCHIVE_PATH="$1"
      ;;
    -n | --n | --namespace )
      if [[ $2 == -* ]] || [[ $2 == "" ]]; then
        die "ERROR: Namespace argument has no value"
      fi
      shift
      NAMESPACE="$1"
      ;;
    -r | --r | --registry )
      if [[ $2 == -* ]] || [[ $2 == "" ]]; then
        die "ERROR: Registry argument has no value"
      fi
      shift
      REGISTRY="$1"
      ;;
    -h | --h | --help )
      showHelp
      exit 2
      ;;
    * | -* )
      echo "Unknown option: $1"
      exit 99
      ;;
  esac
  shift
done

#################################################################
# Start of main script
#
# Upload images to local docker registry
# Create tag / push script
# Execute the script
#################################################################

if [ "$NAMESPACE" == "" ]; then
  showHelp
  echo ""
  die "ERROR: please specify a namespace"
fi

if [ ! -d "$ARCHIVE_PATH/images" ]; then
  die "ERROR: images directory $ARCHIVE_PATH/images doesn't exist. Please make sure the --path argument points to the extracted PPA archive top level directory."
  rm -fr $tmpDir
fi

#################################
# Upload images to local registry 
#################################
docker load -i $ARCHIVE_PATH/images/all-images.tar.gz > $tmpDir/IMG_LOG.txt

#################################
# Create a script to tag and push
# the images to OpenShift 
#################################
for img in `awk -F ':' ' {print $2":"$3} ' $tmpDir/IMG_LOG.txt`
do
  source=$img
  #Remove everything but the image name
  target=${img##*/}
  echo "docker tag $source $REGISTRY/$NAMESPACE/$target" >> $tmpDir/docker_commands.sh
  echo "docker push $REGISTRY/$NAMESPACE/$target" >> $tmpDir/docker_commands.sh
done

#########################
# Run the docker commands
#########################
chmod o+x $tmpDir/docker_commands.sh
$tmpDir/docker_commands.sh

rm -fr $tmpDir
