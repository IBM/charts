# IBM Db2 Warehouse

[IBM Db2 Warehouse](http://www.ibm.com/hr-en/marketplace/db2-warehouse) IBM Db2 Warehouse is a software-defined data warehouse for private clouds and virtual private clouds.

Db2 Warehouse is an analytics data warehouse that you deploy by using a Docker container, allowing you control over data and applications, but simplicity in terms of deployment and management. Db2 Warehouse offers in-memory BLU processing technology and in-database analytics. Db2 Warehouse also provides Oracle and Netezza compatibility.

## Introduction

This chart consists of IBM® Db2 Warehouse Developer-C for Non-Production. 

This chart is only for IBM® Db2 Warehouse Developer-C for Non-Production SMP Deployments.

For more information about Db2 Warehouse, see the [IBM Db2 Warehouse documentation](https://www.ibm.com/support/knowledgecenter/SS6NHC/com.ibm.swg.im.dashdb.doc/admin/ICPdeployment.html)


## Prerequisites

Persistent Volume is required if no dynamic provisioning has been set up. Persistent Volume must be created with accessModes ReadWriteOnce and storage capacity of 25Gi or greater.  You can create a persistent volume via the IBM Cloud private interface or through a yaml file. For example:

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv0001
  labels:
    testlabel: labelvalue
spec:
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName:
  capacity:
    storage: 25Gi
  nfs:
    server: ********
    path: /mnt/clusterfs/
```

## Installing the IBM® Db2 Warehouse Developer-C for Non-Production chart (ibm-db2warehouse-dev)

Before clicking the tile to install Db2 Warehouse, create a persistent volume of at least 25 GiB.
Also create a persistent volume claim (of atleast 25 GiB) for the persistent volume (Best Practice).
If you are installing by using the Catalog, look for Db2 Warehouse.
After accepting the license terms, specify values for the following parameters or accept the defaults.

> Release name: ""  --- No other Deployment should have the same name

> Target namespace: ""

> Worker node architecture: ""

> BLUADMPASS: password: "changemeplease"  --- Password will be used for the bluadmin user

> Storage (Persistent Volume) Configuration:  Use dynamic provisioning for persistent volume: Not Selected

> Storage (Persistent Volume) Configuration: Persistent Volume Selector Label: ""

> Storage (Persistent Volume) Configuration: Selector Label Value: ""

> Storage (Persistent Volume) Configuration: Storage Class Name: ""

> Storage (Persistent Volume) Configuration: Existing Claim Name: ""

> Storage (Persistent Volume) Configuration: Size of the Volume Claim: "25Gi" --- Cannot be less than specified default

> Resource Configuration: Memory: "8Gi" --- Cannot be less than specified default

> Resource Configuration: CPU: "1000m" --- Cannot be less than specified default


To install from the command line for ibm-db2warehouse-dev chart with the release name `my-release`:
```bash
helm install --set arch=<architecture> --name my-release ibm-db2warehouse-dev
```
where architecture is either x86, ppcle or s390x.

For Intel x86, select x86
For IBM POWER LE, select ppcle
For IBM Z, select s390x

Note: The default configuration for each parameter can be changed using
```bash
--set key=value
```
Example for using helm install from command line
```bash
helm install --set arch=x86 --set pvcSettings.volumeLabel=testlabel --set pvcSettings.volumeLabelValue=labelvalue --name my-release ibm-db2warehouse-dev
```
The above command will deploy IBM Db2 Warehouse x86 Developer-C image to a persistent volume labeled testlabel=labelvalue


## Configuration

The following table lists the configurable parameters of the ibm-db2warehouse-dev chart and their default values.

| Parameter                                          | Description                                                   | Default                        |
| -------------------------------------------------- | ------------------------------------------------------------- | -------------------------------| 
| `arch`                                             | Specify the architecture of the worker node                   | `nil`            (required)    |
| `BLUADMPASS.password`                              | Specify the password for the bluadmin user                    | `changemeplease` (default)     |
| `pvcSettings.useDynamicProvisioning`               | Checkbox for dynamic provisioning of persistent volume claim  | `unchecked`      (default)     |
| `pvcSettings.volumeLabel`                          | Specify the persistent volume selector label                  | `nil`                          |
| `pvcSettings.volumeLabelValue`                     | Specify the value for the selector label                      | `nil`                          |
| `pvcSettings.storageClassName`                     | Specifies the storage class name for persistent volume claim  | `nil`                          |
| `pvcSettings.existingClaimName`                    | Specifies an existing claim name for persistent volume claim  | `nil`                          |
| `pvcSettings.size`                                 | Defines the claim storage size (database size)                | `25Gi`           (default)     |
| `resources.requests.memory`                        | Defines the minimum resource value for memory request         | `8Gi`            (default)     |
| `resources.requests.cpu`                           | Defines the minimum resource value for CPU                    | `1000m`          (default)     |


## Verifying the chart

To verify the chart, you need a system with kubectl and Helm installed. 

1. Connect to the master node of the ICP cluster, as follows:
   - On the dashboard, click <username> on the upper right and then Configure Client
   - Copy and paste the content to the master node
2. Check for deployment information by issuing the following commands:
```bash
helm list
helm status my-release
```
3. Copy the name of the pod that was deployed with ibm-db2warehouse-dev by issuing the following command:
```bash
kubectl get pod
```
4. Using the pod name, check under Events to see whether the image was successfully pulled and the container was created and started. Issue the following command:
```bash
kubectl describe pod <pod name>
```
5. Using the pod name, follow the logs until you see the 'You have successfully deployed IBM Db2 Warehouse' banner:
```bash
kubectl logs --follow <pod name>
```


## Connecting to Db2 Warehouse

1. On the cluster dashboard, navigate to Workloads -> Deployments. 
2. Select the name of the deployed Db2 Warehouse application.
3. Under Expose Details:  Endpoint:, look for “access port8443-https.” The link will let you access IBM Db2 Warehouse web console.

Username: bluadmin

Password: <BLUADMPASS: password> --- default is “changemeplease”

“access port50000” will provide you the unencrypted SSL IP address and port number.

“access port50001” will provide you the encrypted SSL IP address and port number.

Both use the same user name and password credentials, as the web console for ODBC and JDBC connections.


## Uninstalling the chart

1. To uninstall the deployed chart from the master node dashboard, click Workloads -> Helm Releases.
2. Find the release name and under action click delete.

To uninstall the deployed chart from command line, issue the following command:
```bash
helm delete --purge my-release 
```


## Storage persistence

You have two options for storage persistence:
- Persistent storage using a predefined PersistentVolumeClaim or PersistentVolume that is set up before the deployment of the chart
  - Either specify predefined Existing Claim Name OR specify the Volume Selector Label and Selector Label Value to deploy to a labeled Persistent Volume OR let the Kubernetes binding process select an existing volume based on the accessMode and size

- Persistent storage using Kubernetes dynamic provisioning. You can use the default storage class that is defined by the Kubernetes administrator or a custom storage class
  - Either specify a custom storageClassName per volume or leave the value blank to use the default storageClass


## Existing PersistentVolumeClaims (Best Practice)

1. Create the PersistentVolume
2. Create the PersistentVolumeClaim
3. Install the chart either by IBM Cloud Private interface or through command line by issuing the following command
```bash
helm install --set arch=<architecture> --set pvcSettings.existingClaimName=pvc-name --name my-release ibm-db2warehouse-dev
```
where architecture is either x86, ppcle or s390x, pvc-name is the persistent volume claim name
