# TOMEE

[TOMEE](http://tomee.apache.org/) - The Embedded or Remote EE Application Server.

```console
$ helm install community/ibm-tomee-dev
```

## PodSecurityPolicy Requirements
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose predefined ibm-anyuid-psp PodSecurityPolicy.

## Prerequisites

- Kubernetes 1.7+ 
- Tiller 2.7.2 or later

## Resources Required
The chart deploys pods consuming minimum resources as specified in the resources configuration parameter (default: Memory: 200Mi, CPU: 100m)

## Introduction

This chart bootstraps a [TOMEE](https://github.com/apache/tomee) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.


## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm intall --name my-release community/ibm-tomee-dev
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Chart Details
This chart bootstraps a [TOMEE](https://hub.docker.com/r/ppc64le/tomee/) deployment on a [Kubernetes](http://kubernetes.io) cluster


## Configuration

The following table lists the configurable parameters of the Open Liberty chart and their default values.

|      Parameter            |          Description            |                         Default                         |
|---------------------------|---------------------------------|---------------------------------------------------------|
| `image.repository`        | Container image                 |  tomee                                                 |
| `image.tag`               | Container image tag             |  8-jre-1.7.5-webprofile                                 |
| `image.pullPolicy`         | Image pull policy               | `Always` if `imageTag` is `latest`, else `IfNotPresent` |
| `NodePreference           | Specify what architecture Node  | `ppc64le`                                               |
| `service.type`            | Kubernetes service type         | `NodePort`                                              |
| `service.port`            | Tomee  exposed port             | `8080`                                                 |
| `replicaCount`            | Tomee  node replica count   | `1`                                                     |
| `resources.limits.cpu`    | Tomee  node cpu limit       |                                                         |
| `resources.limits.memory` | Tomee  node memory limit    |                                                         |
| `resources.requests.cpu`  | Tomee  node initial cpu request |                                                     |
| `resources.requests.memory` | Tomee node initial memory request|                                                 |
| `service.type`            | Tomee service type         | `NodePort`                                              |
| `service.port`            | Tomee service port         | `8080`                                                 |
| `ingress.enabled`         | If true, Tomee Ingress will be created | false                                       |
| `ingress.annotations`     | Tomee  Ingress annotations  | {}                                                      |
| `ingress.path`            | Tomee Ingress Path         | /                                                       |
| `ingress.hosts`           | Tomee Ingress hostnames    | []                                                      |
| `ingress.tls              | Tomee Ingress TLS configuration (YAML)| []                                           |
| `Tolerations`             | Tolerations that are applied to pods for all the services | []                        |



The above parameters map to `ibm-tomee-dev` params.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. 

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml community/ibm-tomee-dev
```


## Support

The helm charts are provided "as-is" and without warranty of any kind.

All helm charts and packages are supported through standard open source forums and helm charts are updated on a best effort basis.

Any issues found can be reported through the links below, and fixes may be proposed/submitted using standard git issues as noted below.

[Submit issue to Helm Chart](https://github.com/ppc64le/charts/issues)

[Submit issue to Tomee docker image](https://github.com/ppc64le/build-scripts/issues)

[Submit issue to Tomee open source community](https://jira.apache.org/jira/projects/TOMEE/issues/TOMEE-2365?filter=allopenissues)



> **Tip**: You can use the default `values.yaml`


### Trusted Registry
Container Image Security is enabled by default in ICP 3.1 and above. Hence add the following to the trusted registries so they can be pulled.
 * docker.io/tomee:8-jre-1.7.5-webprofile

## Limitations
### NOTE 
This chart has been validated on ppc64le.
