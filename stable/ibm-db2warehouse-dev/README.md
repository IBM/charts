# IBM Db2 Warehouse

[IBM Db2 Warehouse](http://www.ibm.com/hr-en/marketplace/db2-warehouse) IBM Db2 Warehouse is a software-defined data warehouse for private clouds and virtual private clouds.

## Introduction

This chart consists of IBM® Db2 Warehouse Developer-C for Non-Production. 

Db2 Warehouse is an analytics data warehouse that you deploy by using a Docker container, allowing you control over data and applications, but simplicity in terms of deployment and management. Db2 Warehouse offers in-memory BLU processing technology and in-database analytics. Db2 Warehouse also provides Oracle and Netezza compatibility.

You cannot use IBM Private Cloud for MPP deployments or updates to deployments.

For more information about Db2 Warehouse, see the IBM Db2 Warehouse documentation.  (https://www.ibm.com/support/knowledgecenter/SS6NHC/com.ibm.swg.im.dashdb.kc.doc/welcome.html)



## Prerequisites

- Persistent Volume is required if no dynamic provisioning has been set up. Persistent Volume must be created with accessModes ReadWriteOnce and storage capacity of 25Gi or greater.  You can create a persistent volume via the IBM Cloud private interface or through a yaml file. For example:

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv0001
spec:
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  storageClassName:
  capacity:
    storage: 25Gi
  hostPath:
    path: /mnt/clusterfs/
```



## Installing the IBM® Db2 Warehouse Developer-C for Non-Production chart (ibm-db2warehouse-dev)

Before clicking the tile to install Db2 Warehouse, create a persistent volume of at least 25 GiB.

If you are installing by using the Catalog, look for Db2 Warehouse.

After accepting the license terms, specify values for the following parameters or accept the defaults.

name: 

BLUADMPASS: password: "changemeplease"  --- Password will be used for the bluadmin user

persistenceVolume:  useDynamicProvisioning: false

persistenceVolumeClaimSettings1:  storageClassName: ""

persistenceVolumeClaimSettings2:  existingClaimName: ""

persistenceVolumeClaimSettings3:  size: 25Gi  --- Cannot be less than specified default, 25Gi.

resources:  requests:    cpu: 1000m    memory: 8Gi  --- For both memory and cpu, cannot be less than the specified default, 1000m and 8Gi.



To install from the command line for ibm-db2warehouse-dev chart with the release name `my-release`:

```bash
$ helm install --name my-release stable/ibm-db2warehouse-dev
```





## Verifying the chart

To verify the chart, you need a system with kubectl and Helm installed. 

1. Connect to the master node of the ICP cluster, as follows:

> On the master node dashboard, click <username> on the upper right  and then Configure Client.

> Copy and paste the content.

2. Check for deployment information by issuing the following commands:

```bash
helm list  <- You should see a DEPLOYED ibm-db2warehouse-dev application
helm status <deployment_name>  <- You should see details of the deployment
```

3. Copy the name of the pod that was deployed with ibm-db2warehouse-dev by issuing the following command:

```bash
kubectl get pod
```

4. Using the pod name, check under Events to see whether the image was successfully pulled and the container was created and started.  Issue the following command:

```bash
kubectl describe pod <pod name>
```

5. Enter the pod container and follow the log until you see Congratulations Issue the following commands:

```bash
kubectl exec -it <pod name> bash
tail -f /var/log/dashdb_local.log  <- You should see a status of RUNNING for five items and “Congratulations” near the end of the log
```



## Connecting to Db2 Warehouse

1. On the cluster dashboard, navigate to Workloads -> Application. 

2. Select the name of the deployed Db2 Warehouse application.

3. Under Expose Details:  Endpoint:, look for “access port8443.”  The link will open to a new ip_address:port_number.

4. On the new link, please place https:// in front of the ip_address:port_number to access the webconsole.

Username: bluadmin

Password: <BLUADMPASS: password> <- default is “changeme”

“access port50000” gives you the unencrypted SSL IP address and port number.

“access port50001” gives you the encrypted SSL IP address and port number.

Both use the same user name and password credentials, such as  for the web console for ODBC and JDBC connections.



## Uninstalling the chart

To uninstall the deployed chart from the master node dashboard, click App Center -> Installed -> <name of the deployed chart> -> Uninstall, on the right side of the screen.

To uninstall the deployed chart from command line, issue the following command:

```bash
helm delete --purge <deployment name>
```



## Configuration

The following table lists the configurable parameters of the ibm-db2warehouse-dev chart and their default values.

| Parameter                                          | Description                                                   | Default              |
| -------------------------------------------------- | ------------------------------------------------------------- | ---------------------|
| `BLUADMPASS.password`                              | Specifies the password for the bluadmin user                  | `changemeplease`     |
| `persistentVolume.useDynamicProvisioning`          | Checkbox for dynamic provisioning of persistent volume claim  | `false`              |
| `persistentVolumeClaimSettings1.storageClassName`  | Specifies the storage class name for persistent volume claim  | ``       (empty)     |
| `persistentVolumeClaimSettings2.existingClaimName` | Specifies an existing claim name for persistent volume claim  | ``       (empty)     |
| `persistentVolumeClaimSettings3.size`              | Defines the claim storage size (database size)                | `25Gi`               |
| `resources.requests.memory`                        | Defines the minimum resource value for memory request         | `8Gi`                |
| `resources.requests.cpu`                           | Defines the minimum resource value for CPU                    | `1000m`              |



## Storage persistence

You have two options for storage persistence:
- Persistent storage using Kubernetes dynamic provisioning. You can use the default storage class that is defined by the Kubernetes administrator or a custom storage class.
  - Ensure that the persistence.useDynamicProvisioning parameter is set to true (the default). 
  - Either specify a custom storageClassName per volume or leave the value blank to use the default storageClass.


- Persistent storage using a predefined PersistentVolumeClaim or PersistentVolume that is set up before the deployment of the chart.
  - Ensure that the persistence.useDynamicProvisioning parameter is set to false.
  - Either specify an existingClaimName per volume or let the Kubernetes binding process select an existing volume based on the accessMode and size.



## Existing PersistentVolumeClaims

1. Create the PersistentVolume.
2. Create the PersistentVolumeClaim.
3. Install the chart by issuing the following command:
```bash
$ helm install --set persistentVolumeClaimSettings2.existingClaimName=PVC_NAME

