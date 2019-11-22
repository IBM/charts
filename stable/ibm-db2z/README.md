# IBM Db2 for z/OS Connector add-on
This chart is for IBM Db2 for z/OS Connector add-on in IBM Cloud Pak for Data.

## Introduction
Db2 for z/OS Connector add-on brings the capabilities of Cloud Pak for Data to your data on IBM Z, on-platform in Db2 for z/OS.

## Chart Details
This chart will do the following:
* Deploy Db2 for z/OS Connector add-on in Cloud Pak for Data.
* Create deployments and services for the add-on.

## Prerequisites
* Kubernetes version >= 1.11.0
* Tiller version >= 2.9.0
* IBM Cloud Pak for Data >= 1.2.0.

### PodSecurityPolicy Requirements
This chart requires the same PodSecurityPolicy [`ibm-restricted-scc`](https://ibm.biz/cpkspec-scc) defined for Cloud Pak for Data.

Custom PodSecurityPolicy definition:	

```	
No Custom PSP is Defined for Db2z for the current release
```
### Red Hat OpenShift SecurityContextConstraints Requirements
This chart requires a custom SecurityContextConstraints named db2u-scc. When installing this chart using the cpd installer, this SecurityContextConstraints will automatically be applied.	

Custom SecurityContextConstraints definition:

```	
Custom SecurityContextConstraints is defined as 'db2u-scc' for Cloud Pak for Data.
```

## Resources Required
* The following minimum resource requirements must available on the cluster for each pod:
    * `ibm-db2z-addon`
        * CPU: `100m`
        * Memory: `256Mi`
    * `ibm-db2z-svp`
        * CPU: `100m`
        * Memory: `256Mi`
    * `ibm-db2z-ui`
        * CPU: `100m`
        * Memory: `256Mi`
    * `ibm-db2z-uc`
        * CPU: `2`
        * Memory: `4Gi`

## Installing the Chart
Follow the documentation instructions to install the chart:
https://docs-icpdata.mybluemix.net/docs/content/SSQNUZ_current/com.ibm.icpdata.doc/extend/db2z/t_install_db2z.html

### Verifying the Chart
Verify that pods are up and resources were created.
```
oc get all | grep db2z
```

## Configuration
Configurable parameters are not exposed with the Cloud Pak for Data UI.

## Limitations
This chart is only meant to be deployed with Cloud Pak for Data.

## Documentation
* [Cloud Pak for Data - Overview of Cloud Pak for Data](https://docs-icpdata.mybluemix.net/docs/content/SSQNUZ_current/com.ibm.icpdata.doc/zen/overview/overview.html)
* [Cloud Pak for Data - Creating a database in Db2 for z/OS](https://docs-icpdata.mybluemix.net/docs/content/SSQNUZ_current/com.ibm.icpdata.doc/extend/db2z/t_create_db_db2z.html)
* [Db2 for z/OS - Knowledge Center](https://www.ibm.com/support/knowledgecenter/en/SSEPEK/db2z_prodhome.html)