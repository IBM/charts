# Readme

Helm Chart for IBM Sterling Transformation Extender for Red Hat Openshift

# Introduction

IBM Sterling Transformation Extender (ITX) for Red Hat OpenShift is a containerized distribution of the translation engine exposing a set of REST API endpoints that you can invoke to run ITX maps. Another name for IBM Sterling Transformation Extender for Red Hat OpenShift is ITX Runtime Server. Maps are designed using ITX Design Studio and compiled for the Linux 64 platform. ITX Design Studio is a component separate from ITX Runtime Server. It must be installed and run locally on a Windows host. When you obtain access to the ITX Runtime Server component, you will be provided with instructions explaining how to obtain the ITX Design Studio component as well.

For additional high-level overview of the ITX Runtime Server product, please refer to this [support page](https://www.ibm.com/support/pages/node/7068837).

# Chart Details

## Prerequisites

This distribution is tested on Red Hat OpenShift 4.18. The OCP project must have access to "redis" to run maps in fenced mode or asynchronously. This deployment is tested with redis-operator 7.22.0 which has been provisioned from OpenShift's OperatorHub.

Installing a PodDisruptionBudget

The configured deployment does not specify a disruption budget. Each consumer of this transformation logic should consider how disruption might impact any specific process.

### Sample Pod Disruption Budget

``` { .yaml }
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: ibm-itx-rs-pdb
spec:
  minAvailable: 1
  selector:
    matchLabels:
      helm.sh/chart: "ibm-itx-rs-prod"
```

## Resources Required

### SecurityContextConstraints Requirements

This chart requires a `SecurityContextConstraints` to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined `SecurityContextConstraints` name: [`anyuid`](https://docs.openshift.com/container-platform/4.18/authentication/managing-security-context-constraints.html) has been verified for this chart.  If your target namespace is bound to this `SecurityContextConstraints` resource, you can proceed to install the chart.

Below is a custom `SecurityContextConstraints` which can be used for fine control of the permissions and capabilities needed to deploy this chart. You can enable this custom `SecurityContextConstraints` resource using these instructions.

From the OpenShift web console, you can copy and paste the following snippets to enable the custom `SecurityContextConstraints`

#### Custom SecurityContextConstraints definition:

``` { .yaml }
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: "This policy allows a singe, non-root user" 
  name: ibm-itx-rs-scc
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegedContainer: false
allowedCapabilities: []
allowedFlexVolumes: []
defaultAddCapabilities: []
allowPrivilegeEscalation: false
forbiddenSysctls:
  - "*"
fsGroup:
  type: MustRunAs
  ranges:
  - max: 1001
    min: 1001
readOnlyRootFilesystem: false
requiredDropCapabilities:
- ALL
runAsUser:
  type: MustRunAsRange
  uidRangeMin: 1000
  uidRangeMax: 65535
seccompProfiles:
- docker/default
seLinuxContext:
  type: RunAsAny
supplementalGroups:
  type: MustRunAs
  ranges:
  - max: 1
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

From the command line, save the YAML object to a file and run the following command to apply the file content to your namespace.

``` { .shell }
oc apply -f <file_name> -n <namespace_name>
```

## Installing the Chart

Follow the chart installation instructions provided in the CASE README for IBM Sterling Transformation Extender for Red Hat Openshift. 

## Configuration

Configuration settings supported by ITX Runtime Server have been listed in the CASE README for IBM Sterling Transformation Extender for Red Hat Openshift. 

## Limitations

Limitations of ITX Runtime Server have been mentioned in the CASE README for IBM Sterling Transformation Extender for Red Hat Openshift.
