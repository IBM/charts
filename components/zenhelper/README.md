
# Chart Information

## Introduction

zen-helper chart is a helper chart  

## Chart Details


## Prerequisites

* [`cpd-zensys-scc`](https://ibm.biz/cpkspec-scc)
* [`cpd-user-scc`](https://ibm.biz/cpkspec-scc)


This scc is not needed for us to deploy
* [`ibm-anyuid-scc`](https://ibm.biz/cpkspec-scc)


## Resources Required

## Red Hat OpenShift SecurityContextConstraints Requirements

## Installing the Chart

## Limitations

## Configuration

### PodSecurityPolicy Requirements
  - Custom SecurityContextConstraints definition:
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
      groups: []
      kind: SecurityContextConstraints
      metadata:
        name: cpd-zensys-scc
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
