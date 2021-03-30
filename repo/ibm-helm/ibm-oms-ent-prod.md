# ibm-oms-ent-prod

Readme for IBM Sterling Order Management Software Enterprise Edition, version 10.0.

## Introduction

This document contains supplementary information about deploying the Sterling Order Management Software Enterprise Edition, version 10.0. For a comprehensive product documentation, visit [IBM Knowledge Center.](https://www.ibm.com/support/knowledgecenter/SS6PEW_10.0.0/om_welcome.html)

## Before you begin

Ensure that you set up and configure the database and messaging server because the Helm chart does not automatically install these middleware applications.

**Note:** You can by default deploy Sterling Order Management Software with Db2 database and MQ messaging by using the Helm chart. If you want to deploy Sterling Order Management Software with a different database and JMS provider, ensure that you customize the certified containers. For more information about customizing the certified containers, see [Customizing certified containers](https://www.ibm.com/support/knowledgecenter/SS6PEW_10.0.0/installation/c_OMRHOC_customizing_OMS_runtime.html).

## Deployment prerequisites

Before deploying Sterling Order Management Software, review and complete the following prerequisites:

- Install Kubernetes version 1.16.0-0 or later.
- Install the Helm version 3.0.0 or later.
- Install Db2 or Oracle database. Ensure that the database is accessible from within the cluster. For more
  information about the database time zone considerations, see [Time zone considerations.](#time-zone-considerations)
- Install MQ or any other JMS server. Ensure that the MQ server is accessible from within the cluster.
- Load the container images to the appropriate container registry. The default images are available in the IBM Cloud 
  Registry. When you are installing the Helm chart, if you want to automatically pull the images, use image pull secret. 
  Alternatively, you can use customized images.
- Configure container registry and container image to pull them to all Kubernetes worker nodes.
- Create a Persistent Volume with access mode as 'Read write many' and having a minimum of 10 GB hard disk space.
- [Create a Secret](#creating-a-secret) with the datasource connectivity details.
- [Create a Role Based Access Control (RBAC).](#creating-a-role-based-access-control-RBAC)
- Configure the agent or integration servers in the Helm chart. For more information about configuring the agent or integration servers, see [Configuring agent and integration server.](#configuring-agent-and-integration-servers)
- Install PodDisruptionBudget.

  The PodDisruptionBudget ensures that a certain number or percentage of pods with an assigned label are not voluntarily 
  evicted at any point in time. For more information about PodDisruptionBudget, see [Disruptions](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/) and [Specifying a disruption budget for your application](https://kubernetes.io/docs/tasks/run-application/configure-pdb/).

## Creating a Secret

To create a Secret, complete the following steps:

1. Configure the values as illustrated in the following <sample_secret_file>.yaml file:

    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
       name: '<Release-name>-oms-secret'
    type: Opaque
    stringData:
      consoleadminpassword: '<liberty console admin password>'
      consolenonadminpassword: '<liberty console non admin password>'
      dbpassword: '<password for database user>'
      tlskeystorepassword: '<Liberty TLS KeyStore password. Required if SSL is enabled and using OpenShift cluster.>'
      trustStorePassword: '<password for custom TrustStore>'
      keyStorePassword: '<password for custom KeyStore>'
    ```
  
  2. Pass the name of the Secret as a value to the `global.appSecret` parameter. 
`
     **Note:** For the Secret name, it is recommended that you prefix release name.
     
  3. Run the following command:

     ```sh
       kubectl create -f <sample_secret_file>.yaml  -n <namespace>

     ```
     A Secret based on the values entered in the <sample_secret_file>.yaml is created and encoded.
     
## Creating a Role Based Access Control (RBAC)

If you are deploying the application on a namespace other than the default namespace, and if you have not created Role Based 
  Access Control (RBAC), create RBAC with the cluster admin role.
  
The following sample file illustrates RBAC for the default service account with the target namespace as `<namespace>`.

  ```yaml
  kind: Role
  apiVersion: rbac.authorization.k8s.io/v1
  metadata:
    name: oms-role-<namespace>
    namespace: <namespace>
  rules:
    - apiGroups: ['']
      resources: ['secrets']
      verbs: ['get', 'watch', 'list', 'create', 'delete', 'patch', 'update']

  ---
  kind: RoleBinding
  apiVersion: rbac.authorization.k8s.io/v1
  metadata:
    name: oms-rolebinding-<namespace>
    namespace: <namespace>
  subjects:
    - kind: ServiceAccount
      name: default
      namespace: <namespace>
  roleRef:
    kind: Role
    name: oms-role-<namespace>
    apiGroup: rbac.authorization.k8s.io
  ```
  
## The Helm chart details

The Helm chart creates following resources:

- ConfigMap with the following resource names:
  - `<deployment name>-config` - Provides Sterling Order Management Software and Liberty configuration.
  - `<deployment name>-def-server-xml-conf` - Provides the default server.xml for Liberty. However, if you are using a custom server.xml file, the Helm chart does not create this resource name.
  
- Service with the name, `<deployment name>`, to access the application server by using a consistent IP address.

- Deployment with the following names:
  - `<deployment name>-appserver` - Sterling Order Management Software application server.
  - `<deployment name>-<server name>` - Sterling Order Management Software agent and integration servers that are configured.
  - `<deployment name>-healthmonitor`- Sterling Order Management Software HealthMonitor agent if you enable health monitor.
  
- Jobs with the following names:
  - `<deployment name>-datasetup` - Set up data for deploying and running the applications, if you enable data setup.
  - `<deployment name>-preinstall` - Complete the pre-installation activities such as generating ingress, tls, and secret.

  Here, 
    - `<deployment name>` refers to `<release name>-ibm-oms-ent-prod`, which can be overridden with `global.fullNameOverride`.
    - `<release name>` refers to the Helm release name.
    - `<server name>` refers to the name of agent or integration server.

## Time zone considerations

Before deploying the application, ensure that the database, application server, and agent server are all in the same time zone. Also, ensure that the time zone is compatible with locale code as specified in the application.

The containers are by default deployed in UTC time zone and the locale code is set to en_US_UTC. Therefore, ensure that you deploy the database in UTC time zone.

## Resources

### Minimum requirements

The Helm chart by default uses the following resources:

- 2560Mi memory for application server.
- 1024Mi memory for each agent or integration server and health monitor.
- 1 CPU core for application server.
- 0.5 CPU core for each agent or integration server and health monitor.

### Recommended requirements

To achieve an approximate throughput of:

- 350 thousand order lines per hour with corresponding inventory calls
- 3 million inventory item updates or lookups per hour
- 200 concurrent call center users
- 1000 concurrent store users

use the following resources:

- Master node (total resources spread across 3 Power9 machines):
  - 4 CPU cores
  - 24 GB memory

- Worker nodes (3 worker nodes on 3 separate Power9 machines):
  - 16 CPU cores each
  - 32 GB memory each
    
## Installing the Helm chart

You can install the Helm chart on a new or preloaded database by appropriately configuring the parameters of values.yaml.

### Installing the Helm chart on a new database

To install the Helm chart on a new database that does not contain tables and factory data, configure the following parameters. 

- Set the value of `datasetup.loadFactoryData` to `install` and `datasetup.mode` to `create`. 
  
- Set the value of `datasetup.fixPack.loadFPFactoryData` to `install` and `datasetup.fixPack.installedFPNo`
  to `0`. 
  
  The application takes appropriate action based on the configured values.

**Note:** Do not specify any agent or integration server in `omserver.servers.name`. When you are installing Helm
  chart on a new database, deploy the application server and configure both agent and integration servers. For more
  information about deploying the agent and integration servers, see [Configuring agent and integration server.](#configuring-agent-and-integration-servers)

### Installing the Helm chart on a preloaded database

To install the Helm chart on a database that contains tables and factory data, configure the following parameters:

- Set the value of `datasetup.loadFactoryData` to `donotinstall` or blank.

- If you want to apply the fix pack factory setup, set the value of `datasetup.fixPack.loadFPFactoryData` to `install` and `datasetup.fixPack.installedFPNo` to the most recently installed fix pack number. 

## Configuration parameters in values.yaml

The following table describes the configurable parameters that are applicable for the Helm chart.

| Parameter                                                                         | Description                                                                                                                                                                                               | Default                                                  |
| --------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------- |
| `global.license`                                                                  | Set the value to `True` to accept the application license.                                                                                                                                       |
| `global.licenseStoreCallCenter`                                                | Set the value to `True` to accept the Sterling Store and Commerce Call Center application licenses.                                                                                                                  |
| `appserver.replicaCount`                                                          | Specify the number of application server instances to be deployed.                                                                                                                                                                             | `1`                                                      |
| `appserver.deploymentStrategy`                                                    | Specify the deployment strategy for application servers. For more information about deployment strategy, see [Deployment strategy.](#deployment-strategy)                                                                                                                                                                    |
| `appserver.image`                                                                 | Provide the container image details for application servers                                                                                                                                                                      |
| `appserver.exposeRestService`                                                     | This flag is applicable only if the  route API (`route.openshift.io/v1`) exists. If enabled, a new deployment of `om-app` image is created that exposes `/smcfs` with a new route prefixed with `xapirest`. |
| `appserver.config.vendor`                                                         | Specify the vendor type.                                                                                                                                                                                              | `websphere`                                              |
| `appserver.config.vendorFile`                                                     | Specify the vendor file.                                                                                                                                                                                          | `servers.properties`                                     |
| `appserver.config.serverName`                                                     | Specify the application server name.                                                                                                                                                                                          | `DefaultAppServer`                                       |
| `appserver.config.jvm`                                                            | Specify minimum and maximum heap size and JVM parameters for the application server.                                                                                                                                                              | `1024m` min, `2048m` max, no parameters                  |
| `appserver.config.database.maxPoolSize`                                           | Specify the database max pool size.                                                                                                                                                                                         | `50`                                                     |
| `appserver.config.database.minPoolSize`                                           | Specify the database min pool size.                                                                                                                                                                                        | `10`                                                     |
| `appserver.config.corethreads`                                                    | Specify the core threads for Liberty.                                                                                                                                                                                | `20`                                                     |
| `appserver.config.maxthreads`                                                     | Specify the maximum threads for Liberty.                                                                                                                                                                               | `100`                                                    |
| `appserver.config.libertyServerXml`                                               | Provide the custom server.xml for Liberty. For more information about the custom server.xml, see [Customizing server.xml for Liberty](customizing-server.xml-for-Liberty).                                                                                                                        |
| `appserver.livenessCheckBeginAfterSeconds`                                        | Specify the approximate wait time in seconds to begin the liveness check.                                                                                                                                                      | `900`                                                    |
| `appserver.livenessFailRestartAfterMinutes`                                       | Specify the approximate time period in minutes after which the server restarts, if liveness check keeps failing for this period.                                                                                                | `10`                                                     |
| `appserver.service.http.port`                                                     | Specify to the HTTP container port.                                                                                                                                                                                      | `9080`                                                   |
| `appserver.service.https.port`                                                    | Specify to the HTTPS container port.                                                                                                                                                                                     | `9443`                                                   |
| `appserver.service.annotations`                                                   | Specify the additional annotations for service resource.                                                                                                                                                              |
| `appserver.service.labels`                                                        | Specify the additional labels for service resource.                                                                                                                                                               |
| `appserver.resources`                                                             | Specify the CPU and memory resource requests and limits.                                                                                                                                                                    | Memory: `2560Mi`, CPU: `1`                               |
| `appserver.ingress.host`                                                          | Specify the Ingress host.                                                                                                                                                                                          |
| `appserver.ingress.controller`                                                    | Specify the controller class for ingress controller.                                                                                                                                                                | nginx                                                    |
| `appserver.ingress.contextRoots`                                                  | Specify the context roots that can be accessed through ingress.                                                                                                                                          | ["smcfs", "sbc", "sma", "isccs", "wsc", "adminCenter"]   |
| `appserver.ingress.annotations`                                                   | Specify any additional annotations for ingress or routes resource.                                                                                                                                                       |
| `appserver.ingress.labels`                                                        | Specify any additional labels for ingress or routes resource.                                                                                                                                                            |
| `appserver.ingress.ssl.enabled`                                                   | Specify whether SSL is enabled for Ingress.                                                                                                                                                                        | true                                                     |
| `appserver.podLabels`                                                             | Specify custom labels for the application servers pods.                                                                                                                                                                    |
| `appserver.tolerations`                                                           | Specify tolerations for the application server pods in accordance with Kubernetes **PodSpec.tolerations**. For more information about affinity and tolerations, see [Configuring affinity and tolerations.](#configuring-affinity-and-tolerations)                                                  |
| `appserver.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution`           | Configure node affinity for the application server pods in accordance with Kubernetes **PodSpec.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution**. For more information about affinity and tolerations, see [Configuring affinity and tolerations.](#configuring-affinity-and-tolerations)                                                                             |
| `appserver.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution`          | Configure node affinity for the application server pods in accordance with Kubernetes **PodSpec.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution**. For more information about affinity and tolerations, see [Configuring affinity and tolerations.](#configuring-affinity-and-tolerations)                                                                                     |
| `appserver.podAffinity.requiredDuringSchedulingIgnoredDuringExecution`            | Configure pod affinity for the application server pods in accordance with Kubernetes **PodSpec.podAffinity.requiredDuringSchedulingIgnoredDuringExecution**. For more information about affinity and tolerations, see [Configuring affinity and tolerations.](#configuring-affinity-and-tolerations)                                                                                         |
| `appserver.podAffinity.preferredDuringSchedulingIgnoredDuringExecution`           | Configure pod affinity for the application server pods in accordance with Kubernetes **PodSpec.podAffinity.preferredDuringSchedulingIgnoredDuringExecution**. For more information about affinity and tolerations, see [Configuring affinity and tolerations.](#configuring-affinity-and-tolerations)                                                                                        |
| `appserver.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution`        | Configure pod anti-affinity for the application server pods in accordance with Kubernetes **PodSpec.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution**. For more information about affinity and tolerations, see [Configuring affinity and tolerations.](#configuring-affinity-and-tolerations)                                                                                     |
| `appserver.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution`       | Configure pod anti-affinity for the application server pods in accordance with Kubernetes **PodSpec.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution**. For more information about affinity and tolerations, see [Configuring affinity and tolerations.](#configuring-affinity-and-tolerations)                                                           |
| `appserver.podAntiAffinity.replicaNotOnSameNode`                                  | Specify the directive to prevent scheduling of replicas in the same node. The valid values are `prefer`, `require`, or blank.                                  | `prefer`                                                 |
| `appserver.podAntiAffinity.weightForPreference`                                   | Specify the preference weight in the range of 1-100. Use only if `prefer` is specified for `appserver.podAntiAffinity.replicaNotOnSameNode`.                              | 100                                                      |
| `omserver.deploymentStrategy`                                                     | Specify the deployment strategy for both agent and integration servers. For more information about deployment strategy, see [Deployment strategy.](#deployment-strategy)                                                                                                                                                               |
| `omserver.image`                                                                  | Specify the container image details of agent server.                                                                                                                                                                 |
| `omserver.healthMonitor.deploy`                                                   | Specify `true` to deploy the health monitor agent.                                                                                                                                                                               | `true`                                                   |
| `omserver.healthMonitor.jvmArgs`                                                  | Specify the JVM arguments for the health monitor agent.                                                                                                                                                                              | `true`                                                   |
| `omserver.healthMonitor.replicaCount`                                             | Specify the number of health monitor agent instances to be deployed.                                                                                                                                                                             | `true`                                                   |
| `omserver.healthMonitor.resources`                                                | Specify the CPU and memory resource requests and limits.                                                                                                                                                                               | `true`                                                   |
| `omserver.common.jvmArgs`                                                         | Specify the JVM arguments for the list of agent servers in common.                                                                                                                                        |
| `omserver.common.replicaCount`                                                    | Specify the number of agent server instances to be deployed in common.                                                                                                                                       |
| `omserver.common.resources`                                                       | Specify the CPU and memory resource requests and limits in common.                                                                                                                                                              | Memory: `1024Mi`, CPU: `0,5`                             |
| `omserver.common.readinessFailRestartAfterMinutes`                                | Specify the approximate time period in minutes after which the agent restarts if readiness check keeps failing for this period.                                                                                                 | 10                                                       |
| `omserver.common.podLabels`                                                       | Specify the custom labels for agent pods.                                                                                                                                                                          |
| `omserver.common.tolerations`                                                     | Specify tolerations for agent server pods in accordance with Kubernetes **PodSpec.tolerations**.                                                       |
| `omserver.common.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution`     | Configure node affinity for the agent server pods in accordance with Kubernetes **PodSpec.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution**. For more information about affinity and tolerations, see [Configuring affinity and tolerations.](#configuring-affinity-and-tolerations)                                                                        |
| `omserver.common.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution`    | Configure node affinity for the agent server pods in accordance with Kubernetes **PodSpec.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution**. For more information about affinity and tolerations, see [Configuring affinity and tolerations.](#configuring-affinity-and-tolerations)                                                              |
| `omserver.common.podAffinity.requiredDuringSchedulingIgnoredDuringExecution`      | Configure pod affinity for the agent server pods in accordance with Kubernetes **PodSpec.podAffinity.requiredDuringSchedulingIgnoredDuringExecution**. For more information about affinity and tolerations, see [Configuring affinity and tolerations.](#configuring-affinity-and-tolerations)                                                                    |
| `omserver.common.podAffinity.preferredDuringSchedulingIgnoredDuringExecution`     | Configure pod affinity for the agent server pods in accordance with Kubernetes **PodSpec.podAffinity.preferredDuringSchedulingIgnoredDuringExecution**. For more information about affinity and tolerations, see [Configuring affinity and tolerations.](#configuring-affinity-and-tolerations)                                                                  |
| `omserver.common.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution`  | Configure pod anti-affinity for the agent server pods in accordance with Kubernetes **PodSpec.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution**. For more information about affinity and tolerations, see [Configuring affinity and tolerations.](#configuring-affinity-and-tolerations)                                                                |
| `omserver.common.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution` | Configure pod anti-affinity for the agent server pods in accordance with Kubernetes **PodSpec.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution**. For more information about affinity and tolerations, see [Configuring affinity and tolerations.](#configuring-affinity-and-tolerations)                                                              |
| `omserver.common.podAntiAffinity.replicaNotOnSameNode`                            | Specify the directive to prevent scheduling of replicas in the same node. The valid values are `prefer`, `require`, or blank.                           | `prefer`                                                 |
| `omserver.common.podAntiAffinity.weightForPreference`                             | Specify the preference weight in the range of 1-100. Use only if `prefer` is specified for `omserver.common.podAntiAffinity.replicaNotOnSameNode`.                                    | 100                                                      |
| `omserver.servers.group`                                                          | Specify the name for the agent server group.                                                                                                                                                                                    | `Default Servers`                                        |
| `omserver.servers.name`                                                           | Specify the list of agent server names as configured in Sterling Order Management Software                                                                                                                                                                               |
| `omserver.servers.jvmArgs`                                                        | Provide the JVM arguments for the list of agent servers in the group.                                                                                                                                                 |
| `omserver.servers.replicaCount`                                                   | Provide the number of instances to be deployed for the list of agent servers in the group.                                                                                                                                                |
| `omserver.servers.resources`                                                      | Provide the CPU and memory resource requests and limits for the list of agent servers in the group.                                                                                                                                                                      | Memory: `1024Mi`, CPU: `0,5`                             |
| `datasetup.loadFactoryData`                                                       | Specify `true` to load the factory data.                                                                                                                                                                                         |
| `datasetup.mode`                                                                  | Specify `create` as the mode for loading the factory data.                                                                                                                                                                            | `create`                                                 |
| `datasetup.fixPack.loadFPFactoryData`                                             | Specify `true` to load the fix pack factory data.                                                                                                                                                                                |
| `datasetup.fixPack.installedFPNo`                                                 | Specify the currently installed fix pack number beyond which the fix pack factory setup needs to be applied.                                                                                                               |
| `global.mq.bindingConfigName`                                                     | Specify the name of the ConfigMap that contains MQ bindings.                                                                                                                                                                    |
| `global.mq.bindingMountPath`                                                      | Specify the path where the bindings file needs to be mounted.                                                                                                                                                               | `/opt/ssfs/.bindings`                                    |
| `global.persistence.claims.name`                                                  | Specify the name of the Persistent Volume claim.                                                                                                                                                                                    | oms-common                                               |
| `global.persistence.claims.accessMode`                                            | Specify the access mode for the Persistent Volume.                                                                                                                                                                                              | ReadWriteMany                                            |
| `global.persistence.claims.capacity`                                              | Specify the capacity for the Persistent Volume.                                                                                                                                                                                                 | 10                                                       |
| `global.persistence.claims.capacityUnit`                                          | Specify the capacity unit of the Persistent Volume.                                                                                                                                                                                              | Gi                                                       |
| `global.persistence.claims.storageClassName`                                      | Specify the storage class for the Persistent Volume claim.                                                                                                                                                                |                                                          |
| `global.persistence.securityContext.fsGroup`                                      | Specify the file system group ID to access the Persistent Volume.                                                                                                                                                      | 0                                                        |
| `global.persistence.securityContext.supplementalGroup`                            | Specify the supplemental group ID to access the Persistent Volume.                                                                                                                                                     | 0                                                        |
| `global.image.repository`                                                         | Specify the repository for container images.                                                                                                                                                                                     |
| `global.image.agentName`                                                         | Specify the name of the agent image that is used for data setup jobs, preinstall, postinstall, and agent servers. If `omserver.image.name` is provided, it takes precedence for deploying agent servers.                                                                                                                                                                                    |
| `global.image.tag`                                                         | Specify the tag of the agent image that is used for data setup jobs, preinstall, postinstall, and agents severs. If `omserver.image.tag` is provided, it takes precedence for deploying agent servers.                                                                                                                                                                                    |
| `global.image.pullPolicy`                                                         | Specify the image pull policy for the  agent image that is used for data setup jobs, preinstall, postinstall, and agents severs. If `omserver.image.pullPolicy` is provided, it takes precedence for deploying agent servers.                                                                                                    |
| `global.appSecret`                                                                | Specify the name of the secret that is created as part of [prerequisites.](#creating-a-secret)                                                                                                                                                                                               |
| `global.database.dbvendor`                                                        | Specify the database vendor as `Db2` or `Oracle`.                                                                                                                                                                                      | DB2                                                      |
| `global.database.serverName`                                                      | Specify the IP address or hostname of database server.                                                                                                                                                                                          |
| `global.database.port`                                                            | Specify the port of the database server.                                                                                                                                                                                            |
| `global.database.dbname`                                                          | Specify the database name or catalog name.                                                                                                                                                                                   |
| `global.database.user`                                                            | Specify the username of the database.                                                                                                                                                                                                  |
| `global.database.datasourceName`                                                  | Specify the name for the external datasource.                                                                                                                                                                                  | jdbc or OMDS                                                |
| `global.database.systemPool`                                                      | Specify whether the database is used as system pool.                                                                                                                                                                                         | true                                                     |
| `global.database.schema`                                                          | Specify the database schema name. For `Db2` it is defaulted as `global.database.dbname` and for `Oracle` it is defaulted as `global.database.user`.                                                                         |
| `global.serviceAccountName`                                                       | Specify the name of the service account that is used for deployment.                                                                                                                                                                                      |
| `global.customerOverrides`                                                        | Provide an array of customer override properties as `key=value`.                                                                                                                                                     |
| `global.envs`                                                                     | Provide an array of environment variables as Kubernetes `EnvVars` objects.                                                                                                                                            |
| `global.arch`                                                                     | Specify the CPU architecture affinity while scheduling pods.                                                                                                                                                               | amd64: `2 - No preference`, ppc64le: `2 - No preference` |
| `global.customConfigMaps`                                                         | Specify an array of custom config maps to be mounted in each pod.                                                                                                                                                    |
| `global.customSecrets`                                                            | Specify an array of custom secrets to be mounted in each pod.                                                                                                                                                    |
| `global.fullnameOverride`                                                        | If you specify `fullnameOverride`, the provided value is used as the prefix for all the generated resources. The default prefix is `<release-name>-<chart-name>`.                                                              |
| `global.nameOverride`                                                        | If you specify `nameOverride`, the generated resources uses `<release-name>-<nameOverride>` as the prefix. The default prefix is `<release-name>-<chart-name>`.                                                                                                                            |
| `global.resources`                                                        | Specify the CPU and memory resource requests and limits.                                                                                                                                                     |
| `global.security.ssl.trustStore.storeLocation`                                        | Specify the path to TrustStore that is used by the application and agent servers to trust the external secure connections in PKCS12 format.                                                                                                                                                 |
| `global.security.ssl.trustStore.trustedCertDir`                                   | Specify the directory in shared volume, which contains the external server certificates that application and agent servers needs to trust. This value is overridden if you specify the `global.security.ssl.trustStore.storeLocation` parameter.                                                                                                                                               |
| `global.security.ssl.trustStore.trustJavaCACerts`                                 | Set the value to `true` if you want the application and agent servers to trust the default Java CA certificates.                                                                                                                                                     |  true |
| `global.security.ssl.keyStore.storeLocation`                                          | Specify the path to KeyStore that is used by the application and agent servers as identity certificate store in PKCS12 format.                                                                                                                                                     |

## SSL configurations for securing external connections

As part of your solution, you might come across situations where your application or agent servers need to communicate with an external or a third-party service for leveraging certain capabilities. Most of the times, these services are exposed over secure protocols such as HTTPS. At times, some services require mutual authentication (mTLS) to securely exchange data. For this, you need to configure SSL certificates in application and agent servers to enable trust with the external services and establish a successful secure connection. The Helm chart provides all the configurations required to configure the SSL certificates for your application and agent servers.  

- Trusting external server certificates

  To trust an external service from your application or agent servers, the Helm chart provides these options.

  - Using a custom TrustStore

    This approach provides you the flexibility to trust the specific services with which your application must establish SSL connection. You can create your own TrustStore by using the `keytool` command of JDK in p12 format. Copy the newly created TrustStore to the Persistent Volume and provide the complete path to the TrustStore with respect to the volume mounted within the pod in the Helm values by using `global.security.ssl.trustStore.storeLocation`. Also, add the password for this TrustStore in the secret created as a prerequisite provided in [Create a Secret](#creating-a-secret) section with the key `trustStorePassword`. For example, if the TrustStore is present in the Persistent Volume at `certs/truststore.p12` provide the value of `global.security.ssl.trustStore.storeLocation` as `/shared/certs/truststore.p12`. 

  - Using specific server certificates

    This approach provides you the ability to pass trusted server certificates as PEM files in the Persistent Volume. Provide the path to the directory that contains the trusted certificates in the Helm values by using `global.security.ssl.trustStore.trustedCertDir`. The application and agent servers already uses the default Java TrustStore. Use this option only if the certificates you want to trust are not already present in the default Java TrustStore. In case you do not want your servers to trust the certificates in default Java TrustStore, set the value of `global.security.ssl.trustStore.trustJavaCACerts` parameter to `False`.

- Providing identity certificates for mutual or client authentication

  You can provide your identity certificates for mutual or client authentication. You can create your own KeyStore by using the `keytool` command of JDK in p12 format. Ensure that this KeyStore includes all your identity certificates and keys that are required for mutual authentication between application and agent servers and external services. Copy the newly created KeyStore to the Persistent Volume and provide the complete path to the KeyStore with respect to the volume mounted within the pod in the Helm values by using `global.security.ssl.keyStore.storeLocation`. Also, add the password for this KeyStore in the secret created as a prerequisite provided in [Create a Secret](#creating-a-secret) section with the key `keyStorePassword`. For example, if the KeyStore is present in the Persistent Volume at `certs/keystore.p12` provide the value of `global.security.ssl.keyStore.storeLocation` as `/shared/certs/keystore.p12`. 

**Note:** If you add a new certificate to the TrustStore or KeyStore, ensure that you perform a rolling update of application and agent servers so that the new certificates are considered.

## Deploying multiple application images

By using the Helm chart, you can deploy multiple application images as part of a single Helm release. 

To deploy multiple application images, use the following `appserver.images` structure in values.yaml:

```yaml
appserver:
  replicaCount:
  image:
    tag: 
    pullPolicy:
    names:
      - name:
        probePath:
        tag:
        replicaCount:
        applications:
        - path:
          routePrefix:
```
To pass an array of image names, use `appserver.image.names` with optional configuration for specifying:

- paths to expose
- context root to expose
- route prefixes
- tag name
- replica count

For example:

```yaml
appserver:
  replicaCount: 1
  image:
    tag: 10.0.0.21
    pullPolicy: IfNotPresent
    names:
      - name: om-app
        tag: 10.0.0.21
      - name: om-app-isccs_sbc
      - name: om-app-sma_wsc
        applications:
          - path: '/sma'
          - path: '/wsc'
            routePrefix: webstore
        replicaCount: 2
      - name: om-app-docs
        probePath: '/smcfsdocs/yfscommon/api_javadocs'
        applications:
          - path: '/smcfsdocs'
            routePrefix: 'smcfsdocs'
```

In this example, 4 deployments are created for 4 images that are listed (`om-app`, `om-app-isccs_sbc`, `om-app-sma_wsc`, and `om-app-docs`). 

The routes and paths that are exposed adheres to the following conventions:

- If the image name is `om-app` and if you do not define the paths, the application exposes contexts that are defined in
  `appserver.ingress.contextRoots` property and defaults the `routePrefix` to `<context>-default`. For example, `smcfs-default`, `sbc-default`, and so on.
- If the image name is `om-app-<modules>`, the module names are broken by using a hyphen (`-`) and underscore (`_`) characters to form a list of modules. Also, the `routePrefix` is defaulted to `<context>-app-default`. For example, for the `om-app-isccs_sbc` image, the paths exposed are `isccs` and `sbc` with routePrefixes `isccs-app-default` and `sbc-app-default`, respectively.
- If the image name is provided only with the `path`information, `routePrefix` is defaulted to `<path>-path-default`. For example, if only `- path: "/sma"` is provided with no `routePrefix`, the `routePrefix` is computed to `sma-path-default`.
- In all of these cases, if you define `routePrefix`, routes are exposed with the provided prefix. Also, when you explicitly list the paths under `applications`, the application exposes only the listed paths through the routes. For example, if you specify `om-app` image with `path: "/smcfs"`, the application exposes only `smcfs` context root in the route.
- You can generate the API Javadoc image with the name `om-app-docs` by following the instructions provided in the [Generating Javadoc](https://www.ibm.com/support/knowledgecenter/en/SS6PEW_10.0.0/installation/c_OMRHOC_customizing_OMS_runtime.html) section. To deploy this image by using the Helm chart,
  - Pass `om-app-docs` under `appserver.image.names`.
  - Define probePath under `om-app-docs` as `/smcfsdocs/yfscommon/api_javadocs`
  - After deploying the `om-app-docs` image, you can access:
    - The API Javadoc from `<routePrefix>.<appserver.ingress.host>/smcfsdocs/yfscommon/api_javadocs/index.html`
    - The Core Javadoc from `<routePrefix>.<appserver.ingress.host>/smcfsdocs/yfscommon/core_javadocs/index.html`
    - The ERD from `<routePrefix>.<appserver.ingress.host>/smcfsdocs/yfscommon/ERD/HTML/erd.html`

## Deploying the REST API service

If a route API (`route.openshift.io/v1`) exists in cluster, you can use `appserver.exposeRestService` to create and dedicate the deployment to REST API. If you set the value of `appserver.exposeRestService` to true, the application creates a new deployment by using the `om-app` image and the tag provided in `appserver.image.tag` with a dedicated service and associated route. the Helm chart also prefixes the route with `xapirest`.

## Exposing the deployed applications

The following configurations are provided for exposing the applications based on your deployment platform:

### Configuring Kubernetes Ingress

**Note:** Ingress is enabled by default and the application is exposed as a `ClusterIP` service.

Configure the following parameters of values.yaml:

- `appserver.ingress.host` - The fully qualified domain name that resolves to the IP address of your cluster’s proxy node. Based on your network settings, it is possible that multiple virtual domain names resolve to the same IP address of the proxy node. You can use any of the domain names, for example "example.com" or "test.example.com".

- `appserver.ingress.ssl.enabled` - Set to `true` by default as SSL is recommended for production environments.

- `appserver.ingress.ssl.secretname` - The secret name that contains TLS certificate, which is used for SSL. If this parameter is blank, the Helm chart automatically generates a secret with a self-signed certificate.

  **Note:** You can use the self-signed certificates only for development purposes.

  For production environments, it is recommended that you obtain a CA certified TLS certificate and manually create a secret by completing the following steps:

  1. Obtain a CA certified TLS certificate for the given `appserver.ingress.host` in the form of a key and certificate files.
  2. Run the following command to create a secret with the name `<Release-name>-ingress-secret` by using the key and certificate files:

     ```sh
     kubectl create secret tls <Release-name>-ingress-secret --key <file containing key> --cert <file containing certificate> -n <namespace>
     ```

  3. Set the secret name as the value under `appserver.ingress.ssl.secretname`.
  
- `appserver.ingress.contextRoots` - Ingress by default exposes `smcfs`, `sbc`, `sma`, `isccs`, `wsc`, and `adminCenter`context roots. If you want to allow any additional context roots, add them to the list.

### Configuring Red Hat OpenShift route

**Note:** If you are using the Red Hat OpenShift cluster, routes are enabled by default and the application is exposed as a `ClusterIP` service.

Configure the following parameters of values.yaml:

- `appserver.ingress.host` - The fully qualified domain name of the cluster through which the applications are exposed. 

- `appserver.ingress.ssl.enabled` - Set to `true` by default as SSL is recommended for production environments.

**Note:** When SSL is enabled, routes are automatically created with TLS certificates. Also, the intracluster traffic is encrypted by using re-encrypt termination policy. During deployment, the routes are updated with the automatically generated service certificates. For more information about re-encrypt termination policy, see [Red Hat OpenShift documentation.](#https://docs.openshift.com/container-platform/latest/networking/routes/secured-routes.html)

## Network policy

A network policy specifies how groups of pods are allowed to communicate with each other and other network endpoints.

The Kubernetes Network Policy resource provides firewall capabilities to pods that are similar to the AWS security groups and programs and the software defined networking infrastructure (OpenShift Default, Flannel, and so on). You can implement the sophisticated network access policies to control the Ingress access to your workload pods.

`<Release-name>-network-policy` network policy is by default provided that establishes the pod communications with the role as `appserver`. For example,

  ```yaml
  ---
  kind: NetworkPolicy
  apiVersion: networking.k8s.io/v1
  metadata:
    name: <Release-name>-network-policy
  spec:
    podSelector:
      matchLabels:
        role: appserver
  ```

You can implement your own network policy. For more information about implementing a network policy, see [Kubernetes documentation.](https://kubernetes.io/docs/concepts/services-networking/network-policies/)

## Configuring IBM MQ for agent and integration servers

To configure IBM MQ, complete the following steps:

1. Ensure that the JMS resources that are required for agent and integration servers are configured in IBM MQ and the corresponding `.bindings` file is generated.

2. Create a ConfigMap to store the IBM MQ bindings. For example, run the following command to create a ConfigMap for the  `.bindings` file.

```sh
kubectl create configmap <config map name> --from-file=<path_to_.bindings_file> -n <namespace>
```

3. Specify the ConfigMap in `global.mq.bindingConfigName`.

After saving your changes in the values.yaml, run the `helm upgrade` command. For more information about upgrading the Helm chart, see [Upgrading the Helm chart](#upgrading-the-helm-chart).

## Configuring the agent and integration servers

**Note:** Ensure that you have [configured IBM MQ.](#configuring-ibm-mq-for-agent-and-integration-servers)

After you have a deployment ready with the application server running, you can configure the agents and integration servers by logging in to **Applications Manager**. After completing the configurations, upgrade the release as follows:

To start the agent and integration servers, in values.yaml of the Helm chart, specify the names of agent or integration servers for `omserver.servers` as illustrated in the following example:

```yaml
---
servers:
  - group: 'Logical Group 1'
    name:
      - scheduleOrder
      - releaseOrder
    jvmArgs: "-Xms512m\ -Xmx1024m"
    replicaCount: 1
    resources:
      requests:
        memory: 1024Mi
        cpu: 0.5

  - group: 'Logical Group 2'
    name:
      - integrationServer1
      - orderPurge
    jvmArgs: "-Xms512m\ -Xmx1024m"
    replicaCount: 2
    resources:
      requests:
        memory: 1024Mi
        cpu: 0.5
```

**Note:** While defining the agent or integration servers, do not use underscore`(_)` in the server name.

The common parameters that are defined under `omserver.common`such as jvmArgs, resources, tolerations, and others are applied to agent or integration server that is defined under `omserver.servers`. For the corresponding agent or integration server, the parameters provided under `omserver.servers` override the parameters that are defined under `omserver.common`. The agent servers defined under the same group share the same `omserver.common` parameters, for example `resources`. If there is a need to define a different set of `omserver.common` parameter, you can define multiple groups in `omserver.servers[]`. For example, if you have to run certain agents with higher CPU and memory requests or replication count, define a new group and  appropriately update the `resources` object.

## Deployment strategy

If you are upgrading to a new Helm chart version, you typically consider how to minimize the application downtime (if any), manage errors with minimal impact on users, address failed deployments in a reliable and effective way, and so on. Depending on your business logic, you might want to choose different strategies for your deployments.

Deployment strategy can be used to define how to replace the existing pods with new pods. The supported deployment strategies are `Recreate` or `RollingUpdate`. By default, the `RollingUpdate` deployment strategy is used.

For more information about the deployment strategies, see [Kubernetes documentation.](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy)

### Sample deployment strategies

#### RollingUpdate

The `RollingUpdate` deployment strategy replaces the existing pods with the new pods systematically such that there is minimal or no downtime.

```yaml
...
spec:
  replicas: 2
  strategy:
        type: RollingUpdate
        rollingUpdate:
           maxSurge: 25%
           maxUnavailable: 25%  
  template:
...
```

- `maxUnavailable` is an optional field that specifies the maximum number of pods that are unavailable during the update process.

- `maxSurge` is an optional field that specifies the number of pods that can be created beyond the maximum number of pods defined in `replicas`.


#### Recreate

The `Recreate` deployment strategy kills the existing pods at once and replaces with new pods.

```yaml
...
spec:
  replicas: 2
  strategy:
        type: Recreate
  template:
...
```

## PodSecurityPolicy Requirements

**Note:** These instructions are applications only for vanilla Kubernetes platform.

The Helm chart requires a `PodSecurityPolicy` to be bound to the target namespace prior to installation. You can select either a predefined `PodSecurityPolicy` or custom `PodSecurityPolicy` that is shared by your cluster administrator.

#### Custom PodSecurityPolicy definition:

```yaml
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  annotations:
    kubernetes.io/description: 'This policy allows pods to run with
      any UID and GID, but preventing access to the host.'
  name: ibm-oms-anyuid-psp
spec:
  allowPrivilegeEscalation: true
  fsGroup:
    rule: RunAsAny
  requiredDropCapabilities:
    - MKNOD
  allowedCapabilities:
    - SETPCAP
    - AUDIT_WRITE
    - CHOWN
    - NET_RAW
    - DAC_OVERRIDE
    - FOWNER
    - FSETID
    - KILL
    - SETUID
    - SETGID
    - NET_BIND_SERVICE
    - SYS_CHROOT
    - SETFCAP
  runAsUser:
    rule: RunAsAny
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  volumes:
    - configMap
    - emptyDir
    - projected
    - secret
    - downwardAPI
    - persistentVolumeClaim
  forbiddenSysctls:
    - '*'
```

To create a custom `PodSecurityPolicy`, create a yaml file with the custom `PodSecurityPolicy` definition and run the following command:

```sh
kubectl create -f <custom_psp.yaml>
```

#### Sample ClusterRole and RoleBinding definitions

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  annotations:
  name: ibm-oms-anyuid-clusterrole
rules:
  - apiGroups:
      - extensions
    resourceNames:
      - ibm-oms-anyuid-psp
    resources:
      - podsecuritypolicies
    verbs:
      - use

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ibm-oms-anyuid-clusterrole-rolebinding
  namespace: <namespace>
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: ibm-oms-anyuid-clusterrole
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: Group
    name: system:serviceaccounts:<namespace>
```

Replace the `<namespace>` definition with the namespace of the target environment.

To create a custom `ClusterRole` and `RoleBinding`, create a yaml file with the custom `ClusterRole` and `RoleBinding` definition and run the following command:

```sh
kubectl create -f <custom_psp_role_and_binding.yaml>
```

## Red Hat OpenShift SecurityContextConstraints Requirements

The Helm chart is verified with the predefined `SecurityContextConstraints` named [`ibm-anyuid-scc.`](https://ibm.biz/cpkspec-scc) Alternatively, you can use a custom `SecurityContextConstraints.` Ensure that you bind the `SecurityContextConstraints` resource to the target namespace prior to installation.

#### Custom SecurityContextConstraints definition:

```yaml
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  annotations:
  name: ibm-oms-scc
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegedContainer: false
allowedCapabilities: []
allowedFlexVolumes: []
defaultAddCapabilities: []
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
priority: 0
```

To create a custom `SecurityContextConstraints`, create a yaml file with the custom `SecurityContextConstraints` definition and run the following command:

```sh
kubectl create -f <custom-scc.yaml>
```

## Installing the Helm chart

In values.yaml, set the values of `global.license` and `global.licenseStoreCallCenter` to `True` along with the required chart parameters.

For detailed instructions on how to install the application and agent servers, see [Deploying the application and agent servers.](https://www.ibm.com/support/knowledgecenter/SS6PEW_10.0.0/installation/c_OMRHOC_applicationserver_agents.html)

**Note:** Depending on the capacity of Kubernetes worker node and database connectivity, the complete deployment process can take approximately 2 to 3 minutes on a preloaded database, and 20 to 30 minutes on a fresh database.

When you check the deployment status, you can see the following values:

- `Running`: Indicates that the container has started.
- `Init: 0/1`: Indicates that the primary container will start only after the init container starts.

You can also see the following values in readiness state:

- `0/1`: Indicates that the container has started, but the application is not yet ready to use.
- `1/1`: Indicates that the application is ready to use.

Run the following command to verify that the log file does not contain any errors:

```sh
# Run the following command to retrieve the list of pods in the deployment namespace and identify the application server pod.
kubectl get pods -n <namespace>

# Run the following command to view the list of application server pod:
kubectl logs -f -n <namespace> <pod_name>
```

## Air gap Installation

You can install certified containers in an air gap environment where your Kubernetes cluster does not have access to the internet. Therefore, it is important to properly configure and install the certified containers in such an environment.

### Downloading Sterling Order Management Software case bundle

You can download the Sterling Order Management Software case bundle and the Helm chart from the remote repositories to your local machine, which will eventually be used for offline installation by running the following command:


  ```bash
    cloudctl case save                                \
      --case <URL containing the CASE file to parse.> \
      --outputdir </path/to/output/dir> 
  ```

For additional help on `cloudctl case save`, run `cloudctl case save -h`.

### Setting credentials to pull or push certified container images

To set up the credentials for downloading the certified container images from IBM Cloud Registry to your local registry, run the appropriate command.

- For local registry without authentication

  ```bash
    # Set the credentials to use for source registry
    cloudctl case launch              \
    --case </path/to/downloaded/case> \
    --inventory ibmOmsEntProd         \
    --action configure-creds-airgap   \
    --args "--registry $SOURCE_REGISTRY --user $SOURCE_REGISTRY_USER --pass $SOURCE_REGISTRY_PASS"
  ```

- For local registry with authentication

  ```bash
    # Set the credentials for the target registry (your local registry)
    cloudctl case launch              \
    --case </path/to/downloaded/case> \
    --inventory ibmOmsEntProd         \
    --action configure-creds-airgap   \
    --args "--registry $TARGET_REGISTRY --user $TARGET_REGISTRY_USER --pass $TARGET_REGISTRY_PASS"
  ```

### Mirroring the certified container images

To mirror the certified container images and configure your cluster by using the provided credentials, run the following command:

  ```bash
    cloudctl case launch              \
    --case </path/to/downloaded/case> \
    --inventory ibmOmsEntProd         \ 
    --action mirror-images            \
    --args "--registry <your local registry> --inputDir </path/to/directory/that/stores/the/case>"
  ```

The certified container images are pulled from the source registry to your local registry that you can use for offline installation.

### Installing the Helm chart in an air gap environment

Before you begin, ensure that you review and complete the [prerequisites.](#deployment-prerequisites)  

To install the Helm chart, run the following command:

  ```bash
    cloudctl case launch                    \
        --case </path/to/downloaded/case>   \
        --namespace <NAME_SPACE>            \
        --inventory ibmOmsEntProd           \
        --action install                    \
        --args "--values </path/to/values.yaml> --releaseName <release-name> --chart </path/to/chart>"
    
    # --values: refers to the path of values.yaml file.
    # --releaseName: refers to the name of the release.
    # --chart: refers to the path of downloaded chart.
  ```

### Uninstalling the Helm chart in an air gap environment

To uninstall the Helm chart, run the following command:

  ```bash
    cloudctl case launch                    \
        --case </path/to/downloaded/case>   \
        --namespace <NAME_SPACE>            \
        --inventory ibmOmsEntProd           \
        --action uninstall                  \
        --args "--releaseName <release-name>"
    
    # --releaseName: refers to the name of the release.
  ```

## Configuring affinity and tolerations

The Helm chart provides various ways for advanced pod scheduling in Kubernetes such as node affinity, pod affinity, pod anti-affinity, and tolerations. For more information about the usage and specifications of affinity and tolerations, see the [Kubernetes documentation.](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/)

The following parameters are exposed to configure affinity and tolerations. For more information about these parameters, see [Configuration parameters in values.yaml.](#configuration-parameters-in-values.yaml)

- Tolerations
  - For application servers, configure tolerations by using `appserver.tolerations`.
  - For agent servers, configure tolerations by using `omserver.common.tolerations`.

- Node affinity

  - For application servers, configure node affinity by using the following parameters:
    - `appserver.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution`
    - `appserver.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution`
  - For agent servers, configure the following parameters:
    - `omserver.common.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution`
    - `omserver.common.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution`

  Depending on the preferred CPU architecture provided in `global.arch`, a suitable value for node affinity is automatically appended in addition to the custom values.

- Pod affinity

  - For application servers, configure pod affinity by using the following parameters:
    - `appserver.podAffinity.requiredDuringSchedulingIgnoredDuringExecution`
    - `appserver.podAffinity.preferredDuringSchedulingIgnoredDuringExecution`
  - For agent servers, configure pod affinity by using the following parameters:
    - `omserver.common.podAffinity.requiredDuringSchedulingIgnoredDuringExecution`
    - `omserver.common.podAffinity.preferredDuringSchedulingIgnoredDuringExecution`

- Pod anti-affinity

  - For application servers, configure pod anti-affinity by using the following parameters:
    - `appserver.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution`
    - `appserver.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution` 
  - For agent servers, configure pod anti-affinity by using the following parameters:
    - `omserver.common.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution`
    - `omserver.common.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution`

  Depending on the value of `podAntiAffinity.replicaNotOnSameNode`, a suitable value for pod anti-affinity is automatically appended in addition to the custom values. This ensures that replicas of a pod are scheduled on the same node.
  - If the value is set to `prefer`, then `podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution` is automatically 
    appended. The `podAntiAffinity.weightForPreference` parameter is set as the preference for which the value must be
    specified in the range of 1-100.
  - If the value is set to `require`, then `podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution` is appended.
  - If the value is blank, then no pod anti-affinity value is automatically appended.

### For application servers

- `appserver.tolerations` 
- `appserver.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution`
- `appserver.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution`
- `appserver.podAffinity.requiredDuringSchedulingIgnoredDuringExecution`
- `appserver.podAffinity.preferredDuringSchedulingIgnoredDuringExecution`
- `appserver.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution`
- `appserver.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution`

### For agent servers

- `omserver.common.tolerations`
- `omserver.common.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution`
- `omserver.common.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution`
- `omserver.common.podAffinity.requiredDuringSchedulingIgnoredDuringExecution`
- `omserver.common.podAffinity.preferredDuringSchedulingIgnoredDuringExecution`
- `omserver.common.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution` 
- `omserver.common.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution`
  
## Readiness and liveness

Kubernetes uses liveness probes to know when to restart a container. It also uses readiness probes to know when a container is ready to start accepting traffic. Readiness and liveness checks are provided for agents and application server pods as applicable.

You can tune readiness and liveness checks for agent and application server pods by using the following parameters:

### For application servers

- `appserver.livenessCheckBeginAfterSeconds`
- `appserver.livenessFailRestartAfterMinutes`

For example, if you set the values of `appserver.livenessCheckBeginAfterSeconds` and `appserver.livenessFailRestartAfterMinutes` to `900` and `10` respectively, and the application server pod is not able to start successfully even after `25` minutes, the application server pod restarts. 

Even though the application server pod has successfully started, if the liveness check keeps failing continuously for 10 minutes, the application server pod restarts.

### For agent servers

- `omserver.common.readinessFailRestartAfterMinutes`
   
   For example, if you set the value of `omserver.common.readinessFailRestartAfterMinutes` to`10` and the agent server pod is not able to successfully start even after `10` minutes, the agent server pod restarts.

For more information about these parameters, see [Configuration parameters in values.yaml.](#configuration-parameters-in-values.yaml)

## Customizing the server.xml file for Liberty

**Note:** If a custom server.xml is not configured, the Helm chart generates the default server.xml file for deployment.

To customize server.xml for the Liberty application server, complete the following steps:

1. Create a custom server.xml file with the name, `server.xml`.

2. Run the following command to create a ConfigMap with the custom server.xml file:

   ```sh
   kubectl create configmap <config map name> --from-file=<path to custom server.xml> -n <namespace>
   ```

3. Specify the name of the ConfigMap in the `appserver.config.libertyServerXml` parameter of values.yaml.

**Important:**

- Ensure that the database information present in the datasource section of the Liberty server.xml is same as what is
  specified in values.yaml for `global.database` object.
- Ensure that the http and https ports in the Liberty server.xml are same as the ports specified in the
  `appserver.service.http.port` and `appserver.service.https.port` parameters of values.yaml.

## Upgrading the Helm chart

When a new application or agent server image is available, you might want to upgrade your deployment to consume the latest image.

To upgrade the Helm chart, complete the following steps:

1. Download the Helm chart. For more information about downloading the Helm chart, see [Downloading the Helm charts.](https://www.ibm.com/support/knowledgecenter/SS6PEW_10.0.0/com.ibm.help.install.omsoftware.doc/installation/c_OMRHOC_download_OMSChart.html)

2. Ensure to set the value of `datasetup.loadFactoryData` parameter to `donotinstall` or blank. 

3. Run the following command to upgrade your deployments:

```sh
helm upgrade <release-name> -f values.yaml ./ibm-oms-ent-prod --timeout 3600s
```

## Rolling back the Helm chart

At times you might want to rollback your current Helm release to a previous revision of the release.

To roll back a Helm release, run the following command:

```sh
helm rollback <release-name> <revision>
```
Here, `<revision>` refers to the revision of the Helm release.

For more information about rolling back a Helm release version, see [Helm documentation.](https://helm.sh/docs/helm/helm_rollback/)

## Uninstalling the Helm chart

To uninstall or delete a Helm deployment, run the following command:

```sh
 helm uninstall <release-name>
```

There are certain additional resources that are created by the Helm chart by using Helm hook. When you run the Helm delete command, these resources are not deleted. Ensure to manually delete them.

The following resources are created by the Helm chart by using Helm hook:

- `<release-name>-ibm-oms-ent-prod-config`
- `<release-name>-ibm-oms-ent-prod-def-server-xml-conf`
- `<release-name>-ibm-oms-ent-prod-datasetup`
- `<release-name>-ibm-oms-ent-prod-auto-ingress-secret`

**Note:** Additionally, you might want to delete resources that are created as part of [prerequisites.](#deployment-prerequisites)
