# IBM Connect Direct for Unix v6.1.0

## Introduction
  
IBM® Connect:Direct® for UNIX links technologies and moves all types of information between networked systems and computers. It manages high-performance transfers by providing such features as automation, reliability, efficient use of resources, application integration, and ease of use. Connect:Direct (C:D) for UNIX offers choices in communications protocols, hardware platforms, and operating systems. It provides the flexibility to move information among mainframe systems, midrange systems, desktop systems, LAN-based workstations and cloud based storage providers (Amazon S3 Object Store for current release). To find out more, see the Knowledge Center for [IBM Connect:Direct](https://www.ibm.com/support/knowledgecenter/SS4PJT_6.1.0/cd_unix_61_welcome.html).

## Chart Details

This chart deploys IBM Connect Direct on a container management platform with the following resources deployments

- a statefulset pod `<release-name>-ibm-connect-direct` with 1 replica by default.
- a configMap `<release-name>-ibm-connect-direct`. This is used to provide default configuration in cd_param_file.
- a service `<release-name>-ibm-connect-direct`. This is used to expose the C:D services for accessing using clients.
- a service-account `<release-name>-ibm-connect-direct-serviceaccount`. This service will not be created if `serviceAccount.create` is `false`.
- a persistence volume claim `<release-name>-ibm-connect-direct`.
- a monitoring dashboard `<release-name>-ibm-connect-direct`. This will not be created if `dashboard.enabled` is `false`.

## Prerequisites

### Chart Image Bundle (Prereq #1) 

The IBM Connect Direct Chart bundle can be downloaded from `Fix Central`:

####  Fix Central

The steps to be followed are as under:-
- Download the Chart Image bundle from [Fix Central](https://www-945.ibm.com/support/fixcentral/). The Chart Image bundle name is `6.1.0.x-IBMConnectDirectforUNIX-Certified-Container-Linux-x86-iFix<ifix_version>.tar`.
- Extract the bundle `6.1.0.x-IBMConnectDirectforUNIX-Certified-Container-Linux-x86-iFix<ifix_version>.tar` and verify that below files exist
  * `cdu6.1_certified_container_6.1.0.x_<ifix_version>.tar` - Docker Image
  * `ibm-connect-direct-<version>.tgz` - Chart Bundle
- Load the Docker Image in registry. For e.g:
  * `docker load -i cdu6.1_certified_container_6.1.0.x.tar`
  * `docker tag <image-name>:<tag> <repository-url>/<image-name>:<tag>`
  * `docker push <repository-url>/<image-name>:<tag>`
- Refer this image during chart installation using `image.repository` and `image.tag` keys defined in values.yaml in helm cli command. The `image.repository` should have `<repository-url>/<image-name>` and `image.tag` should have `<tag>` values.

> **Note**: The same above steps can be followed in `Air-Gap Environment`

### Storage (Prereq #2)
 
IBM Connect Direct for Unix supports NFS storage for storing the persistent data. This needs to be created as a pre-requisite before deploying IBM Connect Direct for Unix. However, IBM Connect Direct for Unix supports - 

- Dynamic Provisioning
- Pre-created Persistent Volume
- Pre-created Persistent Volume Claim
- The only supported access mode is `ReadWriteOnce`
 
- [Persistent Volume](http://kubernetes.io/docs/user-guide/persistent-volumes/) can be created by using a yaml file as the following examples. The `ReadWriteOnce` access mode is recommended.

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
    purpose: cddata
spec:
  storageClassName: <storage classname>
  capacity:
    storage: <storage size>
  accessModes:
    - ReadWriteOnce
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
    purpose: cddata
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
- For non-dynamic provisioning, the NFS/Hostpath mount path should have C:D certificate files to be used for installation. For this, first create the directory inside mount path and place certificate files inside the created directory. Then, pass the name of the created directory to helm chart using `cdArgs.configDir` value. 

Similarly, if LDAP feature is enabled along with TLS authentication, then all the certificate files are needed to be placed inside ldap_certs directory under above created directory.

#### Setting permissions on storage

When shared storage is mounted on a container, it is mounted with same POSIX ownership and permission present on exported NFS directory. The mounted directories on container may not have correct owner and permission needed to perform execution of scripts/binaries or writing to them. This situation can be handled as below - 

- Option A: The easiest and undesirable solution is to have open permissions on the NFS exported directories.

`chmod -R 777 <path-to-directory>`

- Option B: Alternatively, the permissions can be controlled at group level leveraging the supplementalGroups and fsGroup setting. For example - if we want to add GID to `supplementalGroups` or `fsGroup`, it can be done using `storageSecurity.supplementalGroups` or `storageSecurity.fsGroup`.

### Secret (Prereq #3)

To separate application secrets from the Helm release. A secret can be preinstalled with the following shape and referenced from the Helm chart with `secret.secretName` value.

```
apiVersion: v1
kind: Secret
metadata:
  name: <secret name>
type: Opaque
data:
  admPwd: <base64 encoded password>
  crtPwd: <base64 encoded password>
  keyPwd: <base64 encoded password>
  appUserPwd: <base64 encoded password>
```

```
kubectl create -f <secret yaml file>
```

> **Tip**: Use `echo -n "<password>" | base64` to encode to base64

The IBM Connect Direct secret would be created with data described as below: -

| Parameter   | Description                                                                               |
|-------------|-------------------------------------------------------------------------------------------|
|`admPwd`     | The password for C:D admin account `cduser`                                               |
|`crtPwd`     | The password of certificate                                                               |
|`keyPwd`     | The password to be used during the creation of KeyStore created with silent installation  |
|`appUserPwd` | The password for non-admin C:D user                                                       |

> **Note**: You must replace <password> with your own passwords in <secret yaml file> and once secret is created, delete the yaml file for security. The password provided to admPwd will be set as password for user `cduser` during pod initialization.

- For dynamic provisioning, one more secret resource needs to be created for all the certificates (secure plus certificates and LDAP certificates). It can be created using below example as required - 

```
kubectl create secret generic cd-cert-secret --from-file=certificate_file1=/path/to/certificate_file1 --from-file=certificate_file2=/path/to/certificate_file2
``` 

### Tools (Prereq #4)

To install chart from the command prompt, tools needed are:

- Kubernetes version `>=1.11`
- OpenShift version `=3.11 || >=4.4`
- helm version `>=3.2`
- The `kubectl` and `helm` commands available
- The environment should be configured to connect to the target cluster

### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy.

* Predefined PodSecurityPolicy name: [`ibm-privileged-psp`](https://ibm.biz/cpkspec-psp)

This chart optionally defines a custom PodSecurityPolicy which is used to finely control the permissions/capabilities needed to deploy this chart. It is based on the predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://github.com/IBM/cloud-pak/blob/master/spec/security/psp/ibm-restricted-psp.yaml) with extra required privileges. You can enable this policy by using the Platform User Interface or configuration file available under pak_extensions/pre-install/ directory

- From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy

* Custom PodSecurityPolicy definition:  

```
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: ibm-connect-direct-psp
  labels:
    app: "ibm-connect-direct-psp"
spec:
  privileged: false
  allowPrivilegeEscalation: true
  hostPID: false
  hostIPC: false
  hostNetwork: false
  requiredDropCapabilities:
  allowedCapabilities:
  - IPC_OWNER
  - IPC_LOCK
  - CHOWN
  - SETGID
  - SETUID
  - DAC_OVERRIDE
  - FOWNER
  - AUDIT_WRITE
  - SYS_CHROOT
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
  - '*'
```

- Custom ClusterRole for the custom PodSecurityPolicy:

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: "ibm-connect-direct-psp"
  labels:
    app: "ibm-connect-direct-psp"
rules:
- apiGroups:
  - policy
  resourceNames:
  - ibm-connect-direct-psp
  resources:
  - podsecuritypolicies
  verbs:
  - use
```

- From the command line, you can run the setup scripts included under pak_extensions (untar the downloaded archive to extract the pak_extensions directory)

  As a cluster admin the pre-install script is located at:
  - pre-install/clusterAdministration/createSecurityClusterPrereqs.sh

  As team admin the namespace scoped pre-install script is located at:
  - pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh <NAMESPACE>

### SecurityContextConstraints Requirements

* Predefined SecurityContextConstraints name: [`ibm-privileged-scc`](https://ibm.biz/cpkspec-scc)

This chart optionally defines a custom SecurityContextConstraints (on Red Hat OpenShift Container Platform) which is used to finely control the permissions/capabilities needed to deploy this chart.  It is based on the predefined SecurityContextConstraint name: [`ibm-restricted-scc`](https://github.com/IBM/cloud-pak/blob/master/spec/security/scc/ibm-restricted-scc.yaml) with extra required privileges.

* Custom SecurityContextConstraints definition:

```
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  name: ibm-connect-direct-scc
  labels:
    app: "ibm-connect-direct-scc"
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
privileged: false
allowPrivilegeEscalation: true
allowedCapabilities:
- IPC_OWNER
- IPC_LOCK
- FOWNER
- CHOWN
- SETGID
- SETUID
- DAC_OVERRIDE
- AUDIT_WRITE
- SYS_CHROOT
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
  type: MustRunAsNonRoot
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
priority: 0
```

- Custom ClusterRole for the custom SecurityContextConstraints:

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: "ibm-connect-direct-scc"
  labels:
    app: "ibm-connect-direct-scc"
rules:
- apiGroups:
  - security.openshift.io
  resourceNames:
  - ibm-connect-direct-scc
  resources:
  - securitycontextconstraints
  verbs:
  - use
```

- From the command line, you can run the setup scripts included under pak_extensions (untar the downloaded archive to extract the pak_extensions directory)

  As a cluster admin the pre-install script is located at:
  - pre-install/clusterAdministration/createSecurityClusterPrereqs.sh

  As team admin the namespace scoped pre-install script is located at:
  - pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh <NAMESPACE>

## Resources Required

This chart uses the following resources by default:

* 100Mi of persistent volume
* 1 GB Disk space
* 500m CPU
* 2000Mi Memory

## Agreement to IBM Connect:Direct for Unix License

You must read the IBM Connect:Direct for Unix License agreement terms before installation, using the below link:
[License](http://www-03.ibm.com/software/sla/sladb.nsf) (L/N:  L-BCHE-BSLHNW)

## Installing the Chart

To install IBM Connect:Direct for Unix via Helm command line with the release name e.g. `my-release`.

```bash
# This below command  will show the repositories

$ helm repo list

# If you do not have the helm repository, add it using the below command

$ helm repo add ibm-connect-direct-<version>.tgz <helm repository>

# This below command will show all the charts related to the repository

$ helm search repo <text to search>

# Finally install the respective chart

$ helm install my-release --set license=true,image.repository=<reponame> image.tag=<image tag>,cdArgs.crtName=<certificate name>,image.imageSecrets=<image pull secret>,secret.secretName=<C:D secret name> ibm-connect-direct-<version>.tgz

The command deploys ibm-connect-direct-<version>.tgz chart on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Configuration

The following tables lists the configurable parameters of the IBM Connect Direct chart and their default values.

| Parameter                              | Description                                         | Default                                  |
| -------------------------------------- | ----------------------------------------------------| -----------------------------------------|
| `license`                              | License agreement                                   | `true`                                   |
| `licenseType`                          | License Edition Type                                | `non-prod`                               |
| `env.timezone`                         | Timezone                                            | `UTC`                                    |
| `arch`                                 | Node Architecture                                   | `amd64`                                  |
| `replicaCount`                         | Number of deployment replicas                       | `1`                                      |
| `image.repository`                     | Image full name including repository                | `cp.icr.io/cp/ibm-connectdirect/cdu6.1_certified_container_6.1.0.3` |
| `image.tag`                            | Image tag                                           | `6.1.0.3_ifix015`                        |
| `image.imageSecrets`                   | Image pull secrets                                  |                                          |
| `image.digest.enabled`                 | Enable/disable digest to be used for image          | `false`                                  |
| `image.digest.value`                   | Digest has value for image used for deployment      | `sha256:35bae3bc87da3e91dae185a3912cde7edf04c418c6c51d2e35089a20576ea7f4` |
| `image.pullPolicy`                     | Image pull policy                                   | `IfNotPresent`                           |
| `cdArgs.nodeName`                      | Node name                                           | `cdnode`                                 |
| `cdArgs.crtName`                       | Certificate file name                               |                                          |
| `cdArgs.cport`                         | Client Port                                         | `1363`                                   |
| `cdArgs.sport`                         | Server Port                                         | `1364`                                   |
| `cdArgs.configDir`                     | Directory for storing C:D configuration files       | `CDFILES`                                |
| `cdArgs.saclConfig`                    | Configuration values for SACL option                | `n`                                      |
| `appUser.name`                         | Name of Non-Admin C:D User                          | `appuser`                                |
| `appUser.uid`                          | UID of Non-Admin C:D User                           |                                          |
| `appUser.gid`                          | GID of Non-Admin C:D User                           |                                          |
| `persistence.enabled`                  | To use persistent volume                            | `true`                                   |
| `persistence.useDynamicProvisioning`   | To use storage classes to dynamically create PV     | `false`                                  |
| `pvClaim.existingClaimName`            | Existing PVC name                                   |                                          |
| `pvClaim.storageClassName`             | Storage class of the PVC                            |                                          |
| `pvClaim.accessMode`                   | Access Mode for PVC                                 | `ReadWriteOnce`                          |
| `pvClaim.size`                         | Size of PVC volume                                  | `100Mi`                                  |
| `pvClaim.selector.label`               | PV label key to bind this PVC                       |                                          |
| `pvClaim.selector.value`               | PV label value to bind this PVC                     |                                          |
| `service.type`                         | Kubernetes service type exposing ports              | `LoadBalancer`                           |
| `service.apiport.name`                 | API Port name                                       | `api`                                    |
| `service.apiport.port`                 | API port number                                     | `1363`                                   |
| `service.apiport.protocol`             | Protocol for service                                | `TCP`                                    |
| `service.ftport.name`                  | FT Port name                                        | `ft`                                     |
| `service.ftport.port`                  | FT port number                                      | `1364`                                   |
| `service.ftport.protocol`              | Protocol for service                                | `TCP`                                    |
| `service.externalIP`                   | External IP for service discovery                   |                                          |
| `service.loadBalancerIP`               | For LoadBalancer IP                                 |                                          |
| `service.annotations`                  | Annotations for Service                             |                                          |
| `secret.secretName`                    | Secret name for C:D passwords                       |                                          |
| `secret.certSecretName`                | Secret name for C:D and LDAP certificate files      |                                          |
| `resources.limits.cpu`                 | Container CPU limit                                 | `500m`                                   |
| `resources.limits.memory`              | Container memory limit                              | `2000Mi`                                 |
| `resources.requests.cpu`               | Container CPU requested                             | `500m`                                   |
| `resources.requests.memory`            | Container Memory requested                          | `2000Mi`                                 |
| `serviceAccount.create`                | Enable/disable service account creation             | `true`                                   |
| `serviceAccount.name`                  | Name of Service Account to use  for container       |                                          |
| `extraVolumeMounts`                    | Extra Volume mounts                                 |                                          |
| `extraVolume`                          | Extra volumes                                       |                                          |
| `dashboard.enabled`                    | Enable/disable dashboard monitoring                 | `false`                                  |
| `affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution` | k8s PodSpec.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity"                                          |                                      |
| `affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution` | k8s PodSpec.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity"                                          |                                      |
| `affinity.podAffinity.requiredDuringSchedulingIgnoredDuringExecution` | k8s PodSpec.podAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity"                                          |                                      |
| `affinity.podAffinity.preferredDuringSchedulingIgnoredDuringExecution` | k8s PodSpec.podAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity"                                          |                                      |
| `affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution` | k8s PodSpec.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity"                                          |                                      |
| `affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution` | k8s PodSpec.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity"                                          |                                      |
| `livenessProbe.initialDelaySeconds`    | Initial delays for liveness                         | `230`                                    |
| `livenessProbe.timeoutSeconds`         | Timeout for liveness                                | `30`                                     |
| `livenessProbe.periodSeconds`          | Time period for liveness                            | `60`                                     |
| `readinessProbe.initialDelaySeconds`   | Initial delays for readiness                        | `220`                                    |
| `readinessProbe.timeoutSeconds`        | Timeout for readiness                               | `5`                                      |
| `readinessProbe.periodSeconds`         | Time period for readiness                           | `60`                                     |
| `route.enabled`                        | Route for OpenShift Enabled/Disabled                | `false`                                  |
| `cduser.uid`                           | UID for cduser                                      | `45678`                                  |
| `cduser.gid`                           | GID for cduser                                      | `45678`                                  |
| `storageSecurity.fsGroup`              | File system group id for persistent volume          | `45678`                                  |
| `storageSecurity.supplementalGroups`   | Supplemental group id for persistent volume         | `5555`                                   |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
helm install my-release \
  --set cdArgs.cport=9898 \
  ibm-connect-direct-<version>.tgz
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. You can create a copy of values.yaml file e.g. my-values.yaml and edit the values that you need to override. Use the my-values.yaml file for installation. For example, 

```bash
helm install <release-name> -f my-values.yaml ibm-connect-direct-<version>.tgz
```
> **Tip**: You can use the default [values.yaml](values.yaml)

## Affinity

The chart provides various ways in the form of node affinity, pod affinity and pod anti-affinityto configure advance pod scheduling in kubernetes. Refer the kubernetes documentation for details on usage and specifications for the below features.

* Node affinity - This can be configured using parameters `affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the connect direct server.
Depending on the architecture preference selected for the parameter `arch`, a suitable value for node affinity is automatically appended in addition to the user provided values.

* Pod affinity - This can be configured using parameters `affinity.podAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `affinity.podAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the connect direct server.

* Pod anti-affinity - This can be configured using parameters `affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the connect direct server.
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
helm upgrade my-release --reuse-values -f values.yaml ibm-connect-direct-<version>.tgz
```

## Uninstalling the Chart

To uninstall/delete the `my-release`

```bash
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release. Since there are certain kubernetes resources created as pre-requisite for chart, helm delete command will not delete them . You need to manually delete the following resources.

1. The persistence volume

2. The secret

## Backup & Restore

**To Backup:**

You need to take backup of configuration data and other information like stats and TCQ which are present in the persistent volume by following the below steps:

1. Go to mount path of Persistent Volume. 

2. Make copy of all of the directories listed below and store them at your desired and secured place.
   * `WORK`
   * `CFG`
   * `SECPLUS`
   * `SECURITY`

> **Note**:In case of traditional installation of Connect:Direct for Unix, you should take the backup of the below directories and save them at your desired location:
   * `work`
   * `cfg`
   * `secure+`
   * `security`

**To Restore:**

Restoring the data in new deployment, it can be achieved by following steps

1. Create a Persistent Volume.

2. Copy all the backed up directories to the mount path of Persistent Volume.

3. Create a new deployment using the above Persistent Volume using variable `persistentVolume.name` in helm cli command. The pod would come up with desired data.

## Exposing Services

This chart creates a service of `ClusterIP` for communication within the cluster. This type can be changed while installing chart using `service.type` key defined in values.yaml. There are two ports where IBM Connect Direct processes run. API port (1363) and FT port (1364), whose values can be updated during chart installation using `service.apiport.port` or `service.ftport.port`.

IBM Connect Direct services for API and file transfer can be accessed using LoadBalancer external IP and mapped API and FT port. If external LoadBalancer is not present then refer to Master node IP for communication.

> **Note**: `NodePort` service type is not recommended. It exposes additional security concerns and are hard to manage from both an application and networking infrastructure perspective.

## DIME and DARE

1. All sensitive application data at rest is stored in binary format so user cannot decrypt it. This chart does not support Encryption of user data at rest by default. Administrator can configure storage encryption to encrypt all data at rest.

2. Data in motion is enncrypted using transport layer security(TLS 1.3). For more information pls see product [Knowledge center link](https://www.ibm.com/support/knowledgecenter/en/SS4PJT_6.1.0/cd_unix/cdunix_secplus/CDU_Intro_Secure_Plus_.html)

## Limitations

- High availability and scalability are supported in traditional way of Connect:Direct deployment using Kubernetes load balancer service.
- IBM Connect:Direct for Unix chart is supported with only 1 replica count.
- IBM Connect:Direct for Unix chart supports only amd64 architecture.
- FASP feature is not supported.
- File agent service is not available inside the container.
- Interaction with IBM Control Center Director is not supported.
- Non-persistence mode is not supported
