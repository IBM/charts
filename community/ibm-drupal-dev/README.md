# Drupal

[Drupal](https://www.drupal.org/) is one of the most versatile open source content management systems on the market.

## TL;DR;

```console
$ helm install community/ibm-drupal-dev
```

## Introduction

This chart bootstraps a [Drupal](https://hub.docker.com/r/ppc64le/drupal/) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites
- Kubernetes 1.4+ with Beta APIs enabled
- PV provisioner support in the underlying infrastructure

## PodSecurityPolicy Requirements
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose predefined ibm-restricted-psp PodSecurityPolicy.

## Resources Required
The chart deploys pods consuming minimum resources as specified in the resources configuration parameter

## Chart Details
This chart will deploy Drupal.

## Limitations

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install --name my-release community/ibm-drupal-dev
```

The command deploys Drupal on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the Drupal chart and their default values.

| Parameter                                | Description                                | Default                                                   |
| ---------------------------------------- | ------------------------------------------ | --------------------------------------------------------- |
| `image.registry`                         | Drupal image registry                      | `docker.io`                                               |
| `image.repository`                       | Drupal Image name                          | `ppc64le/drupal`                                          |
| `image.tag`                              | Drupal Image tag                           | `8.6.10`                                                  |
| `image.pullPolicy`                       | Drupal image pull policy                   | `Always` if `imageTag` is `latest`, else `IfNotPresent`   |
| `externalDatabase.host`                  | Host of the external database              | `nil`                                                     |
| `externalDatabase.port`                  | Port of the external database              | `3306`                                                    |
| `externalDatabase.user`                  | Existing username in the external db       | `drupal`                                                  |
| `externalDatabase.password`              | Password for the above username            | `nil`                                                     |
| `externalDatabase.database`              | Name of the existing database              | `drupal`                                                  |
| `mariadb.enabled`                        | Whether to use the MariaDB chart           | `true`                                                    |
| `mariadb.database.name`                  | Database name to create                    | `drupal`                                                  |
| `mariadb.database.user`                  | Database user to create                    | `drupal`                                                  |
| `mariadb.database.password`              | Password for the database                  | _random 10 character long alphanumeric string_            |
| `mariadb.service.port`                   | Database port                              | `3306`                                                    |
| `mariadb.persistence.enabled`            | Enable database persistence using PVC      | `true`                                                    |
| `mariadb.dataVolume.storageClassName`    | PVC Storage Class                          | `""`                                                      |
| `mariadb.dataVolume.accessMode`          | PVC Access Mode                            | `ReadWriteMany`                                           |
| `mariadb.dataVolume.size`                | PVC Storage Request                        | `8Gi`                                                     |
| `service.type`                           | Kubernetes Service type                    | `NodePort`                                                |
| `service.port`                           | Service HTTP port                          | `80`                                                      |
| `service.nodePorts.http`                 | Kubernetes http node port                  | `""`                                                      |
| `persistence.enabled`                    | Enable persistence using PVC               | `true`                                                    |
| `persistence.apache.storageClass`        | PVC Storage Class for Apache volume        | `nil` (uses alpha storage class annotation)               |
| `persistence.apache.accessMode`          | PVC Access Mode for Apache volume          | `ReadWriteMany`                                           |
| `persistence.apache.size`                | PVC Storage Request for Apache volume      | `1Gi`                                                     |
| `persistence.drupal.storageClass`        | PVC Storage Class for Drupal volume        | `nil` (uses alpha storage class annotation)               |
| `persistence.drupal.accessMode`          | PVC Access Mode for Drupal volume          | `ReadWriteMany`                                           |
| `persistence.drupal.existingClaim`       | An Existing PVC name                       | `nil`                                                     |
| `persistence.drupal.hostPath`            | Host mount path for Drupal volume          | `nil` (will not mount to a host path)                     |
| `persistence.drupal.size`                | PVC Storage Request for Drupal volume      | `8Gi`                                                     |
| `resources`                              | CPU/Memory resource requests/limits        | `{}`                                                      |
| `volumeMounts.drupal.mountPath`          | Drupal data volume mount path              | `/bitnami/drupal`                                         |
| `volumeMounts.apache.mountPath`          | Apache data volume mount path              | `/bitnami/apache`                                         |
| `livenessProbe.httpGet.path`             | Liveness probe path                        | `/user/login`                                             |
| `livenessProbe.httpGet.port`             | Liveness probe port                        | `http`                                                    |
| `livenessProbe.initialDelaySeconds`      | Delay before liveness probe is initiated   | `120`                                                     |
| `readinessProbe.httpGet.path`            | Readiness probe path                       | `/user/login`                                             |
| `readinessProbe.httpGet.port`            | Readiness probe port                       | `http`                                                    |
| `readinessProbe.initialDelaySeconds`     | Delay before readiness probe is initiated  | `30`                                                      |
| `podAnnotations`                         | Pod annotations                            | `{}`                                                      |
| `nodeSelector`                           | Node labels for pod assignment             | `{}`                                                      |
| `tolerations`                            | List of node taints to tolerate            | `[]`                                                      |
| `affinity`                               | Map of node/pod affinities                 | `{}`                                                      |

The above parameters map to the env variables defined in [drupal](https://hub.docker.com/r/ppc64le/drupal/). For more information please refer to the [drupal](https://hub.docker.com/r/ppc64le/drupal/) image documentation.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```console
$ helm install --name my-release \
--set externalDatabase.user=drupal,externalDatabase.password=drupal \
  community/ibm-drupal-dev
```

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example,

```console
$ helm install --name my-release -f values.yaml community/ibm-drupal-dev
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## Support

The helm charts are provided "as-is" and without warranty of any kind.

All helm charts and packages are supported through standard open source forums and helm charts are updated on a best effort basis.

Any issues found can be reported through the links below, and fixes may be proposed/submitted using standard git issues as noted below.

[Submit issue to Helm Chart] ( https://github.com/ppc64le/charts/issues )

[Submit issue to Drupal docker image]  ( https://hub.docker.com/r/ppc64le/drupal/ )

[Submit issue to helm open source community] ( https://github.com/helm/helm/issues )

## Note

This chart is validated on ppc64le.

