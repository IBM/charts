# Name

IBM&reg; EDB-AS

# Introduction

EDB continues to evolve the capabilities of the core PostgreSQL database server, but also extends the PostgreSQL and cloud ecosystems by providing tools and automation. EDB believes Kubernetes and containers are essential for you to minimize your database management responsibilities while maximizing your IT budget.\n\nEase of deployment and the scalability offered by the EDB Kubernetes Operator integrated into IBM Cloud Pak for Data allows you to provision and manage EDB Postgres Advanced Server. 

https://github.com/EnterpriseDB/edb-k8s-doc

## Features

* Open Source PostgreSQL
* Enterprise Security
* Performance Diagnostics
* Oracle® database compatibility
* Productivity features

# Chart Details
This chart will do the following:
Deploy an instance of EDBAS

## Prerequisites
Have the EDB Operator running and all adm files and crds applied

## Installing the Chart
Install the chart using standard helm commands

## Configuration

In the values.yaml make sure you swap out the correct image links, and specify the correct storage class

### Resources Required

Minimum scheduling capacity:

| Software  | Memory (GB) | CPU (cores) | Disk (GB) | Nodes |
| --------- | ----------- | ----------- | --------- | ----- |
|           |      2      |      1      |     1     |   1   |
| **Total** |             |             |           |       |

# Installing

* https://github.com/EnterpriseDB/edb-k8s-doc/blob/master/k8s-operator/README.md

## Storage

* Dynamically Provisioned

## Limitations

* OpenShift 4.5+ required

# SecurityContextConstraints Requirements

Custom SecurityContextConstraints definition:

```
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  annotations:
  name: edb-operator-scc
priority: 10
allowPrivilegedContainer: false
allowPrivilegeEscalation: true
defaultAddCapabilities: []
requiredDropCapabilities: [MKNOD]
allowedCapabilities: []
seccompProfiles:
volumes:
  - configMap
  - downwardAPI
  - emptyDir
  - persistentVolumeClaim
  - projected
  - secret
allowedFlexVolumes: []
allowHostDirVolumePlugin: true
allowHostNetwork: false
allowHostPorts: false
allowHostPID: false
allowHostIPC: false
readOnlyRootFilesystem: false
runAsUser:
  type: RunAsAny
seLinuxContext:
  type: RunAsAny
fsGroup:
  type: RunAsAny
supplementalGroups:
  type: RunAsAny
```