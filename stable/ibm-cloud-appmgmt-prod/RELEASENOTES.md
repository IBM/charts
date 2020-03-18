# Release Notes for IBM® Cloud App Management

This document describes the latest changes, additions, known issues, and fixes for IBM® Cloud App Management.
___
## About
IBM® Cloud App Management offers a comprehensive infrastructure monitoring solution. It's a cloud-native platform built on modern technology and microservices architecture. If you're already using IBM Cloud APM, IBM Tivoli® Monitoring, or IBM Tivoli Composite Application Manager, Cloud App Management guides you forward.

## What's new in version 2019.4.0
> **Note:** Chart version 1.6.0
For more details see [What's new for Version 2019.4.0](https://ibm.biz/app-mgmt-what-new)
  - Red Hat OpenShift 4.2 support (AMD64 environments)
  - Entitled Registry installation support
  - Baselining of resource metrics (technical preview)


## Fixes
  - Security fixes
  - Various bug fixes

## Prerequisites
  - IBM® Cloud Private 3.2
  - Cluster admin privilege is required for OIDC registration, cluster security policies and service broker

## Documentation
  - For more details see the [IBM® Cloud App Management](http://ibm.biz/app-mgmt-kc) product documentation

## Version History

| App | Chart | Date | Kubernetes Required | Breaking Changes | Details |
| --- | ----- | ---- | ------------------- | ---------------- | ------- |
| 2019.4.0 | 1.6.0 | 12/13/2019 | >= 1.11.0 | None | Product fixes and UI enhacements. Red Hat OpenShift 4.2 support (AMD64 environments) |
| 2019.3.0 | 1.5.0 | 09/20/2019 | >= 1.11.0 | Addition of ElasticSearch introduces new persistent storage requirement and vm.max_map_count minimum value. | Major refresh of ICAM including multiple functional improvements and additional capabilities.  |
| 2019.2.1 | 1.4.0 | 06/28/2019 | >= 1.11.0 | None | Major refresh of ICAM including security remediation, defect remediation, HA support, and performance improvements. |
| 2019.2.0 | 1.3.0 | 04/26/2019 | >= 1.11.1 | StatefulSet uid changes; includes preUpgrade.sh for workaround | |
| 2018.4.1 | 1.2.1 | 12/14/2018 | >=1.11.1 | StatefulSet uid changes ; FixCentral documentation | |
| 2018.4.0 | 1.2.0 | 10/31/2018 | >=1.11.1 | None | Major refresh of ICAM including security remediation, defect remediation, and many feature deliveries |
| 2018.2.0 | 1.0.1 | 07/31/2018 | >=1.10 | None | Initial release of ICAM for running on ICP for monitoring traditional and cloud resources |
