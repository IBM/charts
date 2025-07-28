# IBM Sterling Control Center Monitor V6.3.1.0

## Introduction

IBM▒ Control Center Monitor is a centralized monitoring and management system. It gives operations personnel the capability to continuously monitor the status of Configuration Managers, engines, and adapters across the enterprise for the following server types from one central location: IBM Sterling Connect:Direct▒, IBM Sterling Connect:Enterprise▒, IBM Sterling B2B Integrator, IBM Sterling File Gateway, IBM Global High Availability Mailbox, IBM Sterling Connect:Express, IBM QuickFile, IBM MQ Managed File Transfer and Many FTP servers. To find out more, see the Knowledge Center for [IBM Sterling Control Center Monitor](  https://www.ibm.com/docs/en/control-center/6.3.1?topic=sterling-control-center-monitor-631).

## Chart Details

This chart deploys IBM Sterling Control Center Monitor on a container management platform with the following resources deployments

- a statefulset pod `<release-name>-ibm-sccm` with 1 replica by default.
- a configMap `<release-name>-ibm-sccm`. This is used to provide default configuration in scc_config_file.
- a service `<release-name>-ibm-sccm`. This is used to expose the Control Center Monitor services for accessing using clients.
- a service-account `<release-name>-ibm-sccm-serviceaccount`. This service will not be created if `serviceAccount.create` is `false`.
- a persistence volume claim `<release-name>-ibm-sccm-pvc-ccm`.
- a persistence volume claim `<release-name>-ibm-sccm-pvc-ui`.

## Prerequisites

1. Red Hat OpenShift Container Platform 
   * Version 4.14.0 or later fixes
   * Version 4.15.0 or later fixes
   * Version 4.16.0 or later fixes
   * Version 4.17.0 or later fixes
2. Kubernetes version >= 1.27 and <=1.32 with beta APIs enabled.
3. Helm version >= 3.18.x
4. Ensure that one of the supported database server (Oracle/DB2/MSSQL) is installed and the database is accessible from inside the cluster.
5. Ensure that the docker images for IBM Sterling Control Center Monitor from IBM Entitled Registry are downloaded and pushed to an image registry accessible to the cluster.
6. Database driver files can be passed using any one of the following ways:
a. Create a persistent volume with access mode as 'Read Only Many' and place the database driver jar files in the mapped volume location.
b. Create a wrapper image over existing control center image and add database driver files to that new image and give that path in configuration of control center. Sample Dockerfile content can be found at location ibm_cloud_pak/pak_extensions/pre-install/wrapper/.
c. Create an image that includes database drivers, specify that image as extra init container and use command to copy drivers to one of shared mapped location so that main container can access those drivers.

7. Keystore and trust store files can be passed using one of the following ways:
a. Create a persistent volume with access mode as 'Read Only Many' and place the Key store and trust store files in the mapped volume location.
b. Key store and trust store files can be specified using kubernetes secrets using following command
```
kubectl create secret generic ibm-sccm-certs --from-file=keystore=<path to keystore file> --from-file=truststore=<path to truststore file>
```

8. Create a persistent volume for mapping configuration and logs of Control Center. Sample file can be found at location ibm_cloud_pak/pak_extensions/pre-install/volumes/
9. Create a secret with all secure credentials such as database password, keystore, truststore passwords, admin password and user key. Example can be found at ibm_cloud_pak/pak_extensions/pre-install/secret/.

10. Create a secret to pull the image from a private registry or repository using following command
```
kubectl create secret docker-registry <name of secret> --docker-server=<your-registry-server> --docker-username=<your-username> --docker-password=<your-password> --docker-email=<your-email>
```

Configure this pull secret in the service account used for deployment using this command

```
kubectl patch serviceaccount <service-account-name> -p '{"imagePullSecrets": [{"name": "<pull-secret-name>"}]}'
```

It is recommended to configure the pull secret in the service account as it automatically binds as a pull secret for all application pods. If the pull secret is added to the service account then the image pullSecret configurations in the helm configuration file are not required.

### PodSecurityPolicy Requirements

With Kubernetes v1.25, Pod Security Policy (PSP) API has been removed and replaced with Pod Security Admission (PSA) contoller. Kubernetes PSA conroller enforces predefined Pod Security levels at the namespace level. The Kubernetes Pod Security Standards defines three different levels: privileged, baseline, and restricted. Refer to Kubernetes [`Pod Security Standards`] (https://kubernetes.io/docs/concepts/security/pod-security-standards/) documentation for more details. This chart is compatible with the restricted security level. 

For users upgrading from older Kubernetes version to v1.29 or higher, refer to Kubernetes [`Migrate from PSP`](https://kubernetes.io/docs/tasks/configure-pod-container/migrate-from-psp/) documentation to help with migrating from PodSecurityPolicies to the built-in Pod Security Admission controller.

For users continuing on older Kubernetes versions (<1.25) and using PodSecurityPolicies, choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you. This chart is compatible with most restrictive policies.
Below is an optional custom PSP definition based on the IBM restricted PSP.

* Predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp)
 
- From the user interface or command line, you can copy and paste the following snippets to create and enable the below custom PodSecurityPolicy based on IBM restricted PSP.
	- Custom PodSecurityPolicy definition:

	```
	apiVersion: policy/v1beta1
	kind: PodSecurityPolicy
	metadata:
	  name: ibm-sccm-psp
	  labels:
	    app: "ibm-sccm-psp"
	spec:
	  privileged: false
	  allowPrivilegeEscalation: false
	  hostPID: false
	  hostIPC: false
	  hostNetwork: false
	  allowedCapabilities:
	  requiredDropCapabilities:
	  - ALL
	  allowedHostPaths:
	  runAsUser:
	    rule: MustRunAsNonRoot
	  runAsGroup:
	    rule: MustRunAs
	    ranges:
	    - min: 1
              max: 4294967294
	  seLinux:
	    rule: RunAsAny
	  supplementalGroups:
	    rule: MustRunAs
	    ranges:
	    - min: 1
	      max: 4294967294
	  fsGroup:
	    rule: MustRunAs
	    ranges:
	    - min: 1
	      max: 4294967294
	  volumes:
	  - configMap
	  - emptyDir
	  - projected
	  - secret
	  - downwardAPI
	  - persistentVolumeClaim
	  - nfs
	  forbiddenSysctls:
	  - "*"
	```

	- Custom ClusterRole for the custom PodSecurityPolicy:

	```
	apiVersion: rbac.authorization.k8s.io/v1
	kind: ClusterRole
	metadata:
	  name: "ibm-sccm-psp"
	  labels:
	    app: "ibm-sccm-psp"
	rules:
	- apiGroups:
	  - policy
	  resourceNames:
	  - ibm-sccm-psp
	  resources:
	  - podsecuritypolicies
	  verbs:
	  - use
	```
	
	- Custom Role binding for the custom PodSecurityPolicy:
	
	```
	apiVersion: rbac.authorization.k8s.io/v1beta1
	kind: RoleBinding
	metadata:
	  name: "ibm-sccm-psp"
	  labels:
	    app: "ibm-sccm-psp"
	roleRef:
	  apiGroup: rbac.authorization.k8s.io
	  kind: ClusterRole
	  name: "ibm-sccm-psp"
	subjects:
	- apiGroup: rbac.authorization.k8s.io
	  kind: Group
	  name: system:serviceaccounts
	  namespace: {{ NAMESPACE }}
	```


- From the command line, you can run the setup scripts included under pak_extensions (untar the downloaded archive to extract the pak_extensions directory)

  As a cluster admin the pre-install script is located at:
  - pre-install/clusterAdministration/createSecurityClusterPrereqs.sh

  As team admin the namespace scoped pre-install script is located at:
  - pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh

### SecurityContextConstraints Requirements

Red Hat OpenShift provides a pre-defined or default set of SecurityContextConstraints (SCC). These SCCs are used to control permissions for pods. These permissions include actions that a pod can perform and what resources it can access. You can use SCCs to define a set of conditions that a pod must run with to be accepted into the system. Refer to OpenShift [`Managing Security Context Constraints`](https://docs.openshift.com/container-platform/4.14/authentication/managing-security-context-constraints.html#default-sccs_configuring-internal-oauth) documentation for more details on the default SCCs. This chart is compatible with **nonroot-v2** (added in OpenShift v4.11) default SCCs and does not require a custom SCC to be defined explicity.

For OpenShift, choose either a predefined SCC or have your cluster administrator create a custom SCC for you as per the security profile and policies adopted for all OpenShift deployments. This chart is compatible with most restrictive security context constraints.
Below is an optional custom SCC definition based on the IBM restricted SCC.

* Predefined SecurityContextConstraints name: [`ibm-restricted-scc`](https://ibm.biz/cpkspec-scc)

- From the user interface or command line, you can copy and paste the following snippets to create and enable the below custom SCC based on IBM restricted SCC.

	- Custom SecurityContextConstraints definition:

	```
	apiVersion: security.openshift.io/v1
	kind: SecurityContextConstraints
	metadata:
	  name: ibm-sccm-scc 
	  labels:
	    app: "ibm-sccm-scc"
		app.kubernetes.io/instance: "ibm-sccm"
		app.kubernetes.io/managed-by: "ibm-sccm"
		app.kubernetes.io/name: "ibm-sccm"
	allowHostDirVolumePlugin: false
	allowHostIPC: false
	allowHostNetwork: false
	allowHostPID: false
	allowHostPorts: false
	allowPrivilegeEscalation: false
	allowPrivilegedContainer: false
	allowedCapabilities:
	defaultAddCapabilities: null
	fsGroup:
	  type: MustRunAs
	  ranges:
	  - min: 1
	    max: 4294967294
	priority: 0
	readOnlyRootFilesystem: false
	requiredDropCapabilities:
	- ALL
	runAsUser:
	  type: MustRunAsRange
	  uidRangeMin: 1
	  uidRangeMax: 4294967294
	seLinuxContext:
	  type: MustRunAs
	seccompProfiles:
	- runtime/default
	supplementalGroups:
          type: MustRunAs
          ranges:
          - min: 1
            max: 4294967294
	users: []
	volumes:
	- configMap
	- downwardAPI
	- emptyDir
	- persistentVolumeClaim
	- projected
	- secret
	- nfs
	```

	- Custom ClusterRole for the custom SecurityContextConstraints:

	```
	apiVersion: rbac.authorization.k8s.io/v1
	kind: ClusterRole
	metadata:
	  name: "ibm-sccm-scc"
	  labels:
		app: "ibm-sccm-scc"
	rules:
	- apiGroups:
	  - security.openshift.io
	  resourceNames:
	  - ibm-sccm-scc
	  resources:
	  - securitycontextconstraints
	  verbs:
	  - use
	```

	- Custom Role binding for the custom SecurityContextConstraints:

	```	
	apiVersion: rbac.authorization.k8s.io/v1
	kind: ClusterRoleBinding
	metadata:
	  name: "ibm-sccm-scc"
	  labels:
		app: "ibm-sccm-scc"
	roleRef:
	  apiGroup: rbac.authorization.k8s.io
	  kind: ClusterRole
	  name: "ibm-sccm-scc"
	subjects:
	- apiGroup: rbac.authorization.k8s.io
	  kind: Group
	  name: system:serviceaccounts
	  namespace: {{ NAMESPACE }}
	```

- From the command line, you can run the setup scripts included under pak_extensions (untar the downloaded archive to extract the pak_extensions directory)

  As a cluster admin the pre-install script is located at:
  - pre-install/clusterAdministration/createSecurityClusterPrereqs.sh

  As team admin the namespace scoped pre-install script is located at:
  - pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh
 
  As team admin the namespace scoped pre-install script for adding **nonroot-v2** is located at:
  - pre-install/namespaceAdministration/addNonrootSCCNamespacePrereqs.sh
  
### Installing a PodDisruptionBudget

* defaultPodDisruptionBudget.enabled - If true, It will create a pod disruption budget for IBM Sterling Control Center Monitor pods.
* defaultPodDisruptionBudget.minAvailable - It will specify Minimum number / percentage of pods that should remain scheduled for IBM Sterling Control Center Monitor pod.
  
## Network Policy
For Certified Container deployments, few default network policies are created out of the box as per mandatory security guidelines. By default all ingress and egress traffic are denied with few additional policies to allow communication within cluster and on ports configured in the helm charts configuration. Additionally custom ingress and egress policies can be configured in values yaml to allow traffic from and to specific external service endpoints.

Note: By default all ingress and egress traffic from or to external services are denied. You will need to create custom network policies to allow ingress and egress traffic from or to services outside of the cluster like database, MQ, protocol adapter endpoints, any other third party service integration and so on.

Out of the box Ingress policies

* Deny all ingress traffic
* Allow ingress traffic from all pods in the current namespace in the cluster
* Allow ingress traffic on the additional configured ports in helm values

Out of the box Egress policies

* Deny all egress traffic
* Allow egress traffic within the cluster

## Resources Required

This chart uses the following resources by default:

* 8Gi of persistent volume
* 20 GB Disk space
* 3000m CPU
* 8Gi Memory
* 1 master node and at least 1 worker node

## Agreement to IBM Control Center License

You must read the IBM Sterling Control Center License agreement terms before installation, using the below link:
[License](https://www.ibm.com/support/customer/csol/terms/?id=L-QZDV-G39NEP&lc=en) (L/N: L-QZDV-G39NEP)

## Installing the Chart

Prepare a custom values.yaml file based on the configuration section.

To install the chart with the release name my-release:

Ensure that the chart is downloaded locally and available.

Run the below command

```bash
$ helm install my-release -f values.yaml ibm-sccm-3.1.18.tgz
```

Depending on the capacity of the kubernetes worker node and database network connectivity, chart deployment can take on average 6-7 minutes for Installing Control Center.

## Configuration

The following tables lists the configurable parameters of the IBM Control Center Monitor chart and their default values.

| Parameter                                       | Description                                         | Default                                  |
| ------------------------------------------------| ----------------------------------------------------| -----------------------------------------|
| `arch`                                          | Node Architecture                                   | `amd64`                                  |
| `replicaCount`                                  | Number of deployment replicas                       | `1`                                      |
| `image.repository`                              | Image full name including repository                |                                          |
| `image.tag`                                     | Image tag                                           |                                          |
| `image.imageSecrets`                            | Image pull secrets                                  |                                          |
| `image.pullPolicy`                              | Image pull policy                                   | `IfNotPresent`                           |
| `ccArgs.ccInterval`                             | Interval Time between pod restart                   | `2h`                                     |
| `ccArgs.devEnvDropTables`                       | Flag for dropping table in dev environment          | `false`                                  |
| `ccArgs.enableAutoRebalanceServers`             | Auto rebalancing of monitored servers between EPs   | `true`                                   |
| `ccArgs.engineNamePrefix`                       | Engine Name Prefix for EPs                          |                                          |
| `ccArgs.productEntitilement`                    | Product Entitlement                                 |                                          |
| `ccArgs.dbType`                                 | Database Type                                       |                                          |
| `ccArgs.dbHost`                                 | Database Hostname                                   |                                          |
| `ccArgs.dbPort`                                 | Database Port number                                |                                          |
| `ccArgs.dbUser`                                 | Database Username                                   |                                          |
| `ccArgs.dbName`                                 | Database name                                       |                                          |
| `ccArgs.dbLoc`                                  | Database localization                               | `none`                                   |
| `ccArgs.dbInit`                                 | Database Initialization Flag                        | `true`                                   |
| `ccArgs.dbPartition`                            | Database Partitioning Flag                          | `false`                                  |
| `ccArgs.dbDrivers`                              | Database drivers                                    |                                          |
| `ccArgs.mssqlGlobal`                            | Database Globalization Flag                         | `false`                                  |
| `ccArgs.weblistenAddress`                       | Web Listen Address                                  | `0.0.0.0.`                               |
| `ccArgs.webHost`                                | Web Hostname                                        |                                          |
| `ccArgs.autoStopJavaWebAppServer`               | Auto stop Java web server                           | `true`                                   |
| `ccArgs.eventRepositoryAuth`                    | Event Repository Autentication                      | `false`                                  |
| `ccArgs.emailHostname`                          | Email hostname                                      | `localhost`                              |
| `ccArgs.emailPort`                              | Email Port number                                   | `25`                                     |
| `ccArgs.emailUser`                              | Email username                                      |                                          |
| `ccArgs.emailRespond`                           | Responding email address                            | `noone@anywhere`                         |
| `ccArgs.ccAdminEmailAddress`                    | Admin Email Address                                 | `noone@anywhere`                         |
| `ccArgs.smtpTLSEnabled`                         | Secure TLS is enabled or Not                        |`true`                                    |
| `ccArgs.oracleRacOrScan`                        | Oracle is Single Client Access Name or not          |                                          |
| `ccArgs.jmsEnable`                              | JMS enables or not                                  |                                          |
| `ccArgs.jmsType`                                | JMS type                                            |                                          |
| `ccArgs.jmsHost`                                | JMS Host name                                       |                                          |
| `ccArgs.jmsPort`                                | JMS Port number                                     |                                          |
| `ccArgs.jmsQueueManager`                        | JMS Queue Manager                                   |                                          |
| `ccArgs.jmsChannel`                             | JMS Channel name                                    |                                          |
| `ccArgs.jmsSubject`                             | JMS Subject name                                    |                                          |
| `ccArgs.jmsTopic`                               | JMS Topic name                                      |                                          |
| `ccArgs.jmsEmbedBroker`                         | JMS Embed Broker                                    |                                          |
| `ccArgs.jmsDataDirectory`                       | JMS Data Directory                                  |                                          |
| `ccArgs.jmsTimeToLive`                          | JMS Time to live                                    |                                          |
| `ccArgs.jmsRetries`                             | JMS time to live                                    |                                          |
| `ccArgs.jmsRetryWait`                           | JMS retry wait                                      |                                          |
| `ccArgs.jmsBrokerName`                          | JMS Broker Name                                     |                                          |
| `ccArgs.dbSSL`                                  | Database SSL Enabled                                |                                          |
| `ccArgs.keyStore`                               | Keystore file path                                  |                                          |
| `ccArgs.trustStore`                             | Truststore file path                                |                                          |
| `ccArgs.adminEmailAddress`                      | Admin Email Address                                 |                                          |
| `ccArgs.keyAlias`                               | Key Alias name                                      |                                          |
| `ccArgs.packagePath`                            | Package Path                                        |                                          |
| `ccArgs.seasPrimaryAddress`                     | SEAS Primary Address                                |                                          |
| `ccArgs.seasPrimaryPort`                        | SEAS Primary Port number                            |                                          |
| `ccArgs.seasAlternativeAddress`                 | SEAS Alternative Address                            |                                          |
| `ccArgs.seasAlternativePort`                    | SEAS Alternative Port number                        |                                          |
| `ccArgs.seasSecureConnection`                   | SEAS Secure Connection required or not              | `N`                                      |
| `ccArgs.seasProfileName`                        | SEAS Profile Name                                   |                                          |
| `ccArgs.seasPersistentConnection`               | SEAS Persistent Connection required or not          | `N`                                      |
| `ccArgs.seasSecureProtocol`                     | SEAS Secure Protocol name                           |                                          |
| `dashboard.enabled`                             | For making monitoring dashboard enabled             |                                          |
| `persistentVolumeCCM.enabled`                   | persistent volume for all volumes except user input | `true`                                   |
| `persistentVolumeCCM.useDynamicProvisioning`    | To use storage classes to dynamically create PV     | `false`                                  |
| `persistentVolumeCCM.storageClassName`          | Storage class of the PVC                            | `manual`                                 |
| `persistentVolumeCCM.size`                      | Size of PVC volume                                  | `20Gi`                                   |
| `persistentVolumeCCM.claimName`                 | Already created PVC name                            |                                          |
| `persistentVolumeCCM.accessMode`                | PV accessMode                                       | `ReadWriteOnce`                          |
| `persistentVolumeCCM.selector.label`            | Label name for attaching PV                         |                                          |
| `persistentVolumeCCM.selector.value`            | Label value for attaching PV                        | `ReadWriteOnce`                          |
| `persistentVolumeUserInputs.enabled`            | persistent volume for user input                    | `true`                                   |
| `persistentVolumeUserInputs.useDynamicProvisioning`| To use storage classes to dynamically create PV  | `false`                                  |
| `persistentVolumeUserInputs.storageClassName`   | Storage class of the PVC                            | `manual`                                 |
| `persistentVolumeUserInputs.size`               | Size of PVC volume                                  | `2Gi`                                    |
| `persistentVolumeUserInputs.claimName`          | Already created PVC name                            |                                          |
| `persistentVolumeUserInputs.accessMode`         | PV accessMode                                       | `ReadWriteOnce`                          |
| `persistentVolumeUserInputs.selector.label`     | Label name for attaching PV                         |                                          |
| `persistentVolumeUserInputs.selector.value`     | Label value for attaching PV                        | `ReadWriteOnce`                          |
| `service.type`                                  | Kubernetes service type exposing ports              | `LoadBalancer`                           |
| `service.loadBalancerIP`                        | For passing load balancer IP                        |                                          |
| `service.loadBalancerSourceRanges`              | Load Balancer sources                               | `[]`                                     |
| `service.externalTrafficPolicy`                 | For passing external Traffic Policy                 | `Local`                                  |
| `service.sessionAffinity`                       | For giving session Affinity                         | `ClientIP`                               |
| `service.swingConsole.name`                     | Swing Console name                                  | `swing-console`                          |
| `service.swingConsole.port`                     | Swing Console port number                           | `58080`                                  |
| `service.swingConsole.protocol`                 | Swing Console Protocol for service                  | `TCP`                                    |
| `service.swingConsole.allowIngressTraffic`      | Allowing Ingress traffic for Swing Console          | `true`                                   |
| `service.webConsole.name`                       | Web Console name                                    | `web-console`                            |
| `service.webConsole.port`                       | Web Console port number                             | `58082`                                  |
| `service.webConsole.protocol`                   | Web Console Protocol for service                    | `TCP`                                    |
| `service.webConsole.allowIngressTraffic`        | Allowing Ingress traffic for Web Console            | `true`                                   |
| `service.swingConsoleSecure.name`               | Secure Swing Console Port name                      | `swing-console-secure`                   |
| `service.swingConsoleSecure.port`               | Secure Swing Console port number                    | `58081`                                  |
| `service.swingConsoleSecure.protocol`           | Secure Swing Console Protocol for service           | `TCP`                                    |
| `service.swingConsoleSecure.allowIngressTraffic`| Allowing Ingress traffic for Secure Swing Console   | `true`                                   |
| `service.webConsoleSecure.name`                 | Secure Web Console name                             | `web-console-secure`                     |
| `service.webConsoleSecure.port`                 | Secure Web Console port number                      | `58083`                                  |
| `service.webConsoleSecure.protocol`             | Secure Web Console Protocol for service             | `TCP`                                    |
| `service.webConsoleSecure.allowIngressTraffic`  | Allowing Ingress traffic for Secure Web Console     | `true`                                   |
| `service.externalIP`                            | External IP for service discovery                   |                                          |
| `storageSecurity.fsGroup`                       | Used for controlling access to block storage        |                                          |
| `storageSecurity.fsGroupChangePolicy`           | Used for controlling access to block storage        | `OnRootMismatch`                         |
| `storageSecurity.supplementalGroups`            | Groups IDs are used for controlling access          | `[]`                                     |
| `storageSecurity.runAsUser`                     | UID for container user                              | `1010`                                   |
| `secret.secretName`                             | Secret name for Secure Parameters                   |                                          |
| `secret.certsSecretName`                        | Secret name for certificates                        |                                          |
| `resources.limits.cpu`                          | Container CPU limit                                 | `3000m`                                  |
| `resources.limits.memory`                       | Container memory limit                              | `8Gi`                                    |
| `resources.requests.cpu`                        | Container CPU requested                             | `1500m`                                  |
| `resources.requests.memory`                     | Container Memory requested                          | `4Gi`                                    |
| `initResources.limits.cpu`                      | Container CPU limit                                 | `250m`                                   |
| `initResources.limits.memory`                   | Container memory limit                              | `1Gi`                                    |
| `initResources.requests.cpu`                    | Container CPU requested                             | `250m`                                   |
| `initResources.requests.memory`                 | Container Memory requested                          | `1Gi`                                    |
| `serviceAccount.create`                         | Enable/disable service account creation             | `false`                                   |
| `serviceAccount.name`                           | Name of Service Account to use  for container       | `default`                                         |
| `affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution` | k8s PodSpec.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity"                                          |                                      |
| `affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution` | k8s PodSpec.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity"                                          |                                      |
| `affinity.podAffinity.requiredDuringSchedulingIgnoredDuringExecution` | k8s PodSpec.podAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity"                                          |                                      |
| `affinity.podAffinity.preferredDuringSchedulingIgnoredDuringExecution` | k8s PodSpec.podAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity"                                          |                                      |
| `affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution` | k8s PodSpec.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity"                                          |                                      |
| `affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution` | k8s PodSpec.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity"                                          |                                      |
| `autoscaling.enabled`                           | Autoscaling is enabled or not                       | `false`                                  |
| `autoscaling.minReplicas`                       | minimum pod replica                                 | `1`                                      |
| `autoscaling.maxReplicas`                       | Maximum pod replica                                 | `2`                                      |
| `autoscaling.targetCPUUtilizationPercentage`    | Traget CPU Utilization                              | `60`                                     |
| `autoscaling.targetMemoryUtilizationPercentage` | Traget Memory Utilization                           | `60`                                     |
| `livenessProbe.initialDelaySeconds`             | Initial delays for liveness                         | `175`                                    |
| `livenessProbe.timeoutSeconds`                  | Timeout for liveness                                | `45'                                     |
| `livenessProbe.periodSeconds`                   | Time period for liveness                            | `120`                                    |
| `readinessProbe.initialDelaySeconds`            | Initial delays for readiness                        | `175`                                    |
| `readinessProbe.timeoutSeconds`                 | Timeout for readiness                               | `15`                                     |
| `readinessProbe.periodSeconds`                  | Time period for readiness                           | `120`                                    |
| `networkPolicy.egress.enabled`                  | Network Policy egress rules will be enabled or not  | `false`                                  |
| `networkPolicy.egress.ports`                    | Network Policy egress ports                         |                                          |
| `networkPolicy.egress.toSelectors`              | Network Policy egress selectors                     |                                          |
| `networkPolicy.ingress.enabled`                 | Network Policy ingress rules will be applied or not | `false`                                  |
| `networkPolicy.ingress.ports`                   | Network Policy ingress ports                        |                                          |
| `networkPolicy.ingress.fromSelectors`           | Network Policy ingress selectors                    |                                          |
| `route.enabled`                                 | Route for OpenShift Enabled/Disabled                | `false`                                  |
| `secComp.type`                                  | seccomp profile type                                | `RuntimeDefault`                         |
| `secComp.profile`                               | seccomp profile filepath                            | ``                                       |
| `timeZone`                                      | This flag is used for setting TimeZone of container | `Asia/Calcutta`                          |
| `debugScripts`                                  | This flag is used for debugging and troubleshooting | `false`                                  |
| `extraInitContainers.name`                      | This will be used as name of init container         | `copy-resources`                         |
| `extraInitContainers.repository`                | Image respository for init container                | ``                                       |
| `extraInitContainers.tag`                       | Image respository tag for init container            | ``                                       |
| `extraInitContainers.imageSecrets`              | Image secrets for init container                    | ``                                       |
| `extraInitContainers.pullPolicy`                | Image pull policy used for init container           | `Always`                                 |
| `extraInitContainers.command`                   | command used for running init container             | ``                                       |
| `extraInitContainers.digest.enabled`            | Flag for using digest for images of init container  | `false`                                  |
| `extraInitContainers.digest.value`              | Image digest value used for init container          | ``                                       |
| `extraInitContainers.userInput.enabled`         | user input should be shared volume or not           | `false`                                  |
| `defaultPodDisruptionBudget.enabled`            | This flag will be used to enable or disable         | `false`                                  |
| `defaultPodDisruptionBudget.minAvailable`       | Minimum replicas required for pod disruption budget | `0`                                      |
| `ingress.enabled`                               | Flag to eanble or disable ingress                   | `false`                                  |
| `ingress.host`                                  | Ingress hostname                                    |                                          |
| `ingress.controller`                            | Ingress controller name                             |                                          |
| `ingress.annotations`                           | annotation for ingress resource                     | `[]`                                     |
| `ingress.tls.enabled`                           | TLS is enabled or disabled for ingress resource     | `false`                                  |
| `ingress.tls.secretName`                        | TLS secret name if enabled                          |                                          |
| `consoleLogEnabled`                             | To enable engine logs to redirect to console        | `false`                                  |

> **Tip**: If `ccArgs.dbinit` flag is true, then Only Monitored server activities will be deleted. Change this to true only if you need to delete all the monitored servers' activities. Even when this flag is true, no summary data (CC_PROCESS, CC_FILE_TRANSFER) will be deleted. Also, no configuration data such as Rules, SLCs, Monitored servers connection details will be deleted.

> **Tip**: Globalization is only needed if data to be stored contains multi-byte characters, which are common in character sets such as Kanji. Database I/O performance may drop multiple orders of magnitude if globalization support is selected, so it is NOT recommended you do so with MSSQL. If you set true for `ccArgs.mssqlGlobal` variable, then your database size can also increase significantly.

Specify each parameter in values.yaml to `helm install`. For example,

```bash
helm install my-release -f values.yaml ibm-sccm-3.1.18.tgz
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. You can create a copy of values.yaml file e.g. my-values.yaml and edit the values that you need to override. Use the my-values.yaml file for installation. For example,

```bash
helm install <release-name> -f my-values.yaml ibm-sccm-3.1.18.tgz
```
> **Tip**: You can use the default [values.yaml](values.yaml)

## Affinity

The chart provides various ways in the form of node affinity, pod affinity and pod anti-affinity to configure advanced pod scheduling in kubernetes. Refer the kubernetes documentation for details on usage and specifications for the below features.

* Node affinity - This can be configured using parameters `affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the Control Center server.
Depending on the architecture preference selected for the parameter `arch`, a suitable value for node affinity is automatically appended in addition to the user provided values.

* Pod affinity - This can be configured using parameters `affinity.podAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `affinity.podAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the Control Center server.

* Pod anti-affinity - This can be configured using parameters `affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the Control Center server.
Depending on the value of the parameter `podAntiAffinity.replicaNotOnSameNode`, a suitable value for pod anti-affinity is automatically appended in addition to the user provided values. This is to configure whether replicas of a pod should be scheduled on the same node. If the value is `prefer` then `podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution` is automatically appended whereas if the value is `require` then `podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution` is appended. If the value is blank, then no pod anti-affinity value is automatically appended. If the value is `prefer` then the weighting for the preference is set using the parameter `podAntiAffinity.weightForPreference` which should be specified in the range 1-100.

## Verifying the Chart

See the instructions (from NOTES.txt,packaged with the chart) after the helm installation completes for chart verification. The instructions can also be viewed by running the command:

```
helm status <release name>
```

## Upgrading the Chart

You would want to upgrade your deployment when you have a new docker image for application server or a change in configuration, for e.g. new service ports to be exposed. To upgrade the chart with the release name `my-release`

1. Ensure that the chart is downloaded locally and available.

2. Run the following command to upgrade your deployments.

```sh
helm upgrade my-release -f values.yaml ibm-sccm-3.1.18.gz
```

Refer [RELEASENOTES.md](RELEASENOTES.md) for Fix history.

## Rollback the Chart

What if we notice that we made a mistake after upgrading or upgraded environment is not working as expected? Then we can easily rollback the chart to a previous revision. We support rollback 'one version back' only. To rollback the chart with the release name `my-release`.

1. Run the following command to rollback your deployments to previous version.

```bash
helm rollback my-release --recreate-pods
```

2. After executing the rollback command to check is the history of a release. We only need to provide the release name `my-release`.

```bash
helm bash my-release
```

## Uninstalling the Chart

To uninstall the `my-release`

```bash
$ helm uninstall my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release. Since there are certain kubernetes resources created as pre-requisite for chart, helm uninstall command will not delete them . You need to manually delete the following resources.

1. The persistence volume

2. The secrets

## Backup & Restore

**To Backup:**

You need to take backup of configuration data and other information like stats and TCQ which are present in the persistent volume by following the below steps:

1. Go to mount path of Persistent Volume.

2. Make copy of all of the directories listed below and store them at your desired and secured place.
   * `ccbase`
   * `conf`
   * `conf-exported`
   * `user_inputs`
   * `log`
   * `packages`
   * `reports`
  
> **Note**:In case of traditional installation of Control Center Monitor, you should take the backup of the below directories and save them at your desired location:
   * `INSTALLATION_DIR`

**To Restore:**

Restoring the data in new deployment, it can be achieved by following steps

1. Create a Persistent Volume.

2. Copy all the backed up directories to the mount path of Persistent Volume.

3. Create a new deployment using the above Persistent Volume using variable `persistentVolume.name` in helm cli command. The pod would come up with desired data.

## Exposing Services

This chart creates a service of `LoadBalancer` for communication within the cluster. This type can be changed while installing chart using `service.type` key defined in values.yaml. There are two ports where IBM Control Center Monitor processes run. Swing Console Port (58080), Web Console Port(58082) whose values can be updated during chart installation using `service.swingConsole.port`, `service.webConsole.port`.

IBM Control Center Monitor services for API and file transfer can be accessed using LoadBalancer external IP and mapped ports. If external LoadBalancer is not present then refer to Master node IP for communication.

Use `networkPolicy` to control traffic flow at the port level.

> **Note**: `NodePort` service type is not recommended. It exposes additional security concerns and are hard to manage from both an application and networking infrastructure perspective.

## DIME and DARE

1. All sensitive application data at rest is stored in binary format so user cannot decrypt it. This chart does not support Encryption of user data at rest by default. Administrator can configure storage encryption to encrypt all data at rest.

2. Data in motion is encrypted using transport layer security(TLS 1.2). For more information please see product [Knowledge center link]( https://www.ibm.com/docs/en/control-center/6.3.1?topic=sterling-control-center-monitor-631 )


## Storage

IBM Sterling Control Center Helm chart supports both dynamic and pre-created persistent storage.

* Either use storage class for dynamic provisioning or pre-create Persistent Volume
* To retain the data stored on Persistent Volume, the storage class should have reclaim policy as `Retain`
* The default access mode is set to `ReadWriteOnce`

## Limitations

- High availability and scalability are supported in traditional way of Control Center deployment using Kubernetes load balancer service.
- IBM Control Center Monitor chart supports only amd64,ppc64le architecture.

## Documentation

[IBM Sterling Control Center](https://www.ibm.com/docs/en/control-center/6.3.1?topic=sterling-control-center-monitor-631)
