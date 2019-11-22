<!-- begin_generated_IBM_copyright_prolog                             -->
<!--                                                                  -->
<!-- This is an automatically generated copyright prolog.             -->
<!-- After initializing,  DO NOT MODIFY OR MOVE                       -->
<!-- **************************************************************** -->
<!-- Licensed Materials - Property of IBM                             -->
<!-- 5724-Y95                                                         -->
<!-- (C) Copyright IBM Corp.  2019, 2019    All Rights Reserved.      -->
<!-- US Government Users Restricted Rights - Use, duplication or      -->
<!-- disclosure restricted by GSA ADP Schedule Contract with          -->
<!-- IBM Corp.                                                        -->
<!--                                                                  -->
<!-- end_generated_IBM_copyright_prolog                               -->
# IBM Streams add-on
![](https://raw.githubusercontent.com/IBM/charts/master/logo/ibm-streams-logo-readme.png?sanitize=true)
## Introduction
This chart deploys the IBM Cloud Pak for Data Streams add-on. You can develop and run applications that process in-flight data with the IBM Streams add-on. IBM Streams
enables continuous and fast analysis of massive volumes of moving data to help improve the speed of business insight and decision making.

The IBM Streams add-on enables developers to work with in-flight data in analytics projects.
You can use the add-on to:

- Build and deploy streaming applications by using notebooks. For more information, see Developing applications with IBM Streams.
- Connect to multiple streaming data sources, such as IBM Event Streams, HTTP, and IoT.
- Deliver data and insights to data stores within the IBM Cloud Private for Data platform and to remote data stores, such as Db2® Warehouse and IBM Event Streams.
- Elastically scale Streams applications to accommodate variable workloads.

## Chart Details
This chart does the following. 
- Uses Helm hooks run a job (`notebook-job`) to install streamsx for developing python applications. 
- Creates a configmap (`meta-configmap`) that contains the configuration for the add-on.
- Creates a configmap (`service-configmap`) that contains the configuration for the add-on service provider.
- Deploys a deployment object (`streams-addon`) for the add-on content pod. This is the main pod for the add-on and contains a web service to serve up the add-ons web user interface.
- Deploys a deployment object (`streams-addon-service-provider`) for the add-on service provider pod. The service provider orchestrates the instances of the add-on.
- Creates a service (`streams-addon`) for internally accessing the add-on configuration. 
- Creates a service (`streams-addon-service-provider`) for monitoring the instances of the add-on.
- Creates a persistent volume claim (`streams-addon-service-provider-pvc`) for storing configuration for the instances of the add-on.

## Prerequisites
If you prefer to install from the command prompt, you will need:
* The following commands installed: Kubernetes CLI (kubectl) and Helm CLI (helm).
* Your environment configured to connect to the target cluster.
* This chart requires persistent storage for the service provider configuration. You will either need a storage class to dynamically provision the persistent volume claim or a name of an existing persistent volume claim.
* The namespace for installing the add-on.
* The docker registry pull secret if one is required.
For a complete list of the prerequisites to install the add-on chart see the following topic: [Preparing to deploy and provision and IBM Streams add-on instance](https://www.ibm.com/support/knowledgecenter/SSQNUZ_current/com.ibm.icpdata.doc/streams/prereqs.html).

## Resources Required
The following table contains the minimum CPU, minimum memory and the default replica count for each the main Streams add-on pods (see Resource settings table below). 
For details on resources for an instance of the add-on see the following topic: [Preparing to deploy and provision and IBM Streams add-on instance](https://www.ibm.com/support/knowledgecenter/SSQNUZ_current/com.ibm.icpdata.doc/streams/prereqs.html).


Pod                    | CPU/pod | Memory/pod | Replicas
-----------------------| ------- |----------- |---------
streams-addon          |  250m   | 1Gi*       | 1
streams-addon-service-provider |  250m   | 1Gi*       | 1

The settings marked with an asterisk (*) can be configured.

## PodSecurityPolicy Requirements
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you:

* Predefined PodSecurityPolicy name: [`ibm-anyuid-psp`](https://ibm.biz/cpkspec-psp)
* Custom PodSecurityPolicy definition:

```yaml
apiVersion: extensions/v1beta1 
kind: PodSecurityPolicy
metadata:
  name: ibm-streams-addon-psp
spec:
  allowPrivilegeEscalation: false
  forbiddenSysctls:
  - '*'
  fsGroup:
    rule: RunAsAny
  requiredDropCapabilities:
  - ALL
  runAsUser:
    rule: MustRunRoot
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
```

* Custom ClusterRole for the custom PodSecurityPolicy:

```yaml
apiVersion: rbac.authorization.k8s.io/v1 
kind: ClusterRole
metadata:
  name: ibm-streams-addon-cr
rules:
- apiGroups:
  - extensions
  resourceNames:
  - ibm-streams-addon-psp
  resources:
  - podsecuritypolicies
  verbs:
  - use
```

### Configuration scripts can be used to create the required resources

The archive downloaded from passport advantage contains scripts in the following root directory: StreamsInstallFiles/pak_extensions/pre-install/podpolicy.

* The pre-install instructions are located at `clusterAdministration/psp/createSecurityClusterPrereqs.sh` for cluster administrator to create the PodSecurityPolicy and ClusterRole for all releases of this chart.

* The namespace scoped instructions are located at `namespaceAdministration/createSecurityNamespacePrereqs.sh` for team administrator/operator to create the RoleBinding for the namespace. This script takes one argument; the name of a pre-existing namespace where the chart will be installed.
  * Example usage: `./createSecurityNamespacePrereqs.sh myNamespace`

### Configuration scripts can be used to clean up resources created

The archive downloaded from passport advantage contains scripts in the following root directory: StreamsInstallFiles/pak_extensions/post-delete.

* The namespace scoped instructions are located at `namespaceAdministration/deleteSecurityNamespacePrereqs.sh` for team administrator/operator to delete the RoleBinding for the namespace. This script takes one argument; the name of the namespace where the chart was installed.
  * Example usage: `./deleteSecurityNamespacePrereqs.sh myNamespace`
  
* The post-delete instructions are located at `clusterAdministration/psp/deleteSecurityClusterPrereqs.sh` for cluster administrator to delete the PodSecurityPolicy and ClusterRole for all releases of this chart.

## Red Hat OpenShift SecurityContextConstraints Requirements
This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined SecurityContextConstraints name: [`ibm-anyuid-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.

This chart also defines a custom SecurityContextConstraints which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom SecurityContextConstraints resource using the supplied instructions/scripts in the pak_extension pre-install directory.

- From the user interface, you can copy and paste the following snippets to enable the custom SecurityContextConstraints
  - Custom SecurityContextConstraints definition:
```yaml
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: "This policy allows pods to run with 
      any UID and GID, but preventing access to the host."
    cloudpak.ibm.com/version: "1.0.0"
  name: ibm-streams-addon-scc
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegedContainer: false
allowPrivilegeEscalation: true
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
allowedFlexVolumes: []
allowedUnsafeSysctls: []
defaultAddCapabilities: []
defaultPrivilegeEscalation: true
forbiddenSysctls:
  - "*"
fsGroup:
  type: RunAsAny
readOnlyRootFilesystem: false
requiredDropCapabilities:
- MKNOD
runAsUser:
  type: RunAsAny
seLinuxContext:
  type: RunAsAny
supplementalGroups:
  type: RunAsAny
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
users: []
priority: 0
```
* Custom ClusterRole for the custom SecurityContextConstraints:

```yaml
apiVersion: rbac.authorization.k8s.io/v1 
kind: ClusterRole
metadata:
  name: ibm-streams-addon-cr
rules:
- apiGroups:
  - extensions
  resourceNames:
  - ibm-streams-addon-psp
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

### Create Namespace
You can optionally create a namespace for use by the add-on. Run the following command to create a namespace. You will specify this namespace when installing the chart. You can set the namespace in your kube context to avoid having to specify it with every command. In this example, my namespace is mystreams, replace this name with the name of your choosing:
```bash
kubectl create namespace mystreams
```
### Create a docker registry pull secret
You may need a image pull secret to pull docker images from the docker registry. If the Streams docker images are scoped to a namespace, a pull secret is required. You will create the image pull secret in your namespace. You will specify the pull secret name when installing streams. If you are using the Helm CLI to install the chart set the following value: global.dockerPullSecrets.
Here is an example of creating a docker pull secret, replace the values for the parameters for your environment:
```bash
kubectl create secret docker-registry myregistrykey --docker-server=mycluster.icp:8500 --docker-username=myadmin  --docker-password=myadmin --docker-email myemail@mydomain.com
```
To verify your secret is created in your namespace, run this command:
```bash
kubectl get secret
```
### Install IBM Streams add-on
When you install IBM Streams you will be creating and starting a Streams instance. You can install using the Helm CLI. 

The Configuration section below identifies the required and optional configuration, you will need for the installation. 

If you are installing using the Helm CLI, you should use a values override file to specify your values. Using a values override file provides you a repeatable configuration option. The Configuration section below has an example of a values override file.

Install the chart, specifying the release name, the chart, and a values override file. The Streams add-on will be created with the same name as the Helm release. When the installation completes, you will be able to provision instances of the add-on.   

For example, enter the following command to install the Streams add-on streams-addon. This example assumes the internal Helm repository called local-charts contains the chart and the valuesoverride.yaml file was setup with all the required values.
```bash
$ helm install --name streams-addon local-charts/streams-addon --values valuesoverride.yaml --tls
```

### Verifying the Chart
See chart notes for instructions on verifying the chart.

### Uninstalling the Chart
Before uninstalling the chart you must first remove all the instances of the add-on using the IBM Cloud Pak for Data console.

The helm delete will only remove Kubernetes objects created by the installation. Any Kubernetes objects created outside of the Helm release, such as persistent volumes, and persistent volume claims will not be removed. You can remove these Kubernetes 
objects if you are not using these objects if you do not plan on re-installing Streams add-on.

For example, to stop and remove the Streams add-on called streams-addon, run the following command:
```bash
$ helm delete streams-addon --purge --tls
```
### Cleanup any pre-requirement that were created

Cleanup scripts are included in the archive downloaded from passport advantage in the the following directory: StreamsInstallFiles/pak_extensions/post-delete; run them to cleanup namespace and cluster scoped resources when appropriate.

## Configuration
The following tables list the configurable parameters of the ibm-streams-instance chart and their default values. 

If you are using the Helm CLI to install the chart, create a values override file and specify the file on the helm install. For example, to specify the required values you would create a file called valuesoverride.yaml with the following content. Replace the actual values with the information for your environment.
```yaml

global:
  image:
    prefix: mycluster.icp:8500/zen
    pullSecrets:  myregistrykey
serviceProvider:
  persistence:
    useDynamicProvisioning: true
    storageClassName: oketi-gluster
````
> **Tip**: You can use the following command to see all the values in the values.yaml. 
```bash
helm inspect values local-chart/streams-addon
```

[comment]: # (PLACEHOLDER for generated Configuration, must be blank line before this so this does not show up in README)
### Global settings
| Parameter | Description | Required | Default |
| ---  | --- | --- | --- |
| `global.dockerRegistryPrefix` | `Specifies the Docker repository for the image, this will be pre-appended to the each image.` | true |  
| `global.dockerPullPolicy` | `Specifies the policy used to pull images from docker registry. Valid values are: Always, IfNotPresent.` | false | `Always` |
| `global.dockerPullSecrets` | `Specifies the secret used to pull images from docker registry.` | false |  |
| `global.serviceAccount` | `Specifies the service account for the Streams addon pods` | true | "" |
| `global.storageClassName` | `Specifies if the name of the storage class. You must specify this value or all existing volume claim values. If you specify existing persistent volume claims this value is ignored.` | false | "" |

### Add-on content pod settings
| Parameter | Description | Required | Default |
| ---  | --- | --- | --- |
| `addOn.image.repository` | `Specifies the name of the addon Docker image.` | true | streams-addon |
| `addOn.image.tag` | `Specifies the name of the addon Docker image tag.` | true | 5.2.0.0 |
| `addOn.resources.limit.cpu` | `Specifies the CPU limits for the addon content pod.` | true | `250m` |
| `addOn.resources.limit.memory` | `Specifies the memory limits for the addon content pod.` | true | `1Gi` |
| `addOn.resources.request.cpu` | `Specifies the CPU request for the addon content pod.` | true | `250m` |
| `addOn.resources.request.memory` | `Specifies the memory request for the addon content pod.` | true | `1Gi` |

### Service provider pod settings
| Parameter | Description | Required | Default |
| ---  | --- | --- | --- |
| `serviceProvider.image.repository` | `Specifies the name of the service provider Docker image.` | true | streams-service-provider |
| `serviceProvider.image.tag` | `Specifies the name of the service provider Docker image tag.` | true | 5.2.0.0 |
| `serviceProvider.resources.limit.cpu` | `Specifies the CPU limits for the service provider pod.` | true | `250m` |
| `serviceProvider.resources.limit.memory` | `Specifies the memory limits for the service provider pod.` | true | `2Gi` |
| `serviceProvider.resources.request.cpu` | `Specifies the CPU request for the service provider pod.` | true | `250m` |
| `serviceProvider.resources.request.memory` | `Specifies the memory request for the service provider pod.` | true | `1Gi` |
| `serviceProvider.persistence.existingClaimName` | `Specifies an existing claim name. If this is specified global.storageClassName and all other persistence values are ignored.` | false | ""  |
| `serviceProvider.persistence.size` | `Specifies the the size to request for the persistent volume claim. This is only used if global.storageClassName is specified` | false | `100Mi`  |

### Notebook job pod settings
| Parameter | Description | Required | Default |
| ---  | --- | --- | --- |
| `notebookTemplate.image.repository` | `Specifies the name of the notebook template Docker image.` | true | streams-notebook-template |
| `notebookTemplate.image.tag` | `Specifies the name of the notebook template Docker image tag.` | true | 5.2.0.0 |
| `notebookTemplate.resources.limit.cpu` | `Specifies the CPU limits for the notebook template pod.` | true | `250m` |
| `notebookTemplate.resources.limit.memory` | `Specifies the memory limits for the notebook template pod.` | true | `1Gi` |
| `notebookTemplate.resources.request.cpu` | `Specifies the CPU request for the notebook template pod.` | true | `250m` |
| `notebookTemplate.resources.request.memory` | `Specifies the memory request for the notebook template pod.` | true | `1Gi` 
| `notebookTemplate.startupSleep` | `Specifies to sleep the pre-install hook job. Only used for debugging.` | false |  |
| `notebookTemplate.resolveName` | `Specifies the resolve name to use. Do not edit.` | true | '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' |

[comment]: # (END OF PLACEHOLDER for generated Configuration, must be blank line before this so this does not show up in README)

## Storage
### Service provider configuration storage
Persistent storage is required for the service provider configuration. You can use any persistent storage for the volume, it must be writable by the following runAsUser and fsGroup: 1000320900. A user with Cluster Administrator access level will need to create the persistent volume. 
You can specify for the chart to create the persistent volume claim; or specify an existing persistent volume claim.

## Limitations
* Platforms supported: Linux x86_64.
* Only one instance of this chart can be installed per namespace.

## Documentation
For more information about IBM Streams, see [IBM Streams add-on in the IBM Cloud Pak for Data](https://www.ibm.com/support/knowledgecenter/SSQNUZ_current/com.ibm.icpdata.doc/streams/intro.html) 
