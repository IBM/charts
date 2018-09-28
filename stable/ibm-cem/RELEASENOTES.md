# Release Notes for IBM® Cloud Event Management

This document describes the latest changes, additions, known issues, and fixes for IBM® Cloud Event Management.
___
## About
* Use the IBM® Cloud Event Management service to set up real-time incident management for your services, applications, and infrastructure.
* Restore service and resolve operational incidents fast!
* Empower your DevOps teams to correlate different sources of events into actionable incidents, synchronize teams, and automate incident resolution.
* The service sets you on course to achieve efficient and reliable operational health, service quality and continuous improvement.

## What's new in version 2.0.0
* Try IBM® Cloud Event Management in IBM® Cloud Private as a Community Edition with limited restrictions and easily upgrade to the supported, unlimited Enterprise Edition.
* Use notification overrides within your incident policies to easily adapt notifications to changing situations.
* New integrations including GitHub, Urban Code Deploy, Microsoft Teams, ServiceNow, Stride, and Watson Workspace.
* Create custom templates for an event to override the built-in template used by Cloud Event Management.
* A new API key permission option to access the Runbook Automation API. 

## Fixes
* Resolved an issue where Redis sentinel pods were crashing after installing Cloud Event Management in IBM® Cloud Private.

## Prerequisites
* IBM® Cloud Private 2.1.0.3 or greater

## Documentation
For detailed upgrade instructions go to https://www.ibm.com/support/knowledgecenter/en/SSURRN/com.ibm.cem.doc/em_cem_icpupgrade.html.
___
## Version History
| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- | 
| 2.0.0 | Sept, 2018| >=1.8.3 | 1.2.0-* | None | The initial release of the try and buy of IBM® Cloud Event Management Enterprise Edition.  |
| 1.0.0 | June, 2018| >=1.7.3 | 1.1.0-* | None  | The initial release of IBM® Cloud Event Management Community Edition. |
