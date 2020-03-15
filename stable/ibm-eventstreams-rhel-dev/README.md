# IBM Event Streams Community Edition

*THIS CHART IS NOW DEPRECATED.* Here’s what you need to know: On March 13th, 2020 the helm chart for IBM Event Streams Community Edition will no longer be supported and, eventually, it will be removed from IBM's public helm repository on github.com on April 21th 2020.

Built on Apache Kafka®, [IBM Event Streams](https://ibm.github.io/event-streams/) is a high-throughput, fault-tolerant, event streaming platform that helps you build intelligent, responsive, event-driven applications. Event Streams release 2019.2.1 uses the [Kafka](https://kafka.apache.org/) 2.2.0 release and supports the use of all Kafka interfaces.

## Introduction

This chart deploys Apache Kafka® and supporting infrastructure such as Apache ZooKeeper™. For more information about IBM Event Streams, see the [Event Streams product documentation](https://ibm.github.io/event-streams/about/overview/).

## Chart Details

This Helm chart will install the following:

- An Apache Kafka® cluster using a [StatefulSet](http://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/) with a configurable number of replicas (default is 3)
- An Apache ZooKeeper™ ensemble using a [StatefulSet](http://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/) with 3 replicas
- An administration user interface using a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- An administration server using a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) to support the administration tools
- A REST producer server using a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) to support the sending of messages to IBM Event Streams by using a HTTP POST request
- A REST proxy as a [Service](https://kubernetes.io/docs/concepts/services-networking/service/) to enable connection by REST clients
- A network proxy as a [Service](https://kubernetes.io/docs/concepts/services-networking/service/) to enable connection by kafka clients
- Pod network access rules as a [NetworkPolicy](https://kubernetes.io/docs/concepts/services-networking/network-policies) to control how pods are allowed to communicate
- An access controller as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) to support Kafka authorization
- An Elasticsearch cluster using a [StatefulSet](http://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/) with 2 replicas to support the user interface
- An index manager as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) to provide access to the Elasticsearch nodes
- A Collector as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) to provide monitoring metrics to Prometheus
- A schema registry as a [StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/) to support structured messages, with 2 replicas if persistence is enabled, or 1 if it is not

## Prerequisites

To install using the command line, ensure you have the following:

- The `cloudctl`, `kubectl` and `helm` commands available
- Your environment configured to connect to the target cluster

The installation environment has the following prerequisites:

- Kubernetes 1.9 or later
- A namespace dedicated for use by IBM Event Streams (see "Create a Namespace" below)
- PersistentVolume support in the underlying infrastructure if `persistence.enabled=true` (See "Create Persistent Volumes" below)
### Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a SecurityContextConstraint to be bound to the target namespace prior to installation.

The predefined `SecurityContextConstraints` name: [`ibm-restricted-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this `SecurityContextConstraint` resource you can proceed to install the chart.

Alternatively, you can enable a custom SecurityContextConstraint which can be used to finely control the permissions and capabilities needed to deploy this chart. You can enable this custom SecurityContextConstraint resource using the supplied [setup script](#prereq-scripts---how-to-locate).

Custom SecurityContextConstraints definition:

```
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegedContainer: false
allowedCapabilities: null
allowedFlexVolumes: null
apiVersion: security.openshift.io/v1
defaultAddCapabilities: null
fsGroup:
  type: RunAsAny
kind: SecurityContextConstraints
metadata:
  name: ibm-es-scc
priority: 2
readOnlyRootFilesystem: false
requiredDropCapabilities:
  - MKNOD
runAsUser:
  type: MustRunAsRange
  uidRangeMax: 65534
  uidRangeMin: 5000
seLinuxContext:
  type: MustRunAs
supplementalGroups:
  type: RunAsAny
volumes:
  - configMap
  - downwardAPI
  - emptyDir
  - persistentVolumeClaim
  - projected
  - secret
```

### Prereq scripts - How to locate

To prepare the platform you must run the following setup script which can be extracted from the PPA archive relating to this installation:

```
./pak_extensions/pre-install/scc.sh <namespace>
```

Where `<namespace>` is the namespace you created for your Event Streams installation.

## Resources Required

The following table lists the resource requirements of the IBM Event Streams Helm chart. For details about the requirements for each pod and their containers, see the tables in the [Event Streams product documentation](https://ibm.github.io/event-streams/installing/prerequisites/#helm-resource-requirements).

| Pods                   | Number of replicas | Minimum total CPU | Minimum total memory (Gi) |
| --------------------- | ------------------ | ----------------- | ------------------------- |
| Kafka pod      | 3*                 | 2.2*                | 4.7*                      |
| Event Streams core pods | 12 if no persistence enabled  | 13 if no persistence enabled   | 10 if no persistence enabled   |
| &nbsp;            |  13 if persistence enabled  |  14 if persistence enabled  |  10.5 if persistence enabled|
| Message indexing pods  | 3  | 1.5  | 4.1  |

The settings marked with an asterisk (*) can be configured.




Persistence is not enabled by default and no persistent volumes are required. If you are going to enable persistence, you can find more information about storage requirements below.

If you enable message indexing (which is enabled by default), then you must have the `vm.max_map_count` property set to at least `262144` on all IBM Cloud Private nodes in your cluster (not only the master node). Please note this property may have already been updated by other workloads to be higher than the minimum required. Run the following commands on each node:
```
sudo sysctl -w vm.max_map_count=262144
```
```
echo "vm.max_map_count=262144" | tee -a /etc/sysctl.conf
```


## Installing the Chart

There are four steps to install IBM Event Streams in your environment:

- Create a namespace
- Create persistent volumes (Optional)
- Create a ConfigMap for Kafka static configuration (Optional)
- Install IBM Event Streams

### Create a Namespace

You must use a [namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/) dedicated for use by IBM Event Streams to ensure that the network access policies created by the chart are only applied to the Event Streams installation. Installation to the default namespace is not supported.

To create a namespace, you must have the Cluster Administrator role.

Choose a name for your namespace and run this command using your chosen name:

```
kubectl create namespace <namespace_name>
```

### Create Persistent Volumes

Persistence is not enabled by default so no persistent volumes are required. If you are not using persistence, you can skip this section.

Enable persistence if you want messages sent to topics and configuration to be retained in the event of a restart. If persistence is enabled, one physical volume will be required for each Kafka broker and ZooKeeper server.

To create physical volumes, you must have the Cluster Administrator role.

You can find more information about storage requirements below.

For volumes that support ownership management, specify the group ID of the group owning the persistent volumes' file systems using the `global.fsGroupGid` parameter.

### Create a ConfigMap for Kafka static configuration

You can override the default values for Kafka static configuration using a ConfigMap. These values are then supplied to the Kafka brokers using their `server.properties` files. This mechanism enables you to make changes to Kafka's read-only configuration properties.

To create a ConfigMap, you must have the Operator, Administrator or Cluster Administrator role. Create a ConfigMap from an existing Kafka `server.properties` file by running the following command:

```
kubectl -n <namespace_name> create configmap <configmap_name> --from-env-file=<path/to/server.properties>
```

Alternatively, you can create a blank ConfigMap for future configuration updates, run this command instead:

```
kubectl -n <namespace_name> create configmap <configmap_name>
```

Be sure to specify your config map name in the `kafka.configMapName` parameter during release configuration.

If you choose to omit this step, you may create the ConfigMap after installation and apply it using Helm's upgrade mechanism as shown below:

```
helm upgrade --reuse-values --set kafka.configMapName=<configmap_name> <release_name> ibm-eventstreams-rhel-dev --tls
```

### Install IBM Event Streams

To install the chart, your user id must have the Cluster Administrator role.

Add the IBM Cloud Private internal Helm repository called `local-charts` to the Helm CLI as an external repository, as described in the [IBM Cloud Private documentation](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.2.0/app_center/add_int_helm_repo_to_cli.html).

Install the chart, specifying the release name and namespace with the following command:

```
helm install --name <release_name> --namespace=<namespace_name> --set license=accept local-charts/ibm-eventstreams-rhel-dev --tls
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
helm delete <release_name> --purge --tls
```

This command removes all the Kubernetes components associated with the chart, except any persistent volume claims (PVCs). This is the default behavior of Kubernetes, and ensures that valuable data is not deleted. In order to delete the Kafka and ZooKeeper data, you can delete the PVC using the following command:

```
kubectl delete pvc -l release=<release_name>
```
WARNING: This will remove any existing data from the underlying physical volumes.

## Configuration

The following tables list the configurable parameters of the `ibm-eventstreams-rhel-dev` chart and their default values.

### Global install settings

| Parameter | Description                                                              | Default        |
| --------- | ------------------------------------------------------------------------ | -------------- |
| `license` | Set to 'accept' to indicate that you accept the terms of the IBM license | `Not accepted` |
| `global.image.repository`                       | Docker image registry                                                                         | `ibmcom`                        |
| `global.image.pullSecret`                       | Image pull secret, if using a Docker registry that requires credentials                       | `nil`                           |
| `global.image.pullPolicy`                       | Image pull policy                                                                             | `IfNotPresent`                  |
| `global.fsGroupGid`                             | File system group ID for volumes that support ownership management                            | `nil`                           |
| `global.arch`                                   | The worker node architecture where IBM Event Streams will be deployed                         | `amd64`                         |
| `global.security.tlsInternal` | Control the use of TLS between pods  | disabled  |

### Insights - help us improve our product

| Parameter           | Description                                                              | Default |
| ------------------- | ------------------------------------------------------------------------ | ------- |
| `telemetry.enabled` | Allow IBM to use in-application code to transmit product usage analytics | `false` |

### Kafka broker settings

| Parameter                         | Description                                                                                        | Default |
| --------------------------------- | -------------------------------------------------------------------------------------------------- | ------- |
| `kafka.resources.limits.cpu`      | CPU limit for Kafka brokers                                                                        | `1000m` |
| `kafka.resources.limits.memory`   | Memory limit for Kafka brokers                                                                     | `2Gi`   |
| `kafka.resources.requests.cpu`    | CPU request for Kafka brokers                                                                      | `1000m` |
| `kafka.resources.requests.memory` | Memory request for Kafka brokers                                                                   | `2Gi`   |
| `kafka.brokers`                   | Number of brokers in the Kafka cluster, minimum 3                                                  | `3`     |
| `kafka.configMapName`             | Optional ConfigMap used to apply static configuration to brokers in the cluster                    | `nil`   |
| `kafka.openJMX`                   | Open each Kafka broker's JMX port for secure connections from inside the IBM Cloud Private cluster | `false` |

### Kafka persistent storage settings

| Parameter                              | Description                                                            | Default   |
| -------------------------------------- | ---------------------------------------------------------------------- | --------- |
| `persistence.enabled`                  | Enable persistent storage for Apache Kafka                             | `false`   |
| `persistence.useDynamicProvisioning`   | Use dynamic provisioning for Apache Kafka                              | `false`   |
| `persistence.dataPVC.name`             | Prefix for the name of persistent volume claims used for Apache Kafka  | `datadir` |
| `persistence.dataPVC.storageClassName` | Storage class of the persistent volume claims created for Apache Kafka | `nil`     |
| `persistence.dataPVC.size`             | Size of the persistent volume claims created for Apache Kafka          | `4Gi`     |

### ZooKeeper settings

| Parameter                                      | Description                                                                 | Default   |
| ---------------------------------------------- | --------------------------------------------------------------------------- | --------- |
| `zookeeper.resources.limits.cpu`               | CPU limit for ZooKeeper servers                                             | `100m`    |
| `zookeeper.resources.requests.cpu`             | CPU request for ZooKeeper servers                                           | `100m`    |
| `zookeeper.persistence.enabled`                | Enable persistent storage for ZooKeeper servers                             | `false`   |
| `zookeeper.persistence.useDynamicProvisioning` | Use dynamic provisioning for ZooKeeper servers                              | `false`   |
| `zookeeper.dataPVC.name`                       | Prefix for the name of the persistent volume claims for ZooKeeper servers   | `datadir` |
| `zookeeper.dataPVC.storageClassName`           | Storage class of the persistent volume claims created for ZooKeeper servers | `nil`     |
| `zookeeper.dataPVC.size`                       | Size of the persistent volume claims created for ZooKeeper servers          | `2Gi`     |

### External access settings

| Parameter                | Description                                                                                    | Default |
| ------------------------ | ---------------------------------------------------------------------------------------------- | ------- |
| `proxy.externalEndpoint` | External hostname or IP address to be used by external clients, default to cluster master node | `nil`   |

### Secure connection settings

| Parameter    | Description                                                                                                     | Default      |
| ------------ | --------------------------------------------------------------------------------------------------------------- | ------------ |
| `tls.type`   | Type of certificate, specify 'selfsigned' to have one generated on install, or 'provided' if providing your own | `selfsigned` |
| `tls.key`    | If tls.type is 'provided', base64-encoded TLS private key                                                       | `nil`        |
| `tls.cert`   | If tls.type is 'provided', base64-encoded TLS certificate                                                       | `nil`        |
| `tls.cacert` | If tls.type is 'provided', base64-encoded CA certificate/bundle                                                 | `nil`        |

### Message indexing settings

| Parameter                                 | Description                                                        | Default                                                                |
| ----------------------------------------- | ------------------------------------------------------------------ | ---------------------------------------------------------------------- |
| `messageIndexing.messageIndexingEnabled`  | Enable message indexing to enhance browsing the messages on topics | `true` |
| `messageIndexing.resources.limits.memory` | Memory limits for Index Manager nodes                              | `2Gi`                                                                  |

### External monitoring settings

| Parameter                                     | Description                                                                                  | Default |
| --------------------------------------------- | -------------------------------------------------------------------------------------------- | ------- |
| `externalMonitoring.datadog.<check_template>` | JSON string for the required Datadog® Autodiscovery check template used for Kafka monitoring | `nil`   |

### Schema Registry settings

| Parameter                                              | Description                                                                       | Default   |
| -------------------------------------------------------| ----------------------------------------------------------------------------------| --------- |
| `schema-registry.persistence.enabled`                  | Enable persistent storage for Schema Registry servers                             | `false`   |
| `schema-registry.persistence.useDynamicProvisioning`   | Use dynamic provisioning for Schema Registry servers                              | `false`   |
| `schema-registry.dataPVC.name`                         | Prefix for the name of the persistent volume claims for Schema Registry servers   | `datadir` |
| `schema-registry.dataPVC.storageClassName`             | Storage class of the persistent volume claims created for Schema Registry servers | `nil`     |
| `schema-registry.dataPVC.size`                         | Size of the persistent volume claims created for Schema Registry servers          | `100Mi`   |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, you can use a YAML file to specify the values for the parameters.

## Storage

If persistence is enabled, each Kafka broker and ZooKeeper server requires one Physical Volume. The number of Kafka brokers and ZooKeeper servers depends on your setup. For default requirements, see the [resource requirements table](#resources-required). You either need to create a
[persistent volume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#static) for each Kafka broker and ZooKeeper server, or specify a
storage class that supports [dynamic provisioning](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#dynamic). Kafka and ZooKeeper can
use different storage classes to control how physical volumes are allocated.

If these persistent volumes are to be created manually, this must be done by the system administrator who will add these to a central pool before the Helm chart can be installed. The installation will then claim the required number of persistent volumes from this pool. For manual creation, 'dynamic provisioning' must be disabled in the Helm chart when it is installed. It is up to the administrator to provide appropriate storage to back these physical volumes.

If these persistent volumes are to be created automatically at the time of installation, the system administrator must enable support for this prior to installing the Helm chart. For automatic creation 'dynamic provisioning' should be enabled in the Helm chart when it is installed and storage class names provided to define which types of Persistent Volume get allocated to the deployment.

More information about persistent volumes and the system administration steps required can be found in the [Kubernetes documentation](https://kubernetes.io/docs/concepts/storage/persistent-volumes/).

## Limitations
- The chart must be deployed into a namespace dedicated for use by IBM Event Streams.
- The chart can only be deployed by a Cluster Administrator.
- Linux on Power (ppc64le) is not supported.
- Mixed worker node architecture deployments are not supported.

## Documentation

Find out more about [IBM Event Streams](https://ibm.github.io/event-streams/about/overview/).
