# IBM Sterling Control Center Monitor V6.2.1.0

## Introduction

This tool contains IBM Sterling Control Center Monitor with Red Hat Universal Base Image(UBI). IBM▒ Control Center Monitor is a centralized monitoring and management system. It gives operations personnel the capability to continuously monitor the status of Configuration Managers, engines, and adapters across the enterprise for the following server types from one central location: IBM Sterling Connect:Direct▒, IBM Sterling Connect:Enterprise▒, IBM Sterling B2B Integrator, IBM Sterling File Gateway, IBM Global High Availability Mailbox, IBM Sterling Connect:Express, IBM QuickFile, IBM MQ Managed File Transfer and Many FTP servers. To find out more, see the Knowledge Center for [IBM Sterling Control Center Monitor](  https://www.ibm.com/docs/en/control-center/6.2.1.0?topic=sterling-control-center-monitor-621 ).

## Details

This chart deploys IBM Sterling Control Center Monitor on a container management platform with the following resources deployments

- a statefulset pod `<release-name>-ibm-sccm` with 1 replica by default.
- a configMap `<release-name>-ibm-sccm`. This is used to provide default configuration in scc_config_file.
- a service `<release-name>-ibm-sccm`. This is used to expose the Control Center Monitor services for accessing using clients.
- a service-account `<release-name>-ibm-sccm-serviceaccount`. This service will not be created if `serviceAccount.create` is `false`.
- a persistence volume claim `<release-name>-ibm-sccm-pvc`.

## Prerequisites

### Chart Image Bundle (Prereq #1)

Before you install IBM Certified Container Software for IBM Sterling Control Center Monitor, ensure that the installation files are available on your client system.

#### Downloading the IBM Certified Container Software helm chart from IBM Chart repository
You can download the IBM CCS for IBM Sterling Control Center Monitor helm chart from [IBM Public chart repository](https://www.ibm.com/links?url=https://github.com/IBM/charts/tree/master/repo/ibm-helm/ibm-sccm-1.0.10.tgz).


####  Downloading the IBM Certified Container Software image from IBM Entitled Registry for AirGap Environment
You can download the container image from IBM Entitled registry by using either `cloudctl` or `docker/podman` utility.

**1. Downloading the IBM Certified Container Software image using `cloudctl` utility:** 
- Download latest version of cloudctl CLI from [Cloud Pak CLI](https://www.ibm.com/links?url=https://github.com/IBM/cloud-pak-cli/releases). 
- Download and extract the CASE bundle file
```
cloudctl case save -t 1 --case https://github.com/IBM/cloud-pak/raw/master/repo/case/ibm-sccm/1.0.8/ibm-sccm-1.0.8.tgz --outputdir download_dir/ && tar -xf download_dir/ibm-sccm-1.0.8.tgz
```
> **Note**: download_dir is the output directory in which the BM Sterling Control Center Monitor resources are placed. The output directory is created if it does not exist. You can choose an arbitrary name for --outputdir if required.` 

- Log in to the OCP cluster as cluster-admin role
```
oc login <openshift_url> -u <username> -p <password> -n <namespace>
```
- Configure the authentication credentials (URL, username, and password) for both your local Docker registry and the IBM Entitled Registry by running the following commands:
```
cloudctl case launch \
 --case ibm-sccm \
 --inventory ibmSccm \
 --action configure-creds-airgap \
 --args "--registry cp.icr.io --user cp --pass <entitled_key> --inputDir download_dir/" -t 1
```
```
cloudctl case launch \
--case ibm-sccm \
--inventory ibmSccm \
--action configure-creds-airgap \
--args "--registry <LOCAL_DOCKER_REGISTRY_REPOSITORY> --user <username> --pass <password> --inputDir download_dir/" -t 1
```
- Configure global image pull secret and imageContentSourcePolicy resource by running the following command:
```
cloudctl case launch \
--case ibm-sccm \
--inventory ibmSccm \
--namespace control-center \
--action configure-cluster-airgap \
--args "--registry <LOCAL_DOCKER_REGISTRY_REPOSITORY> --inputDir download_dir/" -t 1 
```
- Mirror the images to the Docker registry by running the following command:
```
cloudctl case launch \
--case ibm-sccm \
--inventory ibmSccm \
--action mirror-images \
--args "--registry <LOCAL_DOCKER_REGISTRY_REPOSITORY>  --inputDir download_dir/" -t 1 
```
- During the helm chart deployment change the value from `false` to `true` for `image.digest.enabled` tag in values.yaml file.

**2. Downloading the IBM Certified Container Software image using `docker/podman` utility:**  
- Log in to the IBM Entitled registry by running the following command:   
  * `docker/podman login -u cp -p <entitled_key> cp.icr.io`

- Pull the container image from IBM Entitled registry by running the following command:
  * `docker/podman pull cp.icr.io/cp/ibm-scc/ibmscc:6.2.1_ifix07`

- Tag and push the container image into local repository by running the following commands: 
  * `docker/podman tag cp.icr.io/cp/ibm-scc/ibmscc:6.2.1_ifix07 <LOCAL_DOCKER_REGISTRY_REPOSITORY>/ibm-scc/ibmscc:6.2.1_ifix07`
  * `docker/podman push <LOCAL_DOCKER_REGISTRY_REPOSITORY>/ibm-scc/ibmscc:6.2.1_ifix07`

### Tools (Prereq #2)

To install chart from the command prompt, tools needed are:

- Kubernetes version >= `1.19.0`
- Helm version >= `3.0`
- OpenShift version = `4.6`
- The `kubectl` and `helm` commands available
- The environment should be configured to connect to the target cluster


### Storage (Prereq #3)

- [Persistent Volume](http://kubernetes.io/docs/user-guide/persistent-volumes/) is recommended for storage. It can be created by using a yaml file as the following examples. The `ReadWriteMany` accessmode is recommended for creating persistent volume.

- Note: Use `supplementalGroups` to specify access permission for NFS based volumes. 

Peristent volume using NFS server
```
kind: PersistentVolume
apiVersion: v1
metadata:
  name: <persistent volume name>
  labels:
    app.kubernetes.io/name: <persistent volume name>
    app.kubernetes.io/instance: <release name>
    app.kubernetes.io/managed-by: <service name>
    helm.sh/chart: <chart name>
    release: <release name>
spec:
  storageClassName: <storage classname>
  capacity:
    storage: <storage size>
  accessModes:
    - ReadWriteMany
  nfs:
    server: <NFS server IP address>
    path: <mount path>
```

Peristent volume using Host Path
```
kind: PersistentVolume
apiVersion: v1
metadata:
  name: <persistent volume name>
  labels:
    app.kubernetes.io/name: <persistent volume name>
    app.kubernetes.io/instance: <release name>
    app.kubernetes.io/managed-by: <service name>
    helm.sh/chart: <chart name>
    release: <release name>
spec:
  storageClassName: <storage classname>
  capacity:
    storage: <storage size>
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: <mount path>
```

```
kubectl create -f <peristentVolume yaml file>
```

### Secret (Prereq #4)

To separate application secrets from the Helm release. A secret can be preinstalled with the following shape and referenced from the Helm chart with `secret.secretName` value.
For jre certificates, we need one more secret that will be used for passing certificates to container and it will be eferenced from the Helm chart with `secret.certsSecretName` value.

```
apiVersion: v1
kind: Secret
metadata:
  name: <secret name>
type: Opaque
data:
  .ccDBPassword: <base64 encoded password>
  .adminUserId: <base64 encoded user id>
  .adminUserPassword: <base64 encoded admin password>
  .trustStorePassword: <base64 encoded password>
  .keyStorePassword: <base64 encoded password>
  .emailPassword: <base64 encoded password>
  .jmsUserId: <base64 encoded user id>
  .jmsPassword: <base64 encoded password>
  .userKey: <base64 encoded user key>

```

```
kubectl create -f <secret yaml file>
```

> **Tip**: Use `echo -n "<password>" | base64` to encode to base64

The IBM Control Center secret would be created with data described as below: -

|----------------------|-------------------------------------------------------------------------------------------|
| Parameter            | Description                                                                               |
|----------------------|-------------------------------------------------------------------------------------------|
|`.adminUserId`        | Username of Control Center                                                                |
|`.adminUserPassword`  | Password of user of Control Center                                                        |
|`.ccDBPassword`       | Password of Database of Control Center                                                    |
|`.emailPassword`      | Email password of Control Center                                                          |
|`.jmsPassword`        | JMS user password of Control Center                                                       |
|`.jmsUserId`          | JMS user ID of Control Center                                                             |
|`.keyStorePassword`   | Keystore password of Control Center                                                       |
|`.userKey`  		   | user key for Control Center                                               |
|`.trustStorePassword` | Truststore password of Control Center                                                     |
|----------------------|-------------------------------------------------------------------------------------------|

Secret for certificates will be used by following command:

```
kubectl create secret generic ibm-sccm-certs --from-file=keystore=<path to keystore file> --from-file=truststore=<path to truststore file>
```

> **Note**: You must replace <password> with your own passwords in <secret yaml file> and once secret is created, delete the yaml file for security. The password provided to adminPassword will be set as admin password for user `admin` during configuring Control Center.

### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy.

* Predefined  PodSecurityPolicy name: [`ibm-privileged-psp`](https://ibm.biz/cpkspec-psp)

This chart optionally defines a custom PodSecurityPolicy which is used to finely control the permissions/capabilities needed to deploy this chart. It is based on the predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://github.com/IBM/cloud-pak/blob/master/spec/security/psp/ibm-restricted-psp.yaml) with extra required privileges. You can enable this policy by using the Platform User Interface or configuration file available under pak_extensions/pre-install/ directory

- From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy

* Custom PodSecurityPolicy definition:

```
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: ibm-sccm-psp
  labels:
    app: "ibm-sccm-psp"
spec:
  privileged: false
  allowPrivilegeEscalation: true
  hostPID: false
  hostIPC: false
  hostNetwork: false
  requiredDropCapabilities:
  allowedCapabilities:
  - CHOWN
  - SETGID
  - SETUID
  - DAC_OVERRIDE
  - FOWNER
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

- From the command line, you can run the setup scripts included under pak_extensions (untar the downloaded archive to extract the pak_extensions directory)

  As a cluster admin the pre-install script is located at:
  - pre-install/clusterAdministration/createSecurityClusterPrereqs.sh

  As team admin the namespace scoped pre-install script is located at:
  - pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh

### SecurityContextConstraints Requirements

* Predefined SecurityContextConstraints name: [`ibm-privileged-scc`](https://ibm.biz/cpkspec-scc)

This chart optionally defines a custom SecurityContextConstraints (on Red Hat OpenShift Container Platform) which is used to finely control the permissions/capabilities needed to deploy this chart.  It is based on the predefined SecurityContextConstraint name: [`ibm-restricted-scc`](https://github.com/IBM/cloud-pak/blob/master/spec/security/scc/ibm-restricted-scc.yaml) with extra required privileges.

* Custom SecurityContextConstraints definition:

```
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  name: ibm-sccm-scc
  labels:
    app: "ibm-sccm-scc"
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
privileged: false
allowPrivilegeEscalation: true
allowPrivilegedContainer: false
allowedCapabilities:
- CHOWN

defaultAddCapabilities: []
defaultAllowPrivilegeEscalation: false
forbiddenSysctls:
- "*"
fsGroup:
  type: MustRunAs
  ranges:
  - min: 1
    max: 4294967294
readOnlyRootFilesystem: false
requiredDropCapabilities: []
runAsUser:
  type: MustRunAsRange
  uidRangeMin: 1000 
  uidRangeMax: 65535
seLinuxContext:
  type: RunAsAny
supplementalGroups:
  type: RunAsAny
  ranges:
  - min: 1
    max: 4294967294
volumes:
- configMap
- downwardAPI
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

- From the command line, you can run the setup scripts included under pak_extensions (untar the downloaded archive to extract the pak_extensions directory)

  As a cluster admin the pre-install script is located at:
  - pre-install/clusterAdministration/createSecurityClusterPrereqs.sh

  As team admin the namespace scoped pre-install script is located at:
  - pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh

## Resources Required

This chart uses the following resources by default:

* 8Gi of persistent volume
* 20 GB Disk space
* 3000m CPU
* 8Gi Memory
* 1 master node and at least 1 worker node

## Agreement to IBM Control Center License

You must read the IBM Sterling Control Center License agreement terms before installation, using the below link:
[License] https://www-40.ibm.com/software/sla/sladb.nsf (L/N: L-KNAN-C6VGE3)

## Installing

To install IBM Sterling Control Center via Helm command line with the release name e.g. `my-release`.

```bash
# This below command  will show the repositories

$ helm repo list

# If you do not have the helm repository, add it using the below command

$ helm repo add ibm-sccm-1.0.10.tgz <helm repository>

# This below command will show all the charts related to the repository

$ helm search <helm repository>

# Finally install the respective chart

$ helm install my-release -f values.yaml ibm-sccm-1.0.10.tgz
```

The command deploys ibm-sccm-1.0.10.tgz chart on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured in values.yaml file during installation.

> **Tip**: List all releases using `helm list`

## Configuration

The following tables lists the configurable parameters of the IBM Control Center Monitor chart and their default values.

|-------------------------------------------------|-----------------------------------------------------|------------------------------------------|
| Parameter                                       | Description                                         | Default                                  |
| ------------------------------------------------| ----------------------------------------------------| -----------------------------------------|
| `arch`                                          | Node Architecture                                   | `amd64`                                  |
| `replicaCount`                                  | Number of deployment replicas                       | `1`                                      |
| `image.repository`                              | Image full name including repository                |                                          |
| `image.tag`                                     | Image tag                                           |                                          |
| `image.imageSecrets`                            | Image pull secrets                                  |                                          |
| `image.pullPolicy`                              | Image pull policy                                   | `IfNotPresent`                           |
| `ccArgs.appUserUID`                             | UID for continer user                               |                                          |
| `ccArgs.appUserGID`                             | GID for container user                              |     									   |
| `ccArgs.productEntitilement`                    | Product Entitlement 				      			|										   |
| `ccArgs.dbType`								  | Database Type										|										   |
| `ccArgs.dbHost`								  | Database Hostname									|										   |
| `ccArgs.dbPort`								  | Database Port number								|										   |
| `ccArgs.dbUser`								  | Database Username									|										   |
| `ccArgs.dbName`								  | Database name										|     									   |
| `ccArgs.dbLoc`								  | Database localization								| `none`								   |
| `ccArgs.dbInit`								  | Database Initialization	Flag						| `true`								   |
| `ccArgs.dbPartition`							  | Database Partitioning Flag  						| `false`								   |
| `ccArgs.dbDrivers`							  | Database drivers									| 										   |
| `ccArgs.mssqlGlobal`							  | Database Globalization Flag							| `false`								   |
| `ccArgs.weblistenAddress`						  | Web Listen Address									| `0.0.0.0.`							   |
| `ccArgs.webHost`								  | Web Hostname										|										   |
| `ccArgs.autoStopJavaWebAppServer`				  | Auto stop Java web server							| `true`								   |
| `ccArgs.eventRepositoryAuth`					  | Event Repository Autentication						| `false`								   |
| `ccArgs.emailHostname`						  | Email hostname										| `localhost`							   |
| `ccArgs.emailPort`							  | Email Port number									| `25`									   |
| `ccArgs.emailUser`							  |	Email username										|										   |
| `ccArgs.emailRespond`							  | Responding email address							| `noone@anywhere`	                       |
| `ccArgs.ccAdminEmailAddress`					  | Admin Email Address									| `noone@anywhere`						   |
| `ccArgs.oracleRacOrScan`						  | Oracle is Single Client Access Name or not			|										   |
| `ccArgs.jmsEnable`							  | JMS enables or not									|										   |
| `ccArgs.jmsType`								  | JMS type											|										   |
| `ccArgs.jmsHost`								  | JMS Host name										|										   |
| `ccArgs.jmsPort`								  | JMS Port number										|										   |
| `ccArgs.jmsQueueManager`						  | JMS Queue Manager									| 										   |
| `ccArgs.jmsChannel`							  | JMS Channel name									|										   |
| `ccArgs.jmsSubject`							  | JMS Subject name									|										   |
| `ccArgs.jmsTopic`								  | JMS Topic name										| 										   |
| `ccArgs.jmsEmbedBroker`						  | JMS Embed Broker									|										   |
| `ccArgs.jmsDataDirectory`						  | JMS Data Directory									|										   |
| `ccArgs.jmsTimeToLive`						  | JMS Time to live									|										   |
| `ccArgs.jmsRetries`							  | JMS time to live									|										   |
| `ccArgs.jmsRetryWait`							  | JMS retry wait										|										   |
| `ccArgs.jmsBrokerName`						  | JMS Broker Name										|										   |
| `ccArgs.dbSSL`								  | Database SSL Enabled								|										   |
| `ccArgs.keyStore`								  | Keystore file path									|										   |
| `ccArgs.trustStore`							  | Truststore file path								|										   |
| `ccArgs.adminEmailAddress`					  | Admin Email Address									|										   |
| `ccArgs.keyAlias`								  | Key Alias name										|										   |
| `ccArgs.packagePath`							  | Package Path										|										   |
| `ccArgs.seasPrimaryAddress`					  |	SEAS Primary Address								|										   |
| `ccArgs.seasPrimaryPort`						  |	SEAS Primary Port number							|										   |
| `ccArgs.seasAlternativeAddress`				  | SEAS Alternative Address							| 										   |
| `ccArgs.seasAlternativePort`					  | SEAS Alternative Port number						|										   |
| `ccArgs.seasSecureConnection`					  | SEAS Secure Connection required or not				| `N`									   |
| `ccArgs.seasProfileName`						  | SEAS Profile Name									|										   |
| `ccArgs.seasPersistentConnection`				  | SEAS Persistent Connection required or not			| `N`									   |
| `ccArgs.seasSecureProtocol`					  | SEAS Secure Protocol name							|										   |
| `dashboard.enabled`                             | For making monitoring dashboard enabled             |                                          |
| `persistentVolumeCCM.enabled`                   | persistent volume for all volumes except user input | `true`                                   |
| `persistentVolumeCCM.useDynamicProvisioning`    | To use storage classes to dynamically create PV     | `false`                                  |
| `persistentVolumeCCM.storageClassName`          | Storage class of the PVC                            | `manual`                                 |
| `persistentVolumeCCM.size`                      | Size of PVC volume                                  | `20Gi`                                    |
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
| `service.externalTrafficPolicy`                 | For passing external Traffic Policy                 | `Local`                                  |
| `service.sessionAffinity`                       | For giving session Affinity                         | `ClientIP`                               |
| `service.swingConsole.name`                     | Swing Console name                                  | `swing-console`                          |
| `service.swingConsole.port`                     | Swing Console port number                           | `58080`                                  |
| `service.swingConsole.protocol`                 | Swing Console Protocol for service                  | `TCP`                                    |
| `service.webConsole.name`                       | Web Console name                                    | `web-console`                            |
| `service.webConsole.port`                       | Web Console port number                             | `58082`                                  |
| `service.webConsole.protocol`                   | Web Console Protocol for service                    | `TCP`                                    |
| `service.swingConsoleSecure.name`               | Secure Swing Console Port name                      | `swing-console-secure`                   |
| `service.swingConsoleSecure.port`               | Secure Swing Console port number                    | `58081`                                  |
| `service.swingConsoleSecure.protocol`           | Secure Swing Console Protocol for service           | `TCP`                                    |
| `service.webConsoleSecure.name`                 | Secure Web Console name                             | `web-console-secure`                     |
| `service.webConsoleSecure.port`                 | Secure Web Console port number                      | `58083`                                  |
| `service.webConsoleSecure.protocol`             | Secure Web Console Protocol for service             | `TCP`                                    |
| `service.externalIP`                            | External IP for service discovery                   |                                          |
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
| `serviceAccount.create`                         | Enable/disable service account creation             | `true`                                   |
| `serviceAccount.name`                           | Name of Service Account to use  for container       |                                          |
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
| `livenessProbe.initialDelaySeconds`             | Initial delays for liveness                         | `175`                                    |
| `livenessProbe.timeoutSeconds`                  | Timeout for liveness                                | `45'                                     |
| `livenessProbe.periodSeconds`                   | Time period for liveness                            | `120`                                    |
| `readinessProbe.initialDelaySeconds`            | Initial delays for readiness                        | `175`                                    |
| `readinessProbe.timeoutSeconds`                 | Timeout for readiness                               | `15`                                     |
| `readinessProbe.periodSeconds`                  | Time period for readiness                           | `120`                                    |
| `route.enabled`                                 | Route for OpenShift Enabled/Disabled                |`false`                                   |

Specify each parameter in values.yaml to `helm install`. For example,

```bash
helm install my-release \
  -f values.yaml \
  ibm-sccm-1.0.10.tgz
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. You can create a copy of values.yaml file e.g. my-values.yaml and edit the values that you need to override. Use the my-values.yaml file for installation. For example,

```bash
helm install <release-name> -f my-values.yaml ibm-sccm-1.0.10.tgz
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
helm upgrade my-release -f values.yaml ibm-sccm-1.0.10.tgz
```

## Rollback the Chart

What if we notice that we made a mistake after upgrading or upgraded environment is not working as expected? Then we can easily rollback the chart to a previous revision. We support rollback 'one version back' only. To rollback the chart with the release name `my-release`.

1. Run the following command to rollback your deployments to previous version.

```
helm rollback my-release --recreate-pods

2. After executing the rollback command to check is the history of a release. We only need to provide the release name `my-release`.

```bash
helm bash my-release
```

## Uninstalling the Chart

To uninstall the `my-release`

```bash
$ helm uninstall my-release

## Uninstalling the Chart

To uninstall/delete the `my-release`

```bash
$ helm uninstall my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release. Since there are certain kubernetes resources created as pre-requisite for chart, helm uninstall command will not delete them . You need to manually delete the following resources.

1. The persistence volume

2. The secret

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

This chart creates a service of `ClusterIP` for communication within the cluster. This type can be changed while installing chart using `service.type` key defined in values.yaml. There are two ports where IBM Control Center Monitor processes run. Swing Console Port (58080), Web Console Port(58082) whose values can be updated during chart installation using `service.swingConsole.port`, `service.webConsole.port`.

IBM Control Center Monitor services for API and file transfer can be accessed using LoadBalancer external IP and mapped ports. If external LoadBalancer is not present then refer to Master node IP for communication.

Use `networkPolicy` to control traffic flow at the port level.

> **Note**: `NodePort` service type is not recommended. It exposes additional security concerns and are hard to manage from both an application and networking infrastructure perspective.

## DIME and DARE

1. All sensitive application data at rest is stored in binary format so user cannot decrypt it. This chart does not support Encryption of user data at rest by default. Administrator can configure storage encryption to encrypt all data at rest.

2. Data in motion is encrypted using transport layer security(TLS 1.2). For more information please see product [Knowledge center link]( https://www.ibm.com/docs/en/control-center/6.2.1.0?topic=sterling-control-center-monitor-621 )

## Limitations

- Dynamic Volume Provisioning is supported for all volumes except user_inputs. Users must manually create Persistent Volume for user_inputs.
- High availability and scalability are supported in traditional way of Control Center deployment using Kubernetes load balancer service.
- IBM Control Center Monitor chart supports only amd64 architecture.


