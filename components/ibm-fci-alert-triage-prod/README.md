
#Financial Crimes Insight for Alert Triage Software

Enable analysts to quickly assess alerts using Watson analytics and cognitive capabilities to determine which alerts warrant further investigation.

## Introduction
This chart deploys Financial Crimes Insight for Alert Triage Software. For more information about IBM Financial Crimes Insight, see the [IBM Financial Crimes Insight product documentation](https://www.ibm.com/support/knowledgecenter/SSCKRH).

## Chart Details
This Helm chart will install the following:

- A Alerts Review component as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- A TLS Analytics component as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- A TLS UI component as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

- Alert Triage Transaction Monitoring Performance Charts [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

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

The predefined `SecurityContextConstraints` name: `restricted` has been verified for the components of this chart.

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

## Resources Required
For information about the resource requirements of the IBM Financial Crimes Insight for Alert Triage Software, see the [IBM Financial Crime Insight product documentation](https://www.ibm.com/support/knowledgecenter/SSCKRH).

Persistence is enabled by default. You can find more information about storage requirements below.

## Installing the Chart

These are the steps to install IBM Financial Crimes Insight for Alert Triage Software in your environment:

- Create persistent volumes (optional)
- Install IBM Financial Crime Insight
- Install IBM Financial Crimes Insight for Alert Triage Software

### Create Persistent Volumes

Persistence is enabled by default.  One Physical volume is required for IBM Financial Crime Insight for Alert Triage Software on top of the requirements for IBM Financial Crime Insight base.

To create physical volumes, you must have the Cluster Administrator role.

You can find more information about storage requirements below.

### Install IBM Financial Crime Insight for Alert Triage Software

See the [IBM Financial Crime Insight product documentation](https://www.ibm.com/support/knowledgecenter/SSCKRH) for information on installing the IBM Financial Crime Insight chart.

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


## Storage
Depending on the component you enable during the installation of IBM Financial Crimes Insight for Alert Triage Software, you may need one Physical Volume. You either need to create a
[persistent volume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#static) for the Financial Crimes Insight for Alert Triage Software component, or specify a
storage class that supports [dynamic provisioning](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#dynamic). Different storage classes can be used to control how physical volumes are allocated.

If these persistent volumes are to be created manually, this must be done by the system administrator who will add these to a central pool before the Helm chart can be installed. The installation will then claim the required number of persistent volumes from this pool. For manual creation, 'dynamic provisioning' must be disabled in the Helm chart when it is installed. It is up to the administrator to provide appropriate storage to back these physical volumes.

If these persistent volumes are to be created automatically at the time of installation, the system administrator must enable support for this prior to installing the Helm chart. For automatic creation 'dynamic provisioning' should be enabled in the Helm chart when it is installed and storage class names provided to define which types of Persistent Volume get allocated to the deployment.

More information about persistent volumes and the system administration steps required can be found in the [Kubernetes documentation](https://kubernetes.io/docs/concepts/storage/persistent-volumes/).

## Limitations
- Linux on Power (ppc64le) is not supported.
- Mixed worker node architecture deployments are not supported.

## Documentation

Find out more about [IBM Financial Crimes Insight](https://www.ibm.com/support/knowledgecenter/SSCKRH).
