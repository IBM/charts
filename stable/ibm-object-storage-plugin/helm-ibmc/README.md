## helm-ibmc

A Helm plugin that installs or upgrades Helm charts in IBM K8S Service

* https://docs.helm.sh/helm/#helm-ibmc

## Installation
  * `helm repo add ibm https://registry.bluemix.net/helm/ibm`
  * `helm repo update`
  * `helm fetch --untar ibm/ibm-object-storage-plugin`
  * `helm plugin install ./ibm-object-storage-plugin/helm-ibmc`
  * `helm ibmc --help`

## Upgrade
  * `helm ibmc --update`

## Usage

### Install IBM Cloud Object Storage plug-in chart
  * `helm ibmc install <chart repo>/<chart name> [flags]`
  * `helm ibmc install ibm/ibm-object-storage-plugin --name ibm-object-storage-plugin`

### Example
```
Mayank-Macbooks-MacBook-Pro:~ mayank-macbook$ helm plugin install ./ibm-object-storage-plugin/helm-ibmc
Installed plugin: ibmc
Mayank-Macbooks-MacBook-Pro:~ mayank-macbook$ helm ibmc --help
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
    helm ibmc install ibm/ibm-object-storage-plugin --name ibm-object-storage-plugin
```

```
Mayank-Macbooks-MacBook-Pro:~ mayank-macbook$ helm ibmc install ibm/ibm-object-storage-plugin --verbos --name ibm-object-storage-plugin
PARAMS
--name ibm-object-storage-plugin
 .........................
Helm kubeconfig = /Users/mayank-macbook/.bluemix/plugins/container-service/clusters/verify-s3-plugin/kube-config-dal10-verify-s3-plugin.yml
Helm home = /Users/mayank-macbook/.helm
Helm plugin = /Users/mayank-macbook/.helm/plugins
Helm plugin dir = /Users/mayank-macbook/.helm/plugins/helm-ibmc
PASSTHRU = install ibm/ibm-object-storage-plugin
FLAGS = --name ibm-object-storage-plugin
Installing the Helm chart
DC: dal10
Chart: ibm/ibm-object-storage-plugin
NAME:   ibm-object-storage-plugin
LAST DEPLOYED: Wed Mar 20 11:21:14 2019
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/ClusterRole
NAME                                   AGE
ibmcloud-object-storage-plugin         4s
ibmcloud-object-storage-secret-reader  4s

==> v1/ClusterRoleBinding
NAME                                   AGE
ibmcloud-object-storage-plugin         4s
ibmcloud-object-storage-secret-reader  4s

==> v1/DaemonSet
NAME                            DESIRED  CURRENT  READY  UP-TO-DATE  AVAILABLE  NODE SELECTOR  AGE
ibmcloud-object-storage-driver  2        2        2      2           2          <none>         4s

==> v1/Deployment
NAME                            READY  UP-TO-DATE  AVAILABLE  AGE
ibmcloud-object-storage-plugin  1/1    1           1          4s

==> v1/Pod(related)
NAME                                             READY  STATUS   RESTARTS  AGE
ibmcloud-object-storage-driver-rvtwn             1/1    Running  0         4s
ibmcloud-object-storage-driver-zhqfv             1/1    Running  0         4s
ibmcloud-object-storage-plugin-7bb9649cdc-c45nm  1/1    Running  0         4s

==> v1/ServiceAccount
NAME                            SECRETS  AGE
ibmcloud-object-storage-driver  1        4s
ibmcloud-object-storage-plugin  1        4s

==> v1/StorageClass
NAME                                  PROVISIONER       AGE
ibmc-s3fs-cold-cross-region           ibm.io/ibmc-s3fs  4s
ibmc-s3fs-cold-regional               ibm.io/ibmc-s3fs  4s
ibmc-s3fs-flex-cross-region           ibm.io/ibmc-s3fs  4s
ibmc-s3fs-flex-perf-cross-region      ibm.io/ibmc-s3fs  4s
ibmc-s3fs-flex-perf-regional          ibm.io/ibmc-s3fs  4s
ibmc-s3fs-flex-regional               ibm.io/ibmc-s3fs  4s
ibmc-s3fs-standard-cross-region       ibm.io/ibmc-s3fs  4s
ibmc-s3fs-standard-perf-cross-region  ibm.io/ibmc-s3fs  4s
ibmc-s3fs-standard-perf-regional      ibm.io/ibmc-s3fs  4s
ibmc-s3fs-standard-regional           ibm.io/ibmc-s3fs  4s
ibmc-s3fs-vault-cross-region          ibm.io/ibmc-s3fs  4s
ibmc-s3fs-vault-regional              ibm.io/ibmc-s3fs  4s


NOTES:
Thank you for installing: ibm-object-storage-plugin.   Your release is named: ibm-object-storage-plugin

1. Verify that plugin pods are in "Running" state:

    kubectl get pods -n kube-system -o wide | grep object

   The installation is successful when you see one `ibmcloud-object-storage-plugin` pod and one or more `ibmcloud-object-storage-driver` pods.
   The number of `ibmcloud-object-storage-driver` pods equals the number of worker nodes in your cluster. All pods must be in a `Running` state
   for the plug-in to function properly. If the pods fail, run `kubectl describe pod -n kube-system <pod_name>`
   to find the root cause for the failure.

2. Verify that the storage classes are created successfully:

    kubectl get storageclass | grep 'ibmc-s3fs'
```
