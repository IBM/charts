# Release Notes for IBM® Cloud Event Management

This document describes the latest changes, additions, known issues, and fixes for IBM® Cloud Event Management.
___
## About
* Use the IBM® Cloud Event Management service to set up real-time incident management for your services, applications, and infrastructure.
* Restore service and resolve operational incidents fast!
* Empower your DevOps teams to correlate different sources of events into actionable incidents, synchronize teams, and automate incident resolution.
* The service sets you on course to achieve efficient and reliable operational health, service quality and continuous improvement.

## What's new in version 2.2.0
* ppc64le architecture support (fat manifest)
* Additional incoming integration (Alert Notification)
* Removal of outgoing integrations (Watson Workspace and Stride)

## Fixes
* Miscellaneous product fixes.

## Prerequisites
* IBM® Cloud Private 3.1.1 or higher
* Cluster admin privilege is required for OIDC registration, cluster security policies and service broker
* The default storage class is used.  See the Storage section in Chart readme.

## Breaking Changes
None

## Documentation
For detailed upgrade instructions go to https://www.ibm.com/support/knowledgecenter/en/SSURRN/com.ibm.cem.doc/em_cem_icpupgrade.html.
___
## Version History
| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- |
| 2.2.0 | Mar, 2019| >=1.11.1 | 1.4.0-* | None | Product fixes and ppc64le architecture support. |
| 2.1.1 | Feb, 2019| >=1.11.1 | 1.3.0-* | None | ppc64le architecture support (MCM release only). |
| 2.1.0 | Dec, 2018| >=1.8.3 | 1.3.0-* | None | Product fixes. Initial release of chart as IBM Cloud Pak. |
| 2.0.0 | Sept, 2018| >=1.8.3 | 1.2.0-* | None | The initial release of the try and buy of IBM® Cloud Event Management Enterprise Edition.  |
| 1.0.0 | June, 2018| >=1.7.3 | 1.1.0-* | None  | The initial release of IBM® Cloud Event Management Community Edition. |
