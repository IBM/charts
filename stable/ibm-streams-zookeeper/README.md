# ZooKeeper (IBM Streams)

## Introduction
[Zookeeper](https://zookeeper.apache.org/) is an open source Apache project that provides centralized 
infrastructure and services that enable synchronization across a distributed cluster.  It is one of the required 
components of IBM Streams runtime.

This chart bootstraps a one resource ZooKeeper deployment for a non-production environment specifically for IBM Streams 
via the [Helm](https://helm.sh) package manager.  It is intent to use as our "Embedded" ZooKeeper in a development
environment. It requires the streams-zookeeper-el7 docker image and that contains Apache ZooKeeper version 3.4.13. 

## Prerequisites

- Kubernetes cluster running version 1.11 or later
- Helm 2.9.1 or later 
- Kubernetes CLI (kubectl) 1.11 or later
- Persistent Volume provisioner support in the underlying infrastructure

## Chart Details
The chart does the following tasks:
- Deploys a Kubernetes StatefulSet (`zookeeper`). There is only one embedded ZooKeeper pod.
- Creates a Kubernetes service (`zookeeper`).
- Creates a Kubernetes headless service (`zookeeper-hs`).
- Creates the following role-based access control objects:
    Role: `zookeeper-role`
    Role binding: `zookeeper-rb`
- When the Helm release is deleted, runs a job as a pre-delete (`rmpvc`) Helm hook to remove the persistent volume claim that was created as part of the StatefulSet.

## Resources Required
The following table contains the minimum CPUs, minimum memory and the default replica count for Embedded ZooKeeper(for development environment):

Pod                  | CPU/pod | Memory/pod | Replicas
-------------------- | ------- |----------- |---------
ZooKeeper            |  1*     | 2G*        | 1*

The settings marked with an asterisk (*) can be configured.

Please refer to the [documentation](#Documentation) below for guidance and recommendations for setting up 
an external ZooKeeper for production environment.  

## PodSecurityPolicy Requirements
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you:

* Predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp)
* Custom PodSecurityPolicy definition:

```yaml
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  name: ibm-streams-zookeeper-psp
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

* Custom ClusterRole for the custom PodSecurityPolicy:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ibm-streams-zookeeper-clusterrole
rules:
- apiGroups:
  - extensions
  resourceNames:
  - ibm-streams-zookeeper-psp
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

The archive downloaded from passport advantage contains scripts in the following root directory: StreamsInstallFiles/pak_extensions/post-delete/podPolicy.

* The namespace scoped instructions are located at `namespaceAdministration/deleteSecurityNamespacePrereqs.sh` for team administrator/operator to delete the RoleBinding for the namespace. This script takes one argument; the name of the namespace where the chart was installed.
  * Example usage: `./deleteSecurityNamespacePrereqs.sh myNamespace`
  
* The post-delete instructions are located at `clusterAdministration/psp/deleteSecurityClusterPrereqs.sh` for cluster administrator to delete the PodSecurityPolicy and ClusterRole for all releases of this chart.

## Red Hat OpenShift SecurityContextConstraints Requirements
This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined SecurityContextConstraints name: [`ibm-restricted-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.

This chart also defines a custom SecurityContextConstraints which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom SecurityContextConstraints resource using the supplied instructions/scripts in the pak_extension pre-install directory.

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
  name: ibm-streams-zookeeper-scc
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
priority: 0
```

* Custom ClusterRole for the custom PodSecurityPolicy:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ibm-streams-zookeeper-clusterrole
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
#### Configuration scripts can be used to create the required resources

The archive downloaded from passport advantage contains scripts in the following root directory: StreamsInstallFiles/pak_extensions/preinstall/podPolicy.

* The pre-install instructions are located at `clusterAdministration/scc/createSecurityClusterPrereqs.sh` for cluster administrator to create the PodSecurityPolicy and ClusterRole for all releases of this chart.

* The namespace scoped instructions are located at `namespaceAdministration/createSecurityNamespacePrereqs.sh` for team administrator/operator to create the RoleBinding for the namespace. This script takes one argument; the name of a pre-existing namespace where the chart will be installed.
  * Example usage: `./createSecurityNamespacePrereqs.sh myNamespace`

#### Configuration scripts can be used to clean up resources created

The archive downloaded from IBM Passport Advantage contains scripts in the following root directory: StreamsInstallFiles/pak_extensions/post-delete/podPolicy.

* The namespace scoped instructions are located at `namespaceAdministration/deleteSecurityNamespacePrereqs.sh` for team administrator/operator to delete the RoleBinding for the namespace. This script takes one argument; the name of the namespace where the chart was installed.
  * Example usage: `./deleteSecurityNamespacePrereqs.sh myNamespace`
  
* The post-delete instructions are located at `clusterAdministration/scc/deleteSecurityClusterPrereqs.sh` for cluster administrator to delete the PodSecurityPolicy and ClusterRole for all releases of this chart.



## Installing the Chart

The following information is required for the installation:
 * Ensure a PV storage class is defined when persistence.enabled is set to true
 * The docker registry pull secret if one is required. 

### Create Namespace
You can optionally create a namespace dedicated for use by ZooKeeper. Run the following command to create a namespace. You will specify this namespace when installing the chart. You can set the namespace in your kube context to avoid having to specify it with every command. In this example, my namespace is mystreams, replace this name with the name of your choosing:
```console
$ kubectl create namespace mystreams
```
### Create a docker registry pull secret
You may need an image pull secret to pull docker images from the docker registry. If the ZooKeeper docker images are scoped to a namespace, a pull secret is required. You will create the image pull secret in your namespace. You will specify the pull secret name when installing ZooKeeper. If you are using the Helm CLI to install the chart set the following value: image.pullSecrets.
Here is an example of creating a docker pull secret, replace the values for the parameters for your environment:
```console
$ kubectl create secret docker-registry myregistrykey --docker-server=mycluster.icp:8500 --docker-username=myadmin  --docker-password=myadmin --docker-email myemail@mydomain.com
```
To verify your secret is created in your namespace, run this command:
```console
$ kubectl get secret
```

To install this helm chart with the default configurations. e.g.:

```console
$ helm install --name my-release ibm-streams-zookeeper --tls
```

To install this helm chart with the override configuration specified in a file called values-override.yaml, e.g.:

```console
$ helm install --name my-release ibm-streams-zookeeper --values values-override.yaml --tls
```

To install this helm chart with individual configuration override, e.g.:

```console
$ helm install --name my-release ibm-streams-zookeeper --set image.prefix="mycluster.icp:8500/zen" --set image.pullSecrets="myregistrykey" --set persistence.enabled=false --tls
```

Please refer to the [Configuration](#Configuration) section for the chart's parameters and their default values.


## Uninstalling the Chart

To uninstall this helm chart:
```console
$ helm delete my-release --purge --tls
```
The chart starts a helm pre-delete job to remove the persistent volume claim created for storing configuration data. 
If this job does not remove the persistent volume claim you can remove it using the following command:
```console
$ kubeclt delete pvc data-my-release-zookeeper-0
```

### Cleanup any pre-requirement that were created

Cleanup scripts are included in the archive downloaded from passport advantage in the the following directory: StreamsInstallFiles/pak_extensions/prereqs; run them to cleanup namespace and cluster scoped resources when appropriate.

## Configuration

The following table lists the configurable parameters of the Zookeeper chart and their respective default values:


[comment]: # (PLACEHOLDER for generated Configuration, must be blank line before this so this does not show up in README)
### General settings
| Parameter | Description | Required | Default |
| ---  | --- | --- | --- |
| `license` | `Specifies if you read the license agreement and agree to the terms. Set the license value to 'accept'.` | true | `not accepted` |
| `affinityRules` | `Specifies additional affinity rules by which pod label-values influence scheduling for the zookeeper pod. By default zookeeper pod will only run on x86_64 resources.` | false |  |
| `debug` | `Specifies if want to debug the delete helm hooks.` | false | `false` |
| `initLimit` | `Specifies the number of ticks that a member of the ZooKeeper ensemble is allowed to perform leader election.` | false | `15` |
| `jvmFlags` | `Specifies the default JVMFLAGS for the ZooKeeper server (if specified, the computed JVM heap size is ignored). For example: -verbose:gc -Xmx3g -Xms1g.` | false | `` |
| `logLevel` | `Specifies the log level for ZooKeeper logger. Valid values are: FATAL, ERROR, WARN, INFO, DEBUG, TRACE.` | false | `INFO` |
| `maxClientCnxns` | `Specifies the number of concurrent connections that a client may make to a single ZooKeeper member. Specify the value 0 for no limit.` | false | `0` |
| `maxSessionTimeout` | `Specifies the maximum session timeout in milliseconds(ms) that the server will allow the client to negotiate (20 * tickTime).` | false | `40000` |
| `minSessionTimeout` | `Specifies the minimum session timeout in milliseconds(ms) that the server will allow the client to negotiate. (2 * tickTime).` | false | `4000` |
| `nodeSelector` | `Specifies the node labels for pod assignment.` | false |  |
| `podLabels` | `Specifies key/value pairs labels that are attached to zookeeper pods.` | false |  |
| `podManagementPolicy` | `Specifies the policy to use when launching and terminating pods.` | false | `Parallel` |
| `purgeInterval` | `Specifies the time interval in hours for which the purge task has to be triggered. Specify 0 to disable.` | false | `1` |
| `replicaCount` | `Specifies the number of ZooKeeper nodes.` | false | `1` |
| `serviceAccount` | `Specifies the service account. If specified, it must be granted permissions for required Kubernetes objects.  If not specified, one will be created with necessary role based access control objects.` | false |  |
| `snapRetainCount` | `Specifies the number of snapshots that the ZooKeeper server will retain.` | false | `5` |
| `syncLimit` | `Specifies the number of ticks by which a follower may lag behind the ZooKeeper ensemble leader.` | false | `10` |
| `tickTime` | `Specifies the basic time unit in milliseconds(ms) used for heartbeats and timeouts.` | false | `2000` |
| `tolerations` | `Specifies the toleration labels for pod assignment.` | false |  |
### Images settings
| Parameter | Description | Required | Default |
| ---  | --- | --- | --- |
| `image.prefix` | `Specifies the repository for the docker images. If specified, this value will be pre-appended to the image names.` | false |  |
| `image.pullPolicy` | `Specifies the policy used to pull images from docker registry. Valid values are: Always, IfNotPresent.` | false | `Always` |
| `image.pullSecrets` | `Specifies the secret used to pull images from docker registry.` | false |  |
| `image.repository` | `Specifies the image to configure for the ZooKeeper.` | true | `streams-zookeeper-el7` |
| `image.tag` | `Specifies the tag portion of the ZooKeeper image.` | true | `5.1.0.2` |
### Persistence settings
| Parameter | Description | Required | Default |
| ---  | --- | --- | --- |
| `persistence.enabled` | `Specifies if dynamic persistence is enabled.` | false | `false` |
| `persistence.storageClass` | `Specifies the storage class for the persistent volume claim. If persistence.enabled is true, and no storage class name is specified, uses default class.` | false |  |
| `persistence.accessMode` | `Specifies the access mode for the persistent volume claim.` | false | `ReadWriteOnce` |
| `persistence.size` | `Specifies the size for the persistent volume claim.` | false | `10Gi` |
### Resources settings
| Parameter | Description | Required | Default |
| ---  | --- | --- | --- |
| `resources.cpu` | `Specifies the minimum required amount of CPU core resources for ZooKeeper Must be less than or equal to resources.cpuLimit.` | true | `1` |
| `resources.cpuLimit` | `Specifies the upper limit of CPU core resource for ZooKeeper.` | true | `1` |
| `resources.memory` | `Specifies the minimum required amount of memory for ZooKeeper. Must be less than or equal to resources.memoryLimit.` | true | `2Gi` |
| `resources.memoryLimit` | `Specifies the upper limit for memory in bytes for ZooKeeper.` | true | `2Gi` |
### Service settings
| Parameter | Description | Required | Default |
| ---  | --- | --- | --- |
| `service.type` | `Specifies the type of Kubernetes service to create for exposing ZooKeeper.` | false | `ClusterIP` |
| `service.electionPort` | `Specifies the election port value for the ZooKeeper service.` | false | `3888` |
| `service.port` | `Specifies the port value for the ZooKeeper service.` | false | `2181` |
| `service.serverPort` | `Specifies the server port value for the ZooKeeper service.` | false | `2888` |
| `service.annotations` | `Specifies arbitrary non-identifying metadata for ZooKeeper service.` | false |  |
| `service.protocol` | `Specifies the protocol for the ZooKeeper service.` | false | `TCP` |
### Update strategy settings
| Parameter | Description | Required | Default |
| ---  | --- | --- | --- |
| `updateStrategy.type` | `Specifies the update stratgey for ZooKeeper.` | false | `RollingUpdate` |

[comment]: # (END OF PLACEHOLDER for generated Configuration, must be blank line before this so this does not show up in README)

## Limitations
* The chart must be deployed by an Cluster administrator.
* Platforms supported: Linux x86_64.

## Documentation
* For more information about Apache ZooKeeper administration, please refer to its [administration page](https://zookeeper.apache.org/doc/r3.4.13/zookeeperAdmin.html).
* For more information about ZooKeeper Setup and Configuration for Streams, please refer to this [IBM Developer page](https://developer.ibm.com/streamsdev/docs/zookeeper-setup-configuration-streams/)
