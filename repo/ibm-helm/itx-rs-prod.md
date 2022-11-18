# Readme

Helm Chart for IBM Sterling Transformation Extender for Red Hat Openshift

## Prerequisites

This distribution is tested on Red Hat OpenShift 4.11. The OCP project must have access to "mongodb", and has been tested with "mongodb-enterpriser.v1.16.4". It also must have access to "redis". This deployment is tested with redis-operator.v0.8.0. Both of these dependencies have been provisioned from OpenShift's OperatorHub.

### PodDisruptionBudgets

The configured deployment does not specify a disruption budget. Each consumer of this transformation logic should consider how disruption might impact any specific process.

### SecurityContextConstraints Requirements

This chart requires a `SecurityContextConstraints` to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined `SecurityContextConstraints` name: [`anyuid`](https://docs.openshift.com/container-platform/4.11/authentication/managing-security-context-constraints.html) has been verified for this chart.  If your target namespace is bound to this `SecurityContextConstraints` resource, you can proceed to install the chart.

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
