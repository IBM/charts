#!/bin/bash
set -e

# Indicates whether chart is tar archive or pulled from repo
flag=0

create_dir_flag=0

CHARTREFERENCE="" # For example, ibm-charts/ibm-object-storage-plugin, ./ibm-object-storage-plugin-1.0.6.tgz, ./ibm-object-storage-plugin
CHARTNAME="" # Name of the chart. For example: ibm-object-storage-plugin
CHARTVERSION=""
RELEASE_NAME=""
OUTPUTDIR=""

usage() {
cat << EOF
Install or upgrade Helm charts in IBM K8S Service(IKS) and IBM Cloud Private(ICP)

Available Commands:
    helm ibmc install [CHART] [flags]                      Install a Helm chart
    helm ibmc upgrade [RELEASE] [CHART] [flags]            Upgrade the release to a new version of the Helm chart
    helm ibmc template [CHART] [flags] [--apply|--delete]  Install/uninstall a Helm chart without tiller

Available Flags:
    -h, --help                    (Optional) This text.
    -u, --update                  (Optional) Update this plugin to the latest version

Example Usage:
    With Tiller:
        Install:   helm ibmc install ibm-charts/ibm-object-storage-plugin --name ibm-object-storage-plugin
    Without Tiller:
        Install:   helm ibmc template ibm-charts/ibm-object-storage-plugin --apply
        Dry-run:   helm ibmc template ibm-charts/ibm-object-storage-plugin
        Uninstall: helm ibmc template ibm-charts/ibm-object-storage-plugin --delete

Note:
    1. It is always recommended to install latest version of ibm-object-storage-plugin chart.
    2. It is always recommended to have 'kubectl' client up-to-date.
EOF
}

install_usage() {
cat << EOF
This command installs a chart archive in IBM K8S Service(IKS) and IBM Cloud Private(ICP).

The install argument must be a chart reference, a path to a packaged chart,
a path to an unpacked chart directory or a URL.

Usage:
  helm ibmc install [CHART] [flags]

Flags:
      --verbos                   (Optional) Verbosity intensifies...
      --ca-file string           verify certificates of HTTPS-enabled servers using this CA bundle
      --cert-file string         identify HTTPS client using this SSL certificate file
      --dep-up                   run helm dependency update before installing the chart
      --devel                    use development versions, too. Equivalent to version '>0.0.0-0'. If --version is set, this is ignored.
      --dry-run                  simulate an install
      --key-file string          identify HTTPS client using this SSL key file
      --keyring string           location of public keys used for verification (default "/Users/mayank-macbook/.gnupg/pubring.gpg")
  -n, --name string              release name. If unspecified, it will autogenerate one for you
      --name-template string     specify template used to name the release
      --namespace string         namespace to install the release into. Defaults to the current kube config namespace.
      --no-hooks                 prevent hooks from running during install
      --password string          chart repository password where to locate the requested chart
      --replace                  re-use the given name, even if that name is already used. This is unsafe in production
      --repo string              chart repository url where to locate the requested chart
      --set stringArray          set values on the command line (can specify multiple or separate values with commas: key1=val1,key2=val2)
      --set-string stringArray   set STRING values on the command line (can specify multiple or separate values with commas: key1=val1,key2=val2)
      --timeout int              time in seconds to wait for any individual Kubernetes operation (like Jobs for hooks) (default 300)
      --tls                      enable TLS for request
      --tls-ca-cert string       path to TLS CA certificate file (default "$HELM_HOME/ca.pem")
      --tls-cert string          path to TLS certificate file (default "$HELM_HOME/cert.pem")
      --tls-key string           path to TLS key file (default "$HELM_HOME/key.pem")
      --tls-verify               enable TLS for request and verify remote
      --username string          chart repository username where to locate the requested chart
  -f, --values valueFiles        specify values in a YAML file or a URL(can specify multiple) (default [])
      --verify                   verify the package before installing it
      --version string           specify the exact chart version to install. If this is not specified, the latest version is installed
      --wait                     if set, will wait until all Pods, PVCs, Services, and minimum number of Pods of a Deployment are in a ready state before marking the release as successful. It will wait for as long as --timeout

Global Flags:
      --debug                           enable verbose output
      --home string                     location of your Helm config. Overrides $HELM_HOME (default "/Users/mayank-macbook/.helm")
      --host string                     address of Tiller. Overrides $HELM_HOST
      --kube-context string             name of the kubeconfig context to use
      --tiller-connection-timeout int   the duration (in seconds) Helm will wait to establish a connection to tiller (default 300)
      --tiller-namespace string         namespace of Tiller (default "kube-system")


Example Usage:
    helm ibmc install ibm-charts/ibm-object-storage-plugin --name ibm-object-storage-plugin
EOF
}

upgrade_usage() {
cat << EOF
This command upgrades a release to a new version of a chart in IBM K8S Service(IKS) and IBM Cloud Private(ICP).

The upgrade arguments must be a release and chart. The chart
argument can be either: a chart reference('stable/mariadb'), a path to a chart directory,
a packaged chart, or a fully qualified URL. For chart references, the latest
version will be specified unless the '--version' flag is set.

Usage:
  helm ibmc upgrade [RELEASE] [CHART] [flags]

Flags:
      --verbos                   (Optional) Verbosity intensifies...
      --ca-file string           verify certificates of HTTPS-enabled servers using this CA bundle
      --cert-file string         identify HTTPS client using this SSL certificate file
      --devel                    use development versions, too. Equivalent to version '>0.0.0-0'. If --version is set, this is ignored.
      --dry-run                  simulate an upgrade
      --force                    force resource update through delete/recreate if needed
  -i, --install                  if a release by this name doesn't already exist, run an install
      --key-file string          identify HTTPS client using this SSL key file
      --keyring string           path to the keyring that contains public signing keys (default "/Users/mayank-macbook/.gnupg/pubring.gpg")
      --namespace string         namespace to install the release into (only used if --install is set). Defaults to the current kube config namespace
      --no-hooks                 disable pre/post upgrade hooks
      --password string          chart repository password where to locate the requested chart
      --recreate-pods            performs pods restart for the resource if applicable
      --repo string              chart repository url where to locate the requested chart
      --reset-values             when upgrading, reset the values to the ones built into the chart
      --reuse-values             when upgrading, reuse the last release's values, and merge in any new values. If '--reset-values' is specified, this is ignored.
      --set stringArray          set values on the command line (can specify multiple or separate values with commas: key1=val1,key2=val2)
      --set-string stringArray   set STRING values on the command line (can specify multiple or separate values with commas: key1=val1,key2=val2)
      --timeout int              time in seconds to wait for any individual Kubernetes operation (like Jobs for hooks) (default 300)
      --tls                      enable TLS for request
      --tls-ca-cert string       path to TLS CA certificate file (default "$HELM_HOME/ca.pem")
      --tls-cert string          path to TLS certificate file (default "$HELM_HOME/cert.pem")
      --tls-key string           path to TLS key file (default "$HELM_HOME/key.pem")
      --tls-verify               enable TLS for request and verify remote
      --username string          chart repository username where to locate the requested chart
  -f, --values valueFiles        specify values in a YAML file or a URL(can specify multiple) (default [])
      --verify                   verify the provenance of the chart before upgrading
      --version string           specify the exact chart version to use. If this is not specified, the latest version is used
      --wait                     if set, will wait until all Pods, PVCs, Services, and minimum number of Pods of a Deployment are in a ready state before marking the release as successful. It will wait for as long as --timeout

Global Flags:
      --debug                           enable verbose output
      --home string                     location of your Helm config. Overrides $HELM_HOME (default "/Users/mayank-macbook/.helm")
      --host string                     address of Tiller. Overrides $HELM_HOST
      --kube-context string             name of the kubeconfig context to use
      --tiller-connection-timeout int   the duration (in seconds) Helm will wait to establish a connection to tiller (default 300)
      --tiller-namespace string         namespace of Tiller (default "kube-system")

Example Usage:
    helm ibmc upgrade [RELEASE] ibm-charts/ibm-object-storage-plugin
EOF
}

template_usage() {
cat << EOF
Render chart templates locally and display the output.

This does not require Tiller. However, any values that would normally be
looked up or retrieved in-cluster will be faked locally. Additionally, none
of the server-side testing of chart validity (e.g. whether an API is supported)
is done.

Usage:
  helm ibmc template [CHART] [flags] [--apply|--delete]

Flags:
      --verbos                   (Optional) Verbosity intensifies...
      --apply                    Install the chart templates, should not be used with '--delete'
      --delete                   Uninstall the chart, should not be used with '--apply'
  -x, --execute stringArray      only execute the given templates
      --kube-version string      kubernetes version used as Capabilities.KubeVersion.Major/Minor (default "1.9")
  -n, --name string              release name (default "RELEASE-NAME")
      --name-template string     specify template used to name the release
      --namespace string         namespace to install the release into
      --notes                    show the computed NOTES.txt file as well
      --output-dir string        writes the executed templates to files in output-dir instead of stdout
      --set stringArray          set values on the command line (can specify multiple or separate values with commas: key1=val1,key2=val2)
      --set-string stringArray   set STRING values on the command line (can specify multiple or separate values with commas: key1=val1,key2=val2)
  -f, --values valueFiles        specify values in a YAML file (can specify multiple) (default [])

Global Flags:
      --debug                           enable verbose output
      --home string                     location of your Helm config. Overrides $HELM_HOME (default "/Users/mayank-macbook/.helm")
      --host string                     address of Tiller. Overrides $HELM_HOST
      --kube-context string             name of the kubeconfig context to use
      --tiller-connection-timeout int   the duration (in seconds) Helm will wait to establish a connection to tiller (default 300)
      --tiller-namespace string         namespace of Tiller (default "kube-system")

Example Usage:
    Install:   helm ibmc template ibm-charts/ibm-object-storage-plugin --apply
    Dry-run:   helm ibmc template ibm-charts/ibm-object-storage-plugin
    Uninstall: helm ibmc template ibm-charts/ibm-object-storage-plugin --delete
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

        --apply)
        APPLY="TRUE"
        ;;

        --delete)
        DELETE="TRUE"
        ;;

        "--output-dir"*)
        if [[ "$1" == "--output-dir="* ]]; then
          OUTPUTDIR=$(echo $1 | awk -F '=' '{print $2}')
        elif [[ $# -gt 1 ]] && [[ "$2" != "-"* ]]; then
          OUTPUTDIR="$2"
          shift
        fi
        ;;

        "--version"*)
        if [[ "$1" == "--version="* ]]; then
          CHARTVERSION=$(echo $1 | awk -F '=' '{print $2}')
        elif [[ $# -gt 1 ]] && [[ "$2" != "-"* ]]; then
          CHARTVERSION="$2"
          shift
        fi
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

COMMAND=${PASSTHRU[0]}
# Show help if flagged
if [ "$HELP" == "TRUE" ]; then
  if [[ "$COMMAND" == "install" ]]; then
    install_usage
    exit 0
  elif [[ "$COMMAND" == "upgrade" ]]; then
    upgrade_usage
    exit 0
  elif [[ "$COMMAND" == "template" ]]; then
    template_usage
    exit 0
  else
    usage
    exit 0
  fi
fi
#  Update this Helm plugin
if [ "$UPDATE" == "TRUE" ]; then
    if [ ! -d "$HELM_HOME/cache/plugins/" ]; then
      mkdir -p $HELM_HOME/cache/plugins/
    fi
    cd $HELM_HOME/cache/plugins

    # Pull latest chart for upgrading ibmc helm plugin
    helm repo add ibmc-upgrade https://icr.io/helm/ibm-charts
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

# COMMAND must be one of 'install', 'upgrade' or 'template'
if [[ "$COMMAND" == "install" || "$COMMAND" == "template" ]]; then
  if [[ "${#PASSTHRU[@]}" -ne 2 ]]; then
    echo "Error: This command needs 1 argument: chart name"
    exit 1
  fi
  CHARTREFERENCE=${PASSTHRU[1]}
elif [[ "$COMMAND" == "upgrade" ]]; then
  if [[ "${#PASSTHRU[@]}" -ne 3 ]]; then
    echo "Error: This command needs 2 arguments: release name, chart path"
    exit 1
  fi
  RELEASE_NAME=${PASSTHRU[1]}
  CHARTREFERENCE=${PASSTHRU[2]}
else
  echo "Error: Invalid command, must be one of 'install', 'upgrade' or 'template'."
  usage
  exit 1
fi

if [[ "$APPLY" == "TRUE" || "$DELETE" == "TRUE" ]] && [[ "$COMMAND" != "template" ]]; then
  echo "ERROR: Invalid options: '--apply' or '--delete' should be used with 'template' command only."
  usage
  exit 1
fi

if [[ "$APPLY" == "TRUE" && "$DELETE" == "TRUE" ]]; then
  echo "ERROR: Invalid options: '--delete' should not be used with '--apply'."
  template_usage
  exit 1
fi

# Check cluster provider (ICP or IKS)
if [[ `kubectl get nodes -o yaml | grep 'node-role\.kubernetes\.io'` == "" || \
  `kubectl get nodes -o yaml | grep 'node-role\.kubernetes\.io/\(compute\|infra\)'` != "" ]]; then
  if [[ `kubectl get nodes -o yaml | grep 'ibm-cloud\.kubernetes\.io/iaas-provider\: \(gc\|g2\|ng\)'` != "" ]]; then
    CLUSTER_PROVIDER="VPC-CLASSIC"
  else
    CLUSTER_PROVIDER="CLASSIC"
  fi
  DC_NAME=$(kubectl get cm cluster-info -n kube-system -o jsonpath='{.data.cluster-config\.json}' | grep datacenter | awk -F ': ' '{print $2}' | sed 's/\"//g' |sed 's/,//g')
elif [[ `kubectl get nodes -o yaml | grep 'node-role\.kubernetes\.io/\(etcd\|master\|management\|worker\|proxy\|va\)'` != "" ]]; then
  CLUSTER_PROVIDER="ICP"
  DC_NAME=""
else
  echo "ERROR: Cluster provider is not supported. Exiting!!!"
  exit 1
fi

# Check worker node's OS
WORKER_OS=$(kubectl get nodes -o jsonpath='{ .items[0].status.nodeInfo.osImage }' | tr [:lower:] [:upper:])
if [[ "$WORKER_OS" == "RED HAT"* ]]; then
  WORKER_OS="redhat"
else
  WORKER_OS="debian"
fi

if [ "$COMMAND" == "install" ]; then
  echo "Installing the Helm chart..."
  if [[ "$CLUSTER_PROVIDER" == *"CLASSIC" ]]; then
    echo "DC: ${DC_NAME}"
  fi
  echo "Chart: $CHARTREFERENCE"
  if [[ "${FLAGS[@]}" = *"-f"* || "${FLAGS[@]}" = *"--values"* ]]; then
    if [[ "$CHARTREFERENCE" = *"/"* ]] && [[ "$CHARTREFERENCE" != ./* ]] && [[ "$CHARTREFERENCE" != /* ]]; then
      if [[ ! -z "$CHARTVERSION" ]]; then
        helm fetch --untar "$CHARTREFERENCE" --version "$CHARTVERSION"
      else
        helm fetch --untar "$CHARTREFERENCE"
      fi
      CHARTNAME=$(echo "$CHARTREFERENCE" | awk -F '/' '{print $2}')
      flag=1
    elif [[ "$CHARTREFERENCE" = *".tgz"* ]]; then
      tar -xzf "$CHARTREFERENCE"
      CHARTNAME=$(tar tzf "$CHARTREFERENCE" | sed -e 's@/.*@@' | uniq)
      flag=1
    fi
  fi
  set +e
  if [[ ! -z "$CHARTVERSION" ]]; then
    helm install --version "$CHARTVERSION" --set dcname="${DC_NAME}" --set provider="${CLUSTER_PROVIDER}" --set workerOS="${WORKER_OS}" "$CHARTREFERENCE" "${FLAGS[@]}"
  else
    helm install --set dcname="${DC_NAME}" --set provider="${CLUSTER_PROVIDER}" --set workerOS="${WORKER_OS}" "$CHARTREFERENCE" "${FLAGS[@]}"
  fi
  if [[ $? -eq 1 ]]; then
    if [[ $flag -eq 1 ]]; then
      rm -rf "$CHARTNAME"
    fi
    exit 1
  fi
  set -e
  if [[ $flag -eq 1 ]]; then
    rm -rf "$CHARTNAME"
  fi
  exit 0
elif [[ "$COMMAND" == "upgrade" ]]; then
  echo "Upgrading the Helm chart..."
  if [[ "$CLUSTER_PROVIDER" == *"CLASSIC" ]]; then
    echo "DC: ${DC_NAME}"
  fi
  echo "Chart: $CHARTREFERENCE"
  if [[ "${FLAGS[@]}" = *"-f"* || "${FLAGS[@]}" = *"--values"* ]]; then
    if [[ "$CHARTREFERENCE" = *"/"* ]] && [[ "$CHARTREFERENCE" != ./* ]] && [[ "$CHARTREFERENCE" != /* ]]; then
      if [[ ! -z "$CHARTVERSION" ]]; then
        helm fetch --untar "$CHARTREFERENCE" --version "$CHARTVERSION"
      else
        helm fetch --untar "$CHARTREFERENCE"
      fi
      CHARTNAME=$(echo "$CHARTREFERENCE" | awk -F '/' '{print $2}')
      flag=1
    elif [[ "$CHARTREFERENCE" = *".tgz"* ]]; then
      tar -xzf "$CHARTREFERENCE"
      CHARTNAME=$(tar tzf "$CHARTREFERENCE" | sed -e 's@/.*@@' | uniq)
      flag=1
    fi
  fi
  set +e
  if [[ ! -z "$CHARTVERSION" ]]; then
    helm upgrade --version "$CHARTVERSION" --set dcname="${DC_NAME}" --set provider="${CLUSTER_PROVIDER}" --set workerOS="${WORKER_OS}" "$RELEASE_NAME" "$CHARTREFERENCE" "${FLAGS[@]}"
  else
    helm upgrade --set dcname="${DC_NAME}" --set provider="${CLUSTER_PROVIDER}" --set workerOS="${WORKER_OS}" "$RELEASE_NAME" "$CHARTREFERENCE" "${FLAGS[@]}"
  fi
  if [[ $? -eq 1 ]]; then
    if [[ $flag -eq 1 ]]; then
      rm -rf "$CHARTNAME"
    fi
    exit 1
  fi
  set -e
  if [[ $flag -eq 1 ]]; then
    rm -rf "$CHARTNAME"
  fi
  exit 0
elif [ "$COMMAND" == "template" ]; then
  if [ "$DELETE" != "TRUE" ]; then
    echo "Rendering the Helm chart templates..."
    if [[ "$CLUSTER_PROVIDER" == *"CLASSIC" ]]; then
      echo "DC: ${DC_NAME}"
    fi
    echo "Chart: $CHARTREFERENCE"
    if [[ "$CHARTREFERENCE" = *"/"* ]] && [[ "$CHARTREFERENCE" != ./* ]] && [[ "$CHARTREFERENCE" != /* ]]; then
      if [[ ! -z "$CHARTVERSION" ]]; then
        helm fetch --untar "$CHARTREFERENCE" --version "$CHARTVERSION"
      else
        helm fetch --untar "$CHARTREFERENCE"
      fi
      CHARTNAME=$(echo "$CHARTREFERENCE" | awk -F '/' '{print $2}')
      flag=1
    elif [[ "$CHARTREFERENCE" = *".tgz"* ]] && [[ "${FLAGS[@]}" = *"-f"* || "${FLAGS[@]}" = *"--values"* ]]; then
      tar -xzf "$CHARTREFERENCE"
      CHARTNAME=$(tar tzf "$CHARTREFERENCE" | sed -e 's@/.*@@' | uniq)
      flag=1
    else
      CHARTNAME="$CHARTREFERENCE"
    fi
    if [[ ! -z "$OUTPUTDIR" ]] && [[ "$APPLY" != "TRUE" ]]; then
      if [[ ! -d "$OUTPUTDIR" ]]; then
        mkdir "$OUTPUTDIR"
        create_dir_flag=1
      fi
    else
      OUTPUTDIR="object-storage-templates"
      mkdir "$OUTPUTDIR"
      create_dir_flag=1
    fi
    set +e
    # Render chart templates
    helm template --output-dir "${OUTPUTDIR}" --set dcname="${DC_NAME}" --set provider="${CLUSTER_PROVIDER}" --set workerOS="${WORKER_OS}" "$CHARTNAME" "${FLAGS[@]}"
    if [[ $? -eq 1 ]]; then
      if [[ $create_dir_flag -eq 1 ]]; then
        rm -rf "$OUTPUTDIR"
      fi
      if [[ $flag -eq 1 ]]; then
        rm -rf "$CHARTNAME"
      fi
      exit 1
    fi
    set -e
    if [[ $flag -eq 1 ]]; then
      rm -rf "$CHARTNAME"
    fi
    if [ "$APPLY" == "TRUE" ]; then
      echo "Installing the Helm chart..."
      kubectl apply --recursive --filename "$OUTPUTDIR"
      rm -rf "$OUTPUTDIR"
    fi
  else
    echo "Uninstalling the Helm chart..."
    for scname in $(kubectl get StorageClass -l app=ibmcloud-object-storage-plugin \
            -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')
    do
        echo "removing StorageClass =>  $scname"
        kubectl delete StorageClass ${scname} --ignore-not-found
    done

    for clsrolebinding in $(kubectl get ClusterRoleBinding --all-namespaces \
            -l app=ibmcloud-object-storage-plugin \
            -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')
    do
        echo "removing ClusterRoleBinding => $clsrolebinding"
        kubectl delete ClusterRoleBinding ${clsrolebinding} --ignore-not-found
    done

    for clsrole in $(kubectl get ClusterRole --all-namespaces \
            -l app=ibmcloud-object-storage-plugin \
            -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')
    do
        echo "removing ClusterRole => $clsrole"
        kubectl delete ClusterRole ${clsrole} --ignore-not-found
    done

    for rolebinding in $(kubectl get RoleBinding --all-namespaces \
            -l app=ibmcloud-object-storage-plugin \
            -o jsonpath='{range .items[*]}{.metadata.namespace}{"\t"}{.metadata.name}{"\n"}{end}')
    do
        echo "RoleBinding => {$rolebinding}"
        if [[ ! -z "$rolebinding" ]]; then
            nsname=$(echo $rolebinding | awk '{ print $1 }')
            rbname=$(echo $rolebinding | awk '{ print $2 }')
            if [[ ! -z "$rbname" ]]; then
                echo "removing RoleBinding => ${nsname}/${rbname}"
                kubectl delete RoleBinding -n ${nsname} ${rbname} --ignore-not-found
            fi
        fi
    done

    for rolebinding in $(kubectl get RoleBinding --all-namespaces \
            -l app=ibmcloud-object-storage-driver \
            -o jsonpath='{range .items[*]}{.metadata.namespace}{"\t"}{.metadata.name}{"\n"}{end}')
    do
        echo "RoleBinding => {$rolebinding}"
        if [[ ! -z "$rolebinding" ]]; then
            nsname=$(echo $rolebinding | awk '{ print $1 }')
            rbname=$(echo $rolebinding | awk '{ print $2 }')
            if [[ ! -z "$rbname" ]]; then
                echo "removing RoleBinding => ${nsname}/${rbname}"
                kubectl delete RoleBinding -n ${nsname} ${rbname} --ignore-not-found
            fi
        fi
    done

    for deploy in "$(kubectl get Deployments --all-namespaces \
        -l app=ibmcloud-object-storage-plugin \
        -o jsonpath='{range .items[*]}{.metadata.namespace}{"\t"}{.metadata.name}{"\n"}{end}')"
    do
        echo "Deployment => {$deploy}"
        if [[ ! -z "$deploy" ]]; then
            nsname=$(echo $deploy | awk '{ print $1 }')
            dpname=$(echo $deploy | awk '{ print $2 }')
            if [[ ! -z "$deploy" ]]; then
                echo "removing Deployment => ${nsname}/${dpname}"
                kubectl delete Deployment -n ${nsname} ${dpname} --ignore-not-found
            fi
        fi
    done

    for daemonset in "$(kubectl get DaemonSets --all-namespaces \
        -l app=ibmcloud-object-storage-driver \
        -o jsonpath='{range .items[*]}{.metadata.namespace}{"\t"}{.metadata.name}{"\n"}{end}')"
    do
        echo "DaemonSet => {$daemonset}"
        if [[ ! -z "$daemonset" ]]; then
            nsname=$(echo $daemonset | awk '{ print $1 }')
            dsname=$(echo $daemonset | awk '{ print $2 }')
            if [[ ! -z "$dsname" ]]; then
                echo "removing DaemonSet => ${nsname}/${dsname}"
                kubectl delete DaemonSet -n ${nsname} ${dsname} --ignore-not-found
            fi
        fi
    done

    for pod in "$(kubectl get pods --all-namespaces \
        -l app=ibmcloud-object-storage-driver-test \
        -o jsonpath='{range .items[*]}{.metadata.namespace}{"\t"}{.metadata.name}{"\n"}{end}')"
    do
        echo "Pod => {$pod}"
        if [[ ! -z "$pod" ]]; then
            nsname=$(echo $pod | awk '{ print $1 }')
            podname=$(echo $pod | awk '{ print $2 }')
            if [[ ! -z "$podname" ]]; then
                echo "removing Pod => ${nsname}/${podname}"
                kubectl delete pod -n ${nsname} ${podname} --ignore-not-found
            fi
        fi
    done

    svcaccount=$(kubectl get ServiceAccount --all-namespaces \
        -l app=ibmcloud-object-storage-driver \
        -o jsonpath='{range .items[*]}{.metadata.namespace}{"\t"}{.metadata.name}{"\n"}{end}')
    echo "ServiceAccount => {$svcaccount}"
    if [[ ! -z "$svcaccount" ]]; then
        nsname=$(echo $svcaccount | awk '{ print $1 }')
        svcaccount=$(echo $svcaccount | awk '{ print $2 }')
        if [[ ! -z "$svcaccount" ]]; then
            echo "removing ServiceAccount => ${nsname}/${svcaccount}"
            kubectl delete ServiceAccount -n ${nsname} ${svcaccount} --ignore-not-found
        fi
    fi

    svcaccount=$(kubectl get ServiceAccount --all-namespaces \
        -l app=ibmcloud-object-storage-plugin \
        -o jsonpath='{range .items[*]}{.metadata.namespace}{"\t"}{.metadata.name}{"\n"}{end}')
    echo "ServiceAccount => {$svcaccount}"
    if [[ ! -z "$svcaccount" ]]; then
        nsname=$(echo $svcaccount | awk '{ print $1 }')
        svcaccount=$(echo $svcaccount | awk '{ print $2 }')
        if [[ ! -z "$svcaccount" ]]; then
            echo "removing ServiceAccount => ${nsname}/${svcaccount}"
            kubectl delete ServiceAccount -n ${nsname} ${svcaccount} --ignore-not-found
        fi
    fi
  fi
  exit 0
fi
