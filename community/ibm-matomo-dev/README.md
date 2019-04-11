# Matomo

[Matomo](https://matomo.org/) is one of the most versatile open source content management systems on the market. A publishing platform for building blogs and websites.

## TL;DR;

```console
$ helm install community/ibm-matomo-dev
```

## Introduction

This chart bootstraps a [Matomo](https://github.com/matomo-org/docker) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

It also packages the [MariaDB chart](https://github.com/helm/charts/tree/master/stable/mariadb) which is required for bootstrapping a MariaDB deployment for the database requirements of the Matomo application.

## Prerequisites

- Kubernetes 1.4+ with Beta APIs enabled
- PV provisioner support in the underlying infrastructure

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install --name my-release community/ibm-matomo-dev
```

The command deploys Matomo on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the Matomo chart and their default values.

|            Parameter                 |                Description                                  |             Default                    |
|--------------------------------------|-------------------------------------------------------------|----------------------------------------|
| `image.registry`                     | Matomo image registry                                       | `docker.io`                            |
| `image.repository`                   | Matomo image name                                           | `ppc64le/matomo`                       |
| `image.tag`                          | Matomo image tag                                            | `5.1.0`                                |
| `image.pullPolicy`                   | Image pull policy                                           | `Always` if `imageTag` is `latest`, else `IfNotPresent` |
| `matomoTablePrefix`                  | Table prefix                                                | `wp_`                                  |
| `replicaCount`                       | Number of Matomo Pods to run                                | `1`                                    |
| `externalDatabase.host`              | Host of the external database                               | `localhost`                            |
| `externalDatabase.user`              | Existing username in the external db                        | `matomo`                               |
| `externalDatabase.password`          | Password for the above username                             | `nil`                                  |
| `externalDatabase.database`          | Name of the existing database                               | `matomo`                               |
| `externalDatabase.port`              | Database port number                                        | `3306`                                 |
| `mariadb.enabled`                    | Deploy MariaDB container(s)                                 | `true`                                 |
| `mariadb.database.name`              | Database name to create                                     | `matomo`                               |
| `mariadb.database.user`              | Database user to create                                     | `matomo`                               |
| `mariadb.database.password`          | Password for the database                                   | _random 10 character long alphanumeric string_          |
| `mariadb.service.port`               | Database port                                               | `3306`                                                  |
| `mariadb.persistence.enabled`        | Enable database persistence using PVC                       | `true`                                                  |
| `mariadb.dataVolume.storageClassName`| PVC Storage Class                                           | `""`                                                    |
| `mariadb.dataVolume.accessMode`      | PVC Access Mode                                             | `ReadWriteMany`                                         |
| `mariadb.dataVolume.size`            | PVC Storage Request                                         | `8Gi`                                                   |
| `service.type`                       | Kubernetes Service type                                     | `NodePort`                                              |
| `service.port`                       | Service HTTP port                                           | `80`                                                    |
| `service.nodePorts.http`             | Kubernetes http node port                                   | `""`                                                    |
| `service.annotations`                | Service annotations                                         | `{}`                                                    |
| `livenessProbe.enabled`              | Enable/disable the liveness probe                           | `true`                                                  |
| `livenessProbe.initialDelaySeconds`  | Delay before liveness probe is initiated                    | `120`                                                   |
| `livenessProbe.periodSeconds`        | How often to perform the probe                              | `10`                                                    |
| `livenessProbe.timeoutSeconds`       | When the probe times out                                    | `5`                                                     |
| `livenessProbe.failureThreshold`     | Minimum consecutive failures to be considered failed        | `6`                                                     |
| `livenessProbe.successThreshold`     | Minimum consecutive successes to be considered successful   | `1`                                                     |
| `readinessProbe.enabled`             | Enable/disable the readiness probe                          | `true`                                                  |
| `readinessProbe.initialDelaySeconds` | Delay before readinessProbe is initiated                    | `30`                                                    |
| `readinessProbe.periodSeconds   `    | How often to perform the probe                              | `10`                                                    |
| `readinessProbe.timeoutSeconds`      | When the probe times out                                    | `5`                                                     |
| `readinessProbe.failureThreshold`    | Minimum consecutive failures to be considered failed        | `6`                                                     |
| `readinessProbe.successThreshold`    | Minimum consecutive successes to be considered successful   | `1`                                                     |
| `persistence.enabled`                | Enable persistence using PVC                                | `true`                                                  |
| `persistence.storageClass`           | PVC Storage Class                                           | `nil` (uses alpha storage class annotation)             |
| `persistence.existingClaim`          | Enable persistence using an existing PVC                    | `nil`                                                   |
| `persistence.accessMode`             | PVC Access Mode                                             | `ReadWriteMany`                                         |
| `persistence.size`                   | PVC Storage Request                                         | `10Gi`                                                  |
| `persistence.useDynamicProvisioning` | Dynamic Provisioning                                        | `false`                                                 |
| `resources`                          | Resources for the pod                                       | `{}`                                                    |
| `nodeSelector`                       | Node labels for pod assignment                              | `{}`                                                    |
| `tolerations`                        | List of node taints to tolerate                             | `[]`                                                    |
| `affinity`                           | Map of node/pod affinities                                  | `{}`                                                    |
| `podAnnotations`                     | Pod annotations                                             | `{}`                                   |      

The above parameters map to the env variables defined in [matomo](https://github.com/matomo-org/docker) For more information please refer to the [matomo](https://github.com/matomo-org/docker) image documentation.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```console
$ helm install --name my-release \
  --set mariadb.database.name=matomo,mariadb.database.user=matomo \
    community/ibm-matomo-dev
```

The above command sets the Matomo MariaDB database name to `matomo` and database user name to `matomo`.

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example,

```console
$ helm install --name my-release -f values.yaml community/ibm-matomo-dev
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## Persistence

Persistent Volume Claims are used to keep the data across deployments. This is known to work in GCE, AWS, and minikube.
See the [Configuration](#configuration) section to configure the PVC or to disable persistence.

## Resources Required

## PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose predefined ibm-restricted-psp PodSecurityPolicy.

## Chart Details

## Limitations

## Using an external database

Sometimes you may want to have matomo connect to an external database rather than installing one inside your cluster, e.g. to use a managed database service, or use run a single database server for all your applications. To do this, the chart allows you to specify credentials for an external database under the [`externalDatabase` parameter](#configuration). You should also disable the MariaDB installation with the `mariadb.enabled` option. For example:

```console
$ helm install community/ibm-matomo-dev \
    --set mariadb.enabled=false,externalDatabase.host=myexternalhost,externalDatabase.user=myuser,externalDatabase.password=mypassword,externalDatabase.database=mydatabase,externalDatabase.port=3306
```

Note also if you disable MariaDB per above you MUST supply values for the `externalDatabase` connection.

## Support

The helm charts are provided "as-is" and without warranty of any kind.

All helm charts and packages are supported through standard open source forums and helm charts are updated on a best effort basis.

Any issues found can be reported through the links below, and fixes may be proposed/submitted using standard git issues as noted below.

[Submit issue to Helm Chart] ( https://github.com/ppc64le/charts/issues )

[Submit issue to Matomo docker image]  ( https://hub.docker.com/r/ppc64le/matomo )

[Submit issue to helm open source community] ( https://github.com/helm/helm/issues )

## Note

This chart is validated on ppc64le.
