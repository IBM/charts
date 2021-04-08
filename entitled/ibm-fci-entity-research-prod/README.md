
# IBM Financial Crimes Entity Research with Watson Software

IBM® Financial Entity Research with Watson® streamlines due diligence processes, enabling financial institutions to improve the customer experience while the increasing accuracy of results. Due Diligence reduces the time required to gather information by pre-populating customer details and automating much of the screening process. The solution uses cognitive accelerators to uncover previously unknown risks in business relationships, delivering a comprehensive and effective approach to Know Your Customer (KYC) compliance – all powered by Watson.

## Introduction
This chart deploys Financial Entity Research Software. For more information about IBM Financial Crimes Insight, see the [IBM Financial Crimes Insight product documentation](https://www.ibm.com/support/knowledgecenter/SSCKRH_6.6.0/fcdd/kc_welcome.html).

## Chart Details
This Helm chart will install the following:

- A Entity Research Liberty component as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- A Entity Research Dossier component as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- A Entity Research WCA component as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- A Entity Research WEX component as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- A Entity Research Royalty component as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- A Entity Research Record component as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- A Entity Research GraphQL API component as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- A Entity Research DSF component as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- A Entity Research Investigation component as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- A Entity Research Adaptor component as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- A Entity Research (Entity Enrichment) Enricher component as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- A Entity Research (Entity Enrichment) Engine component as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- A Entity Research (Entity Enrichment) UI component as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)


## Prerequisites
To install using the command line, ensure you have the following:

- The `kubectl` and `helm` commands available
- Your environment configured to connect to the target cluster
See the [IBM Financial Crimes Insight product documentation](https://www.ibm.com/support/knowledgecenter/SSCKRH) for details on setting up an environment to install this chart.

The installation environment has the following prerequisites:

- Kubernetes 1.18.0 or later
- PersistentVolume support in the underlying infrastructure (See "Create Persistent Volumes" below)

### Red Hat OpenShift SecurityContextConstraints Requirements

### SecurityContextConstraints Requirements

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
For information about the resource requirements of the IBM Financial Crimes Insight for Entity Research Software, see the [IBM Financial Crime Insight product documentation](https://www.ibm.com/support/knowledgecenter/SSCKRH_6.6.0/fcdd/c_fcdd_system_requirements.html).

Persistence is enabled by default. You can find more information about storage requirements below.

## Installing the Chart

These are the steps to install IBM Financial Crimes Insight for Entity Research Software in your environment:

- Create persistent volumes (optional)
- Install IBM Financial Crime Insight
- Install IBM Financial Crimes Insight for Entity Research Software

### Create Persistent Volumes

Persistence is enabled by default.  One Physical volume is required for IBM Financial Crime Insight for Entity Research Software on top of the requirements for IBM Financial Crime Insight base.

To create physical volumes, you must have the Cluster Administrator role.

You can find more information about storage requirements below.

### Install IBM Financial Crime Insight for Entity Research Software

See the [IBM Financial Crime Insight product documentation](https://www.ibm.com/support/knowledgecenter/SSCKRH_6.6.0/fcdd/t_install_fcdd.html) for information on installing the IBM Financial Crime Insight chart.

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

See the [IBM Financial Crime Insight product documentation](https://www.ibm.com/support/knowledgecenter/SSCKRH_6.6.0/fcdd/t_install_overview.html)for more details on the configurable parameters.


## Storage
Depending on the component you enable during the installation of IBM Financial Crimes Insight for Entity Research Software, you may need one Physical Volume. You either need to create a
[persistent volume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#static) for the Financial Crimes Insight for Alert Triage Software component, or specify a
storage class that supports [dynamic provisioning](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#dynamic). Different storage classes can be used to control how physical volumes are allocated.

If these persistent volumes are to be created manually, this must be done by the system administrator who will add these to a central pool before the Helm chart can be installed. The installation will then claim the required number of persistent volumes from this pool. For manual creation, 'dynamic provisioning' must be disabled in the Helm chart when it is installed. It is up to the administrator to provide appropriate storage to back these physical volumes.

If these persistent volumes are to be created automatically at the time of installation, the system administrator must enable support for this prior to installing the Helm chart. For automatic creation 'dynamic provisioning' should be enabled in the Helm chart when it is installed and storage class names provided to define which types of Persistent Volume get allocated to the deployment.

More information about persistent volumes and the system administration steps required can be found in the [Kubernetes documentation](https://kubernetes.io/docs/concepts/storage/persistent-volumes/).

## Limitations
- Linux on Power (ppc64le) is not supported.
- Mixed worker node architecture deployments are not supported.

## Documentation

Find out more about [IBM Financial Crimes Insight](https://www.ibm.com/support/knowledgecenter/SSCKRH_6.6.0/fcdd/kc_welcome.html).
