# IBM Data Virtualization add-on 1.5.0

Data Virtualization integrates data sources across multiple types and locations and turns it into one logical data view. This virtual data lake makes the job of getting value out of your data easy.


## Introduction

This chart configures and bootstraps Data Virtulization 1.5.0 as add-on on a Kubernetes cluster with IBM Cloud Pak for Data installed.


## Chart Details

This chart will do the following:

* Deploy Data Virtualization add-on and service provider.

* Create services configured to connect to the available add-on and service provider deployed for Data Virtulization.


## Prerequisites

1. OpenShift Version >= 3.11
1. Tiller version >= 2.9.0
3. IBM Cloud Pak for Data >= 3.5.0

This chart does not require a PodDisruptionBudget

## Resources Required

To deploy Data Virtualization as add-on in IBM Cloud Pak for Data, you must have the following minimum resources available on at least one node in your cluster:
* Cores: 4 available cores
* Memory: 16 GB available memory
* Local storage: 100 GB
* Persistent network storage: 175GB on NFS

For more details about recommended resources requirement: https://www.ibm.com/support/knowledgecenter/SSQNUZ_3.5.0/cpd/svc/dv/install-dv.html


## Installing the Chart

This chart is to be installed via Cloud Pak for Data integrated interface using add-on logic.

For full step-by-step documentation on how to install this chart follow this link:
https://www.ibm.com/support/knowledgecenter/SSQNUZ_2.1.0/com.ibm.icpdata.doc/dv/install-dv-add-on.html#install-dv-add-on


## Configuration

There are no Data Virtualization add-on parameters exposed or to be configured in IBM Cloud Pak for Data provisioning UI for Data Virtualization.

## Limitations

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