# What's new in Chart Version 3.0.0

The following changes apply only to the Helm chart. For a full list of product updates, see [What's new in VM Quickstarter](https://www.ibm.com/support/knowledgecenter/SSTF9X/about-whats-new.html).

## New features
  - Removed dependencies on extraneous Docker images to help with off-line installation.

## Breaking Changes
  - None

## Fixes
  - Updated `cloudsm-frontend` pod configuration to archive destroyed resources and subscriptions.

# Prerequisites
  - Refer to [Prerequisities of WAS Quickstarter](http://ibm.biz/WASQuickstarterPrerequisites)

# Known Issues
  - As the resources used by WAS VM Quickstarter virtual machines reach the capacity specified in the Helm chart, the service will automatically indicate to users trying to create a new service that there is not enough resources to complete their request.   While the service instance is created, it is placed in `PENDING` state.  When more capacity is added to the target vCenter Datacenter or other services instances have been cancelled making more capacity available, the service instances are left in `PENDING` state.  These service instances can be safely deleted and the user can reattempt creating a new service instance.

# Version History

| Chart | Date | IBM Cloud Private Required | CAM Required | Image(s) Supported |  Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- |
| 3.0.0 | April 8, 2019  | >=3.1.0 | >=3.1.0 | ibmcom/wasaas-devops:3.0.0 ibmcom/wasaas-cloudsm:3.0.0 ibmcom/wasaas-wasdevaas:3.0.0 ibmcom/wasaas-console:3.0.0 couchdb:2.1.1 ibmcom/wasaas-dashboard:3.0.0 | Removed dependencies on extraneous Docker images. |
| 2.0.5 | March 8, 2019 | >=3.1.0 | >=3.1.0 | ibmcom/wasaas-devops:2.0.5 ibmcom/wasaas-cloudsm:2.0.5 ibmcom/wasaas-wasdevaas:2.0.5 ibmcom/wasaas-console:2.0.5 ibmcom/wasaas-dashboard:2.0.5 couchdb:2.1.1 | Bug fixes. |
| 2.0.4 | Feb 18, 2019 | >=3.1.0 | >=3.1.0 | ibmcom/wasaas-devops:2.0.4 ibmcom/wasaas-cloudsm:2.0.4 ibmcom/wasaas-wasdevaas:2.0.4 ibmcom/wasaas-console:2.0.4 ibmcom/wasaas-dashboard:2.0.4 couchdb:2.1.1 | Red Hat Satellite support. |
| 2.0.3 | Dec 14, 2018 | >=3.1.0 | >=3.1.0 | ibmcom/wasaas-devops:2.0.3 ibmcom/wasaas-cloudsm:2.0.3 ibmcom/wasaas-wasdevaas:2.0.3 ibmcom/wasaas-console:2.0.3 ibmcom/wasaas-dashboard:2.0.3 couchdb:2.1.1 | `PodSecurityPolicy` support and non-root updates. |
| 2.0.2 | Nov 30, 2018 | >=3.1.0 | >=3.1.0 | ibmcom/wasaas-devops:2.0.2 ibmcom/wasaas-cloudsm:2.0.2 ibmcom/wasaas-wasdevaas:2.0.2 ibmcom/wasaas-console:2.0.2 couchdb:2.1.1 | New administrative dashboard. |
| 2.0.1 | | | | | skipped |
| 2.0.0 | Sept 30, 2018 | >=3.1.0 | >=3.1.0 | ibmcom/wasaas-devops:2.0 ibmcom/wasaas-cloudsm:2.0 ibmcom/wasaas-wasdevaas:2.0 ibmcom/wasaas-console:2.0 couchdb:2.1.1 | Simplified configuration - fewer config parameters, migration support, installation in non-default namespace, bug fixes |
| 1.0.1 | Aug 15, 2018  | >=2.1.0.3 | >=2.1.0.2 | ibmcom/wasaas-devops:1.0.1 ibmcom/wasaas-cloudsm:1.0.1 ibmcom/wasaas-wasdevaas:1.0.1 ibmcom/wasaas-console:1.0.1 couchdb:2.1.1 | New WebSphere and Java fix packs and database troubleshooting script, plus fixes. |
| 1.0.0 | Jun 29, 2018  | >=2.1.0.3 | >=2.1.0.2 |  ibmcom/wasaas-devops:1.0.0 ibmcom/wasaas-cloudsm:1.0.0 ibmcom/wasaas-wasdevaas:1.0.0 ibmcom/wasaas-console:1.0.0 couchdb:2.1.1 | Initial Delivery of Community Edition. |
