# Jetty

[Jetty](https://www.eclipse.org/jetty) Eclipse Jetty® - Web Container & Clients - supports HTTP/2, HTTP/1.1, HTTP/1.0, websocket, servlets, and more.

```console
$ helm install community/ibm-jetty
```

## Prerequisites

- Kubernetes 1.7+ 
- Tiller 2.7.2 or later

## Resources Required
The chart deploys pods consuming minimum resources as specified in the resources configuration parameter (default: Memory: 200Mi, CPU: 100m)

## PodSecurityPolicy Requirements
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose predefined ibm-anyuid PodSecurityPolicy.

## Introduction

This chart bootstraps a [Jetty](https://hub.docker.com/_/jetty/) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.


## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install --name my-release community/ibm-jetty
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Chart Details
This chart bootstraps a [Jetty](https://hub.docker.com/_/jetty/) deployment on a [Kubernetes](http://kubernetes.io) cluster


## Configuration

The following table lists the configurable parameters of the Jetty chart and their default values.

|      Parameter            |          Description            |                         Default                         |
|---------------------------|---------------------------------|---------------------------------------------------------|
| `image.repository`        | Container image                 |  ibmcom/jetty-ppc64le                                  |
| `image.tag`               | Container image tag             |  9.4.8                                                 |
| `image.pullPolicy`        | Image pull policy               | `Always` if `imageTag` is `latest`, else `IfNotPresent` |
| `node`                    | Specify what architecture Node  | `ppc64le`                                               |
| `service.type`            | Kubernetes service type         | `NodePort`                                              |
| `service.port`            | Jetty  exposed port             | `8080`                                                 |
| `replicaCount`            | Jetty  node replica count   | `1`                                                     |
| `resources.limits.cpu`    | Jetty  node cpu limit       |                                                         |
| `resources.limits.memory` | Jetty  node memory limit    |                                                         |
| `resources.requests.cpu`  | Jetty  node initial cpu request |                                                     |
| `resources.requests.memory` | Tomee node initial memory request|                                                 |
| `service.type`            | Jetty service type         | `NodePort`                                              |
| `service.port`            | Jetty service port         | `8080`                                                 |
| `ingress.enabled`         | If true, Jetty Ingress will be created | false                                       |
| `ingress.annotations`     | Jetty  Ingress annotations  | {}                                                      |
| `ingress.path`            | Jetty Ingress Path         | /                                                       |
| `ingress.hosts`           | Jetty Ingress hostnames    | []                                                      |
| `ingress.tls`              | Jetty Ingress TLS configuration (YAML)| []                                           |
| `Tolerations`             | Tolerations that are applied to pods for all the services | []                        |

The above parameters map to `ibm-jetty` params.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. 

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml community/ibm-jetty
```

> **Tip**: You can use the default `values.yaml`

## Support

The helm charts are provided "as-is" and without warranty of any kind.

All helm charts and packages are supported through standard open source forums and helm charts are updated on a best effort basis.

Any issues found can be reported through the links below, and fixes may be proposed/submitted using standard git issues as noted below.

[Submit issue to Helm Chart](https://github.com/ppc64le/charts/issues)

[Submit issue to Jetty docker image](https://github.com/ppc64le/build-scripts/issues)

[Submit issue to Jetty open source community](https://github.com/eclipse/jetty.project/issues)



## Limitations

### NOTE 
This chart has been validated on ppc64le.
