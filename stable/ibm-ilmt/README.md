# IBM License Reporter Beta

## Introduction

The IBM License Reporter helps you maintain an inventory of the PVU based software deployed in your environment, and measures the PVU licenses required by software product. It is intended to help you manage your IBM software licensing requirements, and help you maintain an audit ready posture.

## Chart Details

This chart deploys IBM License Reporter StatefulSet with 3 containers:
* server
* DB2 database
* datacollector

## Resources Required

* Space requirements: 10 GB of persistent storage space
* Hardware requirements:
    * Processor: 2 cores of CPU
    * Memory: 3.5 GB

## Prerequisites

This chart requires that your Cluster Administrator uses the definitions listed below to create:

* Custom Role,
* Pod Security Policy,
* Persistent Volume and Persistent Volume Claim.

As an example the definitions could be saved to a YAML file and imported using the following commands:
```
kubectl create -f <definition-file>.yml
```

### API Access

To collect information about your cluster, CustomRole must be created by your Cluster Administrator, base on following definition. Make sure to update <namespace> with target namespace.

```yaml
apiVersion: rbac.authorization.k8s.io/v1 
kind: ClusterRole
metadata:
  name: ilmt-dc 
rules:
- apiGroups: [""]
  resources: ["pods", "nodes"]
  verbs: ["get", "list"] 
- apiGroups: [""]
  resources: ["pods/exec"]
  verbs: ["get", "create"]
---
apiVersion: rbac.authorization.k8s.io/v1 
kind: ClusterRoleBinding
metadata:
  name: ilmt-dc
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: ilmt-dc 
subjects:
- kind: ServiceAccount
  name: default
  namespace: <namespace>
```

### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you:

* Predefined PodSecurityPolicy name: [`ibm-privileged-psp`](https://ibm.biz/cpkspec-psp)
* Custom PodSecurityPolicy definition:

Make sure to update <namespace> with target namespace.

```yaml
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  name: ilmt-db2
spec:
  allowPrivilegeEscalation: true
  privileged: false
  allowedCapabilities:
  - SETPCAP
  - MKNOD
  - AUDIT_WRITE
  - CHOWN
  - NET_RAW
  - DAC_OVERRIDE
  - FOWNER
  - FSETID
  - KILL
  - SETGID
  - SETUID
  - NET_BIND_SERVICE
  - SYS_CHROOT
  - SETFCAP
  - SYS_RESOURCE
  - IPC_OWNER
  - SYS_NICE
  fsGroup:
    rule: RunAsAny
  hostIPC: true
  hostNetwork: false
  hostPID: false
  hostPorts:
  - max: 65535
    min: 1
  runAsUser:
    rule: RunAsAny
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  volumes:
  - '*'
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: ilmt-db2
rules:
- apiGroups:
  - extensions
  resources:
  - podsecuritypolicies
  resourceNames:
  - ilmt-db2
  verbs:
  - use
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: ilmt-db2
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: ilmt-db2
subjects:
- kind: Group
  name: system:serviceaccounts:<namespace>
  apiGroup: rbac.authorization.k8s.io
```

### Storage

PersistentVolume and PersistentVolumeClaim needs to be pre-created by cluster administator prior to installing the chart. IBM License Reporter requires about 10GB of disk space. PersistentVolumeClaim should be created in the same namespace where you are going to deploy IBM License Reporter. We recommend to use NFS base persistent volume to ensure data is not lost even if the node with deployed IBM License Reporter application is no longer available. NFS server storage should be configured with no_root_squash option. Below you can find definition for NFS base PersistentVolume and PersistentVolumeClaim.

```yml
kind: PersistentVolume
apiVersion: v1
metadata:
  name: ibm-ilmt
  labels:
    app: ibm-ilmt
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: <nfs server ip or hostname>
    path: "<nfs export path>"
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: ibm-ilmt
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
  storageClassName: ""
  selector:
    matchLabels:
      app: ibm-ilmt 
```

## Installing the Chart

To install the chart ClusterAdministrator authority is required. 

Use following command to install chart from the command line

```bash
helm install --name my-release --namespace <namespace>  -f values.yaml stable/ibm-ilmt --tls
```

## Configuration

The following tables lists the configurable parameters of the ibm-ilmt chart and their default values

### Container image configuration

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `images.server.repository` | Server image repository | `ilmtserver` | 
| `images.server.tag` | Server image tag | `9.2.15.0` |
| `images.serverdb.repository` | DB2 image repository | `ilmtserverdb` |
| `images.serverdb.tag` | DB2 image tag | `9.2.15.0` |
| `images.datacollector.repository` | Data collector image repository | `ilmtdatacollector` |
| `images.datacollector.tag` | Data collector image tag | `9.2.15.0` |

### Resource quotas configuration

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `resources.server.requests.memory` | Server memory resource requests | `1Gi` | 
| `resources.server.requests.cpu` | Server CPU resource requests | `800m` |
| `resources.server.limits.memory` | Server memory resource limits | `2Gi` | 
| `resources.server.limits.cpu` | Server CPU resource limits | `2000m` |
| `resources.serverdb.requests.memory` | DB2 memory resource requests | `2Gi` | 
| `resources.serverdb.requests.cpu` | DB2 CPU resource requests | `1000m` |
| `resources.serverdb.limits.memory` | DB2 memory resource limits | `4Gi` | 
| `resources.serverdb.limits.cpu` | DB2 CPU resource limits | `2000m` |
| `resources.datacollector.requests.memory` | Data collector memory resource requests | `500Mi` | 
| `resources.datacollector.requests.cpu` | Data collector CPU resource requests | `200m` |
| `resources.datacollector.limits.memory` | Data collector memory resource limits | `1Gi` | 
| `resources.datacollector.limits.cpu` | Data collector CPU resource limits | `1000m` |

## Limitations

Reporting license metrics for ICP clusters has the following limitations.

* IBM License Reporter does not have its own interface.

* Troubleshooting capabilities for this solution are limited.

* This Chart can run only on amd64 architecture type.

The limitations are planned to be address in the future releases.

