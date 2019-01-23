# Rook Ceph Cluster (ibm-rook-rbd-cluster V 0.8.3) - Beta

## Introduction
[Rook](https://rook.io/), an open source orchestrator for distributed storage systems, runs in Cloud Native environments.

[Ceph](https://ceph.com/) is a distributed storage system with multiple storage presentations that include object storage, block storage, and POSIX-compliant shared file system.

Rook is now in beta state and supports only Ceph distributed storage system.

## Chart details

This Helm chart bootstraps a Rook Ceph cluster on a [Kubernetes](http://kubernetes.io) cluster by using the
[Helm](https://helm.sh) package manager. Along with a storage cluster, this chart also creates a storage pool
and a storage class.


## Limitations
- Rook is supported on Linux® 64-bit clusters. Currently, it is not supported on Linux® on Power® 64-bit LE and IBM® Z clusters.
- Rook supports multiple Ceph clusters. However, only one cluster per namespace can be set up.
- After Rook cluster is installed and Rook rbd volume is claimed in an application pod, if you see the following errors, you must
  disable some Ceph features by starting the [rook toolbox](https://rook.io/docs/rook/v0.7/toolbox.html) and running
  [`ceph osd crush tunables bobtail`](https://github.com/rook/rook/blob/master/Documentation/common-issues.md#volume-mounting) in
  the rook toolbox container:
   - if you see volume mount failure in the application pod with an error `Failed to complete rbd: signal: interrupt.`
   - if `dmesg` on the node where application pod is scheduled shows the message `libceph: mon2 10.205.92.13:6790 feature set
     mismatch, my 4a042a42 < server's 2004a042a42, missing 20000000000`.

## Prerequisites
- You must have the cluster administrator role to install the chart.
- Role-based access control (RBAC) is enabled by default in IBM Cloud Private. Therefore, you must add certain RBAC objects before
  you deploy the Rook Ceph Operator and ibm-rook-rbd-cluster Helm charts. For more information, see
  [Rook Prerequisites]( https://rook.github.io/docs/rook/master/k8s-pre-reqs.html).
- You must first deploy the Rook Ceph Operator Helm chart, [rook-ceph version v0.8.3](https://rook.io/docs/rook/v0.8/helm-operator.html),
  in your IBM Cloud Private cluster. You must set `rbacEnable` chart configuration parameter to `true` while installing the Rook Ceph
  Operator Helm chart. The  Rook Ceph Operator Helm chart must create one Rook Operator pod, rook-ceph-agent DaemonSet and rook-discover
  DaemonSet in your IBM Cloud Private cluster. You must verify that these objects are successfully created before installing ibm-rook-rbd-cluster.
- In the `storage.nodes` ibm-rook-rbd-cluster chart configuration parameter, you must specify either disks or directories for a storage
  node. Your storage node must be part of IBM Cloud Private cluster. If you specify disk devices, they must not have any file system
  present.
- The path, which is specified as `dataDirHostPath` cluster settings, must not have any pre-existing entries from a previous cluster
  installation. Stale keys and other configurations that exist from a previous installation cause the installation to fail.



### PodSecurityPolicy Requirements

This chart requires the following PodSecurityPolicy before you deploy both Rook operator and Rook Ceph cluster charts:

*PodSecurityPolicy*

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


## Resources required

The Ceph cluster containers have the following resource requests and limits:

| Container                  | Memory Request        | Memory Limit          | CPU Request           | CPU Limit
| -----------------------    | ------------------    | ------------------    | ------------------    | ------------------
| Monitoring                 | 256Mi                 | 512Mi                 | 250m                  | 500m
| ODS                        | 256Mi                 | 512Mi                 | 250m                  | 500m
| Manager                    | 256Mi                 | 512Mi                 | 250m                  | 500m


## Installing Rook Ceph cluster

Installation of a Rook Ceph cluster is three-step process:
1. Configure role-based access control (RBAC)
2. Install the Rook Ceph Operator Helm chart
3. Install the Rook Ceph cluster (`ibm-rook-rbd-cluster`) chart

You must be a cluster administrator to install a Rook Ceph cluster.

### Configure RBAC

Create the following RBAC objects before you deploy both Rook operator and `ibm-rook-rbd-cluster` charts:

Create a `ClusterRole` object.

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
  
Create a `ClusterRoleBinding` object

  *Note: In the following `ClusterRoleBinding` definition, you must change the namespace parameter value to the namespace where
         you are deploying the Rook Operator chart.*

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
  namespace: <Rook Ceph Operator chart namespace>
```

Create the following RBAC objects before you deploy each `ibm-rook-rbd-cluster` chart. The RBAC objects are needed to perform
pre-installation validations. This is optional step. If you do not create these RBAC objects, disable pre-validation
check by setting `preValidation.enabled` parameter to `false` or disable `Pre-validation Checks` on your IBM Cloud Private cluster
management console.


Create a `ClusterRole` object.
```
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: pod-reader
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods"]
  verbs: ["get", "list"]

```

Create a `ClusterRoleBinding` object

  *Note: In the following ClusterRoleBinding definition, you must change the namespace parameter value to the namespace where you are
         deploying the ibm-rook-rbd-cluster chart.*
```
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: pod-reader-binding
subjects:
- kind: ServiceAccount
  name: default
  namespace: <ibm-rook-rbd-cluster namespace>
roleRef:
  kind: ClusterRole
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```


### Install the Rook Ceph Operator Helm chart

The Rook Ceph Operator Helm chart installs the basic components that are required to create, configure, and manage Rook
Ceph clusters on Kubernetes.

For more information about installing the Rook Ceph Operator Helm chart, see [Operator Helm Chart document](https://rook.io/docs/rook/v0.8/helm-operator.html). You must install Beta release version v0.8.3 of Rook Operator Helm chart.

*Note: Make a note of the namespace in which you deployed the Rook Ceph Operator Helm chart. You need to specify this namespace when you deploy the `ibm-rook-rbd-cluster` chart.*

Next, install the `ibm-rook-rbd-cluster` chart.

### Install the Rook Ceph cluster (`ibm-rook-rbd-cluster`) chart

Install the `ibm-rook-rbd-cluster` chart to create a Ceph storage cluster. The chart deploys a Ceph block storage cluster, and creates its storage pool and associated StorageClass.


## Installing the chart

### Installing the chart by using the command line

The following sample YAML shows the storage settings that specify three nodes with disks as storage devices:

```
rookOperatorNamespace: "<Rook Ceph Operator Namespace>"
cluster:
  storage:
    nodes:
      - name: "1.2.3.4"
        devices:
          - name: "vdb"
          - name: "vdc"
      - name: "1.2.3.5"
        devices:
          - name: "vdb"
      - name: "1.2.3.6"
        devices:
          - name: "vdb"
```
*Note: The node name must be the name of a kubernetes node as reported by the `kubectl get nodes` command.*


The following sample YAML shows storage settings that specify three nodes with directories as storage devices:

```
rookOperatorNamespace: "<Rook Ceph Operator Namespace>"
cluster:
  storage:
    nodes:
      - name: "1.2.3.4"
        directories:
          - path: "/rook/storage-dir"
      - name: "1.2.3.5"
        directories:
          - path: "/rook/storage-dir"
      - name: "1.2.3.6"
        directories:
          - path: "/rook/storage-dir"
```

*Note*:
- Replace `<Rook Ceph Operator Namespace>` with the namespace in which you deployed the Rook Ceph Operator chart.
- Disk devices that are specified here must not have any file system present; use `wipefs -a <disk path>` to clean the disks.
- Storage settings can be applied at a cluster or at a node level. See the *Configuration* section for details.

Run the following command to install `ibm-rook-rbd-cluster` chart from command line with the release name `my-release`:

```bash
helm install --name my-release -f values.yaml stable/ibm-rook-rbd-cluster --tls
```

### Installing the chart by using the management console

Consider the following storage settings examples if you are installing the `ibm-rook-rbd-cluster` chart from the IBM Cloud Private Catalog.

Storage setting that specifies three nodes with disks as storage devices:

```
-
    name: "1.2.3.4"
    devices: [{name: "vdb"}, {name: "vdc"}]
-
    name: "1.2.3.5"
    devices: [{name: "vdb"}]
-
    name: "1.2.3.6"
    devices: [{name: "vdb"}]
```

*Note: The node `name` must be the name of a kubernetes node as reported by the `kubectl get nodes` command.*

Storage setting that specifies three nodes with directories as storage devices:

```
-
    name: "1.2.3.4"
    directories: [{path: "/rook/storage-dir"}]
-
    name: "1.2.3.5"
    directories: [{path: "/rook/storage-dir"}]
-
    name: "1.2.3.6"
    directories: [{path: "/rook/storage-dir"}]
```

## Configuration

The following table lists the configurable parameters of the `ibm-rook-rbd-cluster` chart and their default values.


| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
| `rookOperatorNamespace`    | Namespace in which the Rook Ceph Operator Helm chart is installed. This parameter is required to grant adequate permission to Ceph operator to create and manage Ceph cluster pods. *Note: The Rook Ceph Operator Helm chart must be installed before you install the `ibm-rook-rbd-cluster` chart.* | `nil` |
| `cluster.dataDirHostPath`  | Path on the host where configuration files are stored. If not specified, a Kubernetes `emptyDir` is created. *Note: The directory must not have pre-exsiting entries.* | `/var/lib/rook `      |
| `cluster.mon.count`        | Sets the number of Ceph monitoring processes to start. The value must be odd number in the range 1 - 9.| `3`                |
| `cluster.mon.allowMultiplePerNode` | Set it `true` to allow multiple monitoring processes on one node. | `false`            |
| `cluster.network.hostNetwork` |  Set it `true` to use network of the hosts instead of using the software-defined network (SDN) underneath the containers.  | `false`  |
| `cluster.dashboard.enabled` |   Set it `true` to view the Ceph dashboard in your browser.            | `true`                |
| `cluster.placement.all.enabled`    | Set it `true` to enable generic placement configuration for all services (mon, osd, mgr). The placement configuration is used to schedule pods on nodes. Each service has its placement configuration that is generated by merging the generic configuration with the most specific one, which overrides any attribute. For more information, see [Placement Configuration Settings](https://github.com/rook/rook/blob/master/Documentation/ceph-cluster-crd.md#placement-configuration-settings).| `false` |
| `cluster.placement.all.nodeSelectorTerms` | Node affinity match expressions that are associated with nodeSelectorTerms for all the services (mon, osd, mgr). | `[]` |
| `cluster.placement.all.tolerations` | Tolerations that are applied to pods for all the services (mon, osd, mgr). | `nil` |
| `cluster.placement.mon.enabled`    | Set it `true` to enable generic placement configuration for Ceph monitoring service pods. The placement configuration is used to schedule pods on nodes. Each service has its placement configuration that is generated by merging the generic configuration with the most specific one, which overrides any attribute. For more information, see [Placement Configuration Settings](https://github.com/rook/rook/blob/master/Documentation/ceph-cluster-crd.md#placement-configuration-settings). | `false` |
| `cluster.placement.mon.nodeSelectorTerms` | Node affinity match expressions that are associated with nodeSelectorTerms for the Ceph monitoring service. | `[]` |
| `cluster.placement.mon.tolerations` | Tolerations that are applied to pods of the Ceph monitoring service. | `nil` |
| `cluster.placement.osd.enabled`    | Set it `true` to enable generic placement configuration for Ceph OSD service pods. The placement configuration is used to schedule pods on nodes. Each service has its placement configuration that is generated by merging the generic configuration with the most specific one, which overrides any attribute. For more information, see [Placement Configuration Settings](https://github.com/rook/rook/blob/master/Documentation/ceph-cluster-crd.md#placement-configuration-settings). | `false` |
| `cluster.placement.osd.nodeSelectorTerms` | Node affinity match expressions that are associated with nodeSelectorTerms for the Ceph OSD service. | `[]` |
| `cluster.placement.osd.tolerations` | Tolerations that are applied to pods of the Ceph OSD service. | `nil` |
| `cluster.placement.mgr.enabled`    | Set it `true` to enable generic placement configuration for manager service pods. The placement configuration is used to schedule pods on nodes. Each service has its placement configuration that is generated by merging the generic configuration with the most specific one, which overrides any attribute. | `false` |
| `cluster.placement.mgr.nodeSelectorTerms` | Node affinity match expressions that are associated with nodeSelectorTerms for the manager service. | `[]` |
| `cluster.placement.mgr.tolerations` | Tolerations that are applied to pods of the manager service. | `nil` |
| `cluster.storage.useAllNodes` | Set it to `true` to choose all the nodes in the cluster for storage. | `false` |
| `cluster.storage.useAllDevices` | Set it to `true` to automatically consume all devices found on nodes in the cluster by OSDs. Set it to `true` only if you have a controlled environment where you have no risk of formatting devices with existing data. | `false` |
| `cluster.storage.deviceFilter` | A regular expression that allows selection of devices to be consumed by OSDs. For example, `sdb:` selects only the `sdb` device, if found; `^sd[a-d]:` selects devices that start with `sda`, `sdb`, `sdc`,and `sdd`, if found. For more information, see [Storage Selection Settings document](https://github.com/rook/rook/blob/master/Documentation/ceph-cluster-crd.md#storage-selection-settings). | `nil` |
| `cluster.storage.location` | Location information about the cluster to help with data placement, such as region or data center. This information is directly fed into the underlying Ceph CRUSH map. More information on CRUSH maps can be found in the [ceph docs](http://docs.ceph.com/docs/master/rados/operations/crush-map/). | `nil`|
| `cluster.storage.config.storeType` | The underlying storage format to use for each OSD. Valid values are `filestore` or `bluestore`. | `filestore` |
| `cluster.storage.config.databaseSizeMB`| The size of a bluestore database in megabyte (MB). | `"1024"` |
| `cluster.storage.config.journalSizeMB` | The size of a filestore journal in MB. | `"1024"` |
| `cluster.storage.nodes`   | List of storage nodes and its devices. The nodes are Kubernets nodes of your IBM Cloud Private cluster node. The name must be the one as reported by the `kubectl get nodes` command.  Refer to `Installing the chart` for sample format. | `nil`  |
| `resources` | List of resources for mgr, mon, and osd pods. For example, `{\"mgr\": {\"limits\": {\"cpu\":\"500m\", \"memory\": \"512Mi\"}, \"requests\": {\"cpu\":\"250m\", \"memory\": \"256Mi\"}}` are resource limits and requests for manager pods. Use `mon` key to specify resources for monitoring service, and `osd` key to specify resources for osd service. | `nil` |
| `pool.failureDomain` | The failure domain across which the replicas or chunks of data are spread. Possible values are `osd` or `host`. Default value is `host`. For example, if you have replication of size 3 and the failure domain is `host`, all three copies of the data are placed on osds that are found on unique hosts. In such a case, you can tolerate the failure of two hosts. If the failure domain is  `osd`, you would be able to tolerate the loss of two devices. Similarly, for erasure coding, the data and coding chunks would be spread across the requested failure domain. For more information, see [Pool Settings](https://github.com/rook/rook/blob/master/Documentation/ceph-pool-crd.md#pool-settings). | `host` |
| `pool.resilienceType` | Resilience settings for pool. A pool can be either replicated or erasure-coded for resiliency. Allowed values are `replicated` or `erasurecoded`.  |   `replicated` |
| `pool.replicated.size` | The number of copies (replication) of the data in the pool. This value is valid when `pool.resilienceType` parameter is set to `replicated`.  | `3` |
| `pool.erasureCoded.dataChunks` | Choose this number to divide data into as many chunks as the number specified. This value is valid when `pool.resilienceType` parameter is set to `erasurecoded`. For allowed values, see [Erasure Coding Doc](https://github.com/rook/rook/blob/master/Documentation/ceph-pool-crd.md#erasure-coding).  | `2` |
| `pool.codingChunks` | Number of redundant chunks to store. This value is valid when `pool.resilienceType` parameter is set to `erasurecoded`. For allowed values, see [Erasure Coding Doc](https://github.com/rook/rook/blob/master/Documentation/ceph-pool-crd.md#erasure-coding).  | `1` |
| `storageClass.name`        | Name of the storage class that is created while you install Rook Ceph cluster.   | `nil` |
| `storageClass.create`      | Creates a storage class when set to `true`.           | `true`             |
| `storageClass.fsType`      | File System to use for the volume created by the storage class. Possible values are `ext4` or `xfs`. | `ext4`  |
| `storageClass.reclaimPolicy`  | Reclaim policy of the persistent volumes that are dynamically created by the storage class.    | `Delete`           |
| `storageClass.volumeBindingMode`  | Indicates how a volume must be bound. Possible values are `Immediate` or `WaitForFirstConsumer`. | `Immediate` |
| `preValidation.enabled`| Set this parameter to `true` to perform pre-installation validation.  | `true` |
| `preValidation.image.repository`| Docker repository from where the validation utility image is pulled.   | `ibmcom/icp-storage-util` |
| `preValidation.image.tag`                | Image tag that is used to choose utility image release version.  | `3.1.0`       |
| `preValidation.image.pullPolicy`         | Docker image pull policy. Allowed values are `Always`, `Never`, or `IfNotPresent`.  | `IfNotPresent`     |

Specify each parameter by using the `--set key=value[,key=value]` argument with the `helm install` command.

Alternatively, you can provide a YAML file with the parameter values while you install the chart.

For example,

```bash
helm install --name my-release -f values.yaml stable/ibm-rook-rbd-cluster --tls
```

## Verifying the chart

If chart installation is successful, you see a success message on IBM Cloud Private UI.

If you are using the Helm CLI, you see a message similar to the following message:

```
NOTES:
1. Installation of Rook RBD Cluster "default-cluster" successful.

   kubectl get cluster default-cluster --namespace default

2. A RBD pool "default-pool" is also created.

   kubectl get pool default-pool --namespace default
   
3. Storage class rbd-storage-class can be used to create RBD volumes.

   kubectl get storageclasses rbd-storage-class
```

After you successfully install the chart, it takes couple of minutes for all the required pods to be ready.

Before you use the storage class to claim a volume, verify that all the pods are ready and the cluster is usable.
1. There must be as many monitoring pods (`ceph-mon`) as specified in `cluster.monCount` configuration parameter.
2. There must be as many `ceph-osd` pods as the number of storage nodes specified in `cluster.storageNodes` configuration parameter.
3. The `api` and `ceph-mgr` pods must be ready.



All the pods are in same namespace where you deployed the chart.

## Provisioning Persistent Volume

The Ceph storage cluster creates a storage pool and its associated storage class for Rook to provision Ceph storage.

```
kubectl get storageclass
NAME                    TYPE
rbd-storage-class       rook.io/block      

kubectl get pool
NAME           KIND
default-pool   Pool.v1alpha1.rook.io
```

Use the following sample YAML file to create a persistent volume:

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
kubectl apply -f pvc_doc.yaml
persistentvolumeclaim "pv-claim" created

kubectl get pvc
NAME       STATUS    VOLUME                                     CAPACITY   ACCESSMODES   STORAGECLASS        AGE
pv-claim   Bound     pvc-375d2c9a-537b-11e8-a81b-005056a7db67   1Gi        RWO           rbd-storage-class   7s
```

## Uninstalling the chart

To uninstall or delete the `my-release` deployment:

```bash
helm delete --purge  my-release --tls
```

## Copyright
© Copyright IBM Corporation 2018. All Rights Reserved.
