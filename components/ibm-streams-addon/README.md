# IBM Streams service
![](https://raw.githubusercontent.com/IBM/charts/master/logo/ibm-streams-logo-readme.png?sanitize=true)
## Introduction
This chart deploys the IBM Streams service on Cloud Pak for Data. You can develop and run applications that process in-flight data with the IBM Streams service. IBM Streams
enables continuous and fast analysis of massive volumes of moving data to help improve the speed of business insight and decision making.

The IBM Streams service enables developers to work with in-flight data in analytics projects.
You can use the service to:

- Build and deploy streaming applications by using notebooks. For more information, see Developing applications with IBM Streams.
- Connect to multiple streaming data sources, such as IBM Event Streams, HTTP, and IoT.
- Deliver data and insights to data stores within the IBM Cloud Pak for Data platform and to remote data stores, such as Db2® Warehouse and IBM Event Streams.
- Elastically scale Streams applications to accommodate variable workloads.

## Chart Details
This chart does the following. 
- Uses Helm hooks run a job (`notebook-job`) to install streamsx for developing python applications. 
- Creates a configmap (`meta-configmap`) that contains the configuration for the service.
- Creates a configmap (`service-configmap`) that contains the configuration for the service service provider.
- Deploys a deployment object (`streams-addon`) for the service content pod. This is the main pod for the service and contains a web service to serve up the services web user interface.
- Deploys a deployment object (`streams-addon-service-provider`) for the service service provider pod. The service provider orchestrates the instances of the service.
- Creates a service (`streams-addon`) for internally accessing the service configuration. 
- Creates a service (`streams-addon-service-provider`) for monitoring the instances of the service.
- Creates a persistent volume claim (`streams-addon-service-provider-pvc`) for storing configuration for the instances of the service.

## Prerequisites
For information on prerequisites see [Preparing to install and provision the Streams service](https://www.ibm.com/support/knowledgecenter/SSQNUZ_3.0.1/cpd/svc/streams/prereqs.html)

This service does not install a PodDisruptionBudget.

## Resources Required
For information on resources required see [Preparing to install and provision the Streams service] (https://www.ibm.com/support/knowledgecenter/SSQNUZ_3.0.1/cpd/svc/streams/prereqs.html)

## PodSecurityPolicy Requirements
Custom PodSecurityPolicy definition: 
```
none
```

## SecurityContextConstraints Requirements
This chart requires the same SecurityContentConstraints that are set up when Cloud Pak for Data is installed. Specifically it uses the following policy: cpd-user-scc

Custom SecurityContextConstraints definition: 
```
apiVersion: security.openshift.io/v1
metadata:
  annotations: {}
  name: cpd-user-scc
kind: SecurityContextConstraints
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegeEscalation: true
allowPrivilegedContainer: false
allowedCapabilities: null
defaultAddCapabilities: null
fsGroup:
  type: RunAsAny
groups: []
priority: null
readOnlyRootFilesystem: false
requiredDropCapabilities:
- KILL
- MKNOD
- SETUID
- SETGID
runAsUser:
  type: MustRunAsRange
  uidRangeMin: 1000320900
  uidRangeMax: 1000361000
seLinuxContext:
  type: MustRunAs
supplementalGroups:
  type: RunAsAny
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
```

## Installing the Chart
This chart is to be installed via Cloud Pak for Data cpd utility.

For information on installing the Streams service see [Installing Streams] (https://www.ibm.com/support/knowledgecenter/SSQNUZ_3.0.1/cpd/svc/streams/install-intro.html)

### Uninstalling the Chart
For information on uninstalling the Streams service see [Uninstalling Streams] (https://www.ibm.com/support/knowledgecenter/SSQNUZ_3.0.1/cpd/svc/streams/uninstall-addon.html)

## Configuration

### Global settings
| Parameter | Description | Required | Default |
| ---  | --- | --- | --- |
| `global.cloudpakInstanceId` | `Specifies the IBM Cloud Pak for Data instance identifier. Do not set, this is set by the installation program.` | true ||
| `global.dockerPullPolicy` | `Specifies the policy used to pull images from docker registry. Valid values are: Always, IfNotPresent.` | false | `Always` |
| `global.dockerPullSecrets` | `Specifies the secret used to pull images from docker registry.` | false |  |
| `global.dockerRegistryPrefix` | `Specifies the Docker repository for the image, this will be pre-appended to the each image.` | true |  
| `global.serviceAccount` | `Specifies the service account for the Streams addon pods` | true | "" |
| `global.storageClassName` | `Specifies if the name of the storage class. You must specify this value or all existing volume claim values. If you specify existing persistent volume claims this value is ignored.` | false | "" |

### service content pod settings
| Parameter | Description | Required | Default |
| ---  | --- | --- | --- |
| `addOn.image.repository` | `Specifies the name of the addon Docker image.` | true | streams-addon |
| `addOn.image.tag` | `Specifies the name of the addon Docker image tag.` | true | 5.5.0.0|
| `addOn.resources.limit.cpu` | `Specifies the CPU limits for the addon content pod.` | true | `250m` |
| `addOn.resources.limit.memory` | `Specifies the memory limits for the addon content pod.` | true | `1Gi` |
| `addOn.resources.request.cpu` | `Specifies the CPU request for the addon content pod.` | true | `250m` |
| `addOn.resources.request.memory` | `Specifies the memory request for the addon content pod.` | true | `1Gi` |

### Service provider pod settings
| Parameter | Description | Required | Default |
| ---  | --- | --- | --- |
| `serviceProvider.image.repository` | `Specifies the name of the service provider Docker image.` | true | streams-service-provider |
| `serviceProvider.image.tag` | `Specifies the name of the service provider Docker image tag.` | true | 5.3.2.0 |
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
| `notebookTemplate.image.tag` | `Specifies the name of the notebook template Docker image tag.` | true | 5.3.2.0 |
| `notebookTemplate.resources.limit.cpu` | `Specifies the CPU limits for the notebook template pod.` | true | `250m` |
| `notebookTemplate.resources.limit.memory` | `Specifies the memory limits for the notebook template pod.` | true | `1Gi` |
| `notebookTemplate.resources.request.cpu` | `Specifies the CPU request for the notebook template pod.` | true | `250m` |
| `notebookTemplate.resources.request.memory` | `Specifies the memory request for the notebook template pod.` | true | `1Gi` 
| `notebookTemplate.startupSleep` | `Specifies to sleep the pre-install hook job. Only used for debugging.` | false |  |


## Storage
### Service provider configuration storage
Persistent storage is required for the service provider configuration. You can use any persistent storage for the volume, it must be writable by the following runAsUser and runAsGroup: 1000320900. A user with Cluster Administrator access level will need to create the persistent volume. 
The chart will create the persistent volume claim; or you can specify an existing persistent volume claim.

## Limitations
* Platforms supported: Linux x86_64.
* Only one instance of this chart can be installed per namespace.

## Documentation
For more information about IBM Streams, see [IBM Streams service on Cloud Pak for Data](https://www.ibm.com/support/knowledgecenter/SSQNUZ_3.0.1/svc-welcome/streams.html) 
