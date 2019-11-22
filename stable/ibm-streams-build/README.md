# IBM Streams Build Service
![](https://raw.githubusercontent.com/IBM/charts/master/logo/ibm-streams-logo-readme.png?sanitize=true)
## Introduction
IBM® Streams is a software platform that enables the development and execution of applications that process information in data streams. IBM Streams enables continuous and fast analysis of massive volumes of moving data to help improve the speed of business insight and decision making.
IBM Streams consists of a programming language, an API, and an integrated development environment (IDE) for applications, and a runtime system that can run the applications on a 
single or distributed set of resources.

This chart creates and starts an IBM Streams build service for compiling and building Streams applications. The Streams build service  is composed of a build service pod and 1 to n builder pods that compile Streams applications. The build service pod, uses the Kubernetes REST API to allocate and manage the pool of builder pods that will perform the actual compilations. For security reasons, the builder resources only live for the life of a single build, and are disposed of and replaced as necessary.

## Chart Details
This chart does the following. 
- Uses a Helm hook to run a job (`preinstall`) to prepare the environment for running the build service.
- Deploys the Streams build service as a Kubernetes StatefulSet (`build`). There is only one build service pod. This build service pod uses the Kubernetes REST API to allocate and manage the pool of builder pods that compile the applications. These build pool resources have the name <release>-builder-<id>; where the <id> increments as new builder resources are created in the build pool. The builder resources live only for the life of a single build, and are disposed of and replaced as necessary.
- Runs a job (`anaconda`) to install the Anaconda external libraries to a persistent volume.
- Runs a job (`spss`) to install the Statistical Package for the Social Sciences (SPSS) external libraries to a persistent volume.
- Optionally creates a persistent volume claim (`streams-ext-pvc`), if the builder.streamsExtPvcStorageClass is selected, to install external libraries. Otherwise you must create the persistent volume claim and specify the name in the following value: builder.streamsExtPvc. 
- Optionally creates persistent volume claim (`build-pvc`) for build service configuration, if the storage class value (build.persistentStorageClassName) is specified. Otherwise you must create the persistent volume claim and specify the name in the following value: build.persistentVolumeClaim. 
- Optionally creates persistent volume claim (`builder-pvc`) for storing toolkits that are not part of base images, if the storage class value (builder.persistentStorageClassName) is specified. You can also create the persistent volume claim and specify the name in the following value: builder.persistentVolumeClaim.
- Creates a Kubernetes service (`build`) to provide external access to REST APIs.
- Optionally creates a service account (`build`) to provide access to Kubernetes APIs for creating builder pods unless an existing one is specified.
- Creates a configmap (`build`) that contains configuration information for the build service.
- Optionally creates the following role-based access control (RBAC) objects, if an existing service account with required RBAC bindings is not specified.:
        A role: `build`
        A role binding: `build`
- When the Helm release is deleted, runs a job as pre-delete (`stopbuild`) Helm hook to stop builder pods.
- When the Helm release is upgraded or rolled back, runs a job as post-upgrade and post-rollback (`upgrade-build`) Helm hook to restart builder pods.

## Prerequisites
If you prefer to install from the command prompt, you will need:
* The following commands installed: Kubernetes CLI (kubectl) and Helm CLI (helm).
* Your environment configured to connect to the target cluster.

The is a summary of the prerequisites to install the chart. 
### Required
* A Kubernetes cluster running version 1.11 or later, on systems that have x86-64 architecture. This may be installed with the underlying framework.
* Helm 2.9.1 or later - This may be installed with the underlying framework.
* A Kubernetes secret that contains the JAAS module plugin module. 
* A Kubernetes secret that contains the build service administrator and password. 
* Either allow the chart to dynamically create the persistent storage or create a persistent volume claim and specify it when installing (ssee Storage section below).
### Optional 
#### Docker pull secret
* Create a docker registry secret if one is required to pull images from the docker registry (see Create docker registry secret section below).  If you specify an existing service account, you can patch the docker pull secret in that service account. 
* Create a unique namespace for the Streams instance (see Create Namespace section below).
#### Optional customizations
* If using client certificate authentication, an administrator needs to setup Kubernetes secrets for keystore, truststore and passwords. The name of the secret(s) will be input to the Helm install. 
#### Service account and role based access control objects
This chart requires a service account and role-based access control objects and will generate the necessary objects and bindings. You can optionally specify an existing service account. If using an existing service account you must setup the required role-based access control objects. 
- The archive downloaded from passport advantage contains scripts and yaml files in the following root directory to setup the required files: StreamsInstallFiles/pak_extensions/preinstall/rbac. 
- The archive downloaded from passport advantage contains scripts and yaml files in the following root directory to cleanup the files (use after release is deleted): StreamsInstallFiles/pak_extensions/postinstall/rbac.

## Resources Required
The following table contains the minimum CPU, minimum memory and the default replica count for each of the Streams pods (see Resource settings table below). The number of builder pods depends on the number of builder pools configured. 

Pod                  | CPU/pod | Memory/pod | Replicas
-------------------- | ------- |----------- |---------
anaconda             |  1      | 500M       | 1 
spss                 |  1      | 500M       | 1 
build                |  1*     | 1Gi*       | 1
builder pool         |  1*     | 1Gi*       | Depends on number of builder pools

The settings marked with an asterisk (*) can be configured.

## PodSecurityPolicy Requirements
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you:

* Predefined PodSecurityPolicy name: [`ibm-anyuid-psp`](https://ibm.biz/cpkspec-psp)
* Custom PodSecurityPolicy definition:

```yaml
apiVersion: extensions/v1beta1 
kind: PodSecurityPolicy
metadata:
  name: ibm-streams-build-psp
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
  name: ibm-streams-build-sec-cr
rules:
- apiGroups:
  - extensions
  resourceNames:
  - ibm-streams-build-psp
  resources:
  - podsecuritypolicies
  verbs:
  - use
```

### Configuration scripts can be used to create the required resources

The archive downloaded from passport advantage contains scripts in the following root directory: StreamsInstallFiles/pak_extensions/preinstall/podPolicy.

* The pre-install instructions are located at `clusterAdministration/psp/createSecurityClusterPrereqs.sh` for cluster administrator to create the PodSecurityPolicy and ClusterRole for all releases of this chart.

* The namespace scoped instructions are located at `namespaceAdministration/createSecurityNamespacePrereqs.sh` for team administrator/operator to create the RoleBinding for the namespace. This script takes one argument; the name of a pre-existing namespace where the chart will be installed.
  * Example usage: `./createSecurityNamespacePrereqs.sh myNamespace`

### Configuration scripts can be used to clean up resources created

The archive downloaded from IBM Passport Advantage contains scripts in the following root directory: StreamsInstallFiles/pak_extensions/post-delete/psp.

* The namespace scoped instructions are located at `namespaceAdministration/deleteSecurityNamespacePrereqs.sh` for team administrator/operator to delete the RoleBinding for the namespace. This script takes one argument; the name of the namespace where the chart was installed.
  * Example usage: `./deleteSecurityNamespacePrereqs.sh myNamespace`
  
* The post-delete instructions are located at `clusterAdministration/psp/deleteSecurityClusterPrereqs.sh` for cluster administrator to delete the PodSecurityPolicy and ClusterRole for all releases of this chart.

## Red Hat OpenShift SecurityContextConstraints Requirements
This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined SecurityContextConstraints name: [`ibm-anyuid-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.

This chart defines a custom SecurityContextConstraints which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom SecurityContextConstraints resource using the supplied instructions/scripts in the pak_extension pre-install directory.

- From the user interface, you can copy and paste the following snippets to enable the custom SecurityContextConstraints
  - Custom SecurityContextConstraints definition:
  
```yaml
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: "This policy is the most restrictive, 
      requiring pods to run with a non-root UID, and preventing pods from accessing the host." 
    cloudpak.ibm.com/version: "1.0.0"
  name: ibm-streams-build-scc
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

* Custom ClusterRole for the custom PodSecurityPolicy:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ibm-streams-build-clusterrole
rules:
- apiGroups:
  - extensions
  resourceNames:
  - ibm-streams-build-scc
  resources:
  - podsecuritypolicies
  verbs:
  - use
```
### Configuration scripts can be used to create the required resources

The archive downloaded from passport advantage contains scripts in the following root directory: StreamsInstallFiles/pak_extensions/preinstall/podPolicy.

* The pre-install instructions are located at `clusterAdministration/scc/createSecurityClusterPrereqs.sh` for cluster administrator to create the PodSecurityPolicy and ClusterRole for all releases of this chart.

* The namespace scoped instructions are located at `namespaceAdministration/createSecurityNamespacePrereqs.sh` for team administrator/operator to create the RoleBinding for the namespace. This script takes one argument; the name of a pre-existing namespace where the chart will be installed.
  * Example usage: `./createSecurityNamespacePrereqs.sh myNamespace`

### Configuration scripts can be used to clean up resources created

The archive downloaded from IBM Passport Advantage contains scripts in the following root directory: StreamsInstallFiles/pak_extensions/post-delete.

* The namespace scoped instructions are located at `namespaceAdministration/deleteSecurityNamespacePrereqs.sh` for team administrator/operator to delete the RoleBinding for the namespace. This script takes one argument; the name of the namespace where the chart was installed.
  * Example usage: `./deleteSecurityNamespacePrereqs.sh myNamespace`
  
* The post-delete instructions are located at `clusterAdministration/scc/deleteSecurityClusterPrereqs.sh` for cluster administrator to delete the PodSecurityPolicy and ClusterRole for all releases of this chart.

## Installing the Chart
The following information is required for the installation:
* Ensure you have created a persistent volume claim name for the build service (see Storage section below) and have the name of the persistent volume claim.
* Ensure you have created the secret for your JAAS login module and have name of the secret. 
* Ensure you have created the secret with the user name and password for your build administrator.
* The namespace for installing the Streams build service.
* The docker registry pull secret if one is required.

### Create Namespace
You can optionally create a namespace dedicated for use by the build service. Run the following command to create a namespace. You will specify this namespace when installing the chart. You can set the namespace in your kube context to avoid having to specify it with every command. In this example, my namespace is mystreams, replace this name with the name of your choosing:
```bash
kubectl create namespace mystreams
```
### Create a docker registry pull secret
You may need a image pull secret to pull docker images from the docker registry. If you specify a service account, patch the service account with the pull secret. If you don't specify a service account, you will specify the pull secret name when installing streams. If you are using the Helm CLI to install the chart set the following value: image.pullSecret.
Here is an example of creating a docker pull secret, replace the values for the parameters for your environment:
```bash
kubectl create secret docker-registry myregistrykey --docker-server=mycluster:8500 --docker-username=myadmin  --docker-password=myadmin --docker-email myemail@mydomain.com
```
To verify your secret is created in your namespace, run this command:
```bash
kubectl get secret
```
### Install the build service
You must have the Cluster administrator access level to install the chart. You can install using the Helm CLI. 

The Configuration section below identifies the required and optional configuration, you will need for the installation. 

If you are installing using the Helm CLI, you should use a values override file to specify your values. Using a values override file provides you a repeatable configuration option. The Configuration section below has an example of a values override file.

Install the chart, specifying the release name, the chart, and a values override file. A Streams build service will be created with the same name as the Helm release. When the installation completes, the Streams build service will be created and started.   

For example, enter the following command to create a Streams build service named my-release. This example assumes the internal Helm repository called local-charts contains the chart and the valuesoverride.yaml file was setup with all the required values.
```bash
$ helm install --name my-release local-charts/ibm-streams-instance --values valuesoverride.yaml --tls
```

### Verifying the Chart
See chart notes for instructions on verifying the chart.

### Uninstalling the Chart
When you uninstall this chart you are stopping and removing the Streams build service. This will stop all the builder resources associated with build service. Any data written to the persistent storage by the build services will be removed. 

The helm delete will only remove Kubernetes objects created by the installation. Any Kubernetes objects created outside of the Helm release, such as persistent volumes, persistent volume claims, and secrets, will not be removed. You can remove these Kubernetes objects if you are not using these objects for other build services or you do not plan on installing another build service.

For example, to stop and remove the Streams build service called my-release, run the following command:
```bash
$ helm delete my-release --purge --tls
```
### Cleanup any pre-requirements that were created

Cleanup scripts are included in the archive downloaded from Passport Advantage in the the following directory: ibm-streams-build/ibm_cloud_pak/pak_extensions/post-delete; run them to cleanup namespace and cluster scoped resources when appropriate.

## Configuration
The following tables list the configurable parameters of the ibm-streams-build chart and their default values. 

If you are using the Helm CLI to install the chart, create a values override file and specify the file on the helm install. For an example override file see:  ibm-streams-build/ibm_cloud_pak/pak_extensions/samples/valuesoverride-example.yaml.

> **Tip**: You can use the following command to see all the values in the values.yaml. 
```bash
helm inspect values local-chart/ibm-streams-build
```

[comment]: # (PLACEHOLDER for generated Configuration, must be blank line before this so this does not show up in README)
### General settings
| Parameter | Description | Required | Default |
| ---  | --- | --- | --- |
| `debug` | `Specifies if debug is enabled for the helm install. Kubernetes jobs will be left on the system to aid in debug if set to true.` | false | `false` |
| `license` | `Specifies if you read the license agreement and agree to the terms. Set the license value to 'accept'.` | true | `not accepted` |
### Build service settings
| Parameter | Description | Required | Default |
| ---  | --- | --- | --- |
| `build.buildInactivityTimeout` | `Specifies the default build inactivity timeout in minutes.` | false | `15` |
| `build.cpu` | `Specifies the minimum required amount of CPU core resources for the build service. Must be less than or equal to build.cpuLimit.` | true | `1` |
| `build.cpuLimit` | `Specifies the upper limit of CPU core resource for the build service.` | true | `2` |
| `build.installAnaconda` | `Specifies to install anaconda on builder.streamsExtPvc. Valid values are: true, false.` | false | `true` |
| `build.installSpss` | `Specifies to install spps on builder.streamsExtPvc. Valid values are: true, false.` | false | `true` |
| `build.memory` | `Specifies the minimum required amount of memory for the build service. Must be less than or equal to build.memoryLimit.` | true | `1Gi` |
| `build.memoryLimit` | `Specifies the upper limit for memory in bytes for the build service.` | true | `2Gi` |
| `build.persistentStorageClassName` | `Specifies a storage class name to dynamically provision the storage for build related data. If you specify an existing persistent volume claim this value is ignored. You must specify this or build.persistentVolumeClaim.` | false |  |
| `build.persistentVolumeClaim` | `Specifies an existing persistent volume claim for storing build related data. You must specify this or build.persistentStorageClassName.` | false |  |
| `build.persistentVolumeClaimSize` | `Specifies a size to dynamically provision the storage for build related data. If you specify an existing persistent volume claim this value is ignored.` | false | `5Gi` |
| `build.poolResourceWaitTimeout` | `Specifies the time in minutes to wait for a builder resource.` | false | `2` |
| `build.poolSizeMaximum` | `Specifies the maximum number of builder resources.` | false | `5` |
| `build.poolSizeMinimum` | `Specifies the minimum number of builder resources.` | false | `1` |
| `build.securitySecret` | `Specifies the secret containing keystore and truststore files, passwords, and alias for the build service.` | false |  |
| `build.serviceAccount` | `Specifies the service account used for build pod. If specified, it must be granted permissions for required Kubernetes objects.  If not specified, one will be created with necessary role based access control objects.` | false |  |
| `build.serviceExternalIPs` | `Specifies an array of external ip addresses for the Kubernetes service exposing the build service.` | false |  |
| `build.serviceNodePort` | `Specifies a node port value for the Kubernetes service exposing the build service.` | false |  |
| `build.serviceType` | `Specifies the type for the Kubernetes service exposing the build service. Valid values are: ClusterIP, NodePort, LoadBalancer.` | true | `ClusterIP` |
| `build.sslOption` | `Specifies the default cryptographic protocol for the build service. Valid values are: SSL_TLS, SSL_TLSv2, TLSv1, TLSv1.1, TLSv1.2, none.` | false | `TLSv1.2` |
| `build.traceFileCount` | `Specifies the maximum number of files to save for the build service.` | false | `3` |
| `build.traceFileSize` | `Specifies the maximum size, in kilobytes, for each trace file.` | false | `5000` |
| `build.traceLevel` | `Specifies the default trace level to use for debugging problems with the build service. Valid values are: off, error, warn, info, debug, trace.` | false | `error` |
### Builder settings
| Parameter | Description | Required | Default |
| ---  | --- | --- | --- |
| `builder.buildProcessingTimeout` | `Specifies the default build processing timeout in minutes.` | false | `15` |
| `builder.buildProductVersion` | `Specifies the Streams product version to use for builds if not explicitly specified.` | false |  |
| `builder.cpu` | `Specifies the minimum required amount of CPU core resources for builder resources. Must be less than or equal to builder.cpuLimit.` | true | `1` |
| `builder.cpuLimit` | `Specifies the upper limit of CPU core resource for the builder resources.` | true | `10` |
| `builder.memory` | `Specifies the minimum required amount of memory for builder resources. Must be less than or equal to builder.memoryLimit.` | true | `1Gi` |
| `builder.memoryLimit` | `Specifies the upper limit for memory in bytes for the builder resources.` | true | `10Gi` |
| `builder.persistentStorageClassName` | `Specifies a storage class name to dynamically provision the storage for storing toolkits that are not part of base images. If you specify an existing persistent volume claim this value is ignored.` | false |  |
| `builder.persistentVolumeClaim` | `Specifies an existing persistent volume claim for storing toolkits that are not part of base images.` | false |  |
| `builder.persistentVolumeClaimSize` | `Specifies a size to dynamically provision the storage for toolkits that are not part of base images. If you specify an existing persistent volume claim this value is ignored.` | false | `5Gi` |
| `builder.serviceAccount` | `Specifies the service account used for builder pod. If specified, it must be granted permissions for required Kubernetes objects.  If not specified, one will be created with necessary role based access control objects.` | false |  |
| `builder.streamsExtPvc` | `Specifies the persistent volume claim to be initialized with external libraries (i.e. anaconda).` | false |  |
| `builder.streamsExtPvcStorageClass` | `Specifies the storage class used to create the persistent volume claim that will be initialized with external libraries (i.e. anaconda). Do not set this property if you wish to specify an existing persistent volume claim.` | false |  |
### Images settings
| Parameter | Description | Required | Default |
| ---  | --- | --- | --- |
| `image.anaconda` | `Specifies the image to configure for initializing the external libraries persistent volume claim with anaconda libraries.` | true | `streams-anaconda-install-el7` |
| `image.anacondaTag` | `Specifies the tag portion of the anaconda image name.` | true | `5.2.0.0` |
| `image.build` | `Specifies the image to configure for the build service.` | true | `streams-build-el7` |
| `image.buildTag` | `Specifies the tag portion of the build service image.` | true | `5.2.0.0` |
| `image.builder` | `Specifies the image to configure for the builder resources.` | true | `streams-build-compile-el7` |
| `image.builderTag` | `Specifies the tag portion of the builder image name.` | true | `5.2.0.0` |
| `image.prefix` | `Specifies the repository for the docker images. If specified, this value will be pre-appended to the image names.` | false |  |
| `image.pullPolicy` | `Specifies the policy used to pull images from docker registry. Valid values are: Always, IfNotPresent.` | false | `Always` |
| `image.pullSecrets` | `Specifies the secret used to pull images from docker registry.` | false |  |
| `image.spss` | `Specifies the image to configure for initializing the external libraries persistent volume claim with spss libraries.` | true | `streams-spss-install-el7` |
| `image.spssTag` | `Specifies the tag portion of the spss image name.` | true | `5.2.0.0` |
### Security settings
| Parameter | Description | Required | Default |
| ---  | --- | --- | --- |
| `security.ssoRealm` | `Specifies the IBM Streams single sign-on security realm.` | true |  |
| `security.ssoUrl` | `Specifies the URL of the IBM Streams single sign-on service. Format is https://<sso-release>-sso.<sso-namespace>:8446.` | true |  |

[comment]: # (END OF PLACEHOLDER for generated Configuration, must be blank line before this so this does not show up in README)

## Storage
### Build persistent volume 
Persistent storage is required for the build service for storing build related data. You can use any persistent storage for the volume, it must be writable by the following runAsUser and fsGroup: 1000320900. A user with Cluster Administrator access level will need to create the persistent volume. 

You will need to create a persistent volume claim or let the chart dynamically create it for you by specifying a build.persistentStorageClassName. If you create the persistent volume claim, set the name in the following value for the Helm install: build.persistentVolumeClaim. You can use the same persistent volume for multiple Streams build services. A separate directory will be created in the cache for each build service.

For an example if your environment allows for it, you could use NFS for your persistent storage. Here are example yamls for using NFS for the persistent volume and persistent volume claim. 
The template uses NFS volumes by specifying the NFS server IP address and NFS mount path for each volume. If you are using a different storage type, replace the nfs: sections. The storage sizes in the template are the minimum requirement for these volumes:
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: build-service-pv
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
  name: build-service-pvc
  labels:
    app.kubernetes.io/name: ibm-streams-build
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 2G
  # Bind to a specific persistent volume.
  volumeName: "build-service-pv"
```
### External libraries persistent 
You will need a persistent volume for installing the external libraries that are not part of the build service image (i.e. Anaconda).  You will need to specify the name for the persistent volume claim (`builder.streamsExtPvc`) or the storage class (`builder.streamsExtPvcStorageClass`). The chart will create the persistent volume claim and populate the volume with the external libraries. Populating the persistent volume with the external libraries can take several minutes. 

You can also choose to manage the external libraries yourself by populating the persistent volume prior to creating the chart. You may want to do this if you will reuse the same external libraries for multiple instances of the build service. To do this you will have to create the persistent volume claim and populate the volume prior to installing the chart. When you install the chart you will specify the existing persistent volume claim name (`builder.streamsExtPvc`). 

Note: If you let the chart install the external libraries, do not use the same persistent volume claim name for multiple releases.
You cannot use the same persistent volume claim for the build.persistentVolumeClaim and builder.streamsExtPvc.

## Limitations
* The chart must be deployed by a Cluster administrator.
* Platforms supported: Linux x86_64.

## Documentation
For more information about IBM Streams, see [Extending IBM Cloud Pak for Data with streaming analytics](https://www.ibm.com/support/knowledgecenter/SSQNUZ_current/com.ibm.icpdata.doc/streams/intro.html) 
