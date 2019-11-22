# This script will promote chart tgz to stable artifactory repo from incubator artifactory repo.
set -euo pipefail

function show_help() {
  local exit_status="$1"
cat << _EOF
Usage: $0 [options]

Runs through the steps to deploy Sentiment services into ICP cluster.

Options:
  -h, --help              Displays this help message
  -c, --chart-dir         The absolute path to the chart directory
  --artifactory.user      A user with write access to the artifactory repository.
  --artifactory.apikey    The bapikey for artifactory.user.
  --chart-tgz             Chart tgz file name

_EOF
    exit "$exit_status"
}

ARTIFACTORY_USER=""
ARTIFACTORY_APIKEY=""
CHART_TGZ_FILENAME=""

if [[ "$#" -eq 0 ]]; then
  show_help 0
fi

while (( $# > 0 )); do
  case "$1" in
    -h|--help)
      show_help 0;;
    -c|--chart-tgz)
      shift; CHART_TGZ_FILENAME="$1";;
    --artifactory.user)
      shift; ARTIFACTORY_USER="$1";;
    --artifactory.apikey)
      shift; ARTIFACTORY_APIKEY="$1";;
    *)
      echo "Unknown argument: $1" 1>&2
      exit 1
      ;;
  esac
  shift
done

if [[ ! -z "${CHART_TGZ_FILENAME}" ]]; then
  echo "Download Helm chart from incubator Artifactory...."
  curl -H X-JFrog-Art-Api:"${ARTIFACTORY_APIKEY}" -o "${CHART_TGZ_FILENAME}" "https://na.artifactory.swg-devops.com/artifactory/wcp-watson-core-incubator-helm-local/${CHART_TGZ_FILENAME}"

  echo "Upload Helm chart to stable Artifactory...."
  curl -H X-JFrog-Art-Api:"${ARTIFACTORY_APIKEY}" -T "${CHART_TGZ_FILENAME}" "https://na.artifactory.swg-devops.com/artifactory/wcp-watson-core-stable-helm-local/${CHART_TGZ_FILENAME}"
else
  echo "No CHART_TGZ_FILENAME provided, so skipping the promotion."
fi
