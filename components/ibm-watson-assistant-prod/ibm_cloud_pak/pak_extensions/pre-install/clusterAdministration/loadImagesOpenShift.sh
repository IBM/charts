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
# Usage: loadImagesOpenShift.sh --namespace NAMESPACE [--path PATH] [--registry REGISTRY] [--help]
#
#################################################################

set -o nounset
set +e
#set -x

# The location on each node to store the actual PV data
ARCHIVE_PATH="."

# The OpenShift namespace (project) to add to the docker url 
NAMESPACE=""

# The OpenShift docker registry url
REGISTRY="docker-registry.default.svc:5000"

CONTAINER_ENGINE=docker
# Directory to store temporary files
tmp="/tmp"
#################################################################
# End of variables
#################################################################

function die() {
  echo "$@" 1>&2

  exit 99
}

function showHelp() {
  echo "Usage loadImagesOpenShift.sh --namespace NAMESPACE [--path PATH] [--registry REGISTRY] [--tmp DIR] [--help]"
  echo ""
  echo "--namespace: You must provide a namespace."
  echo "--container-engine: The container engine to use for image loading and pushing. Default to docker. Supported values are docker or podman (for cri-o)"
  echo "--path: Defaults to current dir. You can optionally provide the path to the extracted PPA archive."
  echo "--registry: Defaults to docker-registry.default.svc:5000. You can optionally provide an alternative docker url."
  echo "--tmp: The tmp dir to use. Defaults to /tmp"
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
    -t | --tmp )
      if [[ $2 == -* ]] || [[ $2 == "" ]]; then
        die "ERROR: You must specify a directory"
      fi
      shift
      tmp="$1"
      ;;
    --cli | --container-engine )
      if [[ $2 == -* ]] || [[ $2 == "" ]]; then
        die "ERROR: You must specify the container engine used to load images into OpenShift internal registries. Specify either docker or podman"
      fi
      shift
      CONTAINER_ENGINE="$1"
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
  showHelp
  echo ""
  die "ERROR: images directory $ARCHIVE_PATH/images doesn't exist. Please make sure the --path argument points to the extracted PPA archive top level directory."
fi

if [ ! -d $tmp ]; then
  showHelp
  echo ""
  echo "ERROR: Dir $tmp doesn't exist. You must specify an existing dir."
fi

#Use a unique dir beneath $tmp
tmp="${tmp}/$(basename "$0").$(date +%s)"
mkdir -p $tmp

#################################
# Process image one by one 
#################################
for IMG in "$ARCHIVE_PATH/images/"* ; do
  fileName="${IMG##*/}"
  echo
  echo
  echo "Processing ${fileName} (loading image from file)"
  #################################
  # Upload image(s) to local registry 
  #################################
  echo -n "" >$tmp/load_${fileName}.txt
  set +e
  ${CONTAINER_ENGINE} load -i $IMG >> $tmp/load_${fileName}.txt
  rc=$?; [[ $rc != 0 ]] && die "ERROR: ${CONTAINER_ENGINE} load -i $IMG failed"

  #################################
  # Create a script to tag and push
  # the images to OpenShift 
  ################################
  set -e # Fail if any of the commands below fails, especially if generated docker_commands.sh script fails. 
  echo "set -e" > $tmp/push_${fileName}.sh
  for img in `awk -F ':' ' {print $2":"$3} ' $tmp/load_${fileName}.txt`
  do
    # Remove the localhost prefix from podman
    source="${img##localhost/}"
    #Remove everything but the image name
    target=${img##*/}
    echo "echo 'Processing $target (pushing as \"$REGISTRY/$NAMESPACE/$target\")'" >>$tmp/push_${fileName}.sh
    echo "${CONTAINER_ENGINE} tag $source $REGISTRY/$NAMESPACE/$target" >>$tmp/push_${fileName}.sh
    if [ ${CONTAINER_ENGINE} == 'podman' ] ;
    then
      echo "${CONTAINER_ENGINE} push $REGISTRY/$NAMESPACE/$target --tls-verify=false" >>$tmp/push_${fileName}.sh
    else
      echo "${CONTAINER_ENGINE} push $REGISTRY/$NAMESPACE/$target" >>$tmp/push_${fileName}.sh
    fi
  done

  #########################
  # Run the docker commands
  #########################
  chmod ugo+x $tmp/push_${fileName}.sh
  $tmp/push_${fileName}.sh
done

rm -fr $tmp
