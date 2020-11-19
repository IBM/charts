# IBM Data Virtualization API 1.4.1
Data Virtualization integrates data sources across multiple types and locations and turns it into one logical data view. This virtual data lake makes the job of getting value out of your data easy.
## Introduction
This chart configures and bootstraps Data Virtulization API 1.4.1 as add-on on a Kubernetes cluster with CP4D installed

## Chart Details
This chart will do the following:

* Deploy Data Virtualization using a deployment. 

* Create Data Virtualization service configured to connect to the available Data Virtulization instance and other required process on the client ports.

## Prerequisites
1. OpenShift Version >= 3.11
2. Tiller version >= 2.9.0
3. IBM Cloud Pak for Data >= 3.0.1

This chart does not require a PodDisruptionBudget

## Resources Required
To deploy Data Virtualizatio as add-on to IBM Cloud Pak for Data, you must have the following minimum resources available on at least one node in your cluster.
* Cores: 6 available cores
* Memory: 16 GB available memory
* Local storage: 100 GB
* Persistent network storage: 100 GB on GlusterFS

For more details about recommended resources requirement: https://www.ibm.com/support/knowledgecenter/SSQNUZ_2.1.0/com.ibm.icpdata.doc/dv/install-dv-add-on.html#install-dv-add-on


## Installing the Chart

This chart is to be installed via Cloud Pak for Data integrated interface using add-on logic

For full step-by-step documentation on how to install this chart follow this link:
https://www.ibm.com/support/knowledgecenter/SSQNUZ_2.1.0/com.ibm.icpdata.doc/dv/install-dv-add-on.html#install-dv-add-on


## Configuration
The following tables lists the configurable parameters of the ibm-dv-api chart and their default values.

| Parameter| Description | Default|
|----------|-------------|--------|
| `zenServiceInstanceId`| DV Service Instance Id |`nil`|
| `service.type`| k8s service type exposing ports, e.g.`ClusterIP` | `ClusterIP`|
| `service.port`| Interal https port | `3300`|
| `image.repository`| `dv-api` image| `store/ibmcorp/data_server_manager_dev`                         
| `image.tag`| `dv-api` image tag| `1.4.0`|	
| `image.pullPolicy`| `dv-api` image pull policy| `Always`   |


Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

## Limitations
Upgrades from previous chart releases are not supported for this version

## PodSecurityPolicy Requirements	

This chart requires the same PodSecurityPolicy [`ibm-restricted-scc`](https://ibm.biz/cpkspec-scc) that Cloud Pak for Data asks to be bound to the target namespace

Custom PodSecurityPolicy definition:	
```	
No Custom PSP is Defined	for DV for the current release
```

## Red Hat OpenShift SecurityContextConstraints Requirements
Custom SecurityContextConstraints definition:
```
```
Look for the correct version document of IBM Cloud Pak for Data and follow step to provision your Data Virtualization deployment, see https://www.ibm.com/support/knowledgecenter/SSQNUZ
