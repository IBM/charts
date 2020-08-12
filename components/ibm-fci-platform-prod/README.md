# IBM Financial Crimes Insight
IBM Financial Crimes Insight enables financial institutions to leverage analytics and cognitive capabilities to combat financial crime.

## Introduction
This chart deploys IBM Financial Crimes Insight. For more information about IBM Financial Crimes Insight, see the [IBM Financial Crimes Insight product documentation](https://www.ibm.com/support/knowledgecenter/SSCKRH).


## Chart Details
This Helm chart will install the following:

- A DB2 instance using a [StatefulSet](http://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/)
- A Kafka and Zookeeper ensemble using a [StatefulSet](http://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/) with 3 replicas
- An Elasticsearch instance using a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- A Cognos server using a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) to support analytic dashboards
- A WEX server using a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) to crawling and indexing data stores
- An ODM server as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- A Mongodb instance using a [StatefulSet](http://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/)
- A case manager as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) to manage financial crime cases
- A Common Entity Data Model as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) to manage entities used throughout the solution
- An Investigative User Interface as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) to provide end users with a user interface to manage cases
- A Graph component as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) to support graph analytics
- An audit server using a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) to support auditing user actions
- An authentication server using a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) to support authentication of end users through LDAP, SAML, IBM App ID, or internal registry.
- An Analytics Runtime component as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) to leverage the Cloud Pak for Data services for FCI.

## Prerequisites
To install using the command line, ensure you have the following:

- The `kubectl` and `helm` commands available
- Your environment configured to connect to the target cluster
See the [IBM Financial Crimes Insight product documentation](https://www.ibm.com/support/knowledgecenter/SSCKRH) for details on setting up an environment to install this chart.

The installation environment has the following prerequisites:

- Kubernetes 1.11.0 or later
- PersistentVolume support in the underlying infrastructure (See "Create Persistent Volumes" below)

### Red Hat OpenShift SecurityContextConstraints Requirements
The IBM Financial Crimes Insight installer for Red Hat OpenShift Container Platform creates the appropriate SecurityContextConstraint bound to the target namespace prior to installation.


The SCCs used by different components of the IBM Financial Crimes Insight platform are elaborated below.


Containers other than the exceptions listed further down below use the most restricted SCC we have

Restricted SCC Name - `fci-restricted`

```
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: 'This policy is the most restricted context for FCI.  It is based upon the OpenShift restricted SCC'
  name: fci-restricted
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegedContainer: false
allowPrivilegeEscalation: false
allowedCapabilities: []
allowedFlexVolumes: null
allowedUnsafeSysctls: null
defaultAddCapabilities: []
defaultAllowPrivilegeEscalation: false
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
# This can be customized for seLinuxOptions specific to your host machine
seLinuxContext:
  type: RunAsAny
# seLinuxOptions:
#   level:
#   user:
#   role:
#   type:
supplementalGroups:
  type: MustRunAs
  ranges:
  - max: 65535
    min: 1
# This can be customized to host specifics
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
priority: 0
```

Component: `Cognos`
SCC Name: `fci-cognos`

SecurityContextConstraints definition:

```
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: 'This policy is a permissive context for FCI, allowing Cognos containers to run as root as required.'
  name: fci-cognos
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegedContainer: true
allowPrivilegeEscalation: true
allowedCapabilities: []
allowedFlexVolumes: null
allowedUnsafeSysctls: null
defaultAddCapabilities: []
defaultAllowPrivilegeEscalation: false
forbiddenSysctls:
  - "*"
fsGroup:
  type: RunAsAny
readOnlyRootFilesystem: false
runAsUser:
  type: RunAsAny
seccompProfiles:
- docker/default
# This can be customized for seLinuxOptions specific to your host machine
seLinuxContext:
  type: RunAsAny
# seLinuxOptions:
#   level:
#   user:
#   role:
#   type:
supplementalGroups:
  type: RunAsAny
# This can be customized to host specifics
volumes:
- persistentVolumeClaim
- secret
- emptyDir
priority: 10
```

Component: db2
SCC: `fci-db2`

```
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: 'This policy is a permissive context for FCI, allowing DB2 containers to configure kernel parameters and run as root as required.'
  name: fci-db2
allowHostDirVolumePlugin: true
allowHostIPC: true
allowHostNetwork: true
allowHostPID: true
allowHostPorts: true
allowPrivilegeEscalation: true
allowPrivilegedContainer: true
allowedCapabilities:
- '*'
allowedUnsafeSysctls:
- '*'
defaultAddCapabilities: null
fsGroup:
  type: RunAsAny
priority: null
readOnlyRootFilesystem: false
requiredDropCapabilities: null
runAsUser:
  type: RunAsAny
seLinuxContext:
  type: RunAsAny
seccompProfiles:
- '*'
supplementalGroups:
  type: RunAsAny
volumes:
- '*'
```


Component: Elasticsearch
SCC: `fci-elasticsearch`

```
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: 'This policy is a permissive context for FCI, allowing elasticsearch containers to run as root as required.'
  name: fci-elasticsearch
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegedContainer: true
allowPrivilegeEscalation: true
allowedCapabilities:
- CHOWN
allowedFlexVolumes: null
allowedUnsafeSysctls: null
defaultAddCapabilities: []
defaultAllowPrivilegeEscalation: false
forbiddenSysctls:
  - "*"
fsGroup:
  type: RunAsAny
readOnlyRootFilesystem: false
requiredDropCapabilities: []
runAsUser:
  type: RunAsAny
seccompProfiles:
- docker/default
# This can be customized for seLinuxOptions specific to your host machine
seLinuxContext:
  type: RunAsAny
# seLinuxOptions:
#   level:
#   user:
#   role:
#   type:
supplementalGroups:
  type: RunAsAny
# This can be customized to host specifics
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
priority: 0
```

Component: Kafka
SCC: `fci-kafka`

```
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: 'This security context is used for pods that run kakfa.  It provides the ability to run as a specified user as well as chmod/chown files on the persistent volume.'
  name: fci-kafka
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegedContainer: false
allowPrivilegeEscalation: true
allowedCapabilities:
- FOWNER
- CHOWN
allowedFlexVolumes: null
allowedUnsafeSysctls: null
defaultAddCapabilities: []
defaultAllowPrivilegeEscalation: true
forbiddenSysctls:
  - "*"
fsGroup:
  type: RunAsAny
readOnlyRootFilesystem: false
requiredDropCapabilities: []
runAsUser:
  type: RunAsAny
seccompProfiles:
- docker/default
# This can be customized for seLinuxOptions specific to your host machine
seLinuxContext:
  type: RunAsAny
# seLinuxOptions:
#   level:
#   user:
#   role:
#   type:
supplementalGroups:
  type: RunAsAny
# This can be customized to host specifics
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
priority: 0
```

Component: Mongodb
SCC: `fci-mongodb`

```
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: 'This policy is used by mongodb pods.  It has the capability to run as any user (mongodb runs as "mongodb" user) and chown the files on the persistent volume to match.'
  name: fci-mongodb
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegedContainer: true
allowPrivilegeEscalation: true
allowedCapabilities:
- "CHOWN"
allowedFlexVolumes: null
allowedUnsafeSysctls: null
defaultAddCapabilities: []
defaultAllowPrivilegeEscalation: true
forbiddenSysctls:
  - "*"
fsGroup:
  type: RunAsAny
readOnlyRootFilesystem: false
runAsUser:
  type: RunAsAny
seccompProfiles:
- docker/default
# This can be customized for seLinuxOptions specific to your host machine
seLinuxContext:
  type: RunAsAny
# seLinuxOptions:
#   level:
#   user:
#   role:
#   type:
supplementalGroups:
  type: RunAsAny
# This can be customized to host specifics
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
priority: 0
```

Component: MQ
SCC: `fci-mq`

```
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: 'This policy is a permissive context for FCI, allowing MQ containers to configure kernel parameters and run as mqm as required.'
  name: fci-mq
allowHostDirVolumePlugin: false
allowHostIPC: true
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegedContainer: true
allowPrivilegeEscalation: true
allowedCapabilities:
- CHOWN
- DAC_OVERRIDE
- FOWNER
- IPC_OWNER
allowedFlexVolumes: null
allowedUnsafeSysctls: null
defaultAddCapabilities: []
defaultAllowPrivilegeEscalation: false
forbiddenSysctls:
  - "*"
fsGroup:
  type: RunAsAny
readOnlyRootFilesystem: false
requiredDropCapabilities:
- MKNOD
runAsUser:
  type: RunAsAny
seccompProfiles:
- docker/default
# This can be customized for seLinuxOptions specific to your host machine
seLinuxContext:
  type: RunAsAny
# seLinuxOptions:
#   level:
#   user:
#   role:
#   type:
supplementalGroups:
  type: RunAsAny
# This can be customized to host specifics
volumes:
- persistentVolumeClaim
- secret
- emptyDir
priority: 0
```

Component: WCA
SCC: `fci-wca`

```
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: 'This policy is a permissive context for FCI, allowing WCA containers to run as name user as required.'
  name: fci-wca
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegedContainer: true
allowPrivilegeEscalation: true
allowedCapabilities: []
allowedFlexVolumes: null
allowedUnsafeSysctls: null
defaultAddCapabilities: []
defaultAllowPrivilegeEscalation: false
forbiddenSysctls:
  - "*"
fsGroup:
  type: RunAsAny
readOnlyRootFilesystem: false
runAsUser:
  type: RunAsAny
seccompProfiles:
- docker/default
# This can be customized for seLinuxOptions specific to your host machine
seLinuxContext:
  type: RunAsAny
# seLinuxOptions:
#   level:
#   user:
#   role:
#   type:
supplementalGroups:
  type: RunAsAny
# This can be customized to host specifics
volumes:
- persistentVolumeClaim
- secret
- emptyDir
priority: 0
```

For containers that wait for other containers to come up -
SCC Name: fci-kube-api
Containers: Mongodb Init Job

```
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: 'This policy is designed for containers that wait for other containers to start by testing if the required services have endpoints available.  A small subsite of kubernetes API calls are permitted.'
  name: fci-kube-api
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegedContainer: false
allowPrivilegeEscalation: false
allowedCapabilities: []
allowedFlexVolumes: null
allowedUnsafeSysctls: null
defaultAddCapabilities: []
defaultAllowPrivilegeEscalation: false
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
# This can be customized for seLinuxOptions specific to your host machine
seLinuxContext:
  type: RunAsAny
# seLinuxOptions:
#   level:
#   user:
#   role:
#   type:
supplementalGroups:
  type: MustRunAs
  ranges:
  - max: 65535
    min: 1
# This can be customized to host specifics
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
priority: 0
```

The following policy allows containers to run as root to chown files on a persistent volume.  It also has a role binding applied to allow it to make queries to the kubernetes api server to allow containers to wait for services to become available before they start.

SCC Name: `fci-kube-api-chown`
Containers that use this: `Common-ui-nginx`

```
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: 'This policy allows containers to run as root to chown files on a persistent volume.  It also has a role binding applied to allow it to make queries to the kubernetes api server to allow containers to wait for services to become available before they start.'
  name: fci-kube-api-chown
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegedContainer: true
allowPrivilegeEscalation: true
allowedCapabilities:
- CHOWN
allowedFlexVolumes: null
allowedUnsafeSysctls: null
defaultAddCapabilities: []
defaultAllowPrivilegeEscalation: false
forbiddenSysctls:
  - "*"
fsGroup:
  type: RunAsAny
readOnlyRootFilesystem: false
runAsUser:
  type: RunAsAny
seccompProfiles:
- docker/default
# This can be customized for seLinuxOptions specific to your host machine
seLinuxContext:
  type: RunAsAny
# seLinuxOptions:
#   level:
#   user:
#   role:
#   type:
supplementalGroups:
  type: RunAsAny
# This can be customized to host specifics
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
priority: 0
```


The following policy provides pods with FOWNER capabilties primarily to chmod files to fix the mount volume permissions and the ability to run as any user.  It also has a role binding applied to allow it to make queries to the kubernetes api server to allow containers to wait for services to become available before they start.

Note that if the mount points have correct permissions already, the SCC can be overridden by a flag in our values file (`pvRequiresPermissionsFix` set to false) and the pods will use the default restricted SCC instead.

SCC Name - `fci-kube-api-fowner`
Contianers that use this SCC - Case-manager fci-solution, graph-writer liberty, Gremlin, cedm integration liberty.

```
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: 'This policy provides pods with FOWNER capabilties primarily to chmod files and the ability to run as any user.  It also has a role binding applied to allow it to make queries to the kubernetes api server to allow containers to wait for services to become available before they start.'
  name: fci-kube-api-fowner
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegedContainer: false
allowPrivilegeEscalation: false
allowedCapabilities:
- FOWNER
allowedFlexVolumes: null
allowedUnsafeSysctls: null
defaultAddCapabilities: []
defaultAllowPrivilegeEscalation: false
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
  type: RunAsAny
seccompProfiles:
- docker/default
# This can be customized for seLinuxOptions specific to your host machine
seLinuxContext:
  type: RunAsAny
# seLinuxOptions:
#   level:
#   user:
#   role:
#   type:
supplementalGroups:
  type: MustRunAs
  ranges:
  - max: 65535
# This can be customized to host specifics
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
priority: 0
```




## Resources Required
For information about the resource requirements of the IBM Financial Crime Insight Helm chart, including total values and the requirements for each pod and their containers, see the [IBM Financial Crime Insight product documentation](https://www.ibm.com/support/knowledgecenter/SSCKRH).

Persistence is enabled by default. You can find more information about storage requirements below.


## Installing the Chart

These are the steps to install IBM Financial Crimes Insight in your environment:

- Create persistent volumes (optional)
- Install IBM Financial Crime Insight

### Create Persistent Volumes

Persistence is enabled by default.  Physical volumes are required for IBM Financial Crime Insight.

To create physical volumes, you must have the Cluster Administrator role.

You can find more information about storage requirements below.


### Install IBM Financial Crime Insight

See the [IBM Financial Crime Insight product documentation](https://www.ibm.com/support/knowledgecenter/SSCKRH) for information on installing the IBM Financial Crime Insight chart.

### Verifying the Chart

See the NOTES.txt file associated with this chart for verification instructions.

### Uninstalling the Chart

To uninstall IBM Financial Crimes Insight:

```
helm delete <release_name> --purge --tls
```

This command removes all the Kubernetes components associated with the chart, except any persistent volume claims (PVCs). This is the default behavior of Kubernetes, and ensures that valuable data is not deleted. In order to delete the IBM Financial Crimes Insight data, you can delete the PVC using the following command:

```
kubectl delete pvc -l release=<release_name>
```
WARNING: This will remove any existing data from the underlying physical volumes.

## Configuration

The following table lists some of the configurable parameters of the `ibm-fci-platform-prod` chart and their default values.  See the [IBM Financial Crimes Insight product documentation](https://www.ibm.com/support/knowledgecenter/SSCKRH) for more details on the configurable parameters.

### Security authentication settings
| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
| `global.IDENTITY_SERVER_TYPE`             | Type of Identity Server                   | `msad`                                                        |
| `global.LDAP_SERVER_HOST`             | Host name of Identity Server                   | `<hostname>`                                                        |
| `global.LDAP_SERVER_PORT`             | Port of Identity Server                   | `636`                                                        |
| `global.LDAP_SERVER_SSL`             | SSL enabled on Identity Server                   | `True`                                                        |
| `global.LDAP_SERVER_BINDDN`             | Bind dn of LDAP server                   | `administrator`                                                        |
| `global.LDAP_SERVER_SEARCHBASE`             | Base dn of LDAP Server                   | `cn=users,dc=aml,dc=ibm,dc=com`                                                        |
| `global.LDAP_PROFILE_DISPLAYNAME`             | Dispaly name attribute                   | `displayName`                                                        |
| `global.LDAP_PROFILE_EMAIL`             | Email attribute                   | `userPrincipalName`                                                        |
| `global.LDAP_PROFILE_GROUPS`             | Groups attribute                   | `memberOf`                                                        |
| `global.LDAP_PROFILE_ID`             | Id attribute                   | `sAMAccountName`                                                        |
| `global.LDAP_PROFILE_TENANTS`             | Tenants attribute                   | `fciTenants`                                                        |
| `global.LDAP_SERVER_USERNAME_MAPPING`             | Attribute to map to user id                   | `sAMAccountName`                                                        |

## Storage
Several physical volumes are required in order to install this chart. The number of physical volumes depends on your setup. For default requirements, see the [resource requirements table](#resources-required). You either need to create a
[persistent volume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#static) for each Financial Crimes Insight component, or specify a
storage class that supports [dynamic provisioning](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#dynamic). Different storage classes can be used to control how physical volumes are allocated.

If these persistent volumes are to be created manually, this must be done by the system administrator who will add these to a central pool before the Helm chart can be installed. The installation will then claim the required number of persistent volumes from this pool. For manual creation, 'dynamic provisioning' must be disabled in the Helm chart when it is installed. It is up to the administrator to provide appropriate storage to back these physical volumes.

If these persistent volumes are to be created automatically at the time of installation, the system administrator must enable support for this prior to installing the Helm chart. For automatic creation 'dynamic provisioning' should be enabled in the Helm chart when it is installed and storage class names provided to define which types of Persistent Volume get allocated to the deployment.

More information about persistent volumes and the system administration steps required can be found in the [Kubernetes documentation](https://kubernetes.io/docs/concepts/storage/persistent-volumes/).

## Limitations
- Linux on Power (ppc64le) is not supported.
- Mixed worker node architecture deployments are not supported.

## Documentation

Find out more about [IBM Financial Crimes Insight](https://www.ibm.com/support/knowledgecenter/SSCKRH).
