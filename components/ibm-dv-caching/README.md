# IBM Data Virtualization Caching 1.5.0

Data Virtualization integrates data sources across multiple types and locations and turns it into one logical data view. This virtual data lake, simplifies the job of getting value out of your data.


## Introduction

This chart configures and bootstraps Data Virtulization Caching 1.5.0 as add-on on a Kubernetes cluster with IBM Cloud Pak for Data installed


## Chart Details

This chart will do the following:

* Deploy Data Virtualization using a StatefulSet. The only deployment supported for this version follows a replica set of 1.

* Create Data Virtualization service configured to connect to the available Data Virtulization instance and other required process on the client ports.


## Prerequisites

1. OpenShift Version >= 3.11
1. Tiller version >= 2.9.0
3. IBM Cloud Pak for Data >= 3.5.0

This chart does not require a PodDisruptionBudget

## Resources Required

To deploy Data Virtualization as add-on to IBM Cloud Pak for Data, you must have the following minimum resources available on at least one node in your cluster.
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

The following tables lists the configurable parameters of the Data Virtualization chart exposed in Cloud Pak for Data provisioning UI for DV and their default values : 

|                  Parameter                   |             Description               |                         Default                          |
|----------------------------------------------|---------------------------------------|----------------------------------------------------------|
| `resources.dv.requests.memory`                  | `Memory resource requests` | `16Gi`       |
| `resources.dv.requests.cpu`                  | `CPU resource requests` | `6`       |
| `persistence.existingClaimName`                  | `Name of existing volume claim` | `nil`| 
| `persistence.size`                  | `Storage size for the new volume claim` | `200Gi` | 


## Limitations

Upgrades from previous chart releases are not supported for this version

## PodSecurityPolicy Requirements	

This chart requires the same PodSecurityPolicy [`restricted`](https://ibm.biz/cpkspec-scc) that Cloud Pak for Data asks to be bound to the target namespace

Custom PodSecurityPolicy definition:	
```	
No Custom PSP is Defined	for DV for the current release
```

## Red Hat OpenShift SecurityContextConstraints Requirements
Custom SecurityContextConstraints definition:
```
```
Look for the correct version document of IBM Cloud Pak for Data and follow step to provision your Data Virtualization deployment, see https://www.ibm.com/support/knowledgecenter/SSQNUZ
