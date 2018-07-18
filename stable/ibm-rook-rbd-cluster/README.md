# Rook Ceph cluster

## Introduction
[Rook](https://rook.io/), an open source orchestrator for distributed storage systems, runs in cloud Native environments.

[Ceph]( https://ceph.com/) is a distributed storage system with multiple storage presentations that include object storage, block storage, and POSIX-compliant shared file system. 

Rook is now in alpha state and supports only Ceph distributed storage system.  

This Helm chart deploys a Rook Ceph cluster that uses block storage. Along with storage Cluster, this chart also creates its storage pool and a StorageClass.


## Limitations
- Rook is supported on Linux® 64-bit cluster. Currently it is not supported on Linux® on Power® 64-bit LE and IBM® Z clusters.
- Rook supports multiple Ceph clusters. However, only one cluster per namespace can be set up.
- Currently installation supported in default and kube-system namespaces only.
- Rook Ceph cluster is supported on Linux kernel version 3.15 or later.

## Prerequisites
- Installer user must have Cluster administrator role.
- ICP has RBAC enabled, hence it requires to add certain RBAC objects before deploying both Rook Operator and Rook Ceph Cluster charts. For more information, see [Prerequisites]( https://rook.github.io/docs/rook/master/k8s-pre-reqs.html).
- The Rook Operator deployment must be pre-deployed on ICP cluster. This deployment must bring up one Rook Operator Pod in your cluster and a Rook Agent Pod on each of the nodes.
- In storageNodes parameter, either disks or directories can be specified against a storage node. If disk devices are specified, they must not have any file system present.
- The path, specified as dataDirHostPath cluster settings, must not have any pre-existing entries from previous cluster installation. Stale keys and other configurations existing from previous installation will fail the installation.

## Installing Rook Ceph cluster
Installation of a Rook Ceph cluster is three-step process:
1. Configure role-based access control (RBAC)
2. Install the Rook operator Helm chart
3. Install the Ceph storage cluster chart

You must be a cluster administrator to install a Rook Ceph cluster.

### Configure RBAC 
Following RBAC objects must be created before deploying both Rook Operator and Rook Ceph cluster charts:

#### PodSecurityPolicy

  ```
  apiVersion: extensions/v1beta1
  kind: PodSecurityPolicy
  metadata:
    name: rook-privileged
  spec:
    fsGroup:
      rule: RunAsAny
    privileged: true
    runAsUser:
      rule: RunAsAny
    seLinux:
      rule: RunAsAny
    supplementalGroups:
      rule: RunAsAny
    volumes:
    - '*'
    allowedCapabilities:
    - '*'
    hostPID: true
    hostIPC: true
    hostNetwork: true
    hostPorts:
     # CEPH ports
     - min: 6789
       max: 7300
     # rook-api port
     - min: 8124
       max: 8124
  ```
#### ClusterRole

  ```
  # privilegedPSP grants access to use the privileged PSP.
  apiVersion: rbac.authorization.k8s.io/v1
  kind: ClusterRole
  metadata:
    name: privileged-psp-user
  rules:
  - apiGroups:
    - extensions
    resources:
    - podsecuritypolicies
    resourceNames:
    - rook-privileged
    verbs:
    - use  
  ```
  
#### ClusterRoleBinding
*Note: You need to change namespace value to the namespace where you are creating Rook Operator deployment.*
```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: rook-agent-psp
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: privileged-psp-user
subjects:
- kind: ServiceAccount
  name: rook-agent
  namespace: <rook-operator-namespace>
  ```
  
### Install the Rook operator Helm chart
The Rook operator Helm chart installs the basic components that are required to create, configure, and manage Rook Ceph clusters on Kubernetes. 

For more information about installing the Rook operator Helm chart, see [Operator Helm Chart]( https://rook.github.io/docs/rook/master/helm-operator.html ). 

Next, create the Ceph storage cluster

### Create the Ceph storage cluster

Install the `ibm-rook-rbd-cluster` chart to create Ceph storage cluster. It deploys a Ceph block storage cluster, and creates its storage pool and associated StorageClass.


## Installing the chart
To install `ibm-rook-rbd-cluster` chart from command line with release name `my-release`:

```bash
$ install --name my-release -f  values.yaml stable/ibm-rook-rbd-cluster --tls
```

## Configuration
The following table lists the configurable parameters of the `ibm-rook-rbd-cluster` chart and their default values.


| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
| `cluster.dataDirHostPath`  | Path on the host to store configuration and data *Note: It must not have pre-exsiting entries.* | `/var/lib/rook `                                                        |
| `cluster.hostNetwork`      | Uses host network instead of Pod network         | `false`                                                     |
| `cluster.monCount`         | Sets number of Ceph monitoring process to start  | `3`                |
| `cluster.pool.replicaSize` |  Number of storage replica to create             | `2`                |
| `cluster.storageNodes`     |  List of storage nodes and its devices  *Eg. [{"name": "1.2.3.4", "device": [{"name": "sdb"}]}]* *Note: disk devices specified here must not have any file system present, use wipefs -a disk to clean disks.*                   | `nil`                                            |
| `storageClass.name`        | Name of the storage class                        | `nil`              |
| `storageClass.create`      | Creates storage class when set to true           | `true`             |
| `storageClass.fsType`      | File system type supported by Kubernetes         | `ext4`             |
| `storageClass.reclaimPolicy`  | Reclaim policy of the volume being created    | `Delete`           |
| `storageClass.volumeBindingMode`  | Indicates how volume should be bound      | `Immediate`        |
| `image.repository`         | Docker repository to pull hyperkube image from   | `ibmcom/hyperkube` |
| `image.tag`                | Image tag                                        | `v1.10.0-ce`       |
| `image.pullPolicy`         | Image pull policy                                | `IfNotPresent`     |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart.
For example,

```bash
$ helm install --name my-release -f values.yaml stable/ibm-rook-rbd-cluster --tls
```

*Note: In storageNodes parameter, either disks or directories can be specified against a storage node.*

The following is sample YAML file containing storage node (with disks as storage devices) settings to get you started.

```
cluster:
  storageNodes: [{"name": "1.2.3.4", "device" : [{"name": "sdb"}] }, {"name": "1.2.3.5", "device" : [{"name": "sdb"}] }, {"name": "1.2.3.6", "device" : [{"name": "sdb"}] }]
```

The following is sample YAML file containing storage node (with directories as storage devices) settings to get you started.

```
cluster:
  storageNodes: [{"name": "1.2.3.4", "directories" : [{"path": "path1"}] }, {"name": "1.2.3.5", "directories" : [{"path": "path2"}] }, {"name": "1.2.3.6", "directories" : [{"path": "path3"}] }]
```

## Verifying the chart

If chart installation is successful you will see success message on ICP UI.


You will see the following post message if you are using Helm CLI :

```
NOTES:
1. Installation of Rook RBD Cluster "default-cluster" successful.

   kubectl get cluster default-cluster --namespace default

2. A RBD pool "default-pool" is also created.

   kubectl get pool default-pool --namespace default
   
3. Storage class rbd-storage-class can be used to create RBD volumes.

   kubectl get storageclasses rbd-storage-class
 
```

Once chart installation is successful, it takes couple of minutes to bring up all the required pods.
Verify that all the pods have come up and cluster is usable before using the storage class for volume claim.

1. Verify that there are as many monitoring Pods (ceph-mon) as specified in cluster.monCount configuration parameter.
2. Verify that there are as many ceph-osd Pods as number of storage nodes specified in cluster.storageNodes configuration parameter.
3. Verify that api and ceph-mgr Pods are up.

All the above Pods are in same namespace where this chart is being deployed. 


## Provisioning Persistent Volume

The Ceph storage cluster creates a storage pool and associated storage class for Rook to provision Ceph storage.

```
$ kubectl get storageclass
NAME                    TYPE
rbd-storage-class       rook.io/block      


$ kubectl get pool
NAME           KIND
default-pool   Pool.v1alpha1.rook.io
```

Use the following sample yaml file to create a persistent volume:

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pv-claim
spec:
  storageClassName: rbd-storage-class
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```
```
$ kubectl apply -f pvc_doc.yaml 
persistentvolumeclaim "pv-claim" created

$ kubectl get pvc
NAME       STATUS    VOLUME                                     CAPACITY   ACCESSMODES   STORAGECLASS        AGE
pv-claim   Bound     pvc-375d2c9a-537b-11e8-a81b-005056a7db67   1Gi        RWO           rbd-storage-class   7s
```

## Uninstalling the chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete --purge  my-release --tls
```

## Copyright
© Copyright IBM Corporation 2018. All Rights Reserved.
