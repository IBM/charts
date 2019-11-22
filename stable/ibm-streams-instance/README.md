# IBM Streams Instance
![](https://raw.githubusercontent.com/IBM/charts/master/logo/ibm-streams-logo-readme.png?sanitize=true)
## Introduction
IBM® Streams is a software platform that enables the development and execution of applications that process information in data streams. IBM Streams enables continuous and fast analysis of massive volumes of moving data to help improve the speed of business insight and decision making.
IBM Streams consists of a programming language, an API, and an integrated development environment (IDE) for applications, and a runtime system that can run the applications on a 
single or distributed set of resources.

This chart creates and starts an instance of the IBM Streams runtime environment. The Streams runtime environment is composed of a set of management services interacting across one or more pods. The specified for the Helm release is the name of the Streams instance. After the Helm install completes you will have an active Streams instance, consisting of pods running Streams management services. Pods for Streams application processing will be created when a Streams job has been submitted.

## Chart Details
This chart does the following.
- Uses a Helm hook to run a job (`preinstall`) to prepare the environment for running the instance.
- Uses Helm hooks to run a post install job (`mkinstance`) to create and start the Streams instance. 
- Create a configmap (`instance-config`) to contain configuration data for the instance.
- Creates a configmap (`kube-config`) to contain values for access to Prometheus and Kubernetes API,
- Creates a configmap (`app-config`) that contains the default application pod template.
- Creates a persistent volume claim (`instance-pvc`) to store instance configuration, if an existing persistent volume claim is not specified using instance.persistentVolumeClaim.
- Deploys the Streams services as Kubernetes statefulsets. The following pods are created and contain the following Streams services and interfaces:
  - `console`:  This pod contains web management service (sws) and REST API.
  - `management`:  This pod contains application manager (sam), application service (app), application metrics (srm), view and management API (jmx). There can be multiple replicas of this pod based on the following value: replicaCount.
  - `ops`: This pod can be used to run streamtool commands to manage the Streams instance. 
  - `repository`:  This pod contains application cache repository service (repo). 
  - `security`:  This pod contains authentication and authorization (aas) and audit services. There can be multiple replicas of this pod based on the following value: replicaCount.
- Creates the following Kubernetes services:
  - `console`: for the Streams console service. 
  - `jmx`:  to provide external access to JMX APIs.
  - `management`: for the Streams management service. 
  - `ops`: for the Streams operations service. 
  - `repository`: for the Streams repository service. 
  - `security`: for the Streams security service. 
  - `sws`: to provide external access to: REST APIs, and the Streams console.
- Optionally creates a service account (`streams`) to provide access to Kubernetes APIs; if an existing service account is not specified. 
- Optionally creates the following role-based access control objects (if an existing service account is not specified), a role (`streams`) and role binding (`streams`). 
- Optionally creates an application service account (`streams-app`) to provide restricted access to Kubernetes APIs for application pods; if an existing application service account is not specified.
- Optionally creates the following role-based access control objects for application pods (if an existing service account is not specified), a role (`streams-app`) and role binding (`streams-app`). 
- When the Helm release is deleted, runs a job as a pre-delete (`stopinstance`) Helm hook to stop application, stop the instance, and remove the instance.
- When the Helm release is upgrade, runs a job as post-upgrade and post-rollback (`upgradeinstance`) Helm hook to restart application pods that are using the default application image.

## Prerequisites
If you prefer to install from the command prompt, you will need:
* The following commands installed: Kubernetes CLI (kubectl) and Helm CLI (helm).  
* Your environment configured to connect to the target cluster.

The is a summary of the prerequisites to install the chart. 
### Required
* A Kubernetes cluster running version 1.11 or later, on systems that have x86-64 architecture. This may be installed with the underlying framework.
* Helm 2.9.1 or later - This may be installed with the underlying framework.
* Prometheus 2.0 or later - This may be installed with the underlying framework. This is used to by the Streams code to query for cpu and memory utilization.
* Configure a Lightweight Directory Access Protocol (LDAP) authentication server for user authentication. You will need to set up an LDAP user or group as the Streams instance administrator. The LDAP server configuration and instance administrator need to be provided on the installation. See the Security settings table below for the required configuration.
* Persistent storage for the application cache repository (see Storage section below).
### Optional 
#### Docker pull secret
* Create a docker registry secret if one is required to pull images from the docker registry (see Create docker registry secret section below).  If you specify an existing service account you can patch the docker pull secret in that service account. 
* Create a unique namespace for the Streams instance (see Create Namespace section below).
#### Optional customizations
* If using client certificate authentication, an administrator needs to setup Kubernetes secrets for keystore, truststore and passwords. The name of the secret(s) will be input to the Helm install. 
* You can customize the Streams instance during the install of the Helm release. For example, you can grant permissions for Streams users to submit jobs. If you provide customization, you will need the following configuration for the Helm install: the name of the configmap and any of the following as needed: persistent volume, persistent volume claim and environment variables. 
* Streams provides a default application image and default application pod template. You can customize both of these for your applications. If you customize 
the application pod definition, the name of the configmap will be input to the Helm install. 
* If you want any of the following, you will need persistent storage: custom login module and custom login module code, enable Streams auditing logging, HA support for the Streams log or specify a certificate revocation list. The name of the persistent volume claim  will be input to the Helm install. For more information see Storage section below.
#### Service account and role based access control objects
This chart requires a service account and role-based access control objects and will generate the necessary objects and bindings. You can optionally specify an existing service account. If using an existing service account you must setup the required role-based access control objects. 
- The archive downloaded from passport advantage contains scripts and yaml files in the following root directory to setup the required files: StreamsInstallFiles/pak_extensions/preinstall/rbac. 
- The archive downloaded from passport advantage contains scripts and yaml files in the following root directory to cleanup the files (use after release is deleted): StreamsInstallFiles/pak_extensions/postinstall/rbac.

## Resources Required
The following table contains the minimum CPU, minimum memory and the default replica count for each of the Streams pods (see Resource settings table below). The number of application pods depends on the application. There could be multiple pods created per application and multiple applications per Streams instance. 

Pod                  | CPU/pod | Memory/pod | Replicas
-------------------- | ------- |----------- |---------
application (default)|  1*     | 1G*        | Depends on application
console              |  2*     | 4G*        | 1 
management           |  2*     | 4G*        | 1*
ops                  |  1      | 2G         | 1
repository           |  1*     | 2G*        | 1 
security             |  2*     | 2G*        | 1*

The settings marked with an asterisk (*) can be configured.

## PodSecurityPolicy Requirements
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you:

* Predefined PodSecurityPolicy name: [`ibm-anyuid-psp`](https://ibm.biz/cpkspec-psp)
* Custom PodSecurityPolicy definition:

```yaml
apiVersion: extensions/v1beta1 
kind: PodSecurityPolicy
metadata:
  name: ibm-streams-instance-psp
spec:
  allowPrivilegeEscalation: false
  forbiddenSysctls:
  - '*'
  fsGroup:
    ranges:
    - max: 1000361000
      min: 1000320900
    rule: MustRunAs
  requiredDropCapabilities:
  - ALL
  runAsUser:
    rule: MustRunAsNonRoot
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    ranges:
    - max: 1000361000
      min: 1000320900
    rule: MustRunAs
  volumes:
  - configMap
  - emptyDir
  - projected
  - secret
  - downwardAPI
  - persistentVolumeClaim
```

* Custom ClusterRole for the custom PodSecurityPolicy:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ibm-streams-instance-clusterrole
rules:
- apiGroups:
  - extensions
  resourceNames:
  - ibm-streams-instance-psp
  resources:
  - podsecuritypolicies
  verbs:
  - use
```

### Configuration scripts can be used to create the required resources

The archive downloaded from passport advantage contains scripts in the following root directory: StreamsInstallFiles/pak_extensions/preinstall/podpolicy.

* The pre-install instructions are located at `clusterAdministration/psp/createSecurityClusterPrereqs.sh` for cluster administrator to create the PodSecurityPolicy and ClusterRole for all releases of this chart.

* The namespace scoped instructions are located at `namespaceAdministration/createSecurityNamespacePrereqs.sh` for team administrator/operator to create the RoleBinding for the namespace. This script takes one argument; the name of a pre-existing namespace where the chart will be installed.
  * Example usage: `./createSecurityNamespacePrereqs.sh myNamespace`

### Configuration scripts can be used to clean up resources created

The archive downloaded from passport advantage contains scripts in the following root directory: StreamsInstallFiles/pak_extensions/post-delete/psp.

* The namespace scoped instructions are located at `namespaceAdministration/deleteSecurityNamespacePrereqs.sh` for team administrator/operator to delete the RoleBinding for the namespace. This script takes one argument; the name of the namespace where the chart was installed.
  * Example usage: `./deleteSecurityNamespacePrereqs.sh myNamespace`
  
* The post-delete instructions are located at `clusterAdministration/psp/deleteSecurityClusterPrereqs.sh` for cluster administrator to delete the PodSecurityPolicy and ClusterRole for all releases of this chart.

## Red Hat OpenShift SecurityContextConstraints Requirements
This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined SecurityContextConstraints name: [`ibm-anyuid-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.

This chart also defines a custom SecurityContextConstraints which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom SecurityContextConstraints resource using the supplied instructions/scripts in the pak_extension pre-install/scc directory.

Custom SecurityContextConstraints definition:
  
```yaml
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: "This policy is the most restrictive, 
      requiring pods to run with a non-root UID, and preventing pods from accessing the host." 
    cloudpak.ibm.com/version: "1.0.0"
  name: ibm-streams-instance-scc
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
  - max: 1000361000
    min: 1000320900
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
  - max: 1000361000
    min: 1000320900
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
priority: 0
```

* Custom ClusterRole for the custom SecurityContextConstraint:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ibm-streams-instance-clusterrole
rules:
- apiGroups:
  - extensions
  resourceNames:
  - ibm-streams-instance-scc
  resources:
  - podsecuritypolicies
  verbs:
  - use
```
### Configuration scripts can be used to create the required resources

The archive downloaded from passport advantage contains scripts in the following root directory: StreamsInstallFiles/pak_extensions/preinstall/podpolicy.

* The pre-install instructions are located at `clusterAdministration/scc/createSecurityClusterPrereqs.sh` for cluster administrator to create the PodSecurityPolicy and ClusterRole for all releases of this chart.

* The namespace scoped instructions are located at `namespaceAdministration/createSecurityNamespacePrereqs.sh` for team administrator/operator to create the RoleBinding for the namespace. This script takes one argument; the name of a pre-existing namespace where the chart will be installed.
  * Example usage: `./createSecurityNamespacePrereqs.sh myNamespace`

### Configuration scripts can be used to clean up resources created

The archive downloaded from IBM Passport Advantage contains scripts in the following root directory: StreamsInstallFiles/pak_extensions/post-delete/scc.

* The namespace scoped instructions are located at `namespaceAdministration/deleteSecurityNamespacePrereqs.sh` for team administrator/operator to delete the RoleBinding for the namespace. This script takes one argument; the name of the namespace where the chart was installed.
  * Example usage: `./deleteSecurityNamespacePrereqs.sh myNamespace`
  
* The post-delete instructions are located at `clusterAdministration/scc/deleteSecurityClusterPrereqs.sh` for cluster administrator to delete the PodSecurityPolicy and ClusterRole for all releases of this chart.


## Installing the Chart
The following information is required for the installation:
* If your environment is set up to use dynamic storage provisioning, you will need the name of the storage class. If your enviornment is setup for manual storage provisioning you will have to create a persistent volume claim for instance configuration and application cache (see Storage section below).
* Ensure you have LDAP configured and you the following information available:
  - LDAP user or group that will be the Streams instance administrator 
  - LDAP configuration to access the LDAP server
* The namespace for installing the Streams instance.
* The docker registry pull secret if one is required.

For more information, see [Preparing for the installation](https://www.ibm.com/support/knowledgecenter/SSCRJU_5.0.0/com.ibm.streams.install.doc/doc/icp-gather-settings.html#icp-gather-settings).

### Create Namespace
You can optionally create a namespace dedicated for use by the instance. Run the following command to create a namespace. You will specify this namespace when installing the chart. You can set the namespace in your kube context to avoid having to specify it with every command. In this example, my namespace is mystreams, replace this name with the name of your choosing:```bash
kubectl create namespace mystreams
```
### Create a docker registry pull secret
You may need a image pull secret to pull docker images from the docker registry. If you specify a service account patch the service account with the pull secret. If you don't specify a service account, you will specify the pull secret name when installing streams. If you are using the Helm CLI to install the chart set the following value: image.pullSecret.
Here is an example of creating a docker pull secret, replace the values for the parameters for your environment:
```bash
kubectl create secret docker-registry myregistrykey --docker-server=mycluster.icp:8500 --docker-username=myadmin  --docker-password=myadmin --docker-email myemail@mydomain.com
```
To verify your secret is created in your namespace, run this command:
```bash
kubectl get secret
```
### Install IBM Streams
When you install IBM Streams you will be creating and starting a Streams instance. You must have the Cluster administrator access level to install the chart. You can install using the Helm CLI. 

The Configuration section below identifies the required and optional configuration, you will need for the installation. 

If you are installing using the Helm CLI, you should use a values override file to specify your values. Using a values override file provides you a repeatable configuration option. [Add the internal IBM Cloud Private repository, local-charts, to the Helm CLI as an external repository](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.0/app_center/add_int_helm_repo_to_cli.html). The Configuration section below has an example of a values override file.

Install the chart, specifying the release name, the chart, and a values override file. A Streams instance will be created with the same name as the Helm release. When the installation completes, the Streams instance will be created and started.   

For example, enter the following command to create a Streams instance named my-release. This example assumes the internal Helm repository called local-charts contains the chart and the valuesoverride.yaml file was setup with all the required values.
```bash
$ helm install --name my-release local-charts/ibm-streams-instance --values valuesoverride.yaml --tls
```

### Verifying the Chart
See chart notes for instructions on verifying the chart.

### Uninstalling the Chart
When you uninstall the IBM Streams chart you are stopping and removing the Streams instance. This will stop all the Streams application jobs associated with Streams instance. Any data written to the persistent storage by the Streams services will be removed. This includes the application cache, and Streams log, and Audit log. 

The helm delete will only remove Kubernetes objects created by the installation. Any Kubernetes objects created outside of the Helm release, such as persistent volumes, persistent volume claims, secrets, post mkinstance configmap, and application template configmap, will not be removed. You can remove these Kubernetes objects if you are not using these objects for other Streams instances or you do not plan on installing Streams instance.

For example, to stop and remove the Streams instance called my-release, run the following command:
```bash
$ helm delete my-release --purge --tls
```
### Cleanup any pre-requirement that were created

Cleanup scripts are included in the archive downloaded from passport advantage in the the following directory: StreamsInstallFiles/pak_extensions/prereqs; run them to cleanup namespace and cluster scoped resources when appropriate.

## Configuration
The following tables list the configurable parameters of the ibm-streams-instance chart and their default values. 

If you are using the Helm CLI to install the chart, create a values override file and specify the file on the helm install. For example, to specify the required values you would create a file called valuesoverride.yaml with the following content. Replace the actual values with the information for your environment.
```yaml
zkconnect: myzk1:28881;myzk2:28881;myzk3:2888
instance.repositoryApplicationCachePvc: my-app-cache-pvc
image.pullSecret: mydockersecret
security:
  administratorUser: streamsadmin
  ldapGroupMembersAttribute: member
  ldapGroupObjectClass: groupOfNames
  ldapGroupSearchBaseDistinguishedName: ou=group,dc=site,dc=company,dc=com
  ldapServerUrl: ldap://myserver.domain.com:389
  ldapUserAttributeInGroup: dn
  ldapUserDistinguishedNamePattern: uid=*,ou=people,dc=site,dc=company,dc=com
````
> **Tip**: You can use the following command to see all the values in the values.yaml. You may need to [add the ICP internal Helm repository to Helm CLI](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.0/app_center/add_int_helm_repo_to_cli.html).
```bash
helm inspect values local-chart/ibm-streams-instance
```

[comment]: # (PLACEHOLDER for generated Configuration, must be blank line before this so this does not show up in README)
### General settings
| Parameter | Description | Required | Default |
| ---  | --- | --- | --- |
| `debug` | `Specifies if debug is enabled for the helm install. Kubernetes jobs will be left on the system to aid in debug if set to true.` | false | `false` |
| `license` | `Specifies if you read the license agreement and agree to the terms. Set the license value to 'accept'.` | true | `not accepted` |
### Application service settings
| Parameter | Description | Required | Default |
| ---  | --- | --- | --- |
| `app.metricCollectionInterval` | `Specifies the interval in seconds between application service collection of metrics from application processing elements.` | false | `3` |
| `app.pecStartTimeout` | `Specifies maximum time in seconds that application service waits for application processing elements to start.` | false | `30` |
| `app.pecStopTimeout` | `Specifies maximum time in seconds that application service waits for application processing elements to stop gracefully.` | false | `30` |
| `app.serviceAccount` | `Specifies the service account for application pods. If specified, it must be granted permissions for required Kubernetes objects.  If not specified, one will be created with necessary role based access control objects.` | false |  |
| `app.streamsExtPvc` | `Specifies the persistent volume claim containing streams runtime external libraries.` | false |  |
| `app.userExtPvc` | `Specifies the persistent volume claim containing user runtime external libraries.` | false |  |
### Audit log service settings
| Parameter | Description | Required | Default |
| ---  | --- | --- | --- |
| `auditlog.level` | `Specifies the level of audit logging. Valid values are: off, standard.` | false | `off` |
### Controller service settings
| Parameter | Description | Required | Default |
| ---  | --- | --- | --- |
| `controller.securitySecret` | `Specifies the secret containing keystore and truststore files, passwords, and alias for the streams controller.` | false |  |
| `controller.startTimeout` | `Specifies the time in seconds to wait for streams controller to start.` | false | `60` |
| `controller.stopTimeout` | `Specifies the time in seconds to wait for streams controller to stop.` | false | `60` |
| `controller.systemStatisticsInterval` | `Specifies the interval time in seconds between controller collection of pod metrics.` | false | `60` |
### Images settings
| Parameter | Description | Required | Default |
| ---  | --- | --- | --- |
| `image.application` | `Specifies the image to configure for default application resources.` | true | `streams-application-el7` |
| `image.applicationTag` | `Specifies the tag portion of the application image name.` | true | `5.2.0.0` |
| `image.console` | `Specifies the image to configure for the console resource.` | true | `streams-sws-el7` |
| `image.consoleTag` | `Specifies the tag portion of the console image name.` | true | `5.2.0.0` |
| `image.management` | `Specifies the image to configure for management resources.` | true | `streams-management-el7` |
| `image.managementTag` | `Specifies the tag portion of the management image name.` | true | `5.2.0.0` |
| `image.operations` | `Specifies the image to configure for operations resources.` | true | `streams-operations-el7` |
| `image.operationsTag` | `Specifies the tag portion of the operations image name.` | true | `5.2.0.0` |
| `image.prefix` | `Specifies the repository for the docker images. If specified, this value will be pre-appended to the image names.` | false |  |
| `image.pullPolicy` | `Specifies the policy used to pull images from docker registry. Valid values are: Always, IfNotPresent.` | false | `Always` |
| `image.pullSecrets` | `Specifies the secret used to pull images from docker registry.` | false |  |
| `image.repository` | `Specifies the image to configure for repository resources.` | true | `streams-application-repository-el7` |
| `image.repositoryTag` | `Specifies the tag portion of the repository image name.` | true | `5.2.0.0` |
| `image.security` | `Specifies the image to configure for security resources.` | true | `streams-security-el7` |
| `image.securityTag` | `Specifies the tag portion of the security image name.` | true | `5.2.0.0` |
### Instance settings
| Parameter | Description | Required | Default |
| ---  | --- | --- | --- |
| `instance.applicationTemplateConfigMap` | `Specifies a configMap containing application resource templates.` | false |  |
| `instance.governanceEnabled` | `Specifies whether application governance is enabled.` | false | `false` |
| `instance.governanceSecret` | `Specifies the secret containing the governance administrator user ID and password. This value is used if instance.governanceEnabled is to true.` | false |  |
| `instance.governanceUrl` | `Specifies the URL of the service where application governance information is sent. Value is used if instance.governanceEnabled is to true.` | false |  |
| `instance.jobsCpuMaximum` | `Specifies the total maximum upper limit of CPU core resources for all jobs in the instance.` | false |  |
| `instance.localeOverride` | `Specifies the locale in the following locale format that is used by Streams services for tasks such as logging: language[_territory][.codeset].` | false |  |
| `instance.metricStatisticsRetentionScheme` | `Specifies the algorithm used by the metrics package for retaining resource metric data. Valid values are: exponentiallyDecaying, slidingTimeWindow, slidingWindow, uniform.` | false | `slidingTimeWindow` |
| `instance.metricStatisticsRetentionSize` | `Specifies the amount of metrics data to retain. Value is specific to selected retention scheme; see documentation for more information.` | false | `10` |
| `instance.owner` | `Specifies the owner of the instance. This value can only be set when the instance is created.` | false |  |
| `instance.persistentStorageClassName` | `Specifies the storage class name to dynamically provision the storage for streams instance state. If you specify an existing persistent volume claim this value is ignored. You must specify this or instance.persistentVolumeClaim.` | false |  |
| `instance.persistentVolumeClaim` | `Specifies the persistent volume claim used to back the streams instance state. You must specify this or instance.persistentStorageClassName.` | false |  |
| `instance.persistentVolumeClaimSize` | `Specifies a size to dynamically provision the storage for streams instance state. If you specify an existing persistent volume claim this value is ignored.` | false | `10Gi` |
| `instance.serviceAccount` | `Specifies the service account used for all management pods. If specified, it must be granted permissions for required Kubernetes objects.  If not specified, one will be created with necessary role based access control objects.` | false |  |
| `instance.serviceMetricCollectionEnabled` | `Specifies whether metric information is collected for IBM Streams services.` | false | `false` |
| `instance.sslOption` | `Specifies the default cryptographic protocol for all IBM Streams services. This value can only be updated on helm upgrades. Valid values are: SSL_TLS, SSL_TLSv2, TLSv1, TLSv1.1, TLSv1.2, none.` | false | `TLSv1.2` |
### JMX service settings
| Parameter | Description | Required | Default |
| ---  | --- | --- | --- |
| `jmx.inactivityTimeout` | `Specifies the number of minutes of inactivity after which manually registered JMX objects are unregistered.` | false | `30` |
| `jmx.securitySecret` | `Specifies the secret containing the JMX large data handler keystore file and password.` | false |  |
| `jmx.serviceExternalIPs` | `Specifies an array of external ip addresses for the Kubernetes service exposing the JMX large data handler.` | false |  |
| `jmx.serviceLargeDataNodePort` | `Specifies the node port value for the Kubernetes service exposing the JMX large data handler.` | false |  |
| `jmx.serviceNodePort` | `Specifies a node port value for the Kubernetes service exposing the JMX large data handler.` | false |  |
| `jmx.serviceType` | `Specifies the type for the Kubernetes service exposing the JMX large data handler. Valid values are: ClusterIP, NodePort, LoadBalancer.` | true | `ClusterIP` |
### Job settings
| Parameter | Description | Required | Default |
| ---  | --- | --- | --- |
| `job.checkpointRepository` | `Specifies the repository that is used to store application checkpoint information. This value can only be set when the instance is created. Valid values are: notSpecified, fileSystem, redis.` | false |  |
| `job.checkpointRepositoryConfiguration` | `Specifies configuration information for the repository that is used to store application checkpoint information This value can only be set when the instance is created.` | false |  |
| `job.cpuMaximum` | `Specifies the maximum upper limit of CPU core resources for a job.` | false | `20` |
| `job.dynamicThreadingElastic` | `Specifies whether the PE dynamically adapts the number of threads used for dynamic threading in a PE, based on performance.` | false |  |
| `job.dynamicThreadingThreadCount` | `Specifies the initial number of threads for dynamic threading in a PE.` | false |  |
| `job.restartPesOnResourceFailure` | `Specifies whether PEs are restarted after a resource failure.` | false | `true` |
| `job.restartPesOnResourceFailureWaitTime` | `Specifies the period, in seconds, that IBM Streams waits before it restarts processing elements when a resource fails.` | false | `300` |
| `job.threadingModel` | `Specifies the model for an instance that determines how threads run operators in a PE. Valid values are: notSpecified, automatic, manual, dedicated, dynamic.` | false |  |
| `job.transportSecurityType` | `Specifies the cryptographic protocol to use when data is transported between PEs. This value can only be updated on helm upgrades. Valid values are: SSLv3, TLSv1, TLSv1.1, TLSv1.2, none.` | false | `none` |
### Log service settings
| Parameter | Description | Required | Default |
| ---  | --- | --- | --- |
| `log.format` | `Specifies the format of container logs output to the container's console.` | false | `json` |
| `log.level` | `Specifies the default level to use for the administration log. Valid values are: error, warn, info.` | false | `warn` |
| `log.maximumFileCount` | `Specifies the maximum number of files to save for the administration log.` | false | `3` |
| `log.maximumFileSize` | `Specifies the maximum size, in kilobytes, for each administration log file.` | false | `5000` |
### Make instance settings
| Parameter | Description | Required | Default |
| ---  | --- | --- | --- |
| `mkinstance.configMap` | `Specifies a configMap containing custom configuration (i.e. streamtool commands) used when creating the instance.` | false |  |
| `mkinstance.env` | `Specifies environment variables to be used by streamtool commands in the mkinstance.configMap and in the ops pod.` | false |  |
| `mkinstance.timeout` | `Specifies the number of minutes to wait for mkinstance to complete.` | false | `5` |
| `mkinstance.volumeMounts` | `Specifies the yaml snippet for volumes to be to be used when creating the instance and mounted on the ops pod. You must also specify userVolumes.` | false |  |
| `mkinstance.volumes` | `Specifies the yaml snippet for pre-created persistent volumes to be used when creating the instance and mounted on the ops pod. You must also specify userVolumeMounts.` | false |  |
### Prometheus settings
| Parameter | Description | Required | Default |
| ---  | --- | --- | --- |
| `prometheus.credentials` | `Specifies the credentials for accessing Prometheus.` | false |  |
| `prometheus.url` | `Specifies the URL for accessing Prometheus.` | false |  |
### Resources settings
| Parameter | Description | Required | Default |
| ---  | --- | --- | --- |
| `resources.applicationCpu` | `Specifies the minimum required amount of CPU core resources for application resources. Must be less than or equal to resources.applicationCpuLimit.` | true | `1` |
| `resources.applicationCpuLimit` | `Specifies the upper limit of CPU core resource for default application resources.` | true | `2` |
| `resources.applicationMemory` | `Specifies the minimum required amount of memory for default application resources. Must be less than or equal to resources.applicationMemoryLimit.` | true | `1Gi` |
| `resources.applicationMemoryLimit` | `Specifies the upper limit for memory in bytes for default application resources.` | true | `2Gi` |
| `resources.consoleCpu` | `Specifies the minimum required amount of CPU core resources for console resource. Must be less than or equal to resources.consoleCpuLimit.` | true | `2` |
| `resources.consoleCpuLimit` | `Specifies the upper limit of CPU core resource for the console resource.` | true | `8` |
| `resources.consoleMemory` | `Specifies the minimum required amount of memory for console resources. Must be less than or equal to resources.consoleMemoryLimit.` | true | `4Gi` |
| `resources.consoleMemoryLimit` | `Specifies the upper limit for memory in bytes for the console resources.` | true | `6Gi` |
| `resources.managementCpu` | `Specifies the minimum required amount of CPU core resources for management resources. Must be less than or equal to resources.managementCpuLimit.` | true | `2` |
| `resources.managementCpuLimit` | `Specifies the upper limit of CPU core resource for the management resources.` | true | `12` |
| `resources.managementMemory` | `Specifies the minimum required amount of memory for the management resources. Must be less than or equal to resources.managementMemoryLimit.` | true | `4Gi` |
| `resources.managementMemoryLimit` | `Specifies the upper limit for memory in bytes for the management resources.` | true | `8Gi` |
| `resources.repositoryCpu` | `Specifies the minimum required amount of CPU for the repository resource. Must be less than or equal to resources.repositoryCpuLimit.` | true | `1` |
| `resources.repositoryCpuLimit` | `Specifies the upper limit of CPU core resource for the repository resource.` | true | `1` |
| `resources.repositoryMemory` | `Specifies the minimum required amount of memory for the repository resource. Must be less than or equal to resources.repositoryMemoryLimit.` | true | `2Gi` |
| `resources.repositoryMemoryLimit` | `Specifies the upper limit for memory in bytes for the repository resource.` | true | `2Gi` |
| `resources.securityCpu` | `Specifies the minimum required amount of CPU core resources for the security resources. Must be less than or equal to resources.securityCpuLimit.` | true | `2` |
| `resources.securityCpuLimit` | `Specifies the upper limit of CPU core resource for the security resources.` | true | `4` |
| `resources.securityMemory` | `Specifies the minimum required amount of memory for the security resources. Must be less than or equal to resources.securityMemoryLimit.` | true | `2Gi` |
| `resources.securityMemoryLimit` | `Specifies the upper limit for memory in bytes for the security resources.` | true | `4Gi` |
### Security settings
| Parameter | Description | Required | Default |
| ---  | --- | --- | --- |
| `security.administratorGroup` | `Specifies the streams group to configure as an InstanceAdministrator. This value and/or security.administratorUser must be specified. This value can only be set when the instance is created.` | false |  |
| `security.administratorUser` | `Specifies the streams user to configure as an InstanceAdministrator. This value and/or security.administratorGroup must be specified. This value can only be set when the instance is created.` | false |  |
| `security.certificateUserRegularExpression` | `Specifies the format of the certificate used to determine how to extract the Streams user identifier from the certificate distinguished name (DN).` | false | `${cn}` |
| `security.ldapEnabled` | `Specifies whether LDAP is enabled as a default security login module. This value can only be updated on helm upgrades.` | false | `true` |
| `security.ldapGroupMembersAttribute` | `Specifies the name of the element in the group record that contains the list of members in the group. This value can only be updated on helm upgrades.` | false |  |
| `security.ldapGroupObjectClass` | `Specifies the group object class that is used to search for group names in LDAP. This value can only be updated on helm upgrades.` | false |  |
| `security.ldapGroupSearchBaseDistinguishedName` | `Specifies the base distinguished name (DN) that is used to search for groups in LDAP. This value can only be updated on helm upgrades.` | false |  |
| `security.ldapSecret` | `Specifies the secret containing the LDAP administrator user ID and password.` | false |  |
| `security.ldapServerUrl` | `Specifies the URL to the LDAP Server that is used for authentication. This value can only be updated on helm upgrades.` | false |  |
| `security.ldapUserAttributeInGroup` | `Specifies the name of the user record element that is stored in the group record. This value can only be updated on helm upgrades.` | false |  |
| `security.ldapUserDistinguishedNamePattern` | `Specifies the pattern that is used to create a distinguished name (DN) for a user during login when LDAP is used for authentication. This value can only be updated on helm upgrades.` | false |  |
| `security.ldapUserSecondaryLookup` | `Specifies the LDAP query that is used to resolve the LDAP user name based on the provided IBM Streams user identifier. This value can only be updated on helm upgrades.` | false |  |
| `security.revocationLdapUrl` | `Specifies an LDAP URL that IBM Streams uses to retrieve a list of certificates that are revoked but are not expired.` | false |  |
| `security.revocationMethod` | `Specifies the method that the IBM Streams uses to check whether a certificate is revoked. This value can only be updated on helm upgrades. Valid values are: automatic, crl, ocsp, none.` | false | `automatic` |
| `security.sessionTimeout` | `Specifies the number of seconds to wait before timing out a security session. The default value is 4 hours.` | false | `14400` |
| `security.ssoEnabled` | `Specifies whether IBM Streams single sign-on is enabled as a default security login module. This value can only be updated on helm upgrades.` | false | `false` |
| `security.ssoRealm` | `Specifies the IBM Streams single sign-on security realm. This value can only be updated on helm upgrades.` | false |  |
| `security.ssoUrl` | `Specifies the URL of the IBM Streams single sign-on service. Format is https://<sso-release>-sso.<sso-namespace>:8446. This value can only be updated on helm upgrades.` | false |  |
| `security.userGroup` | `Specifies the streams group to configure as an InstanceUser. This value can only be set when the instance is created.` | false |  |
| `security.userPersistentVolumeClaim` | `Specifies the persistent volume claim for reading and writing user supplied security data.` | false |  |
### Web management services settings
| Parameter | Description | Required | Default |
| ---  | --- | --- | --- |
| `sws.clientAuthenticationCertificateRequired` | `Specifies whether a certificate is required when client authentication is enabled for web management services. This value can only be updated on helm upgrades.` | false | `true` |
| `sws.clientAuthenticationEnabled` | `Specifies whether client authentication is enabled for web management services. This value can only be updated on helm upgrades.` | false | `false` |
| `sws.cryptographicKeyManagementMode` | `Specifies the level of adherence to the recommendation for cryptographic key management for the web management service. Valid values are: strict, transition, off.` | false | `strict` |
| `sws.securitySecret` | `Specifies the secret containing keystore and truststore files, passwords, and alias for the Streams Console.` | false |  |
| `sws.serviceExternalIPs` | `Specifies an array of external ip addresses for the Kubernetes service exposing the Streams Console.` | false |  |
| `sws.serviceNodePort` | `Specifies a node port value for the Kubernetes service exposing the Streams Console.` | false |  |
| `sws.serviceType` | `Specifies the type for the Kubernetes service exposing the Streams Console. Valid values are: ClusterIP, NodePort, LoadBalancer.` | true | `ClusterIP` |
### Trace settings
| Parameter | Description | Required | Default |
| ---  | --- | --- | --- |
| `trace.level` | `Specifies the default trace level to use for debugging problems with the IBM Streams services. Valid values are: off, error, warn, info, debug, trace.` | false | `error` |
| `trace.maximumFileCount` | `Specifies the maximum number of trace files to save per IBM Streams service.` | false | `3` |
| `trace.maximumFileSize` | `Specifies the maximum size, in kilobytes, of the trace files for each IBM Streams service.` | false | `5000` |

[comment]: # (END OF PLACEHOLDER for generated Configuration, must be blank line before this so this does not show up in README)

## Storage
### Instance configuartion
Persistent storage is required for the instance configuration data and application cache. The application cache is used to cache the Streams application bundle (SAB) for application high availability when a job is submitted to the Streams runtime. You can use any persistent storage for the volume, it must be writable by the following runAsUser and fsGroup: 1000320900. A user with Cluster Administrator access level will need to create the persistent volume. 

You will need to create a persistent volume claim or let the chart dynamically create it for you by specifying a instance.persistentStorageClassName. 
If you create an existing persistent volume claim specify the value in instance.persistentVolumeClaim. You can use the same persistent volume for multiple Streams instances. A separate directory will be created in the cache for each instance.

For an example if you environment allows for it, you could use NFS for your persistent storage. Here are example yamls for using NFS for the persistent volume and persistent volume claim. 
The template uses NFS volumes by specifying the NFS server IP address and NFS mount path for each volume. If you are using a different storage type, replace the nfs: sections. The storage sizes in the template are the minimum requirement for these volumes:
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: application-cache-pv
spec:
  storageClassName: 
  capacity:
    storage: 2G
  accessModes:
    - ReadWriteMany
  nfs:
    path: <path-to-nfs-directory>
    server: <nfs-server>
  persistentVolumeReclaimPolicy: Recycle

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: application-cache-pvc
  labels:
    app.kubernetes.io/name: ibm-streams-instance
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 2G
  # Bind to a specific persistent volume.
  volumeName: "application-cache-pv"
```
### Security persistent volume claim
You will need persistent storage if you want to use any of the following: custom login module and custom login module code, Streams auditing logging, HA support for the Streams log. or to specify a certificate revocation list. The name of the persistent volume claim  will be input to the Helm install in the following value: security.persistent volume claim. For more information on setting up the persistent volume see [Creating persistent volume](https://www.ibm.com/support/knowledgecenter/SSCRJU_5.0.0/com.ibm.streams.cfg.doc/doc/icp-customize-instance-create-pv.html).

## Limitations
* The chart must be deployed by an Cluster administrator.
* Platforms supported: Linux x86_64.

## Documentation
For more information about IBM Streams, see [Extending IBM Cloud Private for Data with streaming analytics](https://www.ibm.com/support/knowledgecenter/SSQNUZ_current/com.ibm.icpdata.doc/streams/intro.html) 
