# This script assumes following tools are installed. The tools should be included in path and should be accessible.
# Helm > 2.9.0
# cv linter
# cloudctl CLI

set -euo pipefail

function show_help() {
  local exit_status="$1"
cat << _EOF
Usage: $0 [options]

Runs through the steps to deploy Sentiment services into ICP cluster.

Options:
  -h, --help              Displays this help message
  -c, --chart-dir         The path to the chart directory
  --dry-run               Run '$0' in dry-run mode, packages charts but does not deploy
  -R, --release-name      The ICP install release name. Defaults to nlu-test
  -n, --namespace         The ICP cluster namespace.  Defaults to nluicp
  --icp.cluster           The cluster name/ip (ex. 9.42.75.241)
  --icp.user              The user to login to the cluster
  --icp.password          The users password (base64 encoded)
  --artifactory.user      A user with read access to the artifactory repository.
  --artifactory.apikey    The apikey for artifactory.user.
  --load-chart            Build a PPA and load-archive to the cluster
  --cluster.image.repo    The helm cluster image repo (optional - defaults to "mycluster.icp:8500")
  --icp.account.name      The account on the ICP cluster (optional - defaults to "id-mycluster-account")

_EOF
    exit "$exit_status"
}

function validate_args() {
  local failed="f"

  [ -z "$CHART_DIR" ] && echo "'config-repo' must be set!" && failed="t"

  if [[ ! -d "$CHART_DIR" ]]; then
    echo "$CHART_DIR does not exist, is not a directory, or does not contain the correct configuration!"
    failed="t"
  fi

  if [[ "$failed" == "t" ]]; then
    # Exits
    show_help 1
  fi
}

CLUSTER_NAMESPACE="default"
RELEASE_NAME="sentiment-test"
CHART_DIR=""
DRY_RUN="f"
LOAD_CHART="f"

ICP_CLUSTER=""
ICP_USER=""
ICP_PASSWORD=""
ARTIFACTORY_USER=""
ARTIFACTORY_APIKEY=""
CLUSTER_IMAGE_REPO="mycluster.icp:8500"
ICP_ACCOUNT_NAME="id-mycluster-account"

if [[ "$#" -eq 0 ]]; then
  show_help 0
fi

while (( $# > 0 )); do
  case "$1" in
    -h|--help)
      show_help 0;;
    -c|--chart-dir)
      shift; CHART_DIR="$1";;
    --dry-run)
      DRY_RUN="t";;
    --load-chart)
      LOAD_CHART="t";;
    -R|--release-name)
      shift; RELEASE_NAME="$1";;
    -n|--namespace)
      shift; CLUSTER_NAMESPACE="$1";;
    --load-chart)
      LOAD_PPA="t";;
    --icp.cluster)
      shift; ICP_CLUSTER="$1";;
    --icp.user)
      shift; ICP_USER="$1";;
    --icp.password)
      shift; ICP_PASSWORD="$1";;
    --artifactory.user)
      shift; ARTIFACTORY_USER="$1";;
    --artifactory.apikey)
      shift; ARTIFACTORY_APIKEY="$1";;
    --cluster.image.repo)
      shift; CLUSTER_IMAGE_REPO="$1";;
    --icp.account.name)
      shift; ICP_ACCOUNT_NAME="$1";;
    *)
      echo "Unknown argument: $1" 1>&2
      exit 1
      ;;
  esac
  shift
done

validate_args

echo "Run Helm dependency update"

helm repo add sch \
  https://na.artifactory.swg-devops.com/artifactory/hyc-icpcontent-helm-virtual/ \
  --username "$ARTIFACTORY_USER" --password "$ARTIFACTORY_APIKEY"

helm dependency update "${CHART_DIR}"

echo "Run content verifier (cv lint)...."
#cv lint "${CHART_DIR}"

echo "Package helm chart"
mkdir -p "${CHART_DIR}/stable"
helm package -d "${CHART_DIR}/stable" "${CHART_DIR}"

CHART_NAME=$(ls ${CHART_DIR}/stable | tail -n 1 )

echo "Login to cluster"
cloudctl login -a https://$ICP_CLUSTER:8443 -u $ICP_USER -p $(base64 --decode <<< ${ICP_PASSWORD}) -c $ICP_ACCOUNT_NAME -n $CLUSTER_NAMESPACE --skip-ssl-validation

if [[ "$DRY_RUN" == "t" ]]; then
  helm install "${CHART_DIR}/stable/$CHART_NAME" --name $RELEASE_NAME --namespace $CLUSTER_NAMESPACE --set global.icpDockerRepo=$CLUSTER_IMAGE_REPO --tls --dry-run
  echo "In dry-run mode. Would have installed to ICP here."
  echo "ICP run complete. You can view the packaged output here: ${CHART_DIR}/stable"
  exit 0
fi

echo "Load chart to the cluster"
cloudctl catalog load-chart --archive "${CHART_DIR}/stable/$CHART_NAME"

echo "Install chart to cluster"
if [[ "$LOAD_CHART" == "t" ]]; then
  echo "Installing release to cluster"
  helm install "${CHART_DIR}/stable/$CHART_NAME" --name $RELEASE_NAME --namespace $CLUSTER_NAMESPACE --set global.icpDockerRepo=$CLUSTER_IMAGE_REPO/${CLUSTER_NAMESPACE}/ --tls
fi
