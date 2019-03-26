# CrateDB

[CrateDB](https://crate.io/)A distributed SQL DBMS built atop NoSQL storage & indexing delivers the best of SQL & NoSQL in one database. 

```console
$ helm install community/ibm-crate-dev
```

## Prerequisites

- Kubernetes 1.7+ 
- Tiller 2.7.2 or  later

## Resources Required
The chart deploys pods consuming minimum resources as specified in the resources configuration parameter (default: Memory: 200Mi, CPU: 100m).


## PodSecurityPolicy Requirements
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose predefined ibm-anyuid-psp PodSecurityPolicy.

## Introduction

This chart bootstraps a [CrateDB](https://github.com/crate/crate) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.


## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm intall --name my-release community/ibm-crate-dev
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Chart Details
This chart bootstraps a [CrateDB](https://hub.docker.com/r/ibmcom/crate-ppc64le/) deployment on a [Kubernetes](http://kubernetes.io) cluster


## Configuration

The following table lists the configurable parameters of the CrateDB chart and their default values.

|      Parameter            |          Description            |                         Default                         |
|---------------------------|---------------------------------|---------------------------------------------------------|
| `image.repository`        | Container image for Crate       | `ibmcom/crate-ppc64le`                                  |
| `image.pullPolicy`         | Image pull policy               | `Always` if `imageTag` is `latest`, else `IfNotPresent` |
| `image.tag`                | Container image tag for Crate   | `latest`
| `node`                    | Specify what architecture Node  | `ppc64le`                                               |
| `replicaCount`            | Crate node replica count        | `1`                                                     |
| `service.type`            | Crate  service type             | `NodePort`                                              |
| `service.port`               | Crate  service port             | `8080`                                               |
| `ingress.enabled`          | If true, Crate Ingress will be created | false                                           |
| `ingress.annotations`             | Crate Ingress annotations       |  {}                                             |
| `ingress.path`                    | Crate Ingress Path              | /                                               |
| `ingress.hosts`           | Crate Ingress Hostnames         | []                                                      |
| `ingress.tls`                     | Crate Ingress TLS configuration (YAML) | []                                       |
| `resources.limits.cpu`    | Crate node cpu limit       |                                                              |
| `resources.limits.memory` | Crate node memory limit    |                                                              |
| `resources.requests.cpu`  | Crate node initial cpu request |                                                          |
| `resources.requests.memory` | Crate node initial memory request|                                                      |
| `tolerations`               | Tolerations that are applied to pods for all the services| []                           |




The above parameters map to `ibm-crate-dev` params.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. 

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml community/ibm-crate-dev
```

> **Tip**: You can use the default `values.yaml`

### Persistence

If `persistence` is enabled, PVC's will be used to store the web root and the db root. If a pod then is redeployed to another node, it will restart within seconds with the old state prevailing. If it is disabled, `EmptyDir` is used, which would lead to deletion of the persistent storage once the pod is moved. Also cloning a chart with `persistence` disabled will not work. Therefor persistence is enabled by default and should only be disabled in a testing environment. In environments where no PVCs are available you can use `persistence.hostPath` instead. This will store the charts persistent data on the node it is running on.

| Parameter | Description | Default |
| - | - | - |
| `persistence.enabled` | Enables persistent volume - PV provisioner support necessary | true |
| `persistence.accessMode` | PVC Access Mode | ReadWriteMany |
| `persistence.size` | PVC Size | 5Gi |
| `persistence.storageClass` | PVC Storage Class | _empty_ |
| `persistence.name` | PVC Name | "crate-pv" |

## Support

The helm charts are provided "as-is" and without warranty of any kind.

All helm charts and packages are supported through standard open source forums and helm charts are updated on a best effort basis.

Any issues found can be reported through the links below, and fixes may be proposed/submitted using standard git issues as noted below.

[Submit issue to Helm Chart](https://github.com/ppc64le/charts/issues )

[Submit issue to crate docker image](https://github.com/ppc64le/build-scripts/issues )

[Submit issue to crate open source community](https://github.com/crate/crate/issues )

[ICP Support](https://ibm.biz/icpsupport)

## Limitations

## NOTE
This chart is validated on ppc64le only.

