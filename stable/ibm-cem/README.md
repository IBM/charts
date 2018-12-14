# IBM Cloud Event Management Community Edition

## Introduction
* Use the IBM® Cloud Event Management service to set up real-time incident management for your services, applications, and infrastructure.
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

* IBM Cloud Private 2.1.0.3 or higher
* Cluster admin privilege is required for OIDC registration, cluster security policies and service broker
* The default storage class is used.  See the Storage section below.

## PodSecurityPolicy Requirements
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined PodSecurityPolicy name: ibm-restricted-psp has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart.

This chart also defines a custom PodSecurityPolicy which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom PodSecurityPolicy using the ICP user interface or the supplied instructions/scripts in the pak_extension pre-install directory.

- From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy
  - Custom PodSecurityPolicy definition:
    ```
    apiVersion: extensions/v1beta1
    kind: PodSecurityPolicy
    metadata:
      annotations:
        kubernetes.io/description: "This policy is the most restrictive, 
          requiring pods to run with a non-root UID, and preventing pods from accessing the host." 
        apparmor.security.beta.kubernetes.io/allowedProfileNames: runtime/default
        apparmor.security.beta.kubernetes.io/defaultProfileName: runtime/default
        seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
        seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
      name: ibm-restricted-psp
    spec:
      allowPrivilegeEscalation: false
      forbiddenSysctls:
      - '*'
      fsGroup:
        ranges:
        - max: 65535
          min: 1
        rule: MustRunAs
      requiredDropCapabilities:
      - ALL
      runAsUser:
        rule: MustRunAsNonRoot
      seLinux:
        rule: RunAsAny
      supplementalGroups:
        ranges:
        - max: 65535
          min: 1
        rule: MustRunAs
      volumes:
      - configMap
      - emptyDir
      - projected
      - secret
      - downwardAPI
      - persistentVolumeClaim
    ```
  - Custom ClusterRole for the custom PodSecurityPolicy:
    ```
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: ibm-restricted-psp-clusterrole
    rules:
    - apiGroups:
      - extensions
      resourceNames:
      - ibm-restricted-psp
      resources:
      - podsecuritypolicies
      verbs:
      - use
    ```


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

* To verify the installation after all pods are in the ready state, run the following helm command:
`helm test <release> --tls --cleanup`

## Post installation
1. Follow the instructions displayed after the helm installation completes. The instructions can also be displayed by viewing the installed helm release under Menu -> Workloads -> Helm Releases or by running the command: `helm status <release> --tls`.
2. IBM Cloud Event Management is multi-tenant and a single installation supports many service instances. Refer to the [Create service instances](https://www.ibm.com/support/knowledgecenter/SSURRN/com.ibm.cem.doc/em_cem_install_servinstance.html) topic.
3. After creating and launching into a service instance, see the [Configuring](https://www.ibm.com/support/knowledgecenter/SSURRN/com.ibm.cem.doc/em_configuring.html) topic for getting started.

### Uninstalling the Chart via UI:
1. Select the Menu -> Workloads -> Helm Releases
2. Locate the installed helm release and select the actions menu -> Delete
3. Confirm deletion by selecting the Remove button

Removing helm release? If the chart is removed and you do not want to retain its data:
1. Select the Menu -> Platform -> Storage
2. Review any orphned Persistnece Volume Claims and delete as required.

## Configuration

The following tables lists the global configurable parameters of the cloud-event-management chart and their default values.

| Parameter | Description | Default | 
|-----------|-------------|---------| 
| `commonimages` | CEM Services Image Tags| 
| `commonimages.brokers.image.tag` | Brokers image tag. DO NOT EDIT| 
| `commonimages.cemusers.image.tag` | CEM Users image tag. DO NOT EDIT| 
| `commonimages.channelservices.image.tag` | channelservices image tag. DO NOT EDIT| 
| `commonimages.datalayer.image.tag` | Datalayer image tag. DO NOT EDIT| 
| `commonimages.eventanalyticsui.image.tag` | eventanalyticsui image tag. DO NOT EDIT| 
| `commonimages.eventpreprocessor.image.tag` | eventpreprocessor image tag. DO NOT EDIT| 
| `commonimages.incidentprocessor.image.tag` | incidentprocessor image tag. DO NOT EDIT| 
| `commonimages.notificationprocessor.image.tag` | notificationprocessor image tag. DO NOT EDIT| 
| `commonimages.integrationcontroller.image.tag` | integrationcontroller image tag. DO NOT EDIT| 
| `commonimages.normalizer.image.tag` | normalizer image tag. DO NOT EDIT| 
| `commonimages.schedulingui.image.tag` | schedulingui image tag. DO NOT EDIT| 
| `commonimages.rba.rbs.image.tag` | rba-rbs image tag. DO NOT EDIT| 
| `commonimages.rba.as.image.tag` | rba-as image tag. DO NOT EDIT| 
| `commonimages.cemhelmtests.image.tag` | cemhelmtests image tag. DO NOT EDIT| 
| `productName` | Product Name. Recommended NOT to be changed.| 
| `license` | Must be set to "accept" to proceed with installation. Defaults to Not Accepted.| 
| `arch` | Supported architecture. DO NOT EDIT| 
| `brokers` | Brokers Configuration| 
| `brokers.clusterSize` | Number of pod replicas| 
| `cemusers` | CEM Users Configuration| 
| `cemusers.clusterSize` | Number of pod replicas| 
| `channelservices` | Channel Services Configuration| 
| `channelservices.clusterSize` | Number of pod replicas| 
| `datalayer` | Data Layer Configuration| 
| `datalayer.clusterSize` | Number of pod replicas. For production, the recommended replica count is 4 or greater.| 
| `eventanalyticsui` | CEM UI Configuration| 
| `eventanalyticsui.clusterSize` | Number of pod replicas| 
| `eventpreprocessor` | Event Preprocessor Configuration| 
| `eventpreprocessor.clusterSize` | Number of pod replicas| 
| `incidentprocessor` | Incident Processor Configuration| 
| `incidentprocessor.clusterSize` | Number of pod replicas| 
| `integrationcontroller` | Integration Controller Configuration| 
| `integrationcontroller.clusterSize` | Number of pod replicas| 
| `normalizer` | Normalizer Configuration| 
| `normalizer.clusterSize` | Number of pod replicas| 
| `normalizer.outgoingUseSelfsignedCert` | The Switch on self signed certificate check box is enabled by default. It is recommended to leave this check box enabled. Turn this feature on to send outgoing notifications through a secured (HTTP) webhook that uses a self-signed certificate.| 
| `notificationprocessor` | Notification Processor Configuration| 
| `notificationprocessor.clusterSize` | Number of pod replicas| 
| `schedulingui` | Scheduling UI Configuration| 
| `schedulingui.clusterSize` | Number of pod replicas| 
| `rba` | IBM Runbook Automation Services Configuration| 
| `rba.rbs.clusterSize` | Number of pod replicas| 
| `rba.rbs.updateStrategy` | In case of release upgrades a migration task might require downtime to prevent inconsistencies (select Recreate). If no data is migrated, no downtime is necessary (select RollingUpdate)| 
| `rba.as.clusterSize` | Automation - number of pod replicas| 
| `rba.as.updateStrategy` | In case of release upgrades a migration task might require downtime to prevent inconsistencies (select Recreate). If no data is migrated, no downtime is necessary (select RollingUpdate)| 
| `zookeeper` | Zookeeper Configuration| 
| `zookeeper.clusterSize` | Number of pod replicas| 
| `kafka` | Kafka Configuration| 
| `kafka.clusterSize` | Number of pod replicas| 
| `kafka.client.username` | kafka username. DO NOT EDIT| 
| `kafka.client.password` | kafka password. DO NOT EDIT| 
| `kafka.admin.username` | kafka admin username. DO NOT EDIT| 
| `kafka.admin.password` | kafka admin password. DO NOT EDIT| 
| `kafka.ssl.enabled` | Enable Kafka SSL. DO NOT EDIT.| 
| `kafka.ssl.secret` | kafka tls secret. DO NOT EDIT| 
| `kafka.ssl.password` | kafka tls password. DO NOT EDIT| 
| `couchdb` | CouchDB Configuration| 
| `couchdb.clusterSize` | Number of pod replicas| 
| `couchdb.autoClusterConfig.enabled` | Allows you to scale up the Couchbd stateful set automatically using the kubernetes scale command. You must give the default service account in your namespace read access to the kubernetes API before enabling this parameter. Refer to the documentation for more information.| 
| `couchdb.numShards` | This is equivalent to the 'q' parameter in the '[cluster]' section in default.ini and specifies the number of shards. See the [cluster] section documentation in the Couchdb document for details on this parameter. You are recomended to leave it as default unless you increase the number of stateful set replicas to 3 or more. Cloud Event Management uses the default sharding value of 8 shards. This allows up to 8 replicas. Consult couchdb documentation for details on these parameters.| 
| `couchdb.numReplicas` | This is equivalent to the 'n' parameter  in the '[cluster]' section in default.ini and specifies the number of replicas of each document. See the Couchdb documentation for advice on what this should be set to. You are recommended to leave this as the default unless you increase the number of stateful set replicas to more than 3. Cloud Event Management uses the default sharding value of 3 replicas. This allows up to 8 replicas. Consult couchdb documentation for details on these parameters.| 
| `couchdb.secretName` | couchdb secret name. DO NOT EDIT| 
| `redis` | Redis Configuration| 
| `redis.replicas.servers` | Number of pod replicas| 
| `redis.replicas.sentinels` | Sentinels - number of pod replicas| 
| `email` | Sender Email Configuration| 
| `email.mail` | Set this property to the Email address that should be shown as the sender (From) of the message.| 
| `email.type` | Set this property to "smtp" to use a mail relay server. This requires setting the other smtp-prefixed properties as well. Set to "direct" (default) to send directly to the recipient's server. Use "api" if the "sendgrid" service is available. This requires the "apikey" property also to be set.| 
| `email.smtphost` | When "type" is set to "smtp", set this to the host name of your smtp server used for mail relay.| 
| `email.smtpport` | When "type" is set to "smtp", set this to the port number used by the smtp server specified by the "smtphost" value.| 
| `email.smtpuser` | When "type" is set to "smtp", set this to a valid user name for the smtp server specified by the "smtphost" value.| 
| `email.smtppassword` | When "type" is set to "smtp", set this to the password for the user name defined by the "smtpuser" value.| 
| `email.apikey` | When "type" is set to "api", set this value to the API key required by the Sendgrid API. (Send mail authorization is required).| 
| `nexmo` | Nexmo SMS and Voice Configuration| 
| `nexmo.enabled` | Set this property to enable the use of Nexmo to send SMS / Voice messages| 
| `nexmo.key` | Set this value to the API Key required by the Nexmo API| 
| `nexmo.secret` | Set this value to the API secret required by the Nexmo API| 
| `nexmo.sms` | Set this to the Nexmo number from which to send SMS messages| 
| `nexmo.voice` | Set this to the Nexmo number from which to send Voice messages| 
| `nexmo.numbers` | Override numbers used for selected countries. Property names are country codes, values are objects with "voice" and "sms" properties'| 
| `nexmo.countryblacklist` | Numbers from countries to which messages must not be sent| 
| `global` | Global properties accessed in main and dependent charts| 
| `global.image.repository` | Link to the registry containing all CEM services images| 
| `global.image.pullSecret` | If the image registry requires authenication create a docker-registry secret with the Docker credentials and set this value to the name of that secret. Leave empty when using a public registry.| 
| `global.masterIP` | ICP - Master IP| 
| `global.masterPort` | ICP - Master Port| 
| `global.environmentSize` | Controls the resource sizes the value can be either 'size1' or 'size0'. Size0 is a minimal spec for evaluation or development purposes.| 
| `global.cassandraNodeReplicas` | cassandra - node replicas| 
| `global.persistence.enabled` | enable persistence| 
| `global.persistence.supplementalGroups` | Provide the gid of the volumes as list (required for NFS).| 
| `global.persistence.storageClassName` | storage - class name| 
| `global.persistence.storageClassOption.datalayerjobs` | data layer jobs storage class option| 
| `global.persistence.storageClassOption.kafkadata` | kafka data storage class option| 
| `global.persistence.storageClassOption.cassandradata` | Cassandra data Storage Class Type. This can be disabled by not specifying any option.| 
| `global.persistence.storageClassOption.cassandrabak` | cassandra backup storage class option| 
| `global.persistence.storageClassOption.zookeeperdata` | zookeeper data storage class option| 
| `global.persistence.storageClassOption.couchdbdata` | couchdb data storage class option| 
| `global.persistence.storageSize.cassandradata` | cassandra data storage size option| 
| `global.persistence.storageSize.cassandrabak` | cassandra back up storage size option| 
| `global.persistence.storageSize.couchdbdata` | couchdb data storage size option| 
| `global.persistence.storageSize.datalayerjobs` | data layer jobs storage size option| 
| `global.ingress.domain` | Domain must be set to the fully qualified domain name (FQDN) of the CEM service. This FQDN must resolve to the IP address of the ICp proxy host running the ingress controller.  This normally requires a DNS entry, for testing /etc/hosts on any client host may be updated.| 
| `global.ingress.tlsSecret` | If tlsSecret is the empty string CEM will use the default TLS certificate installed on the ingress controller. If this certificate does not match the value of Domain browsers and other clients will raise security warnings. For production use a TLS certificate for the FQDN should be obtained from a well known certificate authority and installed in a TLS secret in the namespace. tlsSecret must be set to the name of this secret.| 
| `global.ingress.prefix` | If multiple releases of CEM are installed in a single ICp each should be given a different FQDN, and each should have a TLS certificate installed. If the same FQDN is used for each release, or tlsSecret is left empty for any release, global.ingress.prefix may be used to give each a different path.  E.g. if global.ingress.domain is 'cem.example.com' and global.ingress.prefix is 'mycem/', the UI end point will be https://cem.example.com/mycem/cemui.| 
| `global.ingress.port` | If installing into an ingress controller that has a specified port number that is different than the default (443), then the port number can be specified here. Normally, this port should be the default value.| 
| `watsonworkspace` | Watson Workspace Outgoing Integration Configuration| 
| `watsonworkspace.appid` | After creating a Watson Workspace application that CEM can integrate with, provide the Watson Workspace application ID to send outgoing notifications.| 
| `watsonworkspace.appsecret` | After creating a Watson Workspace application that CEM can integrate with, provide the Watson Workspace application secret to send outgoing notifications.| 
| `watsonworkspace.sharetoken` | After creating a Watson Workspace application that CEM can integrate with, provide the Watson Workspace application share token to send outgoing notifications.| 
| `cemservicebroker` | CEM Service Broker Configuration| 
| `cemservicebroker.suffix` | If multiple Cloud Event Management products are installed causing multiple cluster service broker registrations, a suffix will be required to separate out the instances so more than one cluster service broker can be registered within a single ICp environment. If not specified, no suffix will be added to the cluster service broker registered service.| 


_NOTE:_

1. Valid values for `global.environmentSize` are `size0` and `size1`. `size0` specifies a minimal resource footprint for development and test purposes, while `size1` is intended for production systems with a larger footprint.

2. If this is left empty the default TLS certificate installed on the Ingress Controller is used.

## Storage

* If the default storage class is glusterfs then Persistent Volumes will be dynamically provisioned.
* If you require a non-default storage class, update the persistance.storageClassName to the storage class name. Alternatively, set each individual value under global.persistance.storageClassOption to specific persistent volumes.

## Limitations

* These charts can be deployed multiple times in the same namespace under different release names.
* To avoid multiple deployments in the same namespace, install one instance per namespace, and deploy multiple namespaces for ease of management and separation of resources.

## Documentation

[IBM Cloud Event Management Knowledge Center ](https://www.ibm.com/support/knowledgecenter/SSURRN/com.ibm.cem.doc/index.html)
