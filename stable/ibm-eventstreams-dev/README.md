 # IBM Event Streams (Tech Preview)

[IBM Event Streams](https://developer.ibm.com/messaging/event-streams/) is a high-throughput, fault-tolerant, pub-sub technology for building event-driven applications. It's built on top of [Apache Kafka®](https://kafka.apache.org/).

Please remember that this is a Tech Preview only. It represents one direction that IBM could take with Apache Kafka but please read the disclaimer below.

## Introduction

This chart deploys Apache Kafka® and supporting infrastructure such as Apache ZooKeeper™ for **_non-production use_**.

## Before You Start

Here are some optional steps you may choose to take before you install IBM Event Streams.

- We strongly recommend you create a namespace (see "Create a Namespace" below) to keep things tidy
- If you want your data to be persisted, create persistent volumes (see "Create Persistent Volumes" below) to prepare the storage

Now, you're ready to install IBM Event Streams.

## Prerequisites

If you prefer to install from the command prompt, you will need:

- The `kubectl` and `helm` commands available
- Your environment configured to connect to the target cluster

The installation environment has the following version prerequisites:

- Kubernetes 1.9

More detailed installation instructions about these steps can be found [here](
https://developer.ibm.com/messaging/event-streams/).

## Chart Details

This Helm chart will install the following:

- An Apache Kafka® cluster using a [StatefulSet](http://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/) with a configurable number of replicas (default 3)
- An Apache ZooKeeper™ ensemble using a [StatefulSet](http://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/) with 3 replicas
- An administration user interface using a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- An administration server using a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) to support the administration tools
- (Optional) A network proxy as a [Service](https://kubernetes.io/docs/concepts/services-networking/service/) so Apache Kafka clients can connect to Kafka from outside the Kubernetes cluster

## Resources Required

This Helm chart has the following resource requirements:

| Component             | Number of replicas | CPU/pod   | Memory/pod (Gi)|
| --------------------- | ------------------ | --------- | -------------- |
| Kafka                 | 3*                 | 1*        | 1*             |
| ZooKeeper             | 3                  | 0.1*      | 0.25*          |
| Administration UI     | 1                  | 0.1       | 0.25           |
| Administration server | 1                  | 1         | 1              |
| Network proxy         | 1                  | unlimited | unlimited      |

The settings marked with an asterisk (*) can be configured.

The CPU and memory limits for the network proxy are not limited by the chart, so will inherit the resource limits for the namespace that the chart is being installed into. If there are no resource limits set for the namespace, the network proxy pod will run with unbounded CPU and memory limits.

Persistence is not enabled by default and no persistent volumes are required. If you are going to enable persistence, you can find more information about storage requirements below.

## Installing the Chart

There are three steps to install IBM Event Streams in your environment:

- Create a namespace (Recommended)
- Create persistent volumes (Optional)
- Install IBM Event Streams

#### Create a Namespace

You can use a [namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/) to organise and control access to your environment. It is recommended to install IBM Event Streams into a separate namespace to keep things tidy.

Choose a name for your namespace and run this command using your chosen name:

```
kubectl create namespace <namespace_name>
```

If you choose not to create a namespace, use the "`default`" namespace instead when performing the installation.

#### Create Persistent Volumes

Persistence is not enabled by default so no persistent volumes are required. If you are not using persistence, you can skip this section.

Enable persistence if you want messages sent to topics and configuration to be retained in the event of a restart. If persistence is enabled, one physical volume will be required for each Kafka broker and ZooKeeper server.

You can find more information about storage requirements below.

#### Install IBM Event Streams

To install the chart, specify the release name and namespace on the following command:

```
helm install --name <release_name> \
     --namespace=<namespace_name> \
     --set license=accept \
     stable/ibm-eventstreams-dev
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

```
helm delete --purge <release_name>
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
| `license`                                       | Set this to accept the terms of the IBM license                                               | `Not accepted`                                             |
| `global.image.repository`                       | Container repository for Docker images                                                        | `ibmcom`                                                   |
| `global.image.pullSecret`                       | Image pull secret, if you are using a Docker registry that requires credentials               | `nil`                                                      |
| `global.image.pullPolicy`                       | Image pull policy                                                                             | `IfNotPresent`                                             |

### Kafka broker configuration

| Parameter                                       | Description                                                                                   | Default                                                    |
| ----------------------------------------------- | --------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| `kafka.resources.limits.cpu`                    | Kubernetes CPU limit for the Kafka container                                                  | `1000m`                                                    |
| `kafka.resources.limits.memory`                 | Kubernetes memory limit for the Kafka container                                               | `1Gi`                                                      |
| `kafka.resources.requests.cpu`                  | Kubernetes CPU request for the Kafka container                                                | `1000m`                                                    |
| `kafka.resources.requests.memory`               | Kubernetes memory request for the Kafka container                                             | `1Gi`                                                      |
| `kafka.brokers`                                 | Number of brokers in the Kafka cluster                                                        | `3`                                                        |
| `kafka.offsetsTopicReplicationFactor`           | The replication factor for the offsets topic                                                  | `3`                                                        |
| `kafka.minInsyncReplicas`                       | Cluster-wide minimum in-sync replica configuration                                            | `2`                                                        |
| `kafka.compressionType`                        | Cluster-wide final compression type configuration                                             | `producer`                                                 |
| `kafka.autoCreateTopicsEnable`               | Enable auto-creation of topics                                                                | `false`                                                    |
| `kafka.deleteTopicEnable`                     | Enable topic deletion                                                                         | `true`                                                     |

### Persistent Storage (Apache Kafka)

| Parameter                                       | Description                                                                                   | Default                                                    |
| ----------------------------------------------- | --------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| `persistence.enabled`                           | Whether to enable persistent storage for the Kafka brokers                                    | `false`                                                     |
| `persistence.useDynamicProvisioning`            | Whether to dynamically create persistent volume claims for the Kafka brokers                  | `false`                                                     |
| `persistence.dataPVC.name`                      | Prefix for name of the persistent volume claims for Kafka brokers                             | `datadir`                                                  |
| `persistence.dataPVC.storageClassName`          | Storage class to use for Kafka brokers if dynamically provisioning persistent volume claims   | `nil`                                                      |
| `persistence.dataPVC.size`                      | Minimum size to use for Kafka nodes if dynamically provisioning persistent volume claims      | `4Gi`                                                      |

### ZooKeeper settings

| Parameter                                       | Description                                                                                   | Default                                                    |
| ----------------------------------------------- | --------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| `zookeeper.resources.limits.cpu`                | Kubernetes CPU limit for the ZooKeeper container                                              | `100m`                                                    |
| `zookeeper.resources.requests.cpu`              | Kubernetes CPU request for the ZooKeeper container                                            | `100m`                                                    |
| `zookeeper.persistence.enabled`                 | Whether to use persistent storage for the ZooKeeper nodes                                     | `false`                                                     |
| `zookeeper.persistence.useDynamicProvisioning`  | Whether to dynamically create persistent volume claims for the ZooKeeper nodes                | `false`                                                     |
| `zookeeper.dataPVC.name`                        | Prefix for name of the persistent volume claims for ZooKeeper nodes                           | `datadir`                                                  |
| `zookeeper.dataPVC.storageClassName`            | Storage class to use for ZooKeeper nodes if dynamically provisioning persistent volume claims | `nil`                                                      |
| `zookeeper.dataPVC.size`                        | Minimum size to use for ZooKeeper nodes if dynamically provisioning persistent volume claims  | `2Gi`                                                      |

### Kafka external access configuration

| Parameter                                       | Description                                                                                   | Default                                                    |
| ----------------------------------------------- | --------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| `proxy.externalAccessEnabled`                   | Whether to allow external access to Kafka from outside the Kubernetes cluster                 | `false`                                                    |
| `proxy.secureConnectionsEnabled`                | Whether to enforce all external connections to be secured with TLS 1.2                        | `false`                                                    |
| `proxy.externalEndpoint`                        | The external hostname or IP address of the master node from which to expose node ports for external access   | `nil`                                                      |

### Secure connections

| Parameter                                       | Description                                                                                   | Default                                                    |
| ----------------------------------------------- | --------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| `tls.type`                                      | Type of certificate, specify 'selfsigned' to have one generated on install, or 'provided' if providing your own | `selfsigned`                                             |
| `tls.key`                                       | If tls.type is 'provided', this is the TLS key or private key                                 | `nil`                                                      |
| `tls.cert`                                      | If tls.type is 'provided', this is the TLS certificate or public key                          | `nil`                                                      |
| `tls.cacert`                                    | If tls.type is 'provided', this is the TLS cacert or Certificate Authority Root Certificate   | `nil`                                                      |

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

- The chart must be installed by a ClusterAdministrator.
- No upgrade path to a newer version of Kafka or the Helm chart is supported.
- IBM Power and Z Systems are not supported.
- For this Technology Preview, testing of persistence exclusively used manual allocation of physical volumes backed by NFS shares.
- Authentication is not enabled for the Administration server REST API in this Tech Preview.

## Documentation

Find out more about [IBM Event Streams](https://developer.ibm.com/messaging/event-streams/).

## Disclaimer

IBM’s statements regarding its plans, directions, and intent are subject to change or withdrawal without notice at IBM’s sole discretion.   Information regarding potential future products is intended to outline our general product direction and it should not be relied on in making a purchasing decision. The information mentioned regarding potential future products is not a commitment, promise, or legal obligation to deliver any material, code or functionality. Information about potential future products may not be incorporated into any contract. The development, release, and timing of any future features or functionality described for our products remains at our sole discretion.

