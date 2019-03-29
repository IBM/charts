# OrientDB

[OrientDB](http://orientdb.com/)OrientDB is the most versatile DBMS supporting Graph, Document, Reactive, Full-Text, Geospatial and Key-Value models in one Multi-Model product.

```console
$ helm install community/ibm-orientdb-dev
```

## Prerequisites

- Kubernetes 1.7+ 
- Tiller 2.7.2 or later

## Resources Required
The chart deploys pods consuming minimum resources as specified in the resources configuration parameter (default: Memory: 200Mi, CPU: 100m)

## PodSecurityPolicy Requirements
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose predefined ibm-anyuid-psp PodSecurityPolicy.

## Introduction

This chart bootstraps a [OrientDB](https://hub.docker.com/r/ppc64le/orientdb/) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Default Credentials
The default credentials for the OrientDB service are username - root and password - test123 . You can create use it for creating NEWDB. 

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install --name my-release community/ibm-orientdb-dev
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Chart Details
This chart bootstraps a [OrientDB](https://hub.docker.com/r/ppc64le/orientdb/) deployment on a [Kubernetes](http://kubernetes.io) cluster


## Configuration

The following table lists the configurable parameters of the OrientDB chart and their default values.

|      Parameter            |          Description            |                         Default                         |
|---------------------------|---------------------------------|---------------------------------------------------------|
| `image.repository`        | OrientDB Container Image       | `ibmcom/orientdb-ppc64le`                              |
| `image.tag`               | OrientDB Container Image Tag   | `2.2.15`                                                |
| `image.pullPolicy`        | Image pull policy               | `Always` if `imageTag` is `latest`, else `IfNotPresent` |
| `node`                    | Specify what architecture Node  | `ppc64le`                                               |
| `replicaCount`            | OrientDB node replica count    | `1`                                                     |
| `service.type`            | OrientDB service type          | `NodePort`                                              |
| `service.port.port1`      | OrientDB service port1          | `2424`                                                  |
| `service.port.port2`      | OrientDB service port 2         | `2480`
| `ingress.enabled`          | If true, OrientDB Ingress will be created | false                                        |
| `ingress.annotations`             | OrientDB Ingress annotations   |  {}                                                     |
| `ingress.path`                    | OrientDB Ingress Path          | /                                                       |
| `ingress.hosts`           | OrientDB Ingress Hostnames     | []                                                      |
| `ingress.tls`                     | OrientDB Ingress TLS configuration (YAML) | []                                           |
| `resources.limits.cpu`    | OrientDB node cpu limit       |                                                         |
| `resources.limits.memory` | OrientDB node memory limit    |                                                         |
| `resources.requests.cpu`  | OrientDB node initial cpu request |                                                     |
| `resources.requests.memory` | OrientDB node initial memory request|                                                 |
| `tolerations`               | Tolerations that are applied to pods for all the services| []                           |

The above parameters map to `ibm-orientdb-dev` params.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. 

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,


### Persistence

If `persistence` is enabled, PVC's will be used to store the web root and the db root. If a pod then is redeployed to another node, it will restart within seconds with the old state prevailing. If it is disabled, `EmptyDir` is used, which would lead to deletion of the persistent storage once the pod is moved. Also cloning a chart with `persistence` disabled will not work. Therefor persistence is enabled by default and should only be disabled in a testing environment. In environments where no PVCs are available you can use `persistence.hostPath` instead. This will store the charts persistent data on the node it is running on.

| Parameter | Description | Default |
| - | - | - |
| `persistence.enabled` | Enables persistent volume - PV provisioner support necessary | true |
| `persistence.keep` | Keep persistent volume after helm delete | false |
| `persistence.accessMode` | PVC Access Mode | ReadWriteOnce |
| `persistence.size` | PVC Size | 2Gi |
| `persistence.storageClass` | PVC Storage Class | _empty_ |
| `persistence.name` | PVC Name | "orientdb-pv" |

```bash
$ helm install --name my-release -f values.yaml community/ibm-orientdb-dev
```

> **Tip**: You can use the default `values.yaml`

## Support

The helm charts are provided "as-is" and without warranty of any kind.

All helm charts and packages are supported through standard open source forums and helm charts are updated on a best effort basis.

Any issues found can be reported through the links below, and fixes may be proposed/submitted using standard git issues as noted below.

[Submit issue to Helm Chart](https://github.com/ppc64le/charts/issues)

[Submit issue to OrientDB docker image](https://github.com/ppc64le/build-scripts/issues)

[Submit issue to OrientDB open source community](https://github.com/orientechnologies/orientdb/issues)

[ICP Support](https://ibm.biz/icpsupport)
 
## Limitations

##NOTE
This chart is validated on ppc64le.
                                 
