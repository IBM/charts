# Release Notes for IBM® Cloud App Management

This document describes the latest changes, additions, known issues, and fixes for IBM® Cloud App Management.
___
## About
IBM® Cloud App Management offers a comprehensive infrastructure monitoring solution. It's a cloud-native platform built on modern technology and microservices architecture. If you're already using IBM Cloud APM, IBM Tivoli® Monitoring, or IBM Tivoli Composite Application Manager, Cloud App Management guides you forward

## What's new in version 2019.3.0
> **Note:** Chart version 1.5.0

  - Integrated monitoring of workloads with IBM Multicloud Management
  - Integrated monitoring of workloads with Agile Service Manager
  - Grouping and Complex Threshold
  - Logfile Monitoring
  - Synthetic testing of APIs
  - Addition of USE signals for delivered agents
  - Custom Slots for events/incidents
  - Offline Alerting
  - Transaction Tracking (POC/Demo)
## Fixes
  - Remediation of various product defects and CVEs
## Prerequisites
  - IBM Cloud Private 3.2.1
  - System admin and Cluster admin roles are required
  - Persistent Storage -- see the Storage and Installation sections in Chart readme
## Breaking Changes
  - Addition of ElasticSearch introduces new persistent storage requirement and vm.max_map_count minimum value.
## Version History

| App | Chart | Date | Kubernetes Required | Breaking Changes | Details |
| --- | ----- | ---- | ------------------- | ---------------- | ------- |
| 2019.3.0 | 1.5.0 | 09/20/2019 | >= 1.11.0 | Addition of ElasticSearch introduces new persistent storage requirement and vm.max_map_count minimum value. | Major refresh of ICAM including multiple functional improvements and additional capabilities.  |
| 2019.2.1 | 1.4.0 | 06/28/2019 | >= 1.11.0 | None | Major refresh of ICAM including security remediation, defect remediation, HA support, and performance improvements. |
| 2019.2.0 | 1.3.0 | 04/26/2019 | >= 1.11.1 | StatefulSet uid changes; includes preUpgrade.sh for workaround | |
| 2018.4.1 | 1.2.1 | 12/14/2018 | >=1.11.1 | StatefulSet uid changes ; FixCentral documentation | |
| 2018.4.0 | 1.2.0 | 10/31/2018 | >=1.11.1 | None | Major refresh of ICAM including security remediation, defect remediation, and many feature deliveries |
| 2018.2.0 | 1.0.1 | 07/31/2018 | >=1.10 | None | Initial release of ICAM for running on ICP for monitoring traditional and cloud resources |
