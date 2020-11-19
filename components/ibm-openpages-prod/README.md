# Chart Information

## Introduction

The ibm-openpages-prod provisions an instance of IBM OpenPages® Extension for IBM Cloud Pak® for Data.

## Chart Details

This chart deploys IBM OpenPages® Extension for IBM Cloud Pak® for Data which is an AI-driven governance, risk and compliance (GRC) solution built to help organizations manage risk and regulatory compliance challenges. For more information about IBM OpenPages see the [product documentation](https://www.ibm.com/support/knowledgecenter/SSFUEU).

This service is not available by default. An administrator must install this service on the IBM® Cloud Pak for Data platform.

## Prerequisites
- Installing a PodDisruptionBudget
- IBM Cloud Pak for Data will need to be deployed prior to the deployment of the IBM OpenPages service add-on.
- Kubernetes 1.11.0 or later is required
- Openshift 3.11 or 4.5
- Shared Storage (OpenShift Container Storage or NFS)
- 3 Worker Nodes (Minimum 8 Cores/32 GB)
- The following service accounts are required, which is set up by the IBM Cloud Pak for Data installation
   - cpd-viewer-sa
   - cpd-editor-sa

## Resources Required


| Component                                   | Replicas 	| Max CPU | Max Memory 	| Min CPU | Min Memory 	|
|-------------------------------------------- |----------	|---------|-------------|---------|-------------|
| OpenPages Instance cm-gen job               | 1        	|  500m   |  256Mi 	    |  250m   |  128Mi	    |
| OpenPages Instance provision job            | 1        	|  500m   |  256Mi 	    |  250m   |  128Mi	    |
| OpenPages Instance secret-gen job           | 1        	|  500m   |  256Mi 	    |  250m   |  128Mi	    |
| OpenPages Instance dbbackup-pvc-genn job    | 1        	|  500m   |  256Mi 	    |  250m   |  128Mi	    |
| OpenPages Instance opstorage-encryption job | 1        	|  500m   |  256Mi 	    |  250m   |  128Mi	    |
| OpenPages Instance Application StatefulSet  | 1-4      	| 4000m   | 8192Mi 	    | 2000m   | 4096Mi	    |

> **Tip**: You can use the default [values.yaml](values.yaml)

## Red Hat OpenShift SecurityContextConstraints Requirements

IBM OpenPages service add-on requires IBM Cloud Pak for Data provided SCCs which are set up by the IBM Cloud Pak for Data installation.

The predefined IBM Cloud Pak for Data SCC named `cpd-user-scc` has been verified for this chart. If your target namespace is bound to this SCC, you can proceed to install the chart.

`cpd-user-scc` definition for reference

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

```
securityContext:
    runAsNonRoot: true
    privileged: false
    allowPrivilegeEscalation: false
```

## Installing the Chart

Follow the service provisioning instruction from Cloud Pak® for Data.

## Persistence

Local Volumes are not portable which means you will lose data volume if you lose that Kubernetes Node.

To prevent that, you may use shared storage like OpenShift Container Storage or NFS.

## Limitations
- Chart can only run on amd64 architecture type

## Configuration

All the default values are set in the charts. However the dockerRegistryPrefix, storageClass needs to be input to the charts.

Additionally the project also need to setup with tiller, scc, sa, rolebindings etc.

## Documentation

See the [product documentation](https://www.ibm.com/support/knowledgecenter/SSFUEU).
