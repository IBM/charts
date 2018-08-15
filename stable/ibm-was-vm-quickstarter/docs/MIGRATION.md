# Migrating Applications to WAS VM Quickstarter

To migrate your WebSphere Application Server traditional environment to WAS VM Quickstarter, you must set up the WAS VM Quickstarter environment to enable migration. To set up your environment for migration, you must have:
1. An NFS server to host the migration files
1. A persistent volume to define the migration store that points to your NFS server mount point
1. Helm chart configuration that enables migration in the WAS VM Quickstarter deployment
1. Feature configuration that enables a migration option in the WebSphere service instances that are created.

Learn more about how to configure each of these requirements in the following sections. 

After your environment is deployed, you can use the [WebSphere Configuration Migration Tool for IBM Cloud](https://developer.ibm.com/wasdev/downloads/#asset/tools-WebSphere_Configuration_Migration_Tool_for_IBM_Cloud) to migrate your profile configuration and applications to virtual machines managed by the WAS VM Quickstarter service.

**Note:** Currently, you can only migrate to Red Hat Enterprise Linux (RHEL) target VMs. Migrating to Ubuntu VMs is not supported.

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

## Deploying the Helm Chart with Migration Enabled

To deploy your Helm chart with migration, you must enable the migration feature and specify the NFS server mount point and IP address in the Helm chart configuration. The following instructions assume you have previously deployed the Helm chart without migration and are upgrading an existing Helm release.

1. Create a Helm chart YAML file that enables the migration feature and points to the persistent volume that you created.

    Defining these values in a separate file enables you to easily choose whether to enable or disable migration when you deploy the Helm chart.

    For example, create a `myvalues.yaml` file with the following values, where the `mountPoint` is set to the directory that you created on your NFS server and `serverAddress` is set to the IP address of your NFS server:

    ```yaml
    migration:
      enabled: true
      mountPoint: "nfs/wasaas/<environment-name>/migration"
      serverAddress: <nfs-ip-address>
    ```

1. Upgrade your WAS VM Quickstarter Helm deployment by running the following command:

    ```bash
    helm upgrade --install <release-name> --tls -f myvalues.yaml stable/ibm-was-vm-quickstarter
    ```
    
## Enabling the Migration Feature for Service Instances

After you deploy your WAS VM Quickstarter service, the final configuration step is to enable the migration feature for service instances. When this feature is enabled, an additional option is displayed during VM provisioning so that you can choose whether to migrate from an existing cell.

To enable the migration feature in the WAS VM Quickstarter service, perform the following steps:

1. [Access the `wasaas-devops` container](https://ibm.biz/WASQuickstarterOperations#accessing-the-scripts-in-the-wasaas-devops-container).
1. Change to the `/bin` directory, and run the following command:

    ```bash
    wasaas.py set-features Migration public
    ```
1. To verify which features are enabled in the WAS VM Quickstarter service, run the following command:

    ```bash
    wasaas.py get-features
    ```

    The `Migration` feature and any other enabled features will be listed.

For information about accessing the container and the `wasaas.py` script, see [Administering WAS VM Quickstarter](https://ibm.biz/WASQuickstarterOperations).
