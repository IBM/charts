# MariaDB Galera Cluster

[MariaDB](https://mariadb.org/) is one of the most popular database servers in the world. It’s made by the original developers of MySQL and guaranteed to stay open source. Notable users include Wikipedia, Facebook and Google.

[Galera Cluster](http://galeracluster.com/) is a multi-master solution for MariaDB which provides an easy-to-use, high-availability solution for MariaDB based databases.

## Introduction

This chart bootstraps a [MariaDB Galera Cluster](https://mariadb.com/kb/en/library/what-is-mariadb-galera-cluster/) deployment on a [Kubernetes](https://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.7+ with Beta APIs enabled
- [PersistentVolume Provisioner](https://github.com/kubernetes/examples/blob/master/staging/persistent-volume-provisioning/README.md)
support in the underlying infrastructure or manually created [Persistent Volumes](kubernetes.io/docs/user-guide/persistent-volumes/)

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install --name my-release stable/ibm-galera-mariadb-dev
```

The command deploys MariaDB Galera Cluster on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete --purge my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the MariaDB chart and their default values.

| Parameter                   | Description                                | Default        |
| --------------------------- | ------------------------------------------ | -------------- |
| `arch.amd64`                | Preference to run on amd64 architecture    | `2 - No preference` |
| `arch.ppc64le`              | Preference to run on ppc64le architecture  | `2 - No preference` |
| `image.repository`          | Docker image repository                    | `ibmcom/galera-mariadb` |
| `image.tag`                 | Docker image tag                           | `10.1-r1`      |
| `image.pullPolicy`          | Image pull policy                          | `IfNotPresent` |
| `mariadb.rootPassword`      | Password for the `root` user.              | _random 16 character alphanumeric string_ |
| `mariadb.user`              | Username of new user to create.            | `""`           |
| `mariadb.password`          | Password for the new user.                 | `""`           |
| `mariadb.database`          | Name for new database to create.           | `""`           |
| `mariadb.configMapName`     | Name of a ConfigMap containing a my_extra.cnf | `""`        |
| `replicas.replicaCount`     | Number of replicas to deploy               | `3`            |
| `persistence.enabled`       | Use a PVC to persist data                  | `true`         |
| `persistence.useDynamicProvisioning` | Use dynamic provisioning for all volumes	| `true`  |
| `dataPVC.storageClassName`  | Storage class of dynamic provisioning      | `""`           |
| `dataPVC.selector.label`    | Refine the binding process if not using dynamic provisioning with the name of a label to search for | `""` |
| `dataPVC.selector.value`    | Refine the binding process if not using dynamic provisioning with the value of a label to search for | `""` |
| `dataPVC.size`              | Size of data volume                        | `2Gi`          |
| `resources.requests.memory` | Memory resource requests                   | `256Mi`        |
| `resources.requests.cpu`    | CPU resource requests                      | `250m`         |
| `resources.limits.memory`   | Memory resource limits                     | `1Gi`          |
| `resources.limits.cpu`      | CPU resource limits                        | `1000m`        |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
$ helm install --name my-release \
  --set mariadb.rootPassword=secretpassword,mariadb.user=my-user,mariadb.password=my-password,mariadb.database=my-database \
    stable/ibm-galera-mariadb-dev
```

The above command sets the MariaDB `root` account password to `secretpassword`. Additionally it creates a standard database user named `my-user`, with the password `my-password`, who has access to a database named `my-database`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml stable/ibm-galera-mariadb-dev
```

> **Tip**: You can use the default [values.yaml](values.yaml)

### Random MariaDB root password

If you don't configure a password for the MariaDB `root` user, `helm` will
generate a random one for you. You can get the configured password from the
created Kubernetes secret:

```bash
$ kubectl get secret <release_name>-ibm-galera-mariadb-dev  -o jsonpath='{.data.mysql-root-password}' | base64 --decode
```

### Custom my.cnf configuration

A Kubernetes [ConfigMap](https://kubernetes.io/docs/user-guide/configmap/) can be created and use that supplies MariaDB configuration 
that would normally go in a `my.cnf` file. If you wnat to inject configuration, you will need to create a ConfigMap containing data for
`my_extra.cnf`.

For example, create a `galera-my-cnf.yaml` file with the following content:

```bash
apiVersion: v1
kind: ConfigMap
metadata:
  name: galera-my-cnf
data:
  my_extra.cnf: |-
    [mysqld]
    max_allowed_packet = 64M
    sql_mode=STRICT_ALL_TABLES
    innodb_buffer_pool_size=2G
```

And then create the ConfigMap:
```bash
kubectl create -f galera-my-cnf.yaml
```

## Persistence

The [MariaDB Galera Chart](https://github.com/kubernetes/charts/) image stores the MariaDB data files at the `/var/lib/mysql` path of the container.

The chart mounts a [Persistent Volume](kubernetes.io/docs/user-guide/persistent-volumes/) at this location in every pod of the StatefulSet. The volumes may be dynamically provisioned by a 
[PersistentVolume Provisioner](https://github.com/kubernetes/examples/blob/master/staging/persistent-volume-provisioning/README.md)
or may be manually created ahead of time and then claimed.
