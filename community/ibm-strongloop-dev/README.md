# Strongloop

[Strongloop](https://strongloop.com/) - Open-source solutions for the API developer community.

```console
$ helm install community/ibm-strongloop-dev
```

## Prerequisites

- Kubernetes 1.7+ 
- Tiller 2.7.2 or later

## Resources Required
The chart deploys pods consuming minimum resources as specified in the resources configuration parameter (default: Memory: 200Mi, CPU: 100m).

## PodSecurityPolicy Requirements
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose predefined ibm-anyuid-psp PodSecurityPolicy.

## Introduction

This chart bootstraps a [Strongloop](https://github.com/strongloop) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.


## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install --name my-release community/ibm-strongloop-dev
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Chart Details
This chart bootstraps a [Strongloop](https://hub.docker.com/r/ibmcom/strongloop-ppc64le/) deployment on a [Kubernetes](http://kubernetes.io) cluster.


## Configuration

The following table lists the configurable parameters of the Strongloop chart and their default values.

|      Parameter            |          Description            |                         Default                         |
|---------------------------|---------------------------------|---------------------------------------------------------|
| `Docker image pull policy`| Image pull policy               | `Always` if `imageTag` is `latest`, else `IfNotPresent` |
| `Repository`              | Container image                 | `ibmcom/strongloop-ppc64le`                             |
| `Tag`                     | Container image tag             | `v6.0.3`                                                |
| `NodePreference           | Specify what architecture Node  | `ppc64le`                                               |
| `service.type`            | Kubernetes service type         | `NodePort`                                              |
| `service.port`            | Strongloop exposed port         | `41629`                                                 |
| `replicaCount`            | Strongloop node replica count   | `1`                                                     |
| `resources.limits.cpu`    | Strongloop node cpu limit       |                                                         |
| `resources.limits.memory` | Strongloop node memory limit    |                                                         |
| `resources.requests.cpu`  | Strongloop node initial cpu request |                                                     |	
| `resources.requests.memory` | Strongloop node initial memory request|                                                 |	
| `Service Type`            | Strongloop service type         | `NodePort`                                              |
| `HTTP Port`               | Strongloop service port         | `41629`                                                 |
| `Enable Ingress`          | If true, Strongloop Ingress will be created | false                                       |
| `Annotations`             | Strongloop Ingress annotations  | {}                                                      |
| `Path`                    | Strongloop Ingress Path         | /                                                       |
| `Virtual hosts`           | Strongloop Ingress hostnames    | []                                                      |
| `TLS`                     | Strongloop Ingress TLS configuration (YAML)| []                                           |
| `Tolerations`             | Tolerations that are applied to pods for all the services | []                            |



The above parameters map to `ibm-strongloop-dev` params.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. 

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml community/ibm-strongloop-dev
```

> **Tip**: You can use the default `values.yaml`

## Support

The helm charts are provided "as-is" and without warranty of any kind.

All helm charts and packages are supported through standard open source forums and helm charts are updated on a best effort basis.

Any issues found can be reported through the links below, and fixes may be proposed/submitted using standard git issues as noted below.

[Submit issue to Helm Chart](https://github.com/ppc64le/charts/issues )

[Submit issue to strongloop docker image](https://github.com/ppc64le/build-scripts/issues )

[Submit issue to strongloop open source community](https://github.com/strongloop/strongloop/issues )

[ICP Support](https://ibm.biz/icpsupport )

## Limitations

## NOTE
This chart is validated on ppc64le only.

