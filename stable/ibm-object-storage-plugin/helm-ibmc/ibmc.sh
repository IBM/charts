#!/bin/bash
set -e

# Indicates whether chart is tar archive or pulled from repo
flag=0

CHARTNAME=""
RELEASE_NAME=""

usage() {
cat << EOF
Install or upgrade Helm charts in IBM K8S Service

Available Commands:
    helm ibmc install [CHART] [flags]              Install a Helm chart
    helm ibmc upgrade [RELEASE] [CHART] [flags]    Upgrades the release to a new version of the Helm chart

Available Flags:
    --verbos                      (Optional) Verbosity intensifies...
    -f, --values valueFiles       (Optional) specify values in a YAML file (can specify multiple) (default [])
    -h, --help                    (Optional) This text.
    -u, --update                  (Optional) Update this plugin to the latest version

Example Usage:
    helm ibmc install iks-charts/ibm-object-storage-plugin --name ibm-object-storage-plugin
EOF
}

# Create the passthru array
PASSTHRU=()
#Create flags array
FLAGS=()

while [[ $# -gt 0 ]]
do
    key="$1"

    # Parse arguments
   case $key in
        -h|--help)
        HELP="TRUE"
        ;;

        --verbos)
        DEBUG="TRUE"
        ;;

        -u|--update)
        UPDATE="TRUE"
        ;;

        "-"*)
        if [[ $# -gt 1 ]] && [[ "$2" != "-"* ]]; then
           FLAGS+=("$1" "$2")
           shift
        else
          FLAGS+=("$1")
        fi
        ;;

        *)       # Command(install/upgrade), release name(only for upgrade) and chart name
        PASSTHRU+=("$1")
        ;;
   esac
   shift  # past argument
done

# Restore PASSTHRU parameters
set -- "${PASSTHRU[@]}"
# Restore FLAG parameters
set -- "${FLAGS[@]}"

PLUGIN_LOCATION=$(ls -l $HELM_PLUGIN_DIR | awk -F ' -> ' '{print $2}')
if [[ "$PLUGIN_LOCATION" != "$HELM_HOME/cache/plugins/helm-ibmc" ]]; then
  if [ ! -d "$HELM_HOME/cache/plugins/" ]; then
    mkdir -p $HELM_HOME/cache/plugins/
  fi
  cp -r $PLUGIN_LOCATION $HELM_HOME/cache/plugins/
  #Delete existing symlink
  rm -rf $HELM_PLUGIN_DIR
  #Create new symlink
  ln -s $HELM_HOME/cache/plugins/helm-ibmc $HELM_PLUGIN_DIR
fi

# Show help if flagged
if [ "$HELP" == "TRUE" ]; then
    usage
    exit 0
fi

#  Update this Helm plugin
if [ "$UPDATE" == "TRUE" ]; then
    if [ ! -d "$HELM_HOME/cache/plugins/" ]; then
      mkdir -p $HELM_HOME/cache/plugins/
    fi
    cd $HELM_HOME/cache/plugins
    
    # Pull latest chart for upgrading ibmc helm plugin
    helm repo add ibmc-upgrade https://registry.bluemix.net/helm/iks-charts
    helm repo update
    helm fetch --untar ibmc-upgrade/ibm-object-storage-plugin
    helm repo remove ibmc-upgrade
    
    cp -r $HELM_HOME/cache/plugins/ibm-object-storage-plugin/helm-ibmc $HELM_HOME/cache/plugins/
    rm -rf $HELM_HOME/cache/plugins/ibm-object-storage-plugin
    PLUGIN_LOCATION=$(ls -l $HELM_PLUGIN_DIR | awk -F ' -> ' '{print $2}')
    if [[ "$PLUGIN_LOCATION" != "$HELM_HOME/cache/plugins/helm-ibmc" ]]; then
      rm -rf $HELM_PLUGIN_DIR
      ln -s $HELM_HOME/cache/plugins/helm-ibmc $HELM_PLUGIN_DIR
    fi
    PLUGIN_VERSION=$(helm plugin list | grep ibmc | awk '{print $2}')
    echo "Success! Updated this plugin to: $PLUGIN_VERSION"
    exit 0
fi

# Print params for debugging
if [ "$DEBUG" == "TRUE" ]; then
    echo "PARAMS";
    echo $*;
    echo " ......................... ";
    echo Helm kubeconfig = "$KUBECONFIG";
    echo Helm home       = "$HELM_HOME";
    echo Helm plugin     = "$HELM_PLUGIN";
    echo Helm plugin dir = "$HELM_PLUGIN_DIR";
    echo PASSTHRU        = "${PASSTHRU[@]}";
    if [[ "${#FLAGS[@]}" -ne 0 ]]; then
     echo FLAGS           = "${FLAGS[@]}";
   fi
fi

# COMMAND must be either 'install' or 'upgrade'
COMMAND=${PASSTHRU[0]}
if [ "$COMMAND" == "install" ]; then
  if [[ "${#PASSTHRU[@]}" -ne 2 ]]; then
    echo "Error: This command needs 1 argument: chart name"
    exit 1
  fi
  CHARTNAME=${PASSTHRU[1]}
elif [[ "$COMMAND" == "upgrade" ]]; then
  if [[ "${#PASSTHRU[@]}" -ne 3 ]]; then
    echo "Error: This command needs 2 arguments: release name, chart path"
    exit 1
  fi
  RELEASE_NAME=${PASSTHRU[1]}
  CHARTNAME=${PASSTHRU[2]}
else
  echo "Error: Invalid command, must be one of 'install' or 'upgrade'"
  usage
  exit 1
fi

# Check cluster provider (ICP or IKS)
CLUSTER_PROVIDER=$(kubectl get nodes | tail -n 1 | awk '{print $5}' | awk -F '+' '{print $2}')
if [ "$CLUSTER_PROVIDER" == "icp" ]; then
  DC_NAME=""
elif [ "$CLUSTER_PROVIDER" == "IKS" ]; then
  DC_NAME=$(kubectl get cm cluster-info -n kube-system -o jsonpath='{.data.cluster-config\.json}' | grep datacenter | awk -F ': ' '{print $2}' | sed 's/\"//g' |sed 's/,//g')
else
  echo "ERROR: Cluster provider is not supported. Exiting!!!"
  exit 1
fi

if [ "$COMMAND" == "install" ]; then
    echo "Installing the Helm chart"
    if [ "$CLUSTER_PROVIDER" == "IKS" ]; then
      echo "DC: ${DC_NAME}"
    fi
    echo "Chart: $CHARTNAME"
    if [[ "${FLAGS[@]}" = *"-f"* || "${FLAGS[@]}" = *"--values"* ]]; then
      if [[ "$CHARTNAME" = *"/"* ]] && [[ "$CHARTNAME" != ./* ]]; then
        helm fetch --untar $CHARTNAME
        flag=1
      elif [[ "$CHARTNAME" = *".tgz"* ]]; then
        tar -xzf $CHARTNAME
        flag=1
      fi
    fi
    helm install --set dcname="${DC_NAME}" --set provider="${CLUSTER_PROVIDER}" "$CHARTNAME" "${FLAGS[@]}"
    if [[ $flag -eq 1 ]]; then
      if [[ "$CHARTNAME" = *"/"* ]] && [[ "$CHARTNAME" != ./* ]]; then
        rm -rf $(echo "$CHARTNAME" | awk -F '/' '{print $2}')
      elif [[ "$CHARTNAME" = *".tgz"* ]]; then
        rm -rf $(tar tzf "$CHARTNAME" | sed -e 's@/.*@@' | uniq)
      fi
    fi
    exit 0
elif [[ "$COMMAND" == "upgrade" ]]; then
  echo "Upgrading the Helm chart"
  if [ "$CLUSTER_PROVIDER" == "IKS" ]; then
    echo "DC: ${DC_NAME}"
  fi
  echo "Chart: $CHARTNAME"
  if [[ "${FLAGS[@]}" = *"-f"* || "${FLAGS[@]}" = *"--values"* ]]; then
    if [[ "$CHARTNAME" = *"/"* ]] && [[ "$CHARTNAME" != ./* ]]; then
      helm fetch --untar $CHARTNAME
      flag=1
    elif [[ "$CHARTNAME" = *".tgz"* ]]; then
      tar -xzf $CHARTNAME
      flag=1
    fi
  fi
  helm upgrade --set dcname="${DC_NAME}" --set provider="${CLUSTER_PROVIDER}" "$RELEASE_NAME" "$CHARTNAME" "${FLAGS[@]}"
  if [[ $flag -eq 1 ]]; then
    if [[ "$CHARTNAME" = *"/"* ]] && [[ "$CHARTNAME" != ./* ]]; then
      rm -rf $(echo "$CHARTNAME" | awk -F '/' '{print $2}')
    elif [[ "$CHARTNAME" = *".tgz"* ]]; then
      rm -rf $(tar tzf "$CHARTNAME" | sed -e 's@/.*@@' | uniq)
    fi
  fi
  exit 0
fi
