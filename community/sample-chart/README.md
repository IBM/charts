# (CHARTNAME) (-Beta)
* [(PRODUCTNAME)](https://<PRODUCTURL>) is ... brief sentence regarding product
* Add "-Beta" as suffix if beta version - beta versions are generally < 1.0.0
* Don't include versions of charts or products

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
* Kubernetes Level - indicate if specific APIs must be enabled (i.e. Kubernetes 1.6 with Beta APIs enabled)
* PersistentVolume requirements (if persistence.enabled) - PV provisioner support, StorageClass defined, etc. (i.e. PersistentVolume provisioner support in underlying infrastructure with ibmc-file-gold StorageClass defined if persistance.enabled=true)
* Simple bullet list of CPU, MEM, Storage requirements
* Even if the chart only exposes a few resource settings, this section needs to inclusive of all / total resources of all charts and subcharts.


## Resources Required
* Describes Minimum System Resources Required

## Installing the Chart
* Include at the basic things necessary to install the chart from the Helm CLI - the general happy path
* Include setup of other items required
* Security privileges required to deploy chart
* Include verification of the chart 
* Ensure CLI only and avoid any ICP or ICS language used

To install the chart with the release name `my-release`:

```bash
$ helm install --name my-release stable/<chartname>
```

The command deploys <Chart name> on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.


> **Tip**: List all releases using `helm list`

* Generally teams have subsections for : 
   * Verifying the Chart
   * Uninstalling the Chart

### Verifying the Chart
See NOTES.txt associated with this chart for verification instructions

### Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release --purge
```

The command removes all the Kubernetes components associated with the chart and deletes the release.  If a delete can result in orphaned components include instructions with additional commands required for clean-up.  

For example :

When deleting a release with stateful sets the associated persistent volume will need to be deleted.  
Do the following after deleting the chart release to clean up orphaned Persistent Volumes.

```console
$ kubectl delete pvc -l release=my-release
```

## Configuration
* Define all the parms in the values.yaml 
* Include "how used" information
* If special configuration impacts a "set of values", call out the set of values required (a = true, y = abc_value, c = 1) to get a desired outcome. One example may be setting on multiple values to turn on or off TLS. 

The following tables lists the configurable parameters of the <CHARTNAME> chart and their default values.

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
* Does it support IBM Cloud Kubernetes Service in addition to IBM Cloud Private?

## Documentation
* Can have as many supporting links as necessary for this specific workload however don't overload the consumer with unnecessary information.
* Can be links to special procedures in the knowledge center.
