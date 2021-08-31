# Name

IBM&reg; EDB-PG

# Introduction

PostgreSQL is the open source database of choice for people looking to do more and go faster. EDB supercharges PostgreSQL to help our customers innovate and accelerate. Ease of deployment and the scalability offered by the EDB Kubernetes Operator integrated into IBM Cloud Pak for Data allows you to provision and manage PostgreSQL.

https://github.com/EnterpriseDB/edb-k8s-doc

## Features

* Open Source PostgreSQL

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

* Describe Minimum System Resources Required

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