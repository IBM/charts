 # IBM Event Streams Community Edition

[IBM Event Streams](https://ibm.github.io/event-streams/) is a high-throughput, fault-tolerant, pub-sub technology for building event-driven applications. It's built on top of [Apache Kafka®](https://kafka.apache.org/) version 2.0.

## Introduction

This chart deploys Apache Kafka® and supporting infrastructure such as Apache ZooKeeper™. Further information about IBM Event Streams can be found [here](
https://ibm.github.io/event-streams/about/overview/).

## Chart Details

This Helm chart will install the following:

- An Apache Kafka® cluster using a [StatefulSet](http://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/) with a configurable number of replicas (default 3)
- An Apache ZooKeeper™ ensemble using a [StatefulSet](http://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/) with 3 replicas
- An administration user interface using a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- An administration server using a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) to support the administration tools
- A network proxy as a [Service](https://kubernetes.io/docs/concepts/services-networking/service/) to enable connection by clients
- Pod network access rules as a [NetworkPolicy](https://kubernetes.io/docs/concepts/services-networking/network-policies) to control how pods are allowed to communicate
- An access controller as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) to support Kafka authorization
- An Elasticsearch cluster using a [StatefulSet](http://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/) with 2 replicas to support the user interface
- An index manager as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) to provide access to the Elasticsearch nodes

## Prerequisites

If you prefer to install from the command prompt, you will need:

- The `cloudctl`, `kubectl` and `helm` commands available
- Your environment configured to connect to the target cluster

The installation environment has the following prerequisites:

- Kubernetes 1.11
- A namespace dedicated for use by IBM Event Streams (see "Create a Namespace" below)
- PersistentVolume support in the underlying infrastructure if `persistence.enabled=true` (See "Create Persistent Volumes" below)

## Resources Required

This Helm chart has the following resource requirements:

| Component             | Number of replicas | CPU/pod   | Memory/pod (Gi)|
| --------------------- | ------------------ | --------- | -------------- |
| Kafka                 | 3*                 | 1*        | 2*             |
| ZooKeeper             | 3                  | 0.1*      | 0.25*          |
| Administration UI     | 1                  | 1         | 1              |
| Administration server | 1                  | 1         | 2              |
| Network proxy         | 2                  | unlimited | unlimited      |
| Access controller     | 1                  | 0.1       | 0.25           |
| Index manager         | 1                  | unlimited | unlimited      |
| Elasticsearch         | 2                  | unlimited | 2              |

The settings marked with an asterisk (*) can be configured.

If the memory limit for the Kafka containers (`kafka.resources.limits.memory`) is modified, you must also modify the heap size for the Kafka JVM (`kafka.jvmHeapSize`) to match. It is recommended that the JVM heap size is set to 75% of the memory limit for the container.

The CPU and memory limits for the network proxy are not limited by the chart, so will inherit the resource limits for the namespace that the chart is being installed into. If there are no resource limits set for the namespace, the network proxy pod will run with unbounded CPU and memory limits.

Persistence is not enabled by default and no persistent volumes are required. If you are going to enable persistence, you can find more information about storage requirements below.

If you enable message indexing (which is enabled by default), then you must have the `vm.max_map_count` property set to at least `262144` on all IBM Cloud Private nodes in your cluster (not only the master node). Please note this property may have already been updated by other workloads to be higher than the minimum required. Run the following commands on each node:
```
sudo sysctl -w vm.max_map_count=262144
```
```
echo "vm.max_map_count=262144" | tee -a /etc/sysctl.conf
```

#### PodSecurityPolicy requirements

Any active PodSecurityPolicy must allow the following capabilities. If any of these are blocked, Event Streams will not operate correctly or may be unable to start.

- Access to the following volume types:
  - configMapName
  - emptyDir
  - persistentVolumeClaim
  - projected


- fsGroup support for the following group ids:
  - 1000
  - 1001


- runAsUser support for the following user ids:
  - 1000
  - 1001
  - 65534


- readOnlyRootFilesystem must be false

- Retain default settings for the following capabilities:
  - SELinux
  - AppArmor
  - seccomp
  - sysctl



## Installing the Chart

There are four steps to install IBM Event Streams in your environment:

- Create a namespace
- Create persistent volumes (Optional)
- Create a ConfigMap for Kafka static configuration (Optional)
- Install IBM Event Streams

#### Create a Namespace

You must use a [namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/) dedicated for use by IBM Event Streams to ensure that the network access policies created by the chart are only applied to the Event Streams installation. Installation to the default namespace is not supported.

To create a namespace, you must have the Cluster administrator role. Choose a name for your namespace and run this command using your chosen name:

```
kubectl create namespace <namespace_name>
```

#### Create Persistent Volumes

Persistence is not enabled by default so no persistent volumes are required. If you are not using persistence, you can skip this section.

Enable persistence if you want messages sent to topics and configuration to be retained in the event of a restart. If persistence is enabled, one physical volume will be required for each Kafka broker and ZooKeeper server.

To create physical volumes, you must have the Cluster administrator role.

You can find more information about storage requirements below.

For volumes that support onwership management, specify the group ID of the group owning the persistent volumes' file systems using the `global.fsGroupGid` parameter.

#### Create a ConfigMap for Kafka static configuration

You can override the default values for Kafka static configuration using a ConfigMap. These values are then supplied to the Kafka brokers using their `server.properties` files. This mechanism enables you to make changes to Kafka's read-only configuration properties.

To create a ConfigMap, you must have the Operator, Administrator or Cluster administrator role. Create a ConfigMap from an existing Kafka `server.properties` file by running the following command:

```
kubectl -n <namespace_name> create configmap <configmap_name> --from-env-file=<path/to/server.properties>
```

Alternateivly, you can create a blank ConfigMap for future configuration updates, run this command instead:

```
kubectl -n <namespace_name> create configmap <configmap_name>
```

Be sure to specify your config map name in the `kafka.configMapName` parameter during release configuration.

If you choose to omit this step, you may create the ConfigMap after installation and apply it using Helm's upgrade mechanism as shown below:

```
helm upgrade --reuse-values --set kafka.configMapName=<configmap_name> <release_name> ibm-eventstreams-dev --tls
```

#### Install IBM Event Streams

To install the chart, your user id must have the Administrator or Cluster administrator role.

Add the IBM Cloud Private internal Helm repository called `local-charts` to the Helm CLI as an external repository, as described [here](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.0/app_center/add_int_helm_repo_to_cli.html).

Install the chart, specifying the release name and namespace with the following command:

```
helm install --name <release_name> --namespace=<namespace_name> --set license=accept ibm-eventstreams-dev --tls
```

NOTE: The release name should consist of lower-case alphanumeric characters and not start with a digit or contain a space.

The command deploys IBM Event Streams on the Kubernetes cluster with the default configuration.

The Configuration section lists the parameters that can be overridden during installation by adding them to the Helm install command as follows:

```
--set key=value[,key=value]
```

### Verifying the Chart

See the NOTES.txt file associated with this chart for verification instructions.

### Uninstalling the Chart

To uninstall IBM Event Streams:

```
helm delete <release_name> --purge --tls
```

This command removes all the Kubernetes components associated with the chart, except any persistent volume claims (PVCs). This is the default behavior of Kubernetes, and ensures that valuable data is not deleted. In order to delete the Kafka and ZooKeeper data, you can delete the PVC using the following command:

```
kubectl delete pvc -l release=<release_name>
```
WARNING: This will remove any existing data from the underlying physical volumes.

## Configuration

The following tables list the configurable parameters of the `ibm-eventstreams-dev` chart and their default values.

### Global install settings

| Parameter                                       | Description                                                                                   | Default                                                    |
| ----------------------------------------------- | --------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| `license`                                       | Set to 'accept' to indiate that you accept the terms of the IBM license                       | `Not accepted`                                             |
| `global.image.repository`                       | Docker image registry                                                                         | `ibmcom`                                                   |
| `global.image.pullSecret`                       | Image pull secret, if using a Docker registry that requires credentials                       | `nil`                                                      |
| `global.image.pullPolicy`                       | Image pull policy                                                                             | `IfNotPresent`                                             |
| `global.fsGroupGid`                             | File system group ID for volumes that support ownership management                            | `nil`                                                      |

### Insights - help us improve our product

| Parameter                                       | Description                                                                                   | Default                                                    |
| ----------------------------------------------- | --------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| `telemetry.enabled`                             | Allow IBM to use in-application code to transmit product usage analytics                      | `false`                                                    |

### Kafka broker settings

| Parameter                                       | Description                                                                                   | Default                                                    |
| ----------------------------------------------- | --------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| `kafka.resources.limits.cpu`                    | CPU limit for Kafka brokers                                                                   | `1000m`                                                    |
| `kafka.resources.limits.memory`                 | Memory limit for Kafka brokers                                                                | `2Gi`                                                      |
| `kafka.resources.requests.cpu`                  | CPU request for Kafka brokers                                                                 | `1000m`                                                    |
| `kafka.resources.requests.memory`               | Memory request for Kafka brokers                                                              | `2Gi`                                                      |
| `kafka.jvmHeapSize`                             | Maximum heap size for Kafka broker JVMs                                                       | `1500M`                                                    |
| `kafka.brokers`                                 | Number of brokers in the Kafka cluster, minimum 3                                             | `3`                                                        |
| `kafka.configMapName`                           | Optional ConfigMap used to apply static configuration to brokers in the cluster               | `nil`                                                      |

### Kafka persistent storage settings

| Parameter                                       | Description                                                                                   | Default                                                    |
| ----------------------------------------------- | --------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| `persistence.enabled`                           | Enable persistent storage for Apache Kafka                                                    | `false`                                                    |
| `persistence.useDynamicProvisioning`            | Use dynamic provisioning for Apache Kafka                                                     | `false`                                                    |
| `persistence.dataPVC.name`                      | Prefix for the name of persistent volume claims used for Apache Kafka                         | `datadir`                                                  |
| `persistence.dataPVC.storageClassName`          | Storage class of the persistent volume claims created for Apache Kafka                        | `nil`                                                      |
| `persistence.dataPVC.size`                      | Size of the persistent volume claims created for Apache Kafka                                 | `4Gi`                                                      |

### ZooKeeper settings

| Parameter                                       | Description                                                                                   | Default                                                    |
| ----------------------------------------------- | --------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| `zookeeper.resources.limits.cpu`                | CPU limit for ZooKeeper servers                                                               | `100m`                                                     |
| `zookeeper.resources.requests.cpu`              | CPU request for ZooKeeper servers                                                             | `100m`                                                     |
| `zookeeper.persistence.enabled`                 | Enable persistent storage for ZooKeeper servers                                               | `false`                                                    |
| `zookeeper.persistence.useDynamicProvisioning`  | Use dynamic provisioning for ZooKeeper servers                                                | `false`                                                    |
| `zookeeper.dataPVC.name`                        | Prefix for the name of the persistent volume claims for ZooKeeper servers                     | `datadir`                                                  |
| `zookeeper.dataPVC.storageClassName`            | Storage class of the persistent volume claims created for ZooKeeper servers                   | `nil`                                                      |
| `zookeeper.dataPVC.size`                        | Size of the persistent volume claims created for ZooKeeper servers                            | `2Gi`                                                      |

### External access settings

| Parameter                                       | Description                                                                                    | Default                                                    |
| ----------------------------------------------- | ---------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| `proxy.externalEndpoint`                        | External hostname or IP address to be used by external clients, default to cluster master node | `nil`                                                      |

### Secure connection settings

| Parameter                                       | Description                                                                                   | Default                                                    |
| ----------------------------------------------- | --------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| `tls.type`                                      | Type of certificate, specify 'selfsigned' to have one generated on install, or 'provided' if providing your own | `selfsigned`                             |
| `tls.key`                                       | If tls.type is 'provided', base64-encoded TLS private key                                     | `nil`                                                      |
| `tls.cert`                                      | If tls.type is 'provided', base64-encoded TLS certificate                                     | `nil`                                                      |
| `tls.cacert`                                    | If tls.type is 'provided', base64-encoded CA certificate/bundle                               | `nil`                                                      |

### Message indexing settings

| Parameter                                       | Description                                                                                   | Default                                                    |
| ----------------------------------------------- | --------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| `messageIndexing.messageIndexingEnabled`        | Enable message indexing to enhance browsing the messages on topics                            | `true`                                                     |
| `messageIndexing.resources.limits.memory`       | Memory limits for Index Manager nodes                                                         | `2Gi`                                                      |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, you can use a YAML file to specify the values for the parameters.

## Storage

If persistence is enabled, each Kafka broker and ZooKeeper server requires one Physical Volume. You either need to create a
[persistent volume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#static) for each Kafka broker and ZooKeeper server, or specify a
storage class that supports [dynamic provisioning](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#dynamic). Kafka and ZooKeeper can
use different storage classes to control how physical volumes are allocated.

If these persistent volumes are to be created manually, this must be done by the system administrator who will add these to a central pool before the Helm chart can be installed. The installation will then claim the required number of persistent volumes from this pool. For manual creation, 'dynamic provisioning' must be disabled in the Helm chart when it is installed. It is up to the administrator to provide appropriate storage to back these physical volumes.

If these persistent volumes are to be created automatically at the time of installation, the system administrator must enable support for this prior to installing the Helm chart. For automatic creation 'dynamic provisioning' should be enabled in the Helm chart when it is installed and storage class names provided to define which types of Persistent Volume get allocated to the deployment.

More information about persistent volumes and the system administration steps required can be found [here](https://kubernetes.io/docs/concepts/storage/persistent-volumes/).

## Limitations

- The chart must be deployed into a namespace dedicated for use by IBM Event Streams.
- The chart can be deployed by an Administrator or Cluster administrator.
- Linux on Power (ppc64le) and IBM Z (s390x) platforms are not supported.

## Documentation

Find out more about [IBM Event Streams](https://ibm.github.io/event-streams/about/overview/).
