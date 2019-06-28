# Release Notes for IBM® Cloud Event Management

This document describes the latest changes, additions, known issues, and fixes for IBM® Cloud Event Management.
___
## About
* Use the IBM® Cloud Event Management service to set up real-time incident management for your services, applications, and infrastructure.
* Restore service and resolve operational incidents fast!
* Empower your DevOps teams to correlate different sources of events into actionable incidents, synchronize teams, and automate incident resolution.
* The service sets you on course to achieve efficient and reliable operational health, service quality and continuous improvement.

## What's new in version 2.3.0
* IBM certified container
* Red Hat OpenShift support
* Event enrichment using lookup tables
* Event forwarding to Netcool Operations Insight
* Backup and restore
* Integrate with VMware vSphere
* Enhanced integration with Microsoft Azure
* Assign runbooks to groups to manage runbook access for users
* Integration of Netcool Operations Insight with Cloud Event Management. Define triggers to connect events in Netcool/OMNIbus to runbooks. You can launch a runbook in Cloud Event Management from the Web GUI Event Viewer in Netcool/OMNIbus
* New menu item and API to create and manage Triggers

## Fixes
* Miscellaneous fixes to support MCM and ICP 3.2

## Prerequisites
* IBM® Cloud Private 3.2
* Cluster admin privilege is required for OIDC registration, cluster security policies and service broker
* The default storage class is used.  See the Storage section in Chart readme

## Breaking Changes
* If using email or nexmo notification capabilities, before upgrading from <2.2.0, create the secrets described in the chart readme (<release-name>-cem-email-auth-secret, <release-name>-cem-nexmo-auth-secret) when applicable
* Due to a duplicate environment variable that was removed in version 2.3.0, performing a rollback from 2.3.0 to a previous version will require the `--force` flag
* The rba-rbs pod has increased its memory consumption from 1 GB to 1.5 GB per instance

## Documentation
For detailed upgrade instructions go to [https://www.ibm.com/support/knowledgecenter/en/SSURRN/com.ibm.cem.doc/em_cem_icpupgrade.html](https://www.ibm.com/support/knowledgecenter/en/SSURRN/com.ibm.cem.doc/em_cem_icpupgrade.html)
___
## Version History
| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- |
| 2.3.0 | June, 2019| >=1.11.1 | 1.5.0-* | None | IBM certified container and Red Hat OpenShift support support |
| 2.2.1 | May, 2019| >=1.11.1 | 1.4.1-* | None | Product fixes to support MCM and ICP 3.2 (MCM release only) |
| 2.2.0 | Mar, 2019| >=1.11.1 | 1.4.0-* | None | Product fixes and ppc64le architecture support |
| 2.1.1 | Feb, 2019| >=1.11.1 | 1.3.0-* | None | ppc64le architecture support (MCM release only) |
| 2.1.0 | Dec, 2018| >=1.8.3 | 1.3.0-* | None | Product fixes. Initial release of chart as an IBM container |
| 2.0.0 | Sept, 2018| >=1.8.3 | 1.2.0-* | None | The initial release of the try and buy of IBM® Cloud Event Management Enterprise Edition  |
| 1.0.0 | June, 2018| >=1.7.3 | 1.1.0-* | None  | The initial release of IBM® Cloud Event Management Community Edition |
