# What's new in Chart Version 2.0.0

## New features

- Passport Advantage Edition with full support
- Support for IBM Cloud Private Version 3.1
- Integrated WebSphere Migration Toolkit support
- Simplified installation: reduced configuration parameters
- Chart can now be installed in user choosen namespace

## Breaking Changes
  - Separately named charts for Passport Advantage (`ibm-was-vm-quickstarter-prod`) and Community Edition (`ibm-was-vm-quickstarter-dev`).  The previous Community Edition 1.0.1 chart (`ibm-was-vm-quickstarter`) will be deprecated.

# What's new in Chart Version 1.0.1
## New features

- Support for WebSphere Application Server traditional 9.0.0.8 and Liberty 18.0.0.2
- Support for Java fix pack 8.0.5.15
- New `get_db_doc.py` troubleshooting script for dumping the contents of the WAS VM Quickstarter CouchDB database

### Deployment enhancements

- Enhanced post-installation tests for verifying your deployment
- Reduced Helm package size by adding `*.png` to the `.helmignore` file
- Simplified the `values.yml` file by moving internal service port values

## Breaking Changes
  - None

## Fixes

### `wasaas-broker` container

- Fixed a null pointer exception in the UI for failed subscriptions
- Fixed VM guest size selection for Portuguese
- Fixed a quota error message for IBM Cloud Private

### `wasaas-cloudsm` container

- Fixed erroneous timing window that caused IPs to be serially reused too soon
- Fixed a null pointer exception from the `wasaas-cloudsm-backend` pod querying VM state in Cloud Automation Manager
- Fixed resource failures cause by special characters in the generated password
- Fixed a `java.lang.IllegalStateException` exception in the `was-cloudsm-backend` pod
- Fixed Linux version checking that was too strict

### `wasaas-devops` container

- Optimized Terraform template to exclude the `embeddablecontainer` feature of Liberty guest VMs.

# Prerequisites
  - Refer to [Prerequisities of WAS Quickstarter](http://ibm.biz/WASQuickstarterPrerequisites)

# Known Issues
  - The Docker image tag names are rendered incorrectly when deploying the Helm chart using the IBM Cloud Private UI. The Helm chart will be deployed with the correct image tags if those fields in the UI are left unmodified.
  - As the resources used by WAS VM Quickstarter virtual machines reach the capacity specified in the Helm chart, the service will automatically indicate to users trying to create a new service that there is not enough resources to complete their request.   While the service instance is created, it is placed in `PENDING` state.  When more capacity is added to the target vCenter Datacenter or other services instances have been cancelled making more capacity available, the service instances are left in `PENDING` state.  These service instances can be safely deleted and the user can reattempt creating a new service instance.

# Version History

| Chart | Date | IBM Cloud Private Required | CAM Required | Image(s) Supported |  Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- |
| 2.0.0 | Sept 30, 2018 | >=3.1.0 | >=3.1.0 | ibmcom/wasaas-devops:2.0 ibmcom/wasaas-cloudsm:2.0 ibmcom/wasaas-wasdevaas:2.0 ibmcom/wasaas-console:2.0 couchdb:2.1.1 | Simplified configuration - fewer config parameters, migration support, installation in non-default namespace, bug fixes |
| 1.0.1 | Aug 15, 2018  | >=2.1.0.3 | >=2.1.0.2 | ibmcom/wasaas-devops:1.0.1 ibmcom/wasaas-cloudsm:1.0.1 ibmcom/wasaas-wasdevaas:1.0.1 ibmcom/wasaas-console:1.0.1 couchdb:2.1.1 | New WebSphere and Java fix packs and database troubleshooting script, plus fixes. |
| 1.0.0 | Jun 29, 2018  | >=2.1.0.3 | >=2.1.0.2 |  ibmcom/wasaas-devops:1.0.0 ibmcom/wasaas-cloudsm:1.0.0 ibmcom/wasaas-wasdevaas:1.0.0 ibmcom/wasaas-console:1.0.0 couchdb:2.1.1 | Initial Delivery of Community Edition. |
