#!/bin/bash

DOCKER_REGISTRY=""
NAMESPACE=speech-services
ARCHIVE_PATH=""

function die() {
    echo "$@" 1>&2
    exit 99
}

function help() {
    echo "$(basename $0)"
    echo "  -n, --namespace                ... namespace for installing release [speech-services]"
    echo "  -p, --path                     ... path to the extracted ppa archive [.]"
    echo "  -r, --registry                 ... OpenShift docker registry"
    echo "  -h, --help                     ... show this help"
}

while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        -n|--namespace)
            NAMESPACE=$2; shift 2 ;;
        -p|--path)
            ARCHIVE_PATH=$2; shift 2 ;;
        -r|--registry)
            DOCKER_REGISTRY=$2; shift 2 ;;
        -h|--help)
            help; exit 0;;
        *)
            echo Unknown option $key.; help; exit 1; shift;;
    esac
done

# parameter checks

if [ "$DOCKER_REGISTRY" == "" ]; then
    help
    echo ""
    die "ERROR: please specify a namespace"
fi

if [ "$ARCHIVE_PATH" == "" ]; then
    help
    echo ""
    die "ERROR: please specify a path to the PPA archive"
fi

if [ ! -d "$ARCHIVE_PATH/images" ]; then
    die "ERROR: images directory $ARCHIVE_PATH/images doesn't exist. Please make sure the --path argument points to the top level directory of the extracted PPA archive"
fi

# iterate over the list of images within the manifest and push them to the Openshift docker registry
manifest=`cat ${ARCHIVE_PATH}/manifest.json`
for row in $(echo "${manifest}" | jq -r '.images[] | @base64'); do
    _jq() {
     echo ${row} | base64 --decode | jq -r ${1}
    }

   image=$(_jq '.image')
   tag=$(_jq '.tag')
   archive=$(_jq '.archive')

   # upload the image to local registry
   docker load -i $ARCHIVE_PATH/$archive
   image_simple="${image##*/}"   # remove everything before the image name
   target_image=${DOCKER_REGISTRY}/${NAMESPACE}/${image_simple}:${tag}
   docker tag ${image}:${tag} $target_image
   docker push $target_image

done
