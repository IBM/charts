# What’s new in IBM Netcool/OMNIbus Gateway for Cloud Event Management Chart Version 1.0.0

This Helm chart deploys IBM Netcool/OMNIbus Gateway for Cloud Event Management
onto Kubernetes. This gateway processes events and alerts from
IBM Netcool/OMNIbus ObjectServer and forwards them to IBM Cloud Event Management (CEM) dashboard.

## Introduction

IBM® Netcool® Operations Insight enables IT and network operations teams to increase effectiveness, efficiency
and reliability by leveraging cognitive analytics capabilities to identify, isolate and resolve problems before
they impact your business. It provides a consolidated view across your local, cloud and hybrid environments and
delivers actionable insight into the health and performance of services and their associated dynamic network and
IT infrastructures. More information can be seen here: [IBM Marketplace - IT Operations Management](https://www.ibm.com/uk-en/marketplace/it-operations-management)

## Breaking Changes

None

## Enhancements

Initial version

## Fixes

None

## Prerequisites

1.  Kubernetes 1.11. Verified running on IBM Cloud Private version 3.2.0.
2.  IBM Netcool Operations Insight 1.6.0.1 Helm Chart version 2.1.1. This solution requires IBM Tivoli Netcool/OMNIbus ObjectServer to be created and running prior to installing the chart. To create and run the IBM Tivoli Netcool/OMNIbus ObjectServer, see installation instructions at [IBM Knowledge Center - Installing on IBM Cloud Private](https://www.ibm.com/support/knowledgecenter/en/SSTPTP_1.6.0/com.ibm.netcool_ops.doc/soc/integration/task/int_installing-on-icp.html).
3.  IBM Cloud Event Management Helm Chart 2.4.0.


## Version History

| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| ----- | -----| --------------------| ------------------ | ---------------- | ------- |
| 1.0.0 | Oct 31, 2019 | >=1.11 | netcool-gateway-cem:2.0.5.3-amd64 | None | Initial Release. |

## Change History

### Changes in Version 1.0.0

Initial Release

-   This chart supports IBM CEM on IBM Cloud Private (ibm-cem) version 2.4.0.


## Documentation

- IBM Netcool/OMNIbus Gateway for IBM Cloud Event Management Helm Chart Knowledge Center [page](https://www.ibm.com/support/knowledgecenter/SSSHTQ/omnibus/helms/cloud_event_management/wip/concept/ceminth_intro.html)
