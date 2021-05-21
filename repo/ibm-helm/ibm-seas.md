# IBM Sterling External Authentication Server v6.0.2.0

## Introduction

IBM Sterling External Authentication Server allows you to implement extended authentication and validation services for IBM products, called client applications. Sterling External Authentication Server includes a server that client applications connect to and a GUI to configure Sterling External Authentication Server requirements. To find out more, see the Knowledge Center for [IBM SEAS](https://www.ibm.com/support/knowledgecenter/SS4T7T_6.0.2/product_landing.html ).

## Chart Details

This chart deploys IBM Sterling External Authentication Server on a container management platform with the following resources deployments

- a statefulset pod `<release-name>-ibm-seas` with 1 replica.
- a configMap `<release-name>-ibm-seas`. This is used to provide default configuration in seas_config_file.
- a service `<release-name>-ibm-seas`. This is used to expose the SEAS services for accessing using clients.
- a service-account `<release-name>-ibm-seas-serviceaccount`. This service will not be created if `serviceAccount.create` is `false`.
- a persistence volume claim `<release-name>-ibm-seas`.

## Prerequisites

### Chart Image Bundle (Prereq #1)

Before you install IBM Certified Container Software for Sterling External Authentication Server, ensure that the helm chart package is available on your client system.

#### Downloading the IBM Certified Container Software helm chart from IBM Chart repository
You can download the IBM CCS for SEAS helm chart from [IBM Public chart repository](https://www.ibm.com/links?url=https://github.com/IBM/charts/tree/master/repo/ibm-helm/ibm-seas-1.1.1.tgz).


####  Downloading the IBM Certified Container Software image from IBM Entitled Registry for AirGap Environment
You can download the container image from IBM Entitled registry by using either `cloudctl` or `docker/podman` utility.

**1. Downloading the IBM Certified Container Software image using `cloudctl` utility:** 
- Download latest version of cloudctl CLI from [Cloud Pak CLI](https://www.ibm.com/links?url=https://github.com/IBM/cloud-pak-cli/releases). 
- Download and extract the CASE bundle file
```
cloudctl case save -t 1 --case https://github.com/IBM/cloud-pak/raw/master/repo/case/ibm-seas/1.0.0/ibm-seas-1.0.0.tgz --outputdir download_dir/ && tar -xf download_dir/ibm-seas-1.0.0.tgz
```
> **Note**: download_dir is the output directory in which the IBM SEAS resources are placed. The output directory is created if it does not exist. You can choose an arbitrary name for --outputdir if required.` 

- Log in to the OCP cluster as cluster-admin role
```
oc login <openshift_url> -u <username> -p <password> -n <namespace>
```
- Configure the authentication credentials (URL, username, and password) for both your local Docker registry and the IBM Entitled Registry by running the following commands:
```
cloudctl case launch \
 --case ibm-seas \
 --inventory ibmSeas \
 --action configure-creds-airgap \
 --args "--registry cp.icr.io --user cp --pass <entitled_key> --inputDir download_dir/" -t 1
```
```
cloudctl case launch \
--case ibm-seas \
--inventory ibmSeas \
--action configure-creds-airgap \
--args "--registry <LOCAL_DOCKER_REGISTRY_REPOSITORY> --user <username> --pass <password> --inputDir download_dir/" -t 1
```
- Configure global image pull secret and imageContentSourcePolicy resource by running the following command:
```
cloudctl case launch \
--case ibm-seas \
--inventory ibmSeas \
--namespace ssp \
--action configure-cluster-airgap \
--args "--registry <LOCAL_DOCKER_REGISTRY_REPOSITORY> --inputDir download_dir/" -t 1 
```
- Mirror the images to the Docker registry by running the following command:
```
cloudctl case launch \
--case ibm-seas \
--inventory ibmSeas \
--action mirror-images \
--args "--registry <LOCAL_DOCKER_REGISTRY_REPOSITORY>  --inputDir download_dir/" -t 1 
```
- During the helm chart deployment change the value from `false` to `true` for `image.digest.enabled` tag in values.yaml file.

**2. Downloading the IBM Certified Container Software image using `docker/podman` utility:**  
- Log in to the IBM Entitled registry by running the following command:   
  * `docker/podman login -u cp -p <entitled_key> cp.icr.io`

- Pull the container image from IBM Entitled registry by running the following command:
  * `docker/podman pull cp.icr.io/cp/ibm-seas/seas-docker-image:6.0.2.0.01`

- Tag and push the container image into local repository by running the following commands: 
  * `docker/podman tag cp.icr.io/cp/ibm-seas/seas-docker-image:6.0.2.0.01 <LOCAL_DOCKER_REGISTRY_REPOSITORY>/seas-docker-image:6.0.2.0.01`
  * `docker/podman push <LOCAL_DOCKER_REGISTRY_REPOSITORY>/seas-docker-image:6.0.2.0.01`


### Tools (Prereq #2)

To install chart from the command prompt, tools needed are:

- Kubernetes version >= `1.19.0`
- Helm version >= `3.0`
- OpenShift version = `4.6`
- The `kubectl` and `helm` commands available
- The environment should be configured to connect to the target cluster


### Storage (Prereq #3)

IBM Sterling External Authentication Server supports NFS storage for storing the persistent data. This needs to be created as a pre-requisite before deploying IBM Sterling External Authentication Server. However, IBM Sterling External Authentication Server supports - 

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

```
apiVersion: v1
kind: Secret
metadata:
  name: <secret name>
type: Opaque
data:
  adminPassword: <base64 encoded password>
  sysPassphrase: <base64 encoded passphrase>

```

```
kubectl create -f <secret yaml file>
```

> **Tip**: Use `echo -n "<password>" | base64` to encode to base64

The IBM SEAS secret would be created with data described as below: -

| Parameter                 | Description                                                                                                           |
|---------------------------|---------------------------------------------------------------------------------------------------------------------- |
|`sysPassphrase`            | The sysPassphrase required to unlock the key that allows encryption and decryption of configuration files.            |
|`adminPassword`            | The adminPassword is used when logging into SEAS for the first time.                                                  |

> **Note**: Once container is up after that delete the secret yaml file and resource object which was created from secret yaml file for security reasons.


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
  name: ibm-seas-psp
  labels:
    app: "ibm-seas-psp"
spec:
  privileged: false
  allowPrivilegeEscalation: true
  hostPID: false
  hostIPC: false
  hostNetwork: false
  requiredDropCapabilities:
  - KILL
  - MKNOD
  - SETFCAP
  - FSETID
  - NET_BIND_SERVICE
  - SYS_CHROOT
  - SETPCAP
  - NET_RAW
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
  - '*'
```

- Custom ClusterRole for the custom PodSecurityPolicy:

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: "ibm-seas-psp"
  labels:
    app: "ibm-seas-psp"
rules:
- apiGroups:
  - policy
  resourceNames:
  - ibm-seas-psp
  resources:
  - podsecuritypolicies
  verbs:
  - use
```

- From the command line, you can run the setup scripts included under pak_extensions (untar the downloaded archive to extract the pak_extensions directory)

  As a cluster admin the pre-install script is located at:
  - chmod +x pre-install/clusterAdministration/createSecurityClusterPrereqs.sh
  - pre-install/clusterAdministration/createSecurityClusterPrereqs.sh

  As team admin the namespace scoped pre-install script is located at:
  - chmod +x pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh
  - pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh <Namespace/Project>

### SecurityContextConstraints Requirements

* Predefined SecurityContextConstraints name: [`ibm-privileged-scc`](https://ibm.biz/cpkspec-scc)

This chart optionally defines a custom SecurityContextConstraints (on Red Hat OpenShift Container Platform) which is used to finely control the permissions/capabilities needed to deploy this chart.  It is based on the predefined SecurityContextConstraint name: [`ibm-restricted-scc`](https://github.com/IBM/cloud-pak/blob/master/spec/security/scc/ibm-restricted-scc.yaml) with extra required privileges.

* Custom SecurityContextConstraints definition:

```
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata: 
  name: ibm-seas-scc
  labels:
    app: "ibm-seas-scc"
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
privileged: false
allowPrivilegeEscalation: true
requiredDropCapabilities:
- KILL
- MKNOD
- SETFCAP
- FSETID
- NET_BIND_SERVICE
- SYS_CHROOT
- SETPCAP
- NET_RAW
allowedCapabilities:
- FOWNER
- CHOWN
- SETGID
- SETUID
- DAC_OVERRIDE 
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
```

- Custom ClusterRole for the custom SecurityContextConstraints:

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: "ibm-seas-scc"
  labels:
    app: "ibm-seas-scc"
rules:
- apiGroups:
  - security.openshift.io
  resourceNames:
  - ibm-seas-scc
  resources:
  - securitycontextconstraints
  verbs:
  - use
```

- From the command line, you can run the setup scripts included under pak_extensions (untar the downloaded archive to extract the pak_extensions directory)

  As a cluster admin the pre-install script is located at:
  - chmod +x pre-install/clusterAdministration/createSecurityClusterPrereqs.sh
  - pre-install/clusterAdministration/createSecurityClusterPrereqs.sh

  As team admin the namespace scoped pre-install script is located at:
  - chmod +x pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh
  - pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh <Namespace/Project>

## Resources Required

This chart uses the following resources by default:

* 2Gi of persistent volume
* 3 GB Disk space
* 1000m CPU
* 1Gi Memory
* 1 master node and at least 1 worker node

## Agreement to IBM SEAS License

You must read the IBM Sterling External Authentication Server License agreement terms before installation, using the below link:
[License] http://www-03.ibm.com/software/sla/sladb.nsf (L/N: L-BCHE-BXLMPM)

## Installing the Chart

To install IBM Sterling External Authentication Server via Helm command line with the release name e.g. `my-release`.

```bash
# This below command  will show the repositories

$ helm repo list

# If you do not have the helm repository, add it using the below command

$ helm repo add ibm-seas-1.1.1.tgz <helm repository>

# This below command will show all the charts related to the repository

$ helm search <helm repository>

# Finally install the respective chart

$ helm install my-release  --set image.repository=<repo name>,image.tag=<image tag>,image.imageSecrets=<image pull secret>,secret.secretName=<SEAS secret name>,service.jettyDns.externalIP=<Service IP>` ibm-seas-1.1.1.tgz
```

The command deploys ibm-seas-1.1.1.tgz chart on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Configuration

The following tables lists the configurable parameters of the IBM SEAS chart and their default values.

| Parameter                                       | Description                                         | Default                                  |
| ------------------------------------------------| ----------------------------------------------------| -----------------------------------------|
| `license`                                       | License Agreement                                   | `false`                                  |
| `licenseType`                                   | License Type                                        | `non-prod`                               |
| `image.repository`                              | Image full name including repository                | `cp.icr.io/cp/ibm-seas/seas-docker-image`|
| `image.tag`                                     | Image tag                                           | `6.0.2.0.01`                             |
| `image.imageSecrets`                            | Image pull secrets                                  |                                          |
| `image.digest.enabled`                          | Enable/disable digest to be used for image          | `false`                                  |
| `image.digest.value`                            | Digest has value for image used for deployment      | `sha256:5e88859118d5145fee14ba895aa351d98652250ecd650f251e056f18dcf2b12b`                                         |
| `image.pullPolicy`                              | Image pull policy                                   | `IfNotPresent`                           |
| `seasArgs.appUserUid`                           | UID for container user                              | `1000`                                   |
| `seasArgs.appUserGid`                           | GID for container user                              | `1000`                                   |
| `seasArgs.maxHeapSize`                          | JVM heap size                                       | `1024m`                                  |
| `persistentVolume.enabled`                      | To use persistent volume                            | `true`                                   |
| `persistentVolume.useDynamicProvisioning`       | To use storage classes to dynamically create PV     | `false`                                  |
| `persistentVolume.existingClaimName`            | Existing PVC name                                   |                                          |
| `persistentVolume.storageClassName`             | Storage class of the PVC                            | `manual`                                 |
| `persistentVolume.size`                         | Size of PVC volume                                  | `2Gi`                                    |
| `persistentVolume.labelName`                    | Persistent volume label name                        | `app.kubernetes.io/name`                 |
| `persistentVolume.labelValue`                   | Persistent volume label value                       | `ibm-seas-pv`                            |
| `persistentVolume.accessMode`                   | PV accessMode                                       | `ReadWriteOnce`                          |
| `service.type`                                  | Service type                                        | `LoadBalancer`                           |
| `service.loadBalancerIP`                        | Load balancer IP                                    |                                          |
| `service.annotations`                           | Service annotations                                 |                                          |
| `service.externalTrafficPolicy`                 | External traffic Policy                             |                                          |
| `service.sessionAffinity`                       | Session Affinity                                    | `ClientIP`                               |
| `service.secure.servicePort`                    | Secure service port                                 | `61366`                                  |
| `service.secure.containerPort`                  | Secure container port                               | `61366`                                  |
| `service.nonSecure.servicePort`                 | Non-Secure service port                             | `61365`                                  |
| `service.nonSecure.containerPort`               | Non-Secure container port                           | `61365`                                  |
| `service.jetty.servicePort`                     | Jetty service port                                  | `9080`                                   |
| `service.jetty.containerPort`                   | Jetty container port                                | `9080`                                   |
| `service.externalIP`                            | External IP for service discovery                   |                                          |
| `secret.secretName`                             | Secret name for Seas                                |                                          |
| `resources.limits.cpu`                          | Container CPU limit                                 | `1000m`                                  |
| `resources.limits.memory`                       | Container memory limit                              | `1Gi  `                                  |
| `resources.requests.cpu`                        | Container CPU requested                             | `1000m`                                  |
| `resources.requests.memory`                     | Container Memory requested                          | `1Gi`                                    |
| `serviceAccount.create`                         | Enable/disable service account creation             | `true`                                   |
| `serviceAccount.name`                           | Name of Service Account to use  for container       |                                          |
| `affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution` | k8s PodSpec.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity"                                          |                                      |
| `affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution` | k8s PodSpec.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity"                                          |                                      |
| `affinity.podAffinity.requiredDuringSchedulingIgnoredDuringExecution` | k8s PodSpec.podAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity"                                          |                                      |
| `affinity.podAffinity.preferredDuringSchedulingIgnoredDuringExecution` | k8s PodSpec.podAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity"                                          |                                      |
| `affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution` | k8s PodSpec.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity"                                          |                                      |
| `affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution` | k8s PodSpec.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity"                                          |                                      |
| `livenessProbe.initialDelaySeconds`             | Initial delays for liveness                         |`200`                                     |
| `livenessProbe.timeoutSeconds`                  | Timeout for liveness                                |`30`                                      |
| `livenessProbe.periodSeconds`                   | Time period for liveness                            |`60`                                      |
| `livenessProbe.failureThreshold`                | Failure threshold for liveness                      |`10`                                      |
| `readinessProbe.initialDelaySeconds`            | Initial delays for readiness                        |`190`                                     |
| `readinessProbe.timeoutSeconds`                 | Timeout for readiness                               |`5`                                       |
| `readinessProbe.periodSeconds`                  | Time period for readiness                           |`60`                                      |
| `readinessProbe.failureThreshold`               | Failure threshold for readiness                     |`10`                                      |
| `route.enabled`                                 | Route for OpenShift Enabled/Disabled                |`false`                                   |
| `route.dashboard`                               | Monitor Dashboard Enabled/Disabled                  |`false`                                   |
| `customProperties`                              | Customize the properties files                      |                                          |
| `vmArguments`                                   | Provide the VM arguments                            |                                          |
| `customFiles`                                   | Map the custom directories/files                    |                                          |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
helm install my-release \
  --set service.externalIP=172.20.185.196 \
  ibm-seas-1.1.1.tgz
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. You can create a copy of values.yaml file e.g. my-values.yaml and edit the values that you need to override. Use the my-values.yaml file for installation. For example,

```bash
helm install <release-name> -f my-values.yaml ibm-seas-1.1.1.tgz
```
> **Tip**: You can use the default [values.yaml](values.yaml)

## Affinity

The chart provides various ways in the form of node affinity, pod affinity and pod anti-affinity to configure advanced pod scheduling in Kubernetes. Refer the Kubernetes documentation for details on usage and specifications for the below features.

* Node affinity - This can be configured using parameters `affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the SEAS server.
Depending on the architecture preference selected for the parameter `arch`, a suitable value for node affinity is automatically appended in addition to the user provided values.

* Pod affinity - This can be configured using parameters `affinity.podAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `affinity.podAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the SEAS server.

* Pod anti-affinity - This can be configured using parameters `affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the SEAS server.
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

```bash
helm upgrade my-release -f values.yaml ibm-seas-1.1.1.tgz
```

## Rollback the Chart

What if we notice that we made a mistake after upgrading or upgraded environment is not working as expected? Then we can easily rollback the chart to a previous revision. We support rollback 'one version back' only. To rollback the chart with the release name `my-release`.

1. Run the following command to rollback your deployments to previous version.

```bash
helm rollback my-release --recreate-pods

2. After executing the rollback command to check is the history of a release. We only need to provide the release name `my-release`.

```bash
helm history my-release


## Uninstalling the Chart

To uninstall the `my-release`

```bash
$ helm uninstall my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release. Since there are certain Kubernetes resources created as pre-requisite for chart, helm uninstall command will not delete them . You need to manually delete the following resources.

1. The persistence volume

2. The secret

## Backup & Restore

**To Backup:**

You need to take backup of configuration data which are present in the persistent volume by following the below steps:

1. Go to mount path of Persistent Volume.

2. Make copy of all of the directories listed below and store them at your desired and secured place.
   * `SEAS`
  
> **Note**:In case of traditional installation of SEAS, you should take the backup of the installation directory and save them at your desired location:
   * `SEAS`

**To Restore:**

Restoring the data in new deployment, it can be achieved by following steps

1. Create a Persistent Volume.

2. Copy all the backed up directories to the mount path of Persistent Volume.

3. Create a new deployment using the helm CLI command. The pod would come up with desired data.

## Exposing Services

This chart creates a service of `ClusterIP` for communication within the cluster. This type can be changed while installing chart using `service.type` key defined in values.yaml. There are three ports where IBM SEAS processes run. Non secure API port (61365), secure API port (61366) and Jetty port (9080) whose values can be updated during chart installation using `service.nonSecure.servicePort`or `service.secure.servicePort` or `service.jetty.servicePort`.

IBM SEAS service can be accessed using LoadBalancer external IP and mapped non secure port. If external LoadBalancer is not present then refer to Master node IP for communication.

> **Note**: `NodePort` service type is not recommended. It exposes additional security concerns and are hard to manage from both an application and networking infrastructure perspective.

## DIME and DARE

1. All sensitive application data at rest is stored in binary format so user cannot decrypt it. This chart does not support Encryption of user data at rest by default. Administrator can configure storage encryption to encrypt all data at rest.

2. Data in motion is enncrypted using transport layer security(TLS 1.2). For more information pls see product [Knowledge center link]( https://www.ibm.com/support/knowledgecenter/SS4T7T_6.0.2/product_landing.html )

## Limitations

- High availability and scalability are supported in traditional way of SEAS deployment using Kubernetes load balancer service.
- IBM Sterling External Authentication Server chart is supported with only 1 replica count.
- IBM Sterling External Authentication Server chart supports only amd64 architecture.
- Non-persistence mode is not supported.

