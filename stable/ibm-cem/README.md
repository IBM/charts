# IBM Cloud Event Management

## Introduction
* Use the IBM® Cloud Event Management service to set up real-time incident management for your services, applications, and infrastructure.
* Restore service and resolve operational incidents fast!
* Empower your DevOps teams to correlate different sources of events into actionable incidents, synchronize teams, and automate incident resolution.
* The service sets you on course to achieve efficient and reliable operational health, service quality and continuous improvement.

## Chart Details
This chart will install the following:

Services via stateful sets:
* cassandra
* couchdb
* kafka
* zookeeper
* datalayer

Services not via stateful sets:
* rba-as
* brokers
* cem-users
* channelservices
* datalayer
* event-analytics-ui
* eventpreprocessor
* incidentprocessor
* integration-controller
* normalizer
* notificationprocessor
* rba-rbs
* scheduling-ui

Ingress resources:
* cem-api
* cem-ingress

Secrets:
* cem-couchdb-secret
* cem-brokers-cred-secret
* cem-cemusers-cred-secret
* cem-channelservices-cred-secret
* cem-email-cred-secret
* cem-event-analytics-ui-session-secret
* cem-integrationcontroller-cred-secret
* rba-devops-secret
* rba-jwt-secret

_NOTE:_
All resources created are prefixed with the release name. For example if the release name is 'user-release', the cassandra stateful set would be named 'user-release-cassandra''

Services and pods are spread across nodes using the Kubernetes anti-affinity
feature.

## Prerequisites
* Kubernetes v1.10 or higher
* The default storage class is used.  See the Storage section in this document.

## Resources Required
#### System resources, based on default install parameters.
* Minimum: 8GB Memory and 4 CPU
* Recommended: 16GB Memory and 18 CPU

The CPU resource is measured in Kuberenetes _cpu_ units. See Kubernetes documentation for details.  

#### Persistence:
* Cassandra will need 108GB of disk space
* Other components will need an additional 4GB

## Installing the Chart
* Set the `global.masterIP` parameter to the IP address of the kubernetes master node
* If multiple instances of the charts are installed set cemusers.secrets.oidcclientid and cemservicebroker.suffix to unique values.
* See the Storage section in this document for storage configuration considerations.

To install the chart with the release name `my-release`:

```bash
$ helm install --tls --name my-release stable/ibm-cloud-evtmgmt
```

The command deploys cloud-event-management on the Kubernetes cluster in the default configuration. The Configuration section in this document lists common parameters that can be configured during installation.

## Verifying the chart

* To verify the installation run the following kubectl command:
`helm test my-release --tls --cleanup`

## Post installation
Follow the instructions displayed after the helm installation completes.
See the  [Configuring](https://www.ibm.com/support/knowledgecenter/SSURRN/com.ibm.cem.doc/em_configuring.html) topic  in the [IBM Cloud Event Management Knowledge Center ](https://www.ibm.com/support/knowledgecenter/SSURRN/com.ibm.cem.doc/index.html)afterwards for further information on Cloud Event Management configuration and use.

### Uninstalling the Chart

To uninstall and delete the `my-release` deployment:

```bash
helm delete --purge my-release
```

The helm delete command does not delete Persistent Volumes created by the installation. If a chart is uninstalled and you do not want to retain its data, review any orphaned Persistent Volume claims using the following command, and delete as required.

```console
$ kubectl get pvc -l release=my-release
```

## Configuration

The following tables lists the global configurable parameters of the cloud-event-management chart and their default values.

| Parameter                                        | Description                              | Default              |
| ------------------------------------------------ | ---------------------------------------- | -------------------- |
| `global.masterIP`                                | The IP of the kubernetes master node     |                      |
| `global.masterPort`                              | The Port of the kubernetes master node   | `8443`               |
| `global.environmentSize`                         | The resource footprint requested         | `size0` _NOTE:1_     |
| `global.cassandraNodeReplicas`                   | The number of cassandra servers          | `1`                  |
| `global.persistence.enabled`                     | Data persistance between restarts        | `true`               |
| `global.persistence.storageClassName`            | Persistance storage name                 | `nil`                |
| `global.persistence.storageClassOption.datalayerjobs`   | Storage class option for Datalayer          | `default`              |
| `global.persistence.storageClassOption.kafkadata`       | Storage class option for Kafka              | `default`              |
| `global.persistence.storageClassOption.cassandradata`   | Storage class option for Cassandra data     | `default`              |
| `global.persistence.storageClassOption.cassandrabak`    | Storage class option for Cassandra backup   | `default`              |
| `global.persistence.storageClassOption.zookeeperdata`   | Storage class option for Zookeeper          | `default`              |
| `global.persistence.storageClassOption.couchdbdata`     | Storage class option for CouchDB            | `default`              |
| `global.persistence.storageSize.cassandradata`    | Data storage for each cassandra server   | `50Gi`               |
| `global.persistence.storageSize.cassandrabak`     | Backup storage for each casandra server  | `50Gi`               |
| `global.persistence.storageSize.couchdbdata `     | Storage for each couchdb server          | `1Gi`                |
| `global.persistence.storageSize.datalayerjobs `   | Storage for dataapi service              | `512Mi`              |
| `global.ingress.domain`                          | Fully Qualified Domain Name of Cloud Event Management            |          |
| `global.ingress.tlsSecret`                       | TLS cerfificates for Ingress controller  | _NOTE:2_             |
| `global.ingress.prefix`                          | Prefix for UI path to UI end point       | ``                   |

_NOTE:_

1. Valid values for `global.environmentSize` are `size0` and `size1`. `size0` specifies a minimal resource footprint for development and test purposes, while `size1` is intended for production systems with a larger footprint.

2. If this is left empty the default TLS certificate installed on the Ingress Controller is used.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart.

## Storage

* If the default storage class is glusterfs then Persistent Volumes will be dynamically provisioned.
* If you require a none-default storage class, update the persistance.storageClassName to the storage class name. Alternatively, set each
individual value under global.persistance.storageClassOption to specific persistent volumes.

## Limitations

* These charts can be deployed multiple times in the same namespace under different release names.
* To avoid multiple deployments in the same namespace, install one instance per namespace, and deploy multiple namespaces for ease of management and separation of resources.

_NOTE:_ IBM Cloud Event Management is multi-tenant and a single installation supports multiple users.

## Documentation

[IBM Cloud Event Management Knowledge Center ](https://www.ibm.com/support/knowledgecenter/SSURRN/com.ibm.cem.doc/index.html)
