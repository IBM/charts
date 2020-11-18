# Chart Information

## Introduction

0010-infra chart lays down basic infrastructure components and microservices for the **Cloud Pak for Data** to be installed on top.

## Chart Details

This chart contains following components

1. Zen-metastoredb statefulset (cockroachdb)
2. Infuxdb deployment
3. User management deployment
4. user-home (shared PV) preparation job
5. User management preparation job
6. Set of configmaps to drive product behavior

## Prerequisites

1. This  chart expects two different SCCs to be present in RHOCP cluster. This chart is **not** meant to be installed on any kubernetes offering except RHOCP.

The SCCs are layed down by installer

* [`cpd-zensys-scc`](https://ibm.biz/cpkspec-scc)
* [`cpd-user-scc`](https://ibm.biz/cpkspec-scc)

This chart also requires a set of PVCs to be attached with PVs in your runtime.

1. *Dynamic Provisioning*

    If you are using a storage-class with dynamic provisioning enabled, the chart will PVs and PVCs bind correctly.

2. *Static Provisioning*
    In case of storage class with static provisioning, Kubernetes needs both PV and PVC to have common label for matching. In case of 0010 chart Cloud Pak for Data uses the following mechanism for label matching using `assign-to` as a common label in both YAML files.

## Resources Required

| Component                   	| Replicas 	| Max CPU | Max Memory 	| Min CPU | Min Memory 	|
|-----------------------------	|----------	|---------|-------------|---------|-------------|
| Influxdb                    	| 1        	| 1000m   | 2048Mi 	    | 100m    | 256Mi 	    |
| Influxdb-populate-job       	| 1        	| 1000m   | 512Mi  	    | 100m    | 512Mi  	    |
| User-home prep job          	| 1        	| 1000m   | 512Mi  	    | 500m    | 256Mi  	    |
| Usermgmt prep job          	| 1        	| 1000m   | 512Mi  	    | 500m    | 256Mi  	    |
| Usermgmt                    	| 2        	| 1000m   | 512Mi  	    | 200m    | 256Mi  	    |
| Zen-metastoredb-init job    	| 1        	| 500m    | 1024Mi 	    | 100m    | 512Mi	    |
| Zen-metastoredb statefulset 	| 3        	| 500m    | 1024Mi 	    | 100m    | 512Mi 	    |
| Createsecret Job          	| 1        	| 500m    | 128Mi 	    | 100m    | 64Mi 	    |

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


## Installing the Chart

Section 5 in this document goes into detail of install procedure for CPD lite <https://ibm.box.com/s/4u08mmazirl9vwo7hha736xuv3ps1qow>

## Limitations

This chart is not self sufficient. It has dependency on other charts. Installing this alone will not be sufficient.

## Configuration

All the default values are set in the charts. However the docker_registry_prefix, storage-class needs to be input to the charts.

Additionally the project also need to setup with tiller, scc, sa, rolebindings etc.
