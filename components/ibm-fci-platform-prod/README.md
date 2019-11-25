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
- A WEX server using a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) to crawling and indesxing data stores
- An ODM server as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- A Mongodb instance using a [StatefulSet](http://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/)
- A case manager as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) to manage financial crime cases
- A Common Entity Data Model as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) to manage entities used throughout the solution
- An Investigative User Interface as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) to provide end users with a user interface to manage cases
- A Graph component as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) to support graph analytics
- An audit server using a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) to support auditing user actions
- An authentication server using a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) to support authentication of end users through LDAP, SAML, IBM App ID, or internal registry.

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

The predefined `SecurityContextConstraints` name: `restricted` has been verified for most of the components of this chart.

[`restricted`](https://ibm.biz/cpkspec-scc) SecurityContextConstraints definition:
```
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegeEscalation: true
allowPrivilegedContainer: false
allowedCapabilities: null
apiVersion: security.openshift.io/v1
defaultAddCapabilities: null
fsGroup:
  type: MustRunAs
groups:
- system:authenticated
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: restricted denies access to all host features and requires
      pods to be run with a UID, and SELinux context that are allocated to the namespace.  This
      is the most restrictive SCC and it is used by default for authenticated users.
  name: restricted
priority: null
readOnlyRootFilesystem: false
requiredDropCapabilities:
- KILL
- MKNOD
- SETUID
- SETGID
runAsUser:
  type: MustRunAsRange
seLinuxContext:
  type: MustRunAs
supplementalGroups:
  type: RunAsAny
users: []
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
```

The following components of this chart require the predefined `SecurityContextConstraints` name: `anyuid`
* Cognos
* WCA
* RMS Streams

[`anyuid`](https://ibm.biz/cpkspec-scc) SecurityContextConstraints definition:
```
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegeEscalation: true
allowPrivilegedContainer: false
allowedCapabilities: null
apiVersion: security.openshift.io/v1
defaultAddCapabilities: null
fsGroup:
  type: RunAsAny
groups:
- system:cluster-admins
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: anyuid provides all features of the restricted SCC
      but allows users to run with any UID and any GID.
  name: anyuid
priority: 10
readOnlyRootFilesystem: false
requiredDropCapabilities:
- MKNOD
runAsUser:
  type: RunAsAny
seLinuxContext:
  type: MustRunAs
supplementalGroups:
  type: RunAsAny
users: []
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
```

The following components of this chart require the predefined `SecurityContextConstraints` name: `privileged`
* DB2
* MQ
* Kafka

[`privileged`](https://ibm.biz/cpkspec-scc) SecurityContextConstraints definition:
```
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
apiVersion: security.openshift.io/v1
defaultAddCapabilities: null
fsGroup:
  type: RunAsAny
groups:
- system:cluster-admins
- system:nodes
- system:masters
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: 'privileged allows access to all privileged and host
      features and the ability to run as any user, any group, any fsGroup, and with
      any SELinux context.  WARNING: this is the most relaxed SCC and should be used
      only for cluster administration. Grant with caution.'
  name: privileged
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
users:
- system:admin
- system:serviceaccount:openshift-infra:build-controller
- system:serviceaccount:openshift-node:sync
- system:serviceaccount:openshift-sdn:sdn
- system:serviceaccount:management-infra:management-admin
- system:serviceaccount:management-infra:inspector-admin
volumes:
- '*'

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
