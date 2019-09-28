# Release Notes for IBM® Cloud Event Management

This document describes the latest changes, additions, known issues, and fixes for IBM® Cloud Event Management.
___
## About
* Use the IBM® Cloud Event Management service to set up real-time incident management for your services, applications, and infrastructure.
* Restore service and resolve operational incidents fast!
* Empower your DevOps teams to correlate different sources of events into actionable incidents, synchronize teams, and automate incident resolution.
* The service sets you on course to achieve efficient and reliable operational health, service quality and continuous improvement.

## What's new in version 2.4.0
* Enhanced Incidents view
* External event enrichment (Multicloud Manager release only)
* Enhanced Netcool/OMINbus Gateway for Cloud Event Management
* Ansible Tower integration added to runbooks
* Performance improvements

## Fixes
* Microservices have been updated to use NodeJS 10.16.3
* Security fixes

## Prerequisites
* IBM® Cloud Private 3.2
* Cluster admin privilege is required for OIDC registration, cluster security policies and service broker
* The default storage class is used.  See the Storage section in Chart readme

## Breaking Changes
None

## Documentation
For more details see the [Cloud Event Management](https://www.ibm.com/support/knowledgecenter/SSURRN/com.ibm.cem.doc/em_whatsnew.html) and [Runbook Automation](https://www.ibm.com/support/knowledgecenter/SSZQDR/com.ibm.rba.doc/GS_whatsnew.html) product documentation.

For detailed upgrade instructions go to [Upgrading in IBM Cloud Private](https://www.ibm.com/support/knowledgecenter/en/SSURRN/com.ibm.cem.doc/em_cem_icpupgrade.html).

___
## Version History
| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- |
| 2.4.0 | Sept, 2019| >=1.11.1 | 1.6.0-* | None | Product fixes and external event enrichment (MCM release only) |
| 2.3.0 | June, 2019| >=1.11.1 | 1.5.0-* | None | IBM certified container and Red Hat OpenShift support support |
| 2.2.1 | May, 2019| >=1.11.1 | 1.4.1-* | None | Product fixes to support MCM and ICP 3.2 (MCM release only) |
| 2.2.0 | Mar, 2019| >=1.11.1 | 1.4.0-* | None | Product fixes and ppc64le architecture support |
| 2.1.1 | Feb, 2019| >=1.11.1 | 1.3.0-* | None | ppc64le architecture support (MCM release only) |
| 2.1.0 | Dec, 2018| >=1.8.3 | 1.3.0-* | None | Product fixes. Initial release of chart as an IBM container |
| 2.0.0 | Sept, 2018| >=1.8.3 | 1.2.0-* | None | The initial release of the try and buy of IBM® Cloud Event Management Enterprise Edition  |
| 1.0.0 | June, 2018| >=1.7.3 | 1.1.0-* | None  | The initial release of IBM® Cloud Event Management Community Edition |
