
# IBM Financial Crimes Insight for Claims Fraud Software
Uncover suspicious behavior early in the insurance claims process before fraudulent claims are paid.

## Introduction
This chart deploys Financial Crimes Insight for Claims Fraud Software. For more information about IBM Financial Crimes Insight, see the [IBM Financial Crimes Insight product documentation](https://www.ibm.com/support/knowledgecenter/SSCKRH_6.6.0/fcii/kc_welcome.html).

## Chart Details
This Helm chart will install the following:

- Liberty Server of the Claims Fraud Software as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

## Prerequisites
To install using the command line, ensure you have the following:

- The `kubectl` and `helm` commands available
- Your environment configured to connect to the target cluster
See the [IBM Financial Crimes Insight product documentation](https://www.ibm.com/support/knowledgecenter/SSCKRH_6.6.0/fcii/t_inst_cf_checklist.html) for details on setting up an environment to install this chart.

The installation environment has the following prerequisites:

- Kubernetes 1.18.0 or later

### SecurityContextConstraints Requirements

### Red Hat OpenShift SecurityContextConstraints Requirements
The IBM Financial Crimes Insight installer for Red Hat OpenShift Container Platform creates the appropriate SecurityContextConstraint bound to the target namespace prior to installation.

The predefined `SecurityContextConstraints` name: `restricted` has been verified for the components of this chart. We also have `fci-restricted` which is based on the restricted version of the openshift scc. The custom scc definition is shown below.

Custom SecurityContextConstraints definition:

```
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegeEscalation: false
allowPrivilegedContainer: false
allowedCapabilities: []
apiVersion: security.openshift.io/v1
defaultAddCapabilities: []
defaultAllowPrivilegeEscalation: false
forbiddenSysctls:
- '*'
fsGroup:
  ranges:
  - max: 65535
    min: 1
  type: MustRunAs
groups: []
kind: SecurityContextConstraints
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"allowHostDirVolumePlugin":false,"allowHostIPC":false,"allowHostNetwork":false,"allowHostPID":false,"allowHostPorts":false,"allowPrivilegeEscalation":false,"allowPrivilegedContainer":false,"allowedCapabilities":[],"allowedFlexVolumes":null,"allowedUnsafeSysctls":null,"apiVersion":"security.openshift.io/v1","defaultAddCapabilities":[],"defaultAllowPrivilegeEscalation":false,"forbiddenSysctls":["*"],"fsGroup":{"ranges":[{"max":65535,"min":1}],"type":"MustRunAs"},"kind":"SecurityContextConstraints","metadata":{"annotations":{"kubernetes.io/description":"This policy is the most restricted context for FCI.  It is based upon the OpenShift restricted SCC"},"name":"fci-restricted"},"priority":0,"readOnlyRootFilesystem":false,"requiredDropCapabilities":["ALL"],"runAsUser":{"type":"MustRunAsNonRoot"},"seLinuxContext":{"type":"RunAsAny"},"seccompProfiles":["docker/default"],"supplementalGroups":{"ranges":[{"max":65535,"min":1}],"type":"MustRunAs"},"volumes":["configMap","downwardAPI","emptyDir","persistentVolumeClaim","projected","secret"]}
    kubernetes.io/description: This policy is the most restricted context for FCI.  It is based upon the OpenShift restricted SCC
  name: fci-restricted
priority: 0
readOnlyRootFilesystem: false
requiredDropCapabilities:
- ALL
runAsUser:
  type: MustRunAsNonRoot
seLinuxContext:
  type: RunAsAny
seccompProfiles:
- docker/default
supplementalGroups:
  ranges:
  - max: 65535
    min: 1
  type: MustRunAs
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
For information about the resource requirements of the IBM Financial Crimes Insight for Claims Fraud Software, see the [IBM Financial Crime Insight product documentation](https://www.ibm.com/support/knowledgecenter/SSCKRH_6.6.0/fcii/c_inst_cf_requirements.html).

## Installing the Chart

These are the steps to install IBM Financial Crimes Insight for Claims Fraud Software in your environment:

- Install IBM Financial Crime Insight
- Install IBM Financial Crimes Insight for Claims Fraud Software

### Install IBM Financial Crime Insight for Claims Fraud Software

See the [IBM Financial Crime Insight product documentation](https://www.ibm.com/support/knowledgecenter/SSCKRH_6.6.0/fcii/t_install_fci_platform.html) for information on installing the IBM Financial Crime Insight chart.

### Uninstalling the Chart

To uninstall IBM Financial Crimes Insight:

```
helm delete <release_name> --purge --tls
```

This command removes all the Kubernetes components associated with the chart.


## Configuration

See the [IBM Financial Crime Insight product documentation](https://www.ibm.com/support/knowledgecenter/SSCKRH_6.6.0/fcii/t_inst_cf_checklist.html) for more details on the configurable parameters.


## Limitations
- Linux on Power (ppc64le) is not supported.
- Mixed worker node architecture deployments are not supported.

## Documentation

Find out more about [IBM Financial Crimes Insight](https://www.ibm.com/support/knowledgecenter/SSCKRH_6.6.0/fcii/kc_welcome.html).
