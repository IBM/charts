# Joomla!

[Joomla!](http://www.joomla.org/) is a PHP content management system (CMS) for publishing web content. It includes features such as page caching, RSS feeds, printable versions of pages, news flashes, blogs, search, and support for language international.

## TL;DR;

```console
$ helm install community/ibm-joomla-dev
```

## Introduction

This chart bootstraps a [Joomla!](https://github.com/docker-library/docs/tree/ppc64le/joomla) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.


## Prerequisites
- Kubernetes 1.4+ with Beta APIs enabled
- PV provisioner support in the underlying infrastructure

## PodSecurityPolicy Requirements
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose predefined ibm-restricted-psp PodSecurityPolicy.

## Resources Required
The chart deploys pods consuming minimum resources as specified in the resources configuration parameter.

## Chart Details
This chart will deploy WordPress.

## Limitations

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install --name my-release community/ibm-joomla-dev
```

The command deploys Joomla! on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the Joomla! chart and their default values.

| Parameter                            | Description                                                 | Default                                        |
| ------------------------------------ | ----------------------------------------------------------- | ---------------------------------------------- |
| `image.registry`                     | Joomla! image registry                                      | `docker.io`                                    |
| `image.repository`                   | Joomla! Image name                                          | `ibmcom/joomla-ppc64le`                        |
| `image.tag`                          | Joomla! Image tag                                           | `3.6.5`                                        |
| `image.pullPolicy`                   | Image pull policy                                           | `IfNotPresent`                                 |
| `externalDatabase.host`              | Host of the external database                               | `nil`                                          |
| `externalDatabase.port`              | Port of the external database                               | `3306`                                         |
| `externalDatabase.user`              | Existing username in the external db                        | `joomla`                                       |
| `externalDatabase.password`          | Password for the above username                             | `nil`                                          |
| `externalDatabase.database`          | Name of the existing database                               | `joomla`                                       |
| `mariadb.enabled`                    | Whether to use the MariaDB chart                            | `true`                                         |
| `mariadb.database.name`              | Database name to create                                     | `joomla`                                       |
| `mariadb.database.user`              | Database user to create                                     | `joomla`                                       |
| `mariadb.database.password`          | Password for the database                                   | `nil`                                          |
| `mariadb.service.port`               | Database port                                               | `3306`                                         |
| `mariadb.persistence.enabled`        | Enable database persistence using PVC                       | `true`                                         |
| `mariadb.dataVolume.storageClassName`| PVC Storage Class                                           | `""`                                           |
| `mariadb.dataVolume.accessMode`      | PVC Access Mode                                             | `ReadWriteMany`                                |
| `mariadb.dataVolume.size`            | PVC Storage Request                                         | `8Gi`                                          |
| `livenessProbe.enabled`              | Enable/disable the liveness probe                           | `true`                                         |
| `livenessProbe.initialDelaySeconds`  | Delay before liveness probe is initiated                    | `120`                                          |
| `livenessProbe.periodSeconds`        | How often to perform the probe                              | `10`                                           |
| `livenessProbe.timeoutSeconds`       | When the probe times out                                    | `5`                                            |
| `livenessProbe.failureThreshold`     | Minimum consecutive failures to be considered failed        | `6`                                            |
| `livenessProbe.successThreshold`     | Minimum consecutive successes to be considered successful   | `1`                                            |
| `readinessProbe.enabled`             | Enable/disable the readiness probe                          | `true`                                         |
| `readinessProbe.initialDelaySeconds` | Delay before readinessProbe is initiated                    | `30`                                           |
| `readinessProbe.periodSeconds   `    | How often to perform the probe                              | `10`                                           |
| `readinessProbe.timeoutSeconds`      | When the probe times out                                    | `5`                                            |
| `readinessProbe.failureThreshold`    | Minimum consecutive failures to be considered failed        | `6`                                            |
| `readinessProbe.successThreshold`    | Minimum consecutive successes to be considered successful   | `1`                                            |
| `service.type`                       | Kubernetes Service type                                     | `NodePort`                                     |
| `service.port`                       | Service HTTP port                                           | `80`                                           |
| `service.LoadBalancerIP`             | Kubernetes LoadBalancerIP to request                        | `nil`                                          |
| `service.nodePorts.http`             | Kubernetes http node port                                   | `""`                                           |
| `persistence.enabled`                | Enable persistence using PVC                                | `true`                                         |
| `persistence.apache.storageClass`    | PVC Storage Class for Apache volume                         | `nil` (uses alpha storage annotation)          |
| `persistence.apache.accessMode`      | PVC Access Mode for Apache volume                           | `ReadWriteMany`                                |
| `persistence.apache.size`            | PVC Storage Request for Apache volume                       | `1Gi`                                          |
| `persistence.joomla.storageClass`    | PVC Storage Class for Joomla! volume                        | `nil` (uses alpha storage annotation)          |
| `persistence.joomla.accessMode`      | PVC Access Mode for Joomla! volume                          | `ReadWriteMany`                                |
| `persistence.joomla.size`            | PVC Storage Request for Joomla! volume                      | `8Gi`                                          |
| `resources`                          | CPU/Memory resource requests/limits                         | `{}`                                           |
| `nodeSelector`                       | Node labels for pod assignment                              | `{}`                                           |
| `tolerations`                        | List of node taints to tolerate                             | `[]`                                           |
| `affinity`                           | Map of node/pod affinities                                  | `{}`                                           |
| `podAnnotations`                     | Pod annotations                                             | `{}`                                           |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```console
$ helm install --name my-release \
  --set externalDatabase.user=joomla,externalDatabase.password=password \
    community/ibm-joomla-dev
```

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example,

```console
$ helm install --name my-release -f values.yaml community/ibm-joomla-dev
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## Support

The helm charts are provided "as-is" and without warranty of any kind.

All helm charts and packages are supported through standard open source forums and helm charts are updated on a best effort basis.

Any issues found can be reported through the links below, and fixes may be proposed/submitted using standard git issues as noted below.

[Submit issue to Helm Chart] ( https://github.com/ppc64le/charts/issues )

[Submit issue to WordPress docker image]  ( https://hub.docker.com/r/ibmcom/joomla-ppc64le )

[Submit issue to helm open source community] ( https://github.com/helm/helm/issues )

## Note

This chart is validated on ppc64le.
