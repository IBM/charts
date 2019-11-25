
#IBM Financial Crimes Insight for Claims Fraud Software
Uncover suspicious behavior early in the insurance claims process before fraudulent claims are paid.

## Introduction
This chart deploys Financial Crimes Insight for Claims Fraud Software. For more information about IBM Financial Crimes Insight, see the [IBM Financial Crimes Insight product documentation](https://www.ibm.com/support/knowledgecenter/SSCKRH).

## Chart Details
This Helm chart will install the following:

- Liberty Server of the Claims Fraud Software as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) 

## Prerequisites
To install using the command line, ensure you have the following:

- The `kubectl` and `helm` commands available
- Your environment configured to connect to the target cluster
See the [IBM Financial Crimes Insight product documentation](https://www.ibm.com/support/knowledgecenter/SSCKRH) for details on setting up an environment to install this chart.

The installation environment has the following prerequisites:

- Kubernetes 1.11.0 or later

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
For information about the resource requirements of the IBM Financial Crimes Insight for Claims Fraud Software, see the [IBM Financial Crime Insight product documentation](https://www.ibm.com/support/knowledgecenter/SSCKRH).

## Installing the Chart

These are the steps to install IBM Financial Crimes Insight for Claims Fraud Software in your environment: 

- Install IBM Financial Crime Insight
- Install IBM Financial Crimes Insight for Claims Fraud Software

### Install IBM Financial Crime Insight for Claims Fraud Software

See the [IBM Financial Crime Insight product documentation](https://www.ibm.com/support/knowledgecenter/SSCKRH) for information on installing the IBM Financial Crime Insight chart.

### Uninstalling the Chart

To uninstall IBM Financial Crimes Insight:

```
helm delete <release_name> --purge --tls
```

This command removes all the Kubernetes components associated with the chart.

## Limitations
- Linux on Power (ppc64le) is not supported.
- Mixed worker node architecture deployments are not supported.

## Documentation

Find out more about [IBM Financial Crimes Insight](https://www.ibm.com/support/knowledgecenter/SSCKRH).
