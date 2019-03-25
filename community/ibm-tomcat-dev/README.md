# Tomcat

[Tomcat](http://tomcat.apache.org/) - Apache Tomcat, often referred to as Tomcat Server, is an open-source Java Servlet Container


```console
$ helm install community/ibm-tomcat-dev
```
## PodSecurityPolicy Requirements
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose predefined ibm-anyuid-psp PodSecurityPolicy.

## Prerequisites

- Kubernetes 1.7+
- Tiller 2.7.2 or later

## Resources Required
The chart deploys pods consuming minimum resources as specified in the resources configuration parameter (default: Memory: 200Mi, CPU: 100m)

## Introduction

This chart bootstraps a [Tomcat](https://hub.docker.com/_/tomcat/) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.


## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install --name my-release community/ibm-tomcat-dev
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Chart Details
This chart bootstraps a [Tomcat](https://hub.docker.com/_/tomcat/) deployment on a [Kubernetes](http://kubernetes.io) cluster.


## Configuration

The following table lists the configurable parameters of the Tomcat chart and their default values.

|      Parameter            |          Description            |                         Default                         |
|---------------------------|---------------------------------|---------------------------------------------------------|
| `image.repository`        | Container image                 |  tomcat                                                 |
| `image.tag`               | Container image tag             |  9.0                                                    |
| `imagePullPolicy`         | Image pull policy               | `Always` if `imageTag` is `latest`, else `IfNotPresent` |
| `node`                    | Specify what architecture Node  | `ppc64le`                                               |
| `service.type`            | Kubernetes service type         | `NodePort`                                              |
| `replicaCount`            | Tomcat node replica count   | `1`                                                     |
| `resources.limits.cpu`    | Tomcat node cpu limit       |                                                         |
| `resources.limits.memory` | Tomcat node memory limit    |                                                         |
| `resources.requests.cpu`  | Tomcat node initial cpu request |                                                     |
| `resources.requests.memory` | Tomcat node initial memory request|                                                 |
| `service.port`            | Tomcat service port         | `8080`                                                 |
| `service.externalPort`    | Tomcat service External Port| `8888`                                                 |
| `service.internalPort`    | Tomcat service Internal Port| `8080`                                                 |
| `ingress.enabled          | If true, Tomcat Ingress will be created | false                                       |
| `ingress.annotations`     | Tomcat  Ingress annotations  | {}                                                      |
| `ingress.path`            | Tomcat Ingress Path         | /                                                       |
| `ingress.hosts`           | Tomcat Ingress hostnames    | []                                                      |
| `ingress.tls              | Tomcat Ingress TLS configuration (YAML)| []                                           |
| `Tolerations`             | Tolerations that are applied to pods for all the services | []                        |


The above parameters map to `ibm-tomcat-dev` params.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. 

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml community/ibm-tomcat-dev
```


## Support

The helm charts are provided "as-is" and without warranty of any kind.

All helm charts and packages are supported through standard open source forums and helm charts are updated on a best effort basis.

Any issues found can be reported through the links below, and fixes may be proposed/submitted using standard git issues as noted below.

[Submit issue to Helm Chart](https://github.com/ppc64le/charts/issues)

[Submit issue to Tomcat docker image](https://github.com/ppc64le/build-scripts/issues)

[Submit issue to Tomcat open source community](http://tomcat.apache.org/bugreport.html)



> **Tip**: You can use the default `values.yaml`

### Trusted Registry

Container Image Security is enabled by default in ICP 3.1 and above. Hence add the following to the trusted registries so they can be pulled.
* docker.io/ppc64le/tomcat:8


## Limitations
### NOTE: This chart has been validated on ppc64le.
