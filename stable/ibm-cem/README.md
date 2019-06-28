# IBM Cloud Event Management Community Edition

## Introduction
* Use the IBM® Cloud Event Management Community Edition service to set up real-time incident management for your services, applications, and infrastructure.
* Restore service and resolve operational incidents fast!
* Empower your DevOps teams to correlate different sources of events into actionable incidents, synchronize teams, and automate incident resolution.
* The service sets you on course to achieve efficient and reliable operational health, service quality and continuous improvement.
* Community (experimental) and enterprise (standard) editions are both available either through the IBM Cloud Private catalog or Passport Advantage,  respectively. The community edition is a non-expiring, limited use version, but is fully upgradable to the enterprise version after installation with minimal data loss.

## Chart Details
This chart will install the following:

Cronjob resources:
* ibm-cem-datalayer-cron

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

Secrets:
* cem-brokers-cred-secret
* cem-cemusers-cred-secret
* cem-channelservices-cred-secret
* cem-couchdb-cred-secret
* cem-email-auth-secret
* cem-event-analytics-ui-session-secret
* cem-intctl-hmac-secret
* cem-integrationcontroller-cred-secret
* cem-model-secret
* cem-nexmo-auth-secret
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
* ibm-redis-master-svc
* ibm-redis-sentinel-svc
* ibm-redis-slave-svc
* kafka
* zkensemble
* zookeeper

ServiceAccount resources:
* ibm-cem-cem-users
* ibm-redis

Statefulset resources:
* cassandra
* couchdb
* ibm-cem-datalayer
* ibm-redis-master
* ibm-redis-sentinel
* kafka
* zookeeper

_NOTE:_
All resources created are prefixed with the release name. For example if the release name is 'user-release', the cassandra stateful set would be named 'user-release-cassandra''

Pods are spread across worker nodes using the Kubernetes anti-affinity feature.

## Prerequisites

* IBM Cloud Private 3.2
* Cluster admin privilege is required for OIDC registration, cluster security policies and service broker
* The default storage class is used. See the Storage section below.

### Secrets Requirements
#### Email
When configuring ibm-cem to allow authentication with either an SMTP server via a username/password or the SendGrid service via an API key, a secret is required before installation. Run the following command to create the secret with the correct values:

`kubectl create secret generic <release-name>-cem-email-auth-secret --from-literal=smtpuser="***" --from-literal=smtppassword="***" --from-literal=apikey="***"`

*Parameters:*
* smtpuser: SMTP Username
* smtppassword: SMTP Password
* apikey: Sendgrid API key

Note: Email needs to be configured and authentication needs to be enabled via the chart installation configuration. All parameters need to be specified regardless of desired set of credentials.

#### Nexmo
When configuring ibm-cem to allow sms/voice notifications via the Nexmo service, a secret is required before installation. Run the following command to create the secret with the correct values:

`kubectl create secret generic <release-name>-cem-nexmo-auth-secret --from-literal=secret="***" --from-literal=key="***"`

*Parameters:*
* secret: Nexmo Secret
* key: Nexmo API key

Note: Nexmo needs to be configured and enabled via the chart installation configuration. All parameters need to be specified regardless of desired set of credentials.

### PodSecurityPolicy Requirements
This chart requires a `PodSecurityPolicy` to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined `PodSecurityPolicy` name: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this `PodSecurityPolicy` you can proceed to install the chart.

This chart also defines a custom `PodSecurityPolicy` which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom `PodSecurityPolicy` using the IBM Cloud Private management console. Note that this `PodSecurityPolicy` is already defined in IBM Cloud Private 3.1.1 or higher.

- From the user interface, you can copy and paste the following snippets to enable the custom `PodSecurityPolicy` into the create resource section
  - Custom PodSecurityPolicy definition:
    ```yaml
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

### Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a `SecurityContextConstraints` to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined `SecurityContextConstraints` name: [`ibm-restricted-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this `SecurityContextConstraints` resource you can proceed to install the chart.

#### Creating the required resources

This chart defines a custom `SecurityContextConstraints` which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom `SecurityContextConstraints` resource using the supplied instructions or scripts in the `ibm_cloud_pak/pak_extensions/prereqs` directory.

* From the user interface, you can copy and paste the following snippets to enable the custom `SecurityContextConstraints`
  * Custom `SecurityContextConstraints` definition:

  ```yaml
  apiVersion: security.openshift.io/v1
  kind: SecurityContextConstraints
  metadata:
    annotations:
      kubernetes.io/description: "This policy is the most restrictive,
        requiring pods to run with a non-root UID, and preventing pods from accessing the host."
      cloudpak.ibm.com/version: "1.0.0"
    name: ibm-restricted-scc
  allowHostDirVolumePlugin: false
  allowHostIPC: false
  allowHostNetwork: false
  allowHostPID: false
  allowHostPorts: false
  allowPrivilegedContainer: false
  allowPrivilegeEscalation: false
  allowedCapabilities: []
  allowedFlexVolumes: []
  allowedUnsafeSysctls: []
  defaultAddCapabilities: []
  defaultPrivilegeEscalation: false
  forbiddenSysctls:
    - "*"
  fsGroup:
    type: MustRunAs
    ranges:
    - max: 65535
      min: 1
  readOnlyRootFilesystem: false
  requiredDropCapabilities:
  - ALL
  runAsUser:
    type: MustRunAsNonRoot
  seccompProfiles:
  - docker/default
  seLinuxContext:
    type: RunAsAny
  supplementalGroups:
    type: MustRunAs
    ranges:
    - max: 65535
      min: 1
  volumes:
  - configMap
  - downwardAPI
  - emptyDir
  - persistentVolumeClaim
  - projected
  - secret
  priority: 11 # default anyuid has priority 10
  ```

* From the command line, you can run the setup scripts included under `ibm_cloud_pak/pak_extensions/prereqs` to create namespace and apply `SecurityContextConstraints` to the namespace
  * `ibm_cloud_pak/pak_extensions/prereqs/createSccAndNamespace.sh --namespace [namespace]`

### Resources Required
#### System resources, based on various install size parameters.

Size 0 (Demo/Test)
* Minimum: 8GB Memory and 4 CPU
* Recommended for heavy load: 16GB Memory and 16 CPU (or more)

Size 1 (Production Ready)
* Minimum: 20GB Memory and 14 CPU
* Recommended for heavy load: 32 GB Memory and 32 CPU (or more)

#### Persistence:
* Cassandra will need 108GB of disk space
* Other components will need an additional 4GB

### Encryption and Security
* Data at rest is unencrypted with the exception of personal data stored in couchdb for GDPR compliance. Disk encryption should be used in the event of additional data at rest encryption requirements.
* Data in motion is unencrypted within the cluster from a node-to-node perspective. IPSEC can be enabled and configured at the cluster level in the event of additional data in motion encryption requirements.

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
2. Review any orphaned Persistence Volume Claims and delete as required.

## Configuration

The following tables lists the global configurable parameters of the cloud-event-management chart and their default values.

| Parameter | Description | Default | 
|-----------|-------------|---------| 
| `commonimages.brokers.image.name` | Brokers image name. DO NOT EDIT | hdm-brokers | 
| `commonimages.brokers.image.tag` | Brokers image tag. DO NOT EDIT | 1.5.1-20190619T081550Z-multi-arch-L-MOCR-BC2KPL | 
| `commonimages.cemusers.image.name` | CEM Users image name. DO NOT EDIT | hdm-cem-users | 
| `commonimages.cemusers.image.tag` | CEM Users image tag. DO NOT EDIT | 1.5.1-20190619T221411Z-multi-arch-L-MOCR-BC2KPL | 
| `commonimages.channelservices.image.name` | channelservices image name. DO NOT EDIT | hdm-channelservices | 
| `commonimages.channelservices.image.tag` | channelservices image tag. DO NOT EDIT | 1.5.1-20190603T154346Z-multi-arch-L-MOCR-BC2KPL | 
| `commonimages.datalayer.image.name` | Datalayer image name. DO NOT EDIT | hdm-datalayer | 
| `commonimages.datalayer.image.tag` | Datalayer image tag. DO NOT EDIT | 1.5.1-20190613T065828Z-multi-arch-L-MOCR-BC2KPL | 
| `commonimages.eventanalyticsui.image.name` | eventanalyticsui image name. DO NOT EDIT | hdm-event-analytics-ui | 
| `commonimages.eventanalyticsui.image.tag` | eventanalyticsui image tag. DO NOT EDIT | 1.5.1-20190619T231410Z-multi-arch-L-MOCR-BC2KPL | 
| `commonimages.eventpreprocessor.image.name` | eventpreprocessor image name. DO NOT EDIT | hdm-eventpreprocessor | 
| `commonimages.eventpreprocessor.image.tag` | eventpreprocessor image tag. DO NOT EDIT | 1.5.1-20190604T064047Z-multi-arch-L-MOCR-BC2KPL | 
| `commonimages.incidentprocessor.image.name` | incidentprocessor image name. DO NOT EDIT | hdm-incidentprocessor | 
| `commonimages.incidentprocessor.image.tag` | incidentprocessor image tag. DO NOT EDIT | 1.5.1-20190604T064101Z-multi-arch-L-MOCR-BC2KPL | 
| `commonimages.notificationprocessor.image.name` | notificationprocessor image name. DO NOT EDIT | hdm-notificationprocessor | 
| `commonimages.notificationprocessor.image.tag` | notificationprocessor image tag. DO NOT EDIT | 1.5.1-20190605T151130Z-multi-arch-L-MOCR-BC2KPL | 
| `commonimages.integrationcontroller.image.name` | integrationcontroller image name. DO NOT EDIT | hdm-integration-controller | 
| `commonimages.integrationcontroller.image.tag` | integrationcontroller image tag. DO NOT EDIT | 1.5.1-20190603T141054Z-multi-arch-L-MOCR-BC2KPL | 
| `commonimages.normalizer.image.name` | normalizer image name. DO NOT EDIT | hdm-normalizer | 
| `commonimages.normalizer.image.tag` | normalizer image tag. DO NOT EDIT | 1.5.1-20190611T033133Z-multi-arch-L-MOCR-BC2KPL | 
| `commonimages.schedulingui.image.name` | schedulingui image name. DO NOT EDIT | hdm-scheduling-ui | 
| `commonimages.schedulingui.image.tag` | schedulingui image tag. DO NOT EDIT | 1.5.1-20190606T192546Z-multi-arch-L-MOCR-BC2KPL | 
| `commonimages.rba.rbs.image.name` | rba-rbs image name. DO NOT EDIT | hdm-icp-rba-rbs | 
| `commonimages.rba.rbs.image.tag` | rba-rbs image tag. DO NOT EDIT | 1.16.0-ubi7-minimal-20190607T094727Z-L-MOCR-BC2KPL | 
| `commonimages.rba.as.image.name` | rba-as image name. DO NOT EDIT | hdm-icp-rba-as | 
| `commonimages.rba.as.image.tag` | rba-as image tag. DO NOT EDIT | 1.16.0-ubi7-minimal-20190607T094727Z-L-MOCR-BC2KPL | 
| `productName` | Product Name. Recommended NOT to be changed. | IBM Cloud Event Management | 
| `license` | Must be set to "accept" to proceed with installation. Defaults to Not Accepted. | not accepted | 
| `ibmRedis.replicas.servers` | Number of redis server replica to deploy. Defaults to 1 | 1 | 
| `ibmRedis.replicas.sentinels` | Number of redis server replica to deploy. A minimum number of 3 is required for high availability. Defaults to 3 | 3 | 
| `brokers.clusterSize` | Number of pod replicas | 1 | 
| `cemusers.clusterSize` | Number of pod replicas | 1 | 
| `channelservices.clusterSize` | Number of pod replicas | 1 | 
| `datalayer.clusterSize` | Number of pod replicas. For production, the recommended replica count is 4 or greater. | 1 | 
| `datalayer.socketReadTimeout` | Number of milliseconds for cassandra client read timeout for setupdb. | 120000 | 
| `eventpreprocessor.clusterSize` | Number of pod replicas | 1 | 
| `incidentprocessor.clusterSize` | Number of pod replicas | 1 | 
| `integrationcontroller.clusterSize` | Number of pod replicas | 1 | 
| `normalizer.clusterSize` | Number of pod replicas | 1 | 
| `normalizer.outgoingUseSelfsignedCert` | The Switch on self signed certificate check box is enabled by default. It is recommended to leave this check box enabled. Turn this feature on to send outgoing notifications through a secured (HTTP) webhook that uses a self-signed certificate. | true | 
| `notificationprocessor.clusterSize` | Number of pod replicas | 1 | 
| `schedulingui.clusterSize` | Number of pod replicas | 1 | 
| `rba.rbs.clusterSize` | Number of pod replicas | 1 | 
| `rba.rbs.updateStrategy` | In case of release upgrades a migration task might require downtime to prevent inconsistencies (select Recreate). If no data is migrated, no downtime is necessary (select RollingUpdate) | Recreate | 
| `rba.as.clusterSize` | Automation - number of pod replicas | 1 | 
| `rba.as.updateStrategy` | In case of release upgrades a migration task might require downtime to prevent inconsistencies (select Recreate). If no data is migrated, no downtime is necessary (select RollingUpdate) | Recreate | 
| `zookeeper.clusterSize` | Number of pod replicas | 1 | 
| `couchdb.clusterSize` | Number of pod replicas | 1 | 
| `couchdb.autoClusterConfig.enabled` | Allows you to scale up the Couchbd stateful set automatically using the kubernetes scale command. Refer to the documentation for more information. | true | 
| `couchdb.numShards` | This is equivalent to the 'q' parameter in the '[cluster]' section in default.ini and specifies the number of shards. See the [cluster] section documentation in the Couchdb document for details on this parameter. You are recommended to leave it as default unless you increase the number of stateful set replicas to 3 or more. Cloud Event Management uses the default sharding value of 8 shards. This allows up to 8 replicas. Consult couchdb documentation for details on these parameters. | 8 | 
| `couchdb.numReplicas` | This is equivalent to the 'n' parameter  in the '[cluster]' section in default.ini and specifies the number of replicas of each document. See the Couchdb documentation for advice on what this should be set to. You are recommended to leave this as the default unless you increase the number of stateful set replicas to more than 3. Cloud Event Management uses the default sharding value of 3 replicas. This allows up to 8 replicas. Consult couchdb documentation for details on these parameters. | 3 | 
| `email.mail` | Set this property to the Email address that should be shown as the sender (From) of the message. | noreply-your-company-notification@your-company.com | 
| `email.type` | Set this property to "smtp" to use a mail relay server. This requires setting the other smtp-prefixed properties as well. Set to "direct" (default) to send directly to the recipient's server. Use "api" if the "sendgrid" service is available. This requires the "apikey" property also to be set. If "smtp" or "apikey" is set, ensure you create the associated secret with the credentials as described in the chart readme. | direct | 
| `email.smtphost` | When "type" is set to "smtp", set this to the host name of your smtp server used for mail relay. |  | 
| `email.smtpport` | When "type" is set to "smtp", set this to the port number used by the smtp server specified by the "smtphost" value. |  | 
| `email.smtpauth` | User authentication required for SMTP connection. Set this to true if the SMTP server requires authentication. | true | 
| `email.smtprejectunauthorized` | Reject unauthorized tls connections for SMTP connection. Set this to false if the SMTP server requires a self-signed certificate. | true | 
| `nexmo.enabled` | Set this property to enable the use of Nexmo to send SMS / Voice messages. If enabled, ensure you create the associated secret with the credentials as described in the chart readme. | false | 
| `nexmo.sms` | Set this to the Nexmo number from which to send SMS messages |  | 
| `nexmo.voice` | Set this to the Nexmo number from which to send Voice messages |  | 
| `nexmo.numbers` | Override numbers used for selected countries. Property names are country codes, values are objects with "voice" and "sms" properties' | {} | 
| `nexmo.countryblacklist` | Numbers from countries to which messages must not be sent | [] | 
| `global.image.repository` | Link to the registry containing all CEM services images |  | 
| `global.image.pullSecret` | If the image registry requires authentication create a docker-registry secret with the Docker credentials and set this value to the name of that secret. Leave empty when using a public registry. |  | 
| `global.masterIP` | ICP - Master IP |  | 
| `global.masterPort` | ICP - Master Port | 8443 | 
| `global.masterCA` | If you have provided your own certificate for the IBM® Cloud Private management ingress you must create a ConfigMap containing the certificate authority's certificate in PEM format (e.g kubectl create configmap master-ca --from-file=./ca.pem) and set this value to the name of this ConfigMap. If you have not provided your own certificate leave this value empty. |  | 
| `global.environmentSize` | Controls the resource sizes the value can be either 'size1' or 'size0'. Size0 is a minimal spec for evaluation or development purposes. | size0 | 
| `global.minReplicasHPAs` | Minimum number of replicas that auto scaling will apply to each deployment. This value may be overridden by deployment specific values. | 1 | 
| `global.maxReplicasHPAs` | Maximum number of replicas that auto scaling will apply to each deployment. This value may be overridden by deployment specific values. | 3 | 
| `global.cassandraNodeReplicas` | cassandra - node replicas | 1 | 
| `global.cassandra.superuserRole` | On install create a superuser role and password based on the secret {{ .Release.name }}-cassandra-auth-secret and disable the default superuser role. If secret does not exist, a secret with user 'admin' and a random password will be created. | false | 
| `global.kafka.clusterSize` | Number of pod replicas | 1 | 
| `global.persistence.enabled` | enable persistence | true | 
| `global.persistence.supplementalGroups` | Provide the gid of the volumes as list (required for NFS). |  | 
| `global.persistence.storageClassName` | storage - class name |  | 
| `global.persistence.storageClassOption.datalayerjobs` | data layer jobs storage class option | default | 
| `global.persistence.storageClassOption.kafkadata` | kafka data storage class option | default | 
| `global.persistence.storageClassOption.cassandradata` | Cassandra data storage class option. This can be disabled by not specifying any option. | default | 
| `global.persistence.storageClassOption.cassandrabak` | cassandra backup storage class option | default | 
| `global.persistence.storageClassOption.zookeeperdata` | zookeeper data storage class option | default | 
| `global.persistence.storageClassOption.couchdbdata` | couchdb data storage class option | default | 
| `global.persistence.storageSize.cassandradata` | cassandra data storage size option | 50Gi | 
| `global.persistence.storageSize.cassandrabak` | cassandra back up storage size option | 50Gi | 
| `global.persistence.storageSize.couchdbdata` | couchdb data storage size option | 1Gi | 
| `global.affinity.podAffinity.weight` | Controls the weighting of the requirement to schedule related pods to run close together in order to improve performance. Unless you are using other affinity or anti-affinity rules you do not need to adjust this parameter. | 50 | 
| `global.affinity.podAntiAffinity.weight` | Controls the weighting of the requirement to schedule apart pods running the same service to improve resilience. Unless you are using other affinity or anti-affinity rules you do not need to adjust this parameter. | 50 | 
| `global.ingress.domain` | Domain must be set to the fully qualified domain name (FQDN) of the CEM service. This FQDN must resolve to the IP address of the IBM® Cloud Private proxy host running the ingress controller.  This normally requires a DNS entry, for testing /etc/hosts on any client host may be updated. |  | 
| `global.ingress.tlsSecret` | If tlsSecret is the empty string CEM will use the default TLS certificate installed on the ingress controller. If this certificate does not match the value of Domain browsers and other clients will raise security warnings. For production use a TLS certificate for the FQDN should be obtained from a well known certificate authority and installed in a TLS secret in the namespace. tlsSecret must be set to the name of this secret. |  | 
| `global.ingress.prefix` | If multiple releases of CEM are installed in a single IBM® Cloud Private each should be given a different FQDN, and each should have a TLS certificate installed. If the same FQDN is used for each release, or tlsSecret is left empty for any release, global.ingress.prefix may be used to give each a different path.  E.g. if global.ingress.domain is 'cem.example.com' and global.ingress.prefix is 'mycem/', the UI end point will be https://cem.example.com/mycem/cemui. |  | 
| `global.ingress.port` | If installing into an ingress controller that has a specified port number that is different than the default (443), then the port number can be specified here. Normally, this port should be the default value. | 443 | 
| `cemservicebroker.suffix` | If multiple Cloud Event Management products are installed causing multiple cluster service broker registrations, a suffix will be required to separate out the instances so more than one cluster service broker can be registered within a single IBM® Cloud Private environment. If not specified, no suffix will be added to the cluster service broker registered service. |  | 
| `icpbroker.adminusername` | The name of the cluster administrator user.  This is the name that will be added to subscriptions  (required for MCM). | admin | 


_NOTE:_

1. Valid values for `global.environmentSize` are `size0` and `size1`. `size0` specifies a minimal resource footprint for development and test purposes, while `size1` is intended for production systems with a larger footprint.

2. If `global.ingress.tlsSecret` is left empty the default TLS certificate installed on the Ingress Controller is used.

## Storage

* If the default storage class is glusterfs then Persistent Volumes will be dynamically provisioned.
* If you require a non-default storage class, update the persistence.storageClassName to the storage class name. Alternatively, set each individual value under global.persistence.storageClassOption to specific persistent volumes.

## Limitations

* These charts can be deployed multiple times in the same namespace under different release names.
* To avoid multiple deployments in the same namespace, install one instance per namespace, and deploy multiple namespaces for ease of management and separation of resources.

## Backup and Restore

You can use Velero to backup your Kubernetes resources. Velero also takes snapshots of your cluster's Persistent Volumes and can restore your cluster's objects and Persistent Volumes to a previous state. For more information on backing up and restoring IBM Cloud Event Management, consult the [Backup and Restore](https://www.ibm.com/support/knowledgecenter/en/SSURRN/com.ibm.cem.doc/em_backuprestore.html) topic.

## Scaling and Performance

* Scaling of StatefulSets such as Cassandra, Kafka, and Zookeeper is only supported for high availability requirements and not performance. Scaling of certain StatefulSets up or down may require additional manual steps to fully enable high availability. Refer to the product documentation for additional information.

## Documentation

[IBM Cloud Event Management Knowledge Center ](https://www.ibm.com/support/knowledgecenter/SSURRN/com.ibm.cem.doc/index.html)
