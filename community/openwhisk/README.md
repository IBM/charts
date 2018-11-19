# Openwhisk
Apache OpenWhisk is an open source, distributed serverless platform that executes functions in response to events at any scale.

## Introduction
This chart ...
* Paragraph overview of the workload
* Include links to external sources for more product info
* Don't say "for ICP" or "Cloud Private" the chart should remain a general chart not directly stating ICP or ICS. 

## Chart Details
* Simple bullet list of what is deployed as the standard config
* General description of the topology of the workload 
* Keep it short and specific with items such as : ingress, services, storage, pods, statefulsets, etc. 

## Prerequisites
* Kubernetes 1.10 - 1.11.*
* PersistentVolume requirements (if persistence.enabled) - PV provisioner support, StorageClass defined, etc. (i.e. PersistentVolume provisioner support in underlying infrastructure with ibmc-file-gold StorageClass defined if persistance.enabled=true)
* Simple bullet list of CPU, MEM, Storage requirements
* Even if the chart only exposes a few resource settings, this section needs to inclusive of all / total resources of all charts and subcharts.
* Describe any custom image policy requirements if using a non-whitelisted image repository.

### PodSecurityPolicy Requirements
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation.  Choose either a predefined PodSecurityPolicy or have your cluster administrator setup a custom PodSecurityPolicy for you:
* Predefined PodSecurityPolicy name: [`ibm-anyuid-hostpath-psp`](https://ibm.biz/cpkspec-psp)
* Custom PodSecurityPolicy definition:

    ```
    apiVersion: extensions/v1beta1
    kind: PodSecurityPolicy
    metadata:
    annotations:
        kubernetes.io/description: "This policy allows pods to run with 
        any UID and GID and any volume, including the host path.  
        WARNING:  This policy allows hostPath volumes.  
        Use with caution." 
    name: ibm-anyuid-hostpath-psp
    spec:
    allowPrivilegeEscalation: true
    fsGroup:
        rule: RunAsAny
    requiredDropCapabilities: 
    - MKNOD
    allowedCapabilities:
    - SETPCAP
    - AUDIT_WRITE
    - CHOWN
    - NET_RAW
    - DAC_OVERRIDE
    - FOWNER
    - FSETID
    - KILL
    - SETUID
    - SETGID
    - NET_BIND_SERVICE
    - SYS_CHROOT
    - SETFCAP 
    runAsUser:
        rule: RunAsAny
    seLinux:
        rule: RunAsAny
    supplementalGroups:
        rule: RunAsAny
    volumes:
    - '*'
    ```

* Custom ClusterRole for the custom PodSecurityPolicy:

  ```
  apiVersion: rbac.authorization.k8s.io/v1
  kind: ClusterRole
  metadata:
    name: ibm-chart-dev-clusterrole
  rules:
  - apiGroups:
    - extensions
    resourceNames:
    - ibm-chart-dev-psp
    resources:
    - podsecuritypolicies
    verbs:
    - use
  ```

### Prereq configuration scripts can be used to create and delete required resources:
_WRITER NOTES: Include instructions on where to find the prereq scripts based on whether PPA or github.com based chart._

_(For github.com based) Download the following scripts from [here](https://github.com/IBM/charts/tree/master/stable/<YOUR CHART NAME>/ibm_cloud_pak/pak_extensions/prereqs)_

or

_(For PPA based) Find the following scripts in pak_extensions/prereqs directory of the downloaded archive._

  - createSecurityClusterPrereqs.sh to create the PodSecurityPolicy and ClusterRole for all releases of this chart.
  - createSecurityNamespacePrereqs.sh to create the RoleBinding for the namespace. This script takes one argument; the name of a pre-existing namespace where the chart will be installed.
    - Example usage: `./createSecurityNamespacePrereqs.sh myNamespace`
  - deleteSecurityClusterPrereqs.sh to delete the PodSecurityPolicy and ClusterRole for all releases of this chart.
  - deleteSecurityNamespacePrereqs.sh to delete the RoleBinding for the namespace. This script takes one argument; the name of the namespace where the chart was installed.
    - Example usage: `./deleteSecurityNamespacePrereqs.sh myNamespace`

## Resources Required
* Describes Minimum System Resources Required

## Installing the Chart
* Include at the basic things necessary to install the chart from the Helm CLI - the general happy path
* Include setup of other items required
* Security privileges required to deploy chart (role, PodSecurityPolicy, etc)
* Include verification of the chart 
* Ensure CLI only and avoid any ICP or ICS language used

To install the chart with the release name `my-release`:

```bash
$ helm install --tls --namespace <your pre-created namespace> --name my-release community/openwhisk
```

The command deploys Openwhisk on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.


> **Tip**: List all releases using `helm list`

* Generally teams have subsections for : 
   * Verifying the Chart
   * Uninstalling the Chart

### Verifying the Chart
See NOTES.txt associated with this chart for verification instructions

### Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release --purge --tls
```

The command removes all the Kubernetes components associated with the chart and deletes the release.  If a delete can result in orphaned components include instructions with additional commands required for clean-up.  

For example :

When deleting a release with stateful sets the associated persistent volume will need to be deleted.  
Do the following after deleting the chart release to clean up orphaned Persistent Volumes.

```console
$ kubectl delete pvc -l release=my-release
```

### Cleanup any pre-reqs that were created
If cleanup scripts where included in the pak_extensions/prereqs directory; run them to cleanup namespace and cluster scoped resources when appropriate.

## Configuration
* Define all the parms in the values.yaml 
* Include "how used" information
* If special configuration impacts a "set of values", call out the set of values required (a = true, y = abc_value, c = 1) to get a desired outcome. One example may be setting on multiple values to turn on or off TLS. 

The following tables lists the configurable parameters of the Openwhisk chart and their default values.

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
| `replicaCount`             | Number of deployment replicas                   | `1`                                                        |
| `image.repository`         | `PRODUCTNAME` image repository                  | `nginx`                                                    |
| `image.pullPolicy`         | Image pull policy                               | `Always` if `imageTag` is `latest`, else `IfNotPresent`    |
| `image.tag`                | `PRODUCTNAME` image tag                         | `stable`                                                   |
| `service.type`             | k8s service type exposing ports, e.g. `NodePort`| `ClusterIP`                                                |
| `service.externalPort`     | External TCP Port for this service              | `80`                                                       |
| `ingress.enabled`          | Ingress enabled                                 | `false`                                                    |
| `ingress.hosts`            | Host to route requests based on                 | `false`                                                    |
| `ingress.annotations`      | Meta data to drive ingress class used, etc.     | `nil`                                                      |
| `ingress.tls`              | TLS secret to secure channel from client / host | `nil`                                                      |
| `resources.requests.memory`| Memory resource requests                        | `128Mi`                                                    |
| `resources.requests.cpu`   | CPU resource requests                           | `100m'                                                     |
| `resources.limits.memory`  | Memory resource limits                          | `128Mi`                                                    |
| `resources.limits.cpu`     | CPU resource limits                             | `100m`                                                     |


A subset of the above parameters map to the env variables defined in [(PRODUCTNAME)](PRODUCTDOCKERURL). For more information please refer to the [(PRODUCTNAME)](PRODUCTDOCKERURL) image documentation.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

> **Tip**: You can use the default values.yaml

## Storage
* Define how storage works with the workload
* Dynamic vs PV pre-created
* Considerations if using hostpath, local volume, empty dir
* Loss of data considerations
* Any special quality of service or security needs for storage

## Limitations
* Deployment limits - can you deploy more than once, can you deploy into different namespace
* List specific limitations such as platforms, security, replica's, scaling, upgrades etc.. - noteworthy limits identified
* List deployment limitations such as : restrictions on deploying more than once or into custom namespaces. 
* Not intended to provide chart nuances, but more a state of what is supported and not - key items in simple bullet form.
* Does it work on IBM Container Services, IBM Private Cloud ?

## Documentation
* Can have as many supporting links as necessary for this specific workload however don't overload the consumer with unnecessary information.
* Can be links to special procedures in the knowledge center.