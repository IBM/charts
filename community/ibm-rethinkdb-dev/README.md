# RethinkDB

[RethinkDB](https://github.com/rethinkdb/rethinkdb) Open-source database for building realtime web applications.

```console
$ helm install community/ibm-rethinkdb-dev
```

## Prerequisites

- Kubernetes 1.7+ 
- Tiller 2.7.2 or later

## Resources Required
The chart deploys pods consuming minimum resources.

## PodSecurityPolicy Requirements
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose predefined ibm-anyuid-psp PodSecurityPolicy.

## Introduction

[RethinkDB](https://github.com/rethinkdb/rethinkdb) Open-source database for building realtime web applications.

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm intall --name my-release community/ibm-rethinkdb-dev
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Chart Details
This chart bootstraps a [RethinkDB](https://github.com/rethinkdb/rethinkdb) deployment on a [Kubernetes](http://kubernetes.io) cluster


## Configuration

The following table lists the configurable parameters of the rethinkdb chart and their default values.

|      Parameter            |          Description            |                         Default                         |
|---------------------------|---------------------------------|---------------------------------------------------------|
| `image.repository`        | RethinkDB Container Image       | `ibmcom/rethinkdb-ppc64le`                              |
| `image.tag`               | RethinkDB Container Image Tag   | `2.3.6`                                                 |
| `image.pullPolicy`        | Image pull policy               | `Always` if `imageTag` is `latest`, else `IfNotPresent` |
| `node`                    | Specify what architecture Node  | `ppc64le`                                               |
| `replicaCount`            | RethinkDB node replica count    | `1`                                                     |
| `service.type`            | RethinkDB service type          | `NodePort`                                              |
| `service.port`               | RethinkDB service port          | `8080`                                                  |
| `ingress.enabled`          | If true, RethinkDB Ingress will be created | false                                        |
| `ingress.annotations`             | RethinkDB Ingress annotations   |  {}                                                     |
| `ingress.path`                    | RethinkDB Ingress Path          | /                                                       |
| `ingress.hosts`           | RethinkDB Ingress Hostnames     | []                                                      |
| `ingress.tls`                     | RethinkDB Ingress TLS configuration (YAML) | []                                           |
| `resources.limits.cpu`    | RethinkDB node cpu limit       |                                                         |
| `resources.limits.memory` | RethinkDB node memory limit    |                                                         |
| `resources.requests.cpu`  | RethinkDB node initial cpu request |                                                     |
| `resources.requests.memory` | RethinkDB node initial memory request|                                                 |


The above parameters map to `ibm-rethinkdb-dev` params.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. 

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml community/ibm-rethinkdb-dev
```

> **Tip**: You can use the default `values.yaml`

### Persistence

If `persistence` is enabled, PVC's will be used to store the web root and the db root. If a pod then is redeployed to another node, it will restart within seconds with the old state prevailing. If it is disabled, `EmptyDir` is used, which would lead to deletion of the persistent storage once the pod is moved. Also cloning a chart with `persistence` disabled will not work. Therefor persistence is enabled by default and should only be disabled in a testing environment. In environments where no PVCs are available you can use `persistence.hostPath` instead. This will store the charts persistent data on the node it is running on.

| Parameter | Description | Default |
| - | - | - |
| `persistence.enabled` | Enables persistent volume - PV provisioner support necessary | true |
| `persistence.keep` | Keep persistent volume after helm delete | false |
| `persistence.accessMode` | PVC Access Mode | ReadWriteOnce |
| `persistence.size` | PVC Size | 2Gi |
| `persistence.storageClass` | PVC Storage Class | _empty_ |

## Support

The helm charts are provided "as-is" and without warranty of any kind.

All helm charts and packages are supported through standard open source forums and helm charts are updated on a best effort basis.

Any issues found can be reported through the links below, and fixes may be proposed/submitted using standard git issues as noted below.

[Submit issue to Helm Chart](https://github.com/ppc64le/charts/issues )

[Submit issue to RethinkDB docker image](https://github.com/ppc64le/build-scripts/issues )

[Submit issue to RethinkDB open source community](https://github.com/rethinkdb/rethinkdb/issues )

[ICP Support](https://ibm.biz/icpsupport )

## Limitations

## NOTE
This chart is validated on ppc64le only.

