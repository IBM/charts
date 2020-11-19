# IBM Watson OpenScale

IBM Watson OpenScale is an enterprise-grade environment for AI infused applications that provides enterprises visibility into how AI is being built, used, and delivers ROI – at the scale of their business. Its open platform enables businesses to operate and automate AI at scale with transparent, explainable outcomes, automatically freed from harmful bias. Watson OpenScale on IBM Cloud Pak for Data allows clients to scale adoption of trusted AI across enterprise applications, all hosted on-premise or in a private cloud environment.

## Introduction

This chart deploys IBM Watson OpenScale for IBM Cloud Pak for Data.

## Chart Details

- See [Details](https://www.ibm.com/support/producthub/icpdata/docs/content/SSQNUZ_current/cpd/svc/openscale/openscale-overview.html)

## Prerequisites

- See [Details](https://www.ibm.com/support/producthub/icpdata/docs/content/SSQNUZ_current/cpd/svc/openscale/openscale-svc-adm-cmd.html#wos-svc-adm-cmd)

## Resources Required

- See [Details](https://www.ibm.com/support/producthub/icpdata/docs/content/SSQNUZ_current/cpd/svc/openscale/openscale-install.html)

## Installing the Chart

- See [Details](https://www.ibm.com/support/producthub/icpdata/docs/content/SSQNUZ_current/cpd/svc/openscale/openscale-install.html)

## Limitations

- See [Details](https://www.ibm.com/support/producthub/icpdata/docs/content/SSQNUZ_current/wos/icp4d-known-wos-issues.html)

## Configuration

See [Details](https://www.ibm.com/support/producthub/icpdata/docs/content/SSQNUZ_current/cpd/svc/openscale/openscale-scaling.html)

## Requirements

- See [Details](https://www.ibm.com/support/producthub/icpdata/docs/content/SSQNUZ_current/cpd/plan/rhos-reqs.html)

## SecurityContextConstraints Requirements:
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
