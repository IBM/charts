#!/usr/bin/env bash

scriptName=$(basename $0)
scriptDir="$( cd "$( dirname "$0" )" && pwd )"

NAMESPACE="default"

usage() {
    echo "Usage:"
    echo "       $scriptName [--version | -v <CHART_VERSION>] [--release | -r <RELEASE_NAME>] [--namespace | -n <NAMESPACE>]"
    echo
    echo "       Render the monitoring dashboards, including Grafana metrics, Kibana logging and Prometheus alert rules"
    echo
    echo "  -v, --version CHART_VERSION      The chart version, e.g. 2.0.0"
    echo
    echo "  -h, --help                       print command help and exit"
    echo
    echo "  -r, --release RELEASE_NAME       The HELM release name"
    echo
    echo "  -n, --namespace NAMESPACE        The namespace of the deployment. Defaults to default."
    echo
}

# Parse the command line arguments
while [[ $# > 0 ]]
do
  key="$1"

  case $key in
    -h|--help)
        usage
        exit 0
    ;;
    -v|--version)
        VERSION="$2"
        shift
    ;;
    -r|--release)
        # Lowercase the provided ENV
        RELEASE="$2"
        shift
    ;;
    -n|--namespace)
        NAMESPACE="$2"
        shift
    ;;
    -*)
        echo "unknown argument: $key"
        echo
        usage
        exit 1
    ;;
  esac
  shift
done

# ----- Required parameter checks -----
if [ -z "$VERSION" ]; then
  >&2 echo "ERROR: No chart version was provided. Please specify a chart version."
  >&2 echo
  usage
  exit 1
fi

if [ -z "$RELEASE" ]; then
  >&2 echo "ERROR: No release name was provided. Please specify a release name."
  >&2 echo
  usage
  exit 1
fi


for file in $scriptDir/*.tpl; do
  cat "$file" | sed "s#@@CHART_VERSION@@#$VERSION#g; \
                     s#@@RELEASE_NAME@@#$RELEASE#g; \
                     s#@@NAMESPACE@@#$NAMESPACE#g" > ${file%.tpl}
done

echo "The dashboard JSON files are generated under $scriptDir."