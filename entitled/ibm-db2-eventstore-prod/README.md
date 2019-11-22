# ibm-db2-eventstore-prod
* [IBM Db2 Event Store](https://www.ibm.com/us-en/marketplace/db2-event-store) is an in-memory database optimized for event-driven data processing and analysis.

## Introduction
This chart provides a data store that is capable of extremely high speed ingest and deep, real-time analytics.
* https://www.ibm.com/support/knowledgecenter/en/SSGNPV/eventstore/local/overview.html

## Chart Details
- Event Store runtime
- [Jupyter Notebook](http://jupyter.org/) enabled for Python and Scala, with an [Apache Spark runtime](https://spark.apache.org/)

## Prerequisites

- Kubernetes Level - ">=1.10.11"

- A deployed ibm-dsx-prod chart

- PersistentVolume requirements - requires NFS or a hostPath PV that is a mounted clustered filesystem across all worker nodes.

- Label requirements - 3 Worker nodes must be labelled to schedule the eventstore engine containers. In a local install this is done automatically.

- HostPath - Each of the 3 worker nodes must have a host path available for the engine containers to mount

- In order to deploy the IBM Db2 Event Store into a non-default namespace, the non-default namespace must be assigned the privileged role binding:

```bash
NAMESPACE=es-namespace
kubectl create namespace ${NAMESPACE}
kubectl create rolebinding eventstoreprivilege --clusterrole=privileged --serviceaccount=${NAMESPACE}:default --namespace=${NAMESPACE}
```

**IMPORTANT** - IBM Db2 Event Store must be installed while connected to the internet. If offline, run the following commands prior to installing the chart

```bash
kubectl label node <address.eventstoreNode1> is_eventstore=true
kubectl label node <address.eventstoreNode2> is_eventstore=true
kubectl label node <address.eventstoreNode3> is_eventstore=true
```
The [configuration](#configuration) section describes a suitable value for `<address.eventstoreNode*>`.

## Resources Required

* The nodes targeted to run the IBM Db2 Event Store service, needs to be compliant with the IBM Db2 Event Store [documented requirements](https://www.ibm.com/support/knowledgecenter/SSGNPV/eventstore/local/requirements-local.html#requirements-local)

## Installing the Chart

### Installing IBM Db2 Event Store using COS/S3 as the object storage

To install the chart using COS or S3 as the object storage you need to precreate a kubernetes secret with your storage keys. The format of the kubernetes secret is as follows:
- Name: bluspark-dm.cloud-storage
- Data:
    access_key_id: which contains your COS or S3 access key 
    secret_key_id: which contains your COS or S3 secret key

[Kubernetes Secrets documentation](https://kubernetes.io/docs/concepts/configuration/secret/#creating-your-own-secrets)

### Installing from the command line

To create the secret from the command line:

```bash
echo -n '<Your access key' > ./access_key_id
echo -n '<Your secret key' > ./secret_key_id
kubectl create secret generic bluspark-dm.cloud-storage --from-file=./access_key_id --from-file=./secret_key_id
```
To install the chart from the command line with the release name eventstore-release:

```bash
helm install --namespace ${NAMESPACE} --name eventstore-release --set address.virtualIp=<PROXY_IP> --set address.eventstoreNode1=<WORKER_1_IP> --set address.eventstoreNode2=<WORKER_2_IP> --set address.eventstoreNode3=<WORKER_3_IP> local-charts/ibm-eventstore-prod
```

This command deploys IBM Db2 Event Store on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

### Verifying the Chart
See NOTES.txt associated with this chart for verification instructions

### Uninstalling IBM Db2 Event Store Enterprise Edition

To uninstall/delete the `eventstore-release` deployment in the console or with the CLI:

```bash
$ helm delete eventstore-release --purge
```

Note: If any of the `PersistentVolume` were added manually, they will need to be removed manually as well.

### Configuration

The following tables lists the configurable parameters of the IBM Db2 Event Store chart and their default values.

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
| prerequisiteCheck          | Run a prerequisite check before installing | `disabled` |
| address.virtualIp	     | Name of the proxy node                  | |
| address.eventstoreNode1   | Name of the first IBM Db2 Event Store worker node  | |
| address.eventstoreNode2   | Name of the second IBM Db2 Event Store worker node  | |
| address.eventstoreNode3   | Name of the third IBM Db2 Event Store worker node  | |
| disk.storagePath         | Directory where the Db2 Event Store local logs will be stored |  `/ibm` |
| disk.storageDev         | Disk device where the Db2 Event Store local logs will be stored. Run df -k on disk.storagePath to find out the disk information | |
| disk.computePath         | Directory where the Db2 Event Store metadata will be stored | `/ibm` |
| disk.computeDev         | Disk device where the Db2 Event Store metadata will be stored. Run df -k on disk.computePath to find out the disk information | |
| pvcSettings.useDynamicProvisioning | Use dynamic provisioning | `true`  |
| pvcSettings.storageClassName | Storage class to use for provisioning | `managed-nfs-storage` |
| image.pullPolicy | Image pull policy  | `Always`  |
| image.UniversalTag | Image tag used for all images  | `latest`  |
| eventStoreService.replicas | Amount of replicas for IBM Db2 Event Store, 3 is currently the only supported option| `3` | 
| objectStorage.useObjectStorage | Use S3 or COS for object storage. You have to have the secrets precreated | `false` | 
| objectStorage.type | The type of object storage to use S3 or COS are the two available options | |
| objectStorage.bucketName | The name of the bucket that IBM DB2 Event Store will use if object storage is enabled| |
| objectStorage.S3.region | The region to use if using object storage with type S3 | |
| objectStorage.COS.endpointURL | The endpoint url is using object storage with type COS | |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.
> **Tip**: You can use the default values.yaml

## Storage
Deploying IBM Db2 Event Store Enterprise Edition requires a persistent volume. By default, dynamic provisioning is assumed and a GlusterFS storage class named `glusterfs-distributed` is assumed to have been configured as documented below:

* [Creating a storage class](https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0.2/manage_cluster/create_sc_glusterfs.html)

Dynamic provisioning could be disabled by setting the configuration parameter *useDynamicProvisioning* to `false`.

## Limitations
* IMPORTANT - We currently only support a single deployed instance of the IBM Db2 Event Store Enterprise Edition Helm Chart, and it must be deployed in the same namespace of a deployed IBM DSX Enterprise Edition Helm Chart.

## Documentation
* https://www.ibm.com/support/knowledgecenter/en/SSGNPV/eventstore/local/overview.html
