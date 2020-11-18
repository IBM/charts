## Introduction

This chart contains one of the components that is an integral part of the Bootstrap module for services within IBM Cloud Pak for Data.

## Prerequisites

This chart pre-reqs the bootstrap chart: 0010-infra. These charts sets up the PV and brings in essential services like user management, metastoredb etc.

[`cpd-user-scc`](https://ibm.biz/cpkspec-scc)

## Resources Required

Cumulatively the minimum CPU required by all deployments is 500m and the minimum memory is 256Mi.

| Component                   	| Replicas 	| Max CPU | Max Memory 	| Min CPU | Min Memory 	|
|-----------------------------	|----------	|---------|-------------|---------|-------------|
| Nginx deployment          	  | 3        	| 1000m   | 512Mi 	    | 200m    | 256Mi	      |
| Setup Nginx Job               | 1        	| 1000m   | 512Mi 	    | 500m    | 256Mi 	    |



## Chart Details

This chart mainly contains the nginx component that sets up the proxy for Cloud Pak for Data.

## Installing the Chart

Section 5 in this document goes into detail of install procedure for ICPD lite https://ibm.box.com/s/4u08mmazirl9vwo7hha736xuv3ps1qow

## Configuration

All the default values are set in the charts. However the docker_registry_prefix, existing claim name needs to be input to the charts.

Additionally the project also needs to be setup with tiller, scc, sa, rolebindings etc.

## Limitations

This chart is not self sufficient. It has dependency on other charts. Installing this alone will not be sufficient.

## Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a SecurityContextConstraints to be bound to the target service accounts prior to installation. 

From the user interface, you can copy and paste the following snippets to enable the custom SecurityContextConstraints

- Custom SecurityContextConstraints definition:

```yaml
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

```yaml
apiVersion: security.openshift.io/v1
metadata:
  annotations: {}
  name: cpd-zensys-scc
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
runAsUser:
  type: MustRunAs
  uid: 1000321000
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
```yaml
apiVersion: security.openshift.io/v1
metadata:
  annotations: {}
  name: cpd-noperm-scc
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
  type: MustRunAs
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
This then will need to be manually added to the service account.

```
oc adm policy add-scc-to-user cpd-zensys-scc -z cpd-admin-sa
oc adm policy add-scc-to-user cpd-user-scc -z cpd-viewer-sa
oc adm policy add-scc-to-user cpd-user-scc -z cpd-editor-sa
oc adm policy add-scc-to-user cpd-noperm-scc -z cpd-norbac-sa
```

This all can be automated using cpd-cli and is documented here: https://www.ibm.com/support/producthub/icpdata/docs/content/SSQNUZ_current/cpd/install/service_accts.html
