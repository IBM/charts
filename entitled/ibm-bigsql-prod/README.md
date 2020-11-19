# IBM Db2 Big SQL 7.1.1


## Introduction

IBM Db2 Big SQL is a cloud-native, elastic, scalable SQL engine for open data formats on decoupled storage.

Db2 Big SQL (Big SQL in short) running on Cloud Pak for Data can query large amounts of data residing on legacy Hadoop clusters as well as on Private or Public Cloud Object Storage. Big SQL is highly optimized for multiple open source data formats, including Parquet, ORC, Avro and CSV.

When querying data stored on legacy Hadoop clusters, Big SQL leverages the configurations of open source components like HDFS, Hive metastore and Ranger.

For more information, see https://www.ibm.com/products/db2-big-sql


## Chart Details

This chart will do the following:

* Deploy the Db2 Big SQL Head node using a Deployment
* Deploy Db2 Big SQL Worker nodes using a StatefulSet
* Deploy a MariaDB container to be optionally used if connectinb to Object Store service using a Deployment

* Create Db2 Big SQL service configured to connect to the available Big SQL instance and other required process on the client ports.


## Prerequisites

1. Kubernetes version >= 1.11.0
1. Tiller version >= 2.9.0
3. IBM Cloud Pak for Data >= 2.5.0.0

This chart does not require a PodDisruptionBudget

### PodSecurityPolicy Requirements	

This chart requires the same PodSecurityPolicy [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) that Cloud Pak for Data asks to be bound to the target namespace

Custom PodSecurityPolicy definition:	
```	
No Custom PSP is Defined for Big SQL for the current release
```
### Red Hat OpenShift SecurityContextConstraints Requirements

This chart defines a custom SecurityContextConstraints [`bigsql-scc`](https://ibm.biz/cpkspec-scc) which must be used to finely control the permissions/capabilities needed to deploy this chart. This custom SecurityContextConstraints resource will be enabled by executing the below instructions to deploy this chart. 

Custom SecurityContextConstraints definition:
```yaml
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints

metadata:
  annotations:
    kubernetes.io/description: SCC for IBM Db2 Big SQL Add-On
  labels:
    app: db2-bigsql
  name: bigsql

allowedCapabilities:
  - AUDIT_WRITE 	
  - CHOWN	
  - DAC_OVERRIDE	
  - FOWNER	
  - FSETID	
  - KILL	
  - MKNOD	
  - NET_BIND_SERVICE	
  - NET_RAW	
  - SETFCAP	
  - SETGID	
  - SETPCAP	
  - SETUID	
  - SYS_CHROOT
  - IPC_OWNER

allowedUnsafeSysctls:
  - kernel.sem

allowHostDirVolumePlugin: false
allowHostIPC: true
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false

allowPrivilegedContainer: false
allowPrivilegeEscalation: true

fsGroup:
  type: RunAsAny

runAsUser:
  type: MustRunAsRange
  uidRangeMax: 1000361000
  uidRangeMin: 1000320900

seLinuxContext:
  type: MustRunAs

supplementalGroups:
  type: RunAsAny

volumes:
  - downwardAPI
  - persistentVolumeClaim
  - secret
```

### Resources Required

To deploy Db2 Big SQL as add-on to IBM Cloud Pak for Data, you must have the following minimum resources available in your cluster.

For one Head and one Worker Pod (minimum configuration), and one optional Metastore database:
* Cores: 9 available cores
* Memory: 66 GB available memory
* Persistent network storage: 200 GB


## Installing the Chart

This chart is to be installed via Cloud Pak for Data integrated interface using add-on logic

For full step-by-step documentation on how to install this chart follow this link:
https://www.ibm.com/support/knowledgecenter/SSQNUZ_3.5.0_test/svc-bigsql/bigsql_install_intro.html

## Configuration

The following tables lists the configurable parameters of the Db2 Big SQL chart exposed in Cloud Pak for Data provisioning UI for DV and their default values : 

| Parameter                               | Description                                                   | Default               |
|-----------------------------------------|---------------------------------------------------------------|-----------------------|
| `workerCount`                           | `The initial number of workers`                               | `1`                   |
| `global.persistence.storageClassName`   | `The storage class to allocate the nodes persistent volumes`  | `managed-nfs-storage` |
| `persistence.headVersionedPvSize`       | `Storage allocated for the head node (versioned)`             | `50Gi`                |
| `persistence.headUnversionedPvSize`     | `Storage allocated for the head node (unversioned)`           | `150Gi`               |
| `persistence.workerVersionedPvSize`     | `Storage allocated for the worker node (versioned)`           | `50Gi`                |
| `persistence.workerUnversionedPvSize`   | `Storage allocated for the worker node (unversioned)`         | `150Gi`               |
| `remoteCluster.cm_protocol`             | `Protocol to connect to remote Ambari server (http/https)`    | `nil`                 |
| `remoteCluster.cm_host`                 | `Remote cluster Ambari server host`                           | `nil`                 |
| `remoteCluster.cm_port`                 | `Remote cluster Ambari server port`                           | `nil`                 |
| `remoteCluster.cm_admin_user`           | `Remote cluster Ambari server admin user login`               | `nil`                 |
| `objectStore.endpoint`                  | `Object Store End Point`                                      | `nil`                 |
| `objectStore.hmacAccess`                | `Object Store HMAC access key to access object store`         | `nil`                 |


## Storage 


## Limitations

Upgrades from previous chart releases are not supported for this version
