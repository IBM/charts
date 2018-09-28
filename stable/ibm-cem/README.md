# IBM Cloud Event Management Community Edition

## Introduction
* Use the IBM® Cloud Event Management Community Edition service to set up real-time incident management for your services, applications, and infrastructure.
* Restore service and resolve operational incidents fast!
* Empower your DevOps teams to correlate different sources of events into actionable incidents, synchronize teams, and automate incident resolution.
* The service sets you on course to achieve efficient and reliable operational health, service quality and continuous improvement.

## Chart Details
This chart will install the following:

Cluster Service Broker resources:
* ibm-cem-cemcsb

Deployment resources:
* ibm-cem-rba-as
* ibm-cem-brokers
* ibm-cem-cem-users
* ibm-cem-channelservices
* ibm-cem-event-analytics-ui
* ibm-cem-eventpreprocessor
* ibm-cem-incidentprocessor
* ibm-cem-integration-controller
* ibm-cem-normalizer
* ibm-cem-notificationprocessor
* ibm-cem-rba-rbs
* ibm-cem-scheduling-ui
* redis-server
* redis-sentinel

Horizontal Pod Autoscale resources:
* ibm-cem-brokers
* ibm-cem-cem-users
* ibm-cem-channelservices
* ibm-cem-event-analytics-ui
* ibm-cem-eventpreprocessor
* ibm-cem-incidentprocessor
* ibm-cem-integration-controller
* ibm-cem-normalizer
* ibm-cem-notificationprocessor
* ibm-cem-rba-as
* ibm-cem-rba-rbs
* ibm-cem-scheduling-ui

Ingress resources:
* cem-api
* cem-ingress

Secret resources:
* cem-couchdb-secret
* cem-brokers-cred-secret
* cem-cemusers-cred-secret
* cem-channelservices-cred-secret
* cem-email-cred-secret
* cem-event-analytics-ui-session-secret
* cem-integrationcontroller-cred-secret
* cem-nexmo-cred-secret
* rba-devops-secret
* rba-jwt-secret

Service resources:
* cassandra
* couchdb
* ibm-cem-brokers
* ibm-cem-cem-users
* ibm-cem-channelservices
* ibm-cem-datalayer
* ibm-cem-event-analytics-ui
* ibm-cem-eventpreprocessor
* ibm-cem-incidentprocessor
* ibm-cem-integration-controller
* ibm-cem-normalizer
* ibm-cem-notificationprocessor
* ibm-cem-rba-as
* ibm-cem-rba-rbs
* ibm-cem-scheduling-ui
* kafka
* redis-master-svc
* redis-sentinel
* redis-slave-svc
* zkensemble
* zookeeper

Statefulset resources:
* cassandra
* couchdb
* ibm-cem-datalayer
* kafka
* zookeeper

_NOTE:_
All resources created are prefixed with the release name. For example if the release name is 'user-release', the cassandra stateful set would be named 'user-release-cassandra''

Pods are spread across worker nodes using the Kubernetes anti-affinity feature.

## Prerequisites

* IBM Cloud Private 2.1.0.3
* Cluster admin privilege is required for OIDC registration, cluster security policies and service broker
* The default storage class is used.  See the Storage section below.

## Resources Required
#### System resources, based on default install parameters.
* Minimum: 8GB Memory and 4 CPU
* Recommended: 16GB Memory and 18 CPU

The CPU resource is measured in Kuberenetes _cpu_ units. See Kubernetes documentation for details.  

#### Persistence:
* Cassandra will need 108GB of disk space
* Other components will need an additional 4GB

## Installing the Chart
1. From the IBM Cloud Private dashboard console, open the Catalog.
2. Locate and select the `ibm-cem` chart.
3. Review the provided instructions and select Configure.
4. Provide a release name and select a namespace.
5. Review and accept the license(s).
6. Using the Configuration table below, provide the required configuration based on requirements specific to your installation. Required fields are displayed with an asterisk. 
7. Select the Install button to complete the helm installation.

For more information on installing IBM Cloud Event Management, consult the [Installation](https://www.ibm.com/support/knowledgecenter/SSURRN/com.ibm.cem.doc/em_install_cem_icp.html) topic.

Note:
* If multiple installs of the chart in a single IBM Cloud Private environment is required, set the CEM Users OIDC client ID, CEM Users OIDC client secret, and CEM Service Broker Configuration `suffix` properties to unique values. If the same `Ingress Domain` is used between the installs, specify a unique `Ingress Prefix` path value.
* See the Storage section below for storage configuration considerations.

## Verifying the Chart via the Command Line: 

* To verify the installation after all pods are in the ready state, run the following kubectl command:
`helm test <release> --tls --cleanup`

## Post installation
1. Follow the instructions displayed after the helm installation completes. The instructions can also be displayed by viewing the installed helm release under Menu -> Workloads -> Helm Releases or by running the command: `helm status <release> --tls`.
2. IBM Cloud Event Management is multi-tenant and a single installation supports many service instances. Refer to the [Create service instances](https://www.ibm.com/support/knowledgecenter/SSURRN/com.ibm.cem.doc/em_cem_install_servinstance.html) topic.
3. After creating and launching into a service instance, see the [Configuring](https://www.ibm.com/support/knowledgecenter/SSURRN/com.ibm.cem.doc/em_configuring.html) topic for getting started.

### Uninstalling the Chart via UI:
1. Select the Menu -> Workloads -> Helm Releases
2. Locate the installed helm release and select the actions menu -> Delete
3. Confirm deletion by selecting the Remove button

The helm delete command does not delete Persistent Volumes created by the installation. If the chart is removed and you do not want to retain its data:
1. Select the Menu -> Platform -> Storage
2. Review any orphned Persistnece Volume Claims and delete as required.

### Uninstalling the Chart via the Command Line

To uninstall and delete the deployment:

```bash
helm delete --purge <release> --tls
```

The helm delete command does not delete Persistent Volumes created by the installation. If the chart is removed and you do not want to retain its data, review any orphaned Persistent Volume claims using the following command, and delete as required.

```console
$ kubectl get pvc -l release=<release>
```

## Configuration

The following tables lists the global configurable parameters of the cloud-event-management chart and their default values.

| Parameter                                        | Description                              | Default              |
| ------------------------------------------------ | ---------------------------------------- | -------------------- |
| `global.image.repository`                        | Registry containing CEM services images  | ``                   |
| `global.image.pullSecret`                        | Images pull secret                       | ``                   |
| `global.masterIP`                                | The IP of the kubernetes master node     | ``                     |
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
| `commonimages.brokers.image.tag`                 | Brokers image tag                        |                      |
| `commonimages.cemusers.image.tag`                | Users image tag                          |                      |
| `commonimages.channelservices.image.tag`         | Channel services image tag               |                      |
| `commonimages.datalayer.image.tag`               | Data layer image tag                     |                      |
| `commonimages.eventanalyticsui.image.tag`        | Event analytics ui image tag             |                      |
| `commonimages.eventpreprocessor.image.tag`       | Event preprocessor image tag             |                      |
| `commonimages.incidentprocessor.image.tag`       | Incident processor image tag             |                      |
| `commonimages.notificationprocessor.image.tag`   | Notification processor image tag         |                      |
| `commonimages.integrationcontroller.image.tag`   | Integration Controller image tag         |                      |
| `commonimages.normalizer.image.tag`              | Normalizer image tag                     |                      |
| `commonimages.schedulingui.image.tag`            | Scheduling ui image tag                  |                      |
| `commonimages.rba.rbs.image.tag`                 | Runbook service image tag                |                      |
| `commonimages.rba.as.image.tag`                  | Automation service image tag             |                      |
| `commonimages.cemhelmtests.image.tag`            | CEM helm tests image tag                 |                      |
| `productName`                                    | Product name                             |                      |
| `license`                                        | License                                  | `not accepted`       |
| `arch`                                           | Architecture                             |                      |
| `brokers.clusterSize`                            | Brokers cluster size                     | `1`                  |
| `cemusers.clusterSize`                           | CEM users cluster size                   | `1`                  |
| `channelservices.clusterSize`                    | Channel services cluster size            | `1`                  |
| `datalayer.clusterSize`                          | Data layer cluster size                  | `1`                  |
| `eventanalyticsui.clusterSize`                   | Eventan alytics ui cluster size          | `1`                  |
| `eventpreprocessor.clusterSize`                  | Event preprocessor cluster size          | `1`                  |
| `incidentprocessor.clusterSize`                  | Incident processor cluster size          | `1`                  |
| `integrationcontroller.clusterSize`              | Integration controller cluster size      | `1`                  |
| `normalizer.clusterSize`                         | Normalizer cluster size                  | `1`                  |
| `normalizer.outgoingUseSelfsignedCert`           | Self signed certificate                  | `true`               |
| `notificationprocessor.clusterSize`              | Notification processor cluster size      | `1`                  |
| `schedulingui.clusterSize`                       | Scheduling ui cluster size               | `1`                  |
| `rba.rbs.clusterSize`                            | Runbook cluster size                     | `1`                  |
| `rba.as.clusterSize`                             | Automation cluster size                  | `1`                  |
| `kafka.clusterSize`                              | Kafka cluster size                       | `1`                  |
| `kafka.client.username`                          | Kafka username                           |                      |
| `kafka.client.password`                          | Kafka password                           |                      |
| `kafka.admin.username`                           | Kafka admin username                     |                      |
| `kafka.admin.password`                           | Kafka admin password                     |                      |
| `kafka.ssl.enabled`                              | Enable kafka SSL                         |                      |
| `kafka.ssl.secret`                               | Kafka TLS secret                         |                      |
| `kafka.ssl.password`                             | Kafka TLS password                       |                      |
| `couchdb.clusterSize`                            | CouchDB cluster size                     | `1`                  |
| `couchdb.autoClusterConfig.enabled`              | CouchDB cluster config                   | `false`              |
| `couchdb.numShards`                              | CouchDB number of shards                 | `8`                  |
| `couchdb.numReplicas`                            | CouchDB number of replicas               | `3`                  |
| `couchdb.secretName`                             | CouchDB secret name                      |                      |
| `redis.replicas.servers`                         | Redis servers replica count              | `3`                  | 
| `redis.replicas.sentinels`                       | Redis sentinels replica count            | `3`                  | 
| `email.mail`                                     | Sender email configuration               | `noreply-your-company-notification@your-company.com` |
| `email.type`                                     | Email type                               | `direct`             |
| `email.smtphost`                                 | Smtp host                                | ``                   | 
| `email.smtpport`                                 | Smtp port                                | ``                   | 
| `email.smtpuser`                                 | Smtp user                                | ``                   | 
| `email.smtppassword`                             | Smtp password                            | ``                   | 
| `email.apikey`                                   | API key required by the Sendgrid API     | ``                   | 
| `nexmo.enabled`                                  | Nexmo SMS and Voice Messages             | `false`              | 
| `nexmo.key`                                      | API key required by the Nexmo API        | ``                   | 
| `nexmo.secret`                                   | API secret required by the Nexmo API     | ``                   | 
| `nexmo.sms`                                      | Nexmo number to send SMS messages        | ``                   | 
| `nexmo.voice`                                    | Nexmo number to send voice messages      | ``                   | 
| `nexmo.numbers`                                  | API key required by the Sendgrid API     | `{}`                 | 
| `nexmo.countryblacklist`                         | Blacklisted countries                    | `{}`                  | 

_NOTE:_

1. Valid values for `global.environmentSize` are `size0` and `size1`. `size0` specifies a minimal resource footprint for development and test purposes, while `size1` is intended for production systems with a larger footprint.

2. If this is left empty the default TLS certificate installed on the Ingress Controller is used.

## Storage

* If the default storage class is glusterfs then Persistent Volumes will be dynamically provisioned.
* If you require a none-default storage class, update the persistance.storageClassName to the storage class name. Alternatively, set each individual value under global.persistance.storageClassOption to specific persistent volumes.

## Limitations

* These charts can be deployed multiple times in the same namespace under different release names.
* To avoid multiple deployments in the same namespace, install one instance per namespace, and deploy multiple namespaces for ease of management and separation of resources.

## Documentation

[IBM Cloud Event Management Knowledge Center ](https://www.ibm.com/support/knowledgecenter/SSURRN/com.ibm.cem.doc/index.html)
