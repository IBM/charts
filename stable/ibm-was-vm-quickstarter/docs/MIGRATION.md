# Migrating Applications to WAS VM Quickstarter

The optional migration feature facilitates application migration from your on-premises environment to WAS VM Quickstarter.

To enable the migration feature, you must have:
* An NFS server to host the migration files
* A persistent volume to define the migration store that points to your NFS server mount point
* Helm chart configuration that enables migration

## Setting Up the NFS Server

You can use the Cloud Automation Manager NFS server, or a separate NFS server.

In your NFS server, create a `nfs/wasaas/<environment-name>/migration` directory, where _environment-name_ is a name for your environment. This directory serves as a mount point for the persistent volume, which links the directory to your WAS VM Quickstarter service.

To configure security for the mount point, specify a range of IP addresses in the `/etc/exports` configuration file on the NFS server. The IP address range must cover all of the potential addresses that can be assigned to guest VMs and IBM Cloud Private worker nodes that host the WAS VM Quickstarter service management Kubernetes pods. The addresses for the guest VMs only need read access to the mount point. The addresses for the worker nodes require read/write access.

For example:
```
/nfs/prod/migration    203.0.113.256/16(rw,sync,no_subtree_check)   // IP address range of worker nodes     
/nfs/prod/migration    192.168.10.190/16(ro,sync,no_subtree_check)   // IP address range of guest VMs
```

## Creating the Migration Persistent Volume

Create a `pv-migration.yaml` file that defines the migration volume. Use the values in the following example, replacing the items in <brackets\>. The NFS path specification in this YAML file must point to the migration directory on the NFS server.

```yaml
kind: PersistentVolume
apiVersion: v1
metadata:
  name: data-<releaseName>-ibm-was-vm-quickstarter-migration
  labels:
    component: "migration"
    releaseName: "<releaseName>"
spec:
  capacity:
    storage: 13Gi
accessModes:
- ReadWriteMany
persistentVolumeReclaimPolicy: Retain
nfs:
  path: /nfs/wasaas/<environment-name>/migration
  server: <nfs-server-address>
```

Run the following command to create the volume:

  ```bash
kubectl create -f pv-migration.yaml
  ```
