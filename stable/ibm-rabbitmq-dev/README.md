# RabbitMQ

[RabbitMQ](https://www.rabbitmq.com/) is an open source message broker software that implements the Advanced Message Queuing Protocol (AMQP).

## Introduction

This chart bootstraps a [RabbitMQ](https://www.rabbitmq.com/) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.9 or later
- Tiller 2.7.2 or later
- To persist data, a PersistentVolume needs to be pre-created prior to installing the chart if `persistance.enabled=true` and `persistence.dynamicProvisioning=false` (default values, see [persistence](#persistence) section). It can be created by using the IBM Cloud Private UI or with the CLI. Create a `pv.yaml` file with the following content:
  ```bash
  apiVersion: v1
  kind: PersistentVolume
  metadata:
    name: my-release-rabbitmq
  spec:
    accessModes:
      - ReadWriteOnce
    capacity:
      storage: 8Gi
    hostPath:
      path: /var/data/my-release-rabbitmq
  ```
  From shell, run the following:
  ```bash
  $ kubectl create -f pv.yaml
  ```

## Installing the Chart

> This deploys RabbitMQ on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

Install the chart with the release name `my-release` and default configuration:

```bash
$ helm install -n my-release stable/ibm-rabbitmq-dev
```

After the command runs, it will print the current status of the release and extra information such as how to access the RabbitMQ admin console with a browser. You can also access the admin console through the IBM Cloud Private UI:
1. From Menu navigate to **Workloads -> Deployments**
2. Click the deployment. The default from above is `my-release`
3. Click on Endpoint **"access stats"**


## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete --purge my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release. It will delete create Persistent Volume Claims but not Persistent Volumes.


## Configuration

The following tables lists the configurable parameters of the RabbitMQ chart and their default values.

|         Parameter          |                       Description                       |                         Default                          |
|----------------------------|---------------------------------------------------------|----------------------------------------------------------|
| `arch.amd64`               | Preference to run on amd64 architecture                 | `2 - No preference`                                      |
| `arch.ppc64le`             | Preference to run on ppc64le architecture               | `2 - No preference`                                      |
| `image.repository`         | Docker image repository                                 | `rabbitmq`                                               |
| `image.tag`                | Docker image tag                                        | `3.7.3-management-alpine`                                |
| `image.pullPolicy`         | Image pull policy                                       | `Always` if `imageTag` is `latest`, else `IfNotPresent`. |
| `image.pullSecret`         | Name of an image pull secret if using a private registry |                                                         |
| `rabbitmqUsername`         | RabbitMQ default username                               | `admin`                                                  |
| `rabbitmqPassword`         | RabbitMQ default user password                          | `admin`                                                  |
| `rabbitmqErlangCookie`     | Erlang cookie (how clustered nodes authenticate)        | _random 32 character long alphanumeric string_           |
| `rabbitmqNodePort`         | Node port (5671 with TLS, else 5672)                    | `5671`                                                   |
| `rabbitmqNodeType`         | Node type                                               | `stats`                                                  |
| `rabbitmqNodeName`         | Node name                                               | `rabbit`                                                 |
| `rabbitmqClusterNodeName`  | Node name to cluster with. e.g.: `clusternode@hostname` |                                                          |
| `rabbitmqVhost`            | RabbitMQ application vhost                              | `/`                                                      |
| `rabbitmqManagerPort`      | RabbitMQ Manager port (15671 with TLS, else 15672)      | `15671`                                                  |
| `persistence.enabled`      | Use a PVC to persist data                               | `true`                                                   |
| `persistence.useDynamicProvisioning` | Use dynamic provisioning                      | `false`                                                  |
| `dataPVC.name`             | Name of the Persistent Volume Claim to create           | `rabbitmq-data-pvc`                                      |
| `dataPVC.selector.label`   | Field to select the volume                              |                                                          |
| `dataPVC.selector.value`   | Value of the field to select the volume                 |                                                          |
| `dataPVC.storageClass`     | Storage class for dynamic provisioning                  |                                                          |
| `dataPVC.existingClaimName`| Use an existing PVC to persist data                     |                                                          |
| `dataPVC.accessMode`       | Use volume as ReadOnly or ReadWrite                     | `ReadWriteOnce`                                          |
| `dataPVC.size`             | Size of data volume                                     | `8Gi`                                                    |
| `resources.requests.cpu`   | Requested CPU                                           | `100m`                                                   |
| `resources.requests.memory` | Requested memory                                       | `256Mi`                                                  |
| `tls.enabled`              | Enabled TLS security on communications ports            | `true`                                                   |
| `tls.key`                  | Size of data volume                                     | `8Gi`                                                    |
| `tls.crt`                  | Size of data volume                                     | `8Gi`                                                    |
| `tls.cacrt`                | CA certficate for TLS (Base64 encoded)                  |                                                          |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
$ helm install --name my-release \
  --set rabbitmqUsername=admin,rabbitmqPassword=secretpassword,rabbitmqErlangCookie=secretcookie \
    stable/ibm-rabbitmq-dev
```

The above command sets the RabbitMQ admin username and password to `admin` and `secretpassword` respectively. Additionally the secure Erlang cookie is set to `secretcookie`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml stable/ibm-rabbitmq-dev
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## Persistence

The image stores the RabbitMQ data and configurations at the `/var/lib/rabbitmq` path of the container.

The chart mounts a [Persistent Volume](kubernetes.io/docs/user-guide/persistent-volumes/) volume at this location. By default, you must create the persistent volume ahead of time as shown in step 1 of the Installing the Chart section above. If you have dynamic provisioning set up, you can install the helm chart with persistence.useDynamicProvisioning=true. An existing PersistentVolumeClaim can also be defined.

### Using Existing PersistentVolumeClaims

1. Create the PersistentVolume
2. Create the PersistentVolumeClaim
3. Install the chart:
    ```bash
    $ helm install --set dataPVC.existingClaimName=PVC_NAME stable/ibm-rabbitmq-dev
    ```

## Copyright
© Copyright IBM Corporation 2018. All Rights Reserved.