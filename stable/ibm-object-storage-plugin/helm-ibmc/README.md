## helm-ibmc

A Helm plugin that installs or upgrades Helm charts in IBM K8S Service

* https://docs.helm.sh/helm/#helm-ibmc

## Fixes
  * With v2.0.0, `ibmc` helm plugin supports installation of object-storage-plugin with helm client `v2.x` and `v3.x`.

## Installation
  * `helm repo add ibm-charts https://icr.io/helm/ibm-charts`
  * `helm repo update`
  * `helm fetch --untar ibm-charts/ibm-object-storage-plugin`
  * `helm plugin install ./ibm-object-storage-plugin/helm-ibmc`
  * `helm ibmc --help`

## Upgrade
  * `helm ibmc --update`

## Usage

### Install IBM Cloud Object Storage plug-in chart(with helm client v2.x)
  * `helm ibmc install <chart repo>/<chart name> [flags]`
  * `helm ibmc install ibm-charts/ibm-object-storage-plugin --name ibm-object-storage-plugin`

### Install IBM Cloud Object Storage plug-in chart(with helm client v3.x)
  * `helm ibmc install <release name> <chart repo>/<chart name> [flags]`
  * `helm ibmc install ibm-object-storage-plugin ibm-charts/ibm-object-storage-plugin`

### Example
```
$ helm plugin install ./ibm-object-storage-plugin/helm-ibmc
Installed plugin: ibmc
$ helm ibmc --help
Helm version: v3.0.2+g19e47ee
Install or upgrade Helm charts in IBM K8S Service(IKS) and IBM Cloud Private(ICP)

Usage:
  helm ibmc [command]

Available Commands:
  install           Install a Helm chart
  upgrade           Upgrade the release to a new version of the Helm chart

Available Flags:
  -h, --help        (Optional) This text.
  -u, --update      (Optional) Update this plugin to the latest version

Example Usage:
    Install: helm ibmc install ibm-object-storage-plugin ibm-charts/ibm-object-storage-plugin
    Upgrade: helm ibmc upgrade [RELEASE] ibm-charts/ibm-object-storage-plugin

Note:
    1. It is always recommended to install latest version of ibm-object-storage-plugin chart.
    2. It is always recommended to have 'kubectl' client up-to-date.
```

```
$  helm ibmc install ibm-object-storage-plugin ibm-charts/ibm-object-storage-plugin --verbos
Helm version:- v3.0.2+g19e47ee
PARAMS

 .........................
Helm kubeconfig = ~/.bluemix/plugins/container-service/clusters/iks-165-dal-admin/kube-config-dal10-iks-165-dal.yml
Helm plugin dir = ~/Library/helm/plugins/helm-ibmc
helm plugin cache dir = ~/Library/Caches/helm/repository/../plugins
PASSTHRU = install ibm-object-storage-plugin ibm-charts/ibm-object-storage-plugin
Installing the Helm chart...
PROVIDER: CLASSIC
DC: dal10
Chart: ibm-charts/ibm-object-storage-plugin
NAME: ibm-object-storage-plugin
LAST DEPLOYED: Fri Jan 24 11:12:24 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
Thank you for installing: ibm-object-storage-plugin.   Your release is named: ibm-object-storage-plugin

1. Verify that the storage classes are created successfully:

   $ kubectl get storageclass | grep 'ibmc-s3fs'

2. Verify that plugin pods are in "Running" state:

   $ kubectl get pods -n kube-system -o wide | grep object

   The installation is successful when you see one `ibmcloud-object-storage-plugin` pod and one or more `ibmcloud-object-storage-driver` pods.
   The number of `ibmcloud-object-storage-driver` pods equals the number of worker nodes in your cluster. All pods must be in a `Running` state
   for the plug-in to function properly. If the pods fail, run `kubectl describe pod -n kube-system <pod_name>`
   to find the root cause for the failure.

######################################################
Additional steps for IBM Kubernetes Service(IKS) only:
######################################################

  1. If the plugin pods show an "ErrImagePull" or "ImagePullBackOff" error, verify that the image pull secrets to access IBM Cloud Container Registry exist in the "kube-system" namespace of your cluster.

     $ kubectl get secrets -n kube-system | grep icr-io

     Example output if the secrets exist:
     ----o/p----
     kube-system-icr-io
     kube-system-us-icr-io
     kube-system-uk-icr-io
     kube-system-de-icr-io
     kube-system-au-icr-io
     kube-system-jp-icr-io
     ----end----

  2. If the secrets do not exist in the "kube-system" namespace, check if the secrets are available in the "default" namespace of your cluster.

     $ kubectl get secrets -n default | grep icr-io

  3. If the secrets are available in the "default" namespace, copy the secrets to the "kube-system" namespace of your cluster. If the secrets are not available, continue with the next step.

     $ kubectl get secret -n default default-icr-io -o yaml | sed 's/default/kube-system/g' | kubectl -n kube-system create -f -
     $ kubectl get secret -n default default-us-icr-io -o yaml | sed 's/default/kube-system/g' | kubectl -n kube-system create -f -
     $ kubectl get secret -n default default-uk-icr-io -o yaml | sed 's/default/kube-system/g' | kubectl -n kube-system create -f -
     $ kubectl get secret -n default default-de-icr-io -o yaml | sed 's/default/kube-system/g' | kubectl -n kube-system create -f -
     $ kubectl get secret -n default default-au-icr-io -o yaml | sed 's/default/kube-system/g' | kubectl -n kube-system create -f -
     $ kubectl get secret -n default default-jp-icr-io -o yaml | sed 's/default/kube-system/g' | kubectl -n kube-system create -f -

  4. If the secrets are not available in the "default" namespace, you might have an older cluster and must generate the secrets in the "default" namespace.

     i.  Generate the secrets in the "default" namespace.

         $ ibmcloud ks cluster-pull-secret-apply

     ii. Verify that the secrets are created in the "default" namespace. The creation of the secrets might take a few minutes to complete.

         $ kubectl get secrets -n default | grep icr-io

     iii. Run the commands in step 3 to copy the secrets from the "default" namespace to the "kube-system" namespace.

  5. Verify that the image pull secrets are available in the "kube-system" namespace.

     $ kubectl get secrets -n kube-system | grep icr-io

  6. Verify that the state of the plugin pods changes to "Running".

     $ kubectl get pods -n kube-system | grep object
```
