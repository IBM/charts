# Geode

[Geode](http://geode.apache.org/) Apache Geode provides a database-like consistency model, reliable transaction processing and a shared-nothing architecture to maintain very low latency performance with high concurrency processing.


```console
$ helm install community/ibm-geode-dev
```

## Prerequisites

- Kubernetes 1.7+ 
- Tiller 2.7.2 or later

## Resources Required
The chart deploys pods consuming minimum resources as specified in the resources configuration parameter (default: Memory: 200Mi, CPU: 100m)

## PodSecurityPolicy Requirements
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose predefined ibm-anyuid-psp PodSecurityPolicy.

## Introduction

This chart bootstraps a [Geode](https://hub.docker.com/r/ppc64le/geode ) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.


## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install --name my-release community/ibm-geode-dev
```

## Default Credentials
The default credentials for the Geode service are username - admin and password - admin


## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Chart Details
This chart bootstraps a [Geode](https://hub.docker.com/r/ppc64le/geode ) deployment on a [Kubernetes](http://kubernetes.io) cluster


## Configuration

The following table lists the configurable parameters of the Geode chart and their default values.


|      Parameter            |          Description            |                         Default                         |
|---------------------------|---------------------------------|---------------------------------------------------------|
| `image.repository`        | Container image                 |  ibmcom/geode-ppc64le                                   |
| `image.tag`               | Container image tag             |  1.8.0                                                  |
| `imagePullPolicy`         | Image pull policy               | `Always` if `imageTag` is `latest`, else `IfNotPresent` |
| `node`                    | Specify what architecture Node  | `ppc64le`                                               |
| `service.type`            | Kubernetes service type         | `NodePort`                                              |
| `service.port`            | Geode  exposed port             | `8080`                                                  |
| `replicaCount`            | Geode  node replica count       | `1`                                                     |
| `resources.limits.cpu`    | Geode  node cpu limit           |                                                         |
| `resources.limits.memory` | Geode  node memory limit        |                                                         |
| `resources.requests.cpu`  | Geode  node initial cpu request |                                                         |
| `resources.requests.memory` | Geode node initial memory request|                                                      |
| `service.type`            | Geode service type              | `NodePort`                                              |
| `service.port`            | Geode service port              | `8080`                                                  |
| `ingress.enabled          | If true, Geode Ingress will be created | false                                            |
| `ingress.annotations`     | Geode  Ingress annotations      | {}                                                      |
| `ingress.path`            | Geode Ingress Path              | /                                                       |
| `ingress.hosts`           | Geode Ingress hostnames         | []                                                      |
| `ingress.tls`             | Geode Ingress TLS configuration (YAML)| []                                                |
| `Tolerations`             | Tolerations that are applied to pods for all the services | []                            |


The above parameters map to `ibm-geode-dev` params.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. 

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml community/ibm-geode-dev
```

> **Tip**: You can use the default `values.yaml`

## Support

The helm charts are provided "as-is" and without warranty of any kind.

All helm charts and packages are supported through standard open source forums and helm charts are updated on a best effort basis.

Any issues found can be reported through the links below, and fixes may be proposed/submitted using standard git issues as noted below.

[Submit issue to Helm Chart](https://github.com/ppc64le/charts/issues)

[Submit issue to Geode docker image](https://github.com/ppc64le/build-scripts/issues)

[Submit issue to Geode open source community](https://issues.apache.org/jira/projects/GEODE/issues/GEODE-6152?filter=allopenissues)



## Limitations

### NOTE
This chart is validated on ppc64le.

