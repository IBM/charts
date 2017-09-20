# MongoDB - BETA

[MongoDB](https://www.mongodb.com/) is a cross-platform document-oriented database. Classified as a NoSQL database, MongoDB eschews the traditional table-based relational database structure in favor of JSON-like documents with dynamic schemas, making the integration of data in certain types of applications easier and faster.

## Introduction

This chart bootstraps a [MongoDB](https://github.ibm.com/tools-for-aps/dsm_on_cloud/tree/master/platform/Kubernetes/IBMCp/Databases/MongoDB) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.4+ with Beta APIs enabled
- PV provisioner support in the underlying infrastructure

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install --name my-release stable/ibm-mongodb-dev
```

The command deploys MongoDB on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following tables lists the configurable parameters of the MongoDB chart and their default values.

|                  Parameter                   |             Description               |                         Default                          |
|----------------------------------------------|---------------------------------------|----------------------------------------------------------|
| `image`                                      | MongoDB image                         | `mongodb`                                                |
| `image.imagePullPolicy`                      | Image pull policy                     | `Always` if `imageTag` is `latest`, else `IfNotPresent`. |
| `database.user`                              | MongoDB admin user                    | `mongo`                                                  |
| `database.password`                          | MongoDB admin user password           | `nil`                                                    |
| `database.name`                              | Database to create                    | `admin`                                                  |
| `service.type`                               | Kubernetes Service type               | `ClusterIP`                                              |
| `service.port`                               | MongoDB port                          | `27017`                                                  |
| `persistence.enabled`                        | Use a PVC to persist data             | `true`                                                   |
| `persistence.useDynamicProvisioning`         | Specify a storageclass or leave empty | `false`                                                  |
| `dataVolume.persistence.enabled`             | Use a PVC to persist data             | `true`                                                   |
| `dataVolume.storageClassName`                | Storage class of backing PVC          | `nil` (uses alpha storage class annotation)              |
| `dataVolume.existingClaimName`               | Name of the Existing Claim to be used | `nil`                                                    |
| `dataVolume.size`                            | Size of data volume                   | `8Gi`                                                    |

The above parameters map to the env variables defined in [mongodb](https://github.ibm.com/tools-for-aps/dsm_on_cloud/tree/master/platform/Kubernetes/IBMCp/Databases/MongoDB). For more information please refer to the [mongodb](https://github.ibm.com/tools-for-aps/dsm_on_cloud/tree/master/platform/Kubernetes/IBMCp/Databases/MongoDB) image documentation.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
$ helm install --name my-release \
  --set database.password=mypassword,database.user=myuser \
    stable/ibm-mongodb-dev
```

The above command sets the MongoDB `myuser` account password to `mypassword`. 

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml stable/ibm-mongodb-dev
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## Persistence

The [mongoDB](https://github.ibm.com/tools-for-aps/dsm_on_cloud/tree/master/platform/Kubernetes/IBMCp/Databases/MongoDB) image stores the MongoDB data at the `/data/db` path of the container.

The chart mounts a [Persistent Volume](http://kubernetes.io/docs/user-guide/persistent-volumes/) volume at this location. The volume is created using dynamic volume provisioning.
