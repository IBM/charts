# ibm-eventstore-dev
* [IBM Db2 Event Store](https://www.ibm.com/us-en/marketplace/db2-event-store) is an in-memory database optimized for event-driven data processing and analysis.

## Introduction
This chart provides a data store that is capable of extremely high speed ingest and deep, real-time analytics.
* https://www.ibm.com/support/knowledgecenter/en/SSGNPV/eventstore/local/overview.html

## Chart Details
- Event Store runtime
- [Jupyter Notebook](http://jupyter.org/) enabled for Python and Scala, with an [Apache Spark runtime](https://spark.apache.org/)

## Prerequisites

- An IBM Cloud Private 2.1.0.2 or other Kubernetes cluster at the [following version](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_2.1.0.2/getting_started/components.html)

- In order to deploy the IBM Db2 Event Store into a non-default namespace, the non-default namespace must be assigned the privileged role binding:

```bash
NAMESPACE=es-namespace
kubectl create namespace ${NAMESPACE}
kubectl create rolebinding eventstoreprivilege --clusterrole=privileged --serviceaccount=${NAMESPACE}:default --namespace=${NAMESPACE}
```

**IMPORTANT** - IBM Db2 Event Store must be installed while connected to the internet. If offline, run the following command prior to installing the chart

```bash
kubectl label node <address.eventstoreNode> bluspark_node=H1
```
The [configuration](#configuration) section describes a suitable value for `<address.eventstoreNode>`.

## Resources Required

* The node targeted to run the IBM Db2 Event Store service, needs to be compliant with the IBM Db2 Event Store [documented requirements](https://www.ibm.com/support/knowledgecenter/SSGNPV/eventstore/local/requirements-local.html#requirements-local)

## Installing the Chart

### Installing from the command line

To install the chart from the command line with the release name eventstore-release:

```bash
helm repo add ibm-charts https://raw.githubusercontent.com/IBM/charts/master/repo/stable/
helm install --namespace ${NAMESPACE} --name eventstore-release --set address.virtualIp=<PROXY_IP> --set address.eventstoreNode=<WORKER_IP> ibm-charts/ibm-eventstore-dev
```

This command deploys IBM Db2 Event Store on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

### Installing with IBM Cloud Private

To install the chart with the release name `eventstore-release`:
- Select configure
- Configure the release name
- Select the target namespace configured for with a privileged role binding (documented above)
- Accept the license agreement
- Configure the name of the proxy node
  - Get the name of the proxy node by navigating to https://<ICP Cluster IP>:8443/console/platform/nodes
- Configure the name of the IBM Db2 Event Store worker node (https://<ICP Cluster IP>:8443/console/platform/nodes)
  - Get the name of the worker node by navigating to https://<ICP Cluster IP>:8443/console/platform/nodes
- Optionally configure the Shared and Local storage paths
- Optionally configure the Storage Class Name
- Select Install

### Verifying the Chart
See NOTES.txt associated with this chart for verification instructions

### Uninstalling IBM Db2 Event Store Developer Edition

To uninstall/delete the `eventstore-release` deployment in the console or with the CLI:

```bash
$ helm delete eventstore-release --purge
```

Note: If any of the `PersistentVolume` were added manually, they will need to be removed manually as well.

### Configuration

The following tables lists the configurable parameters of the IBM Db2 Event Store chart and their default values.

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
| address.virtualIp        | Name of the proxy node                  | |
| address.eventstoreNode   | Name of the IBM Db2 Event Store worker node  | |
| disk.storagePath         | Directory where the Db2 Event Store local logs will be stored |  `/ibm` |
| disk.computePath         | Directory where the Db2 Event Store metadata will be stored | `/ibm` |
| ibmEsPvc.existingClaimName| Name for the Persistent Volume claim. Leave empty for dynamic provisioning |  |
| ibmEsPvc.storageClassName | Storage class to use for provisioning | `glusterfs-distributed` |
| ibmEsPvc.size         | Size allocated to the IBM Db2 Event Store persistent volume | `100Gi` |
| ibmdsxdev.pullPolicy | Image pull policy  | `IfNotPresent`  |
| ibmdsxdev.useDynamicProvisioning | Use dynamic provisioning | `true`  |
| ibmdsxdev.existingClaimName | Name for the Persistent Volume claim. Leave empty for dynamic provisioning | |
| ibmdsxdev.storageClassName| Storage class to use for provisioning | `glusterfs-distributed` |
| ibmdsxdev.userHomePvc.persistence.size   | Size allocated to the user-home persistent volume |`10Gi` |
| ibmdsxdev.sparkMetricsPvc.persistence.size   | Size allocated to the Spark runtime persistent volume | `50Gi`  |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.
> **Tip**: You can use the default values.yaml

## Storage
Deploying IBM Db2 Event Store Developer Edition requires several persistent volumes. By default, dynamic provisioning is assumed and a GlusterFS storage class named `glusterfs-distributed` is assumed to have been configured as documented below:

* [Adding GlusterFS to the ICP cluster](https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0.2/manage_cluster/create_sc_glusterfs.html)
* [Creating a storage class](https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0.2/manage_cluster/create_sc_glusterfs.html)

Dynamic provisioning could be disabled by setting the configuration parameter *useDynamicProvisioning* to `false`.

## Limitations
* IMPORTANT - We currently only support a single deployed instance of the IBM Db2 Event Store Dev. Edition Helm Chart

## Documentation
* https://www.ibm.com/support/knowledgecenter/en/SSGNPV/eventstore/local/overview.html
