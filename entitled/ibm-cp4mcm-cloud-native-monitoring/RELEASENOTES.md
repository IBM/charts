# Release Notes for icam-clouddc-klusterlet
This document describes the latest changes, additions, known issues, and fixes for icam-clouddc-klusterlet.
___
## About
* ICAM klusterlet to configure and receive kubernetes cluster events and report to Event Management and Monitoring services on CP4MCM hub clusters. 

## What's new in version 1.2.0
* Red Hat OpenShift 4.2 support 
* Support AMD64, PPC64le and S390x environments

## Fixes
* Simplify installation parameters.
* Boot kubenetest monitor when event is ready.

## Prerequisites
* [IBM Cloud App Management server within CP4MCM installed on the hub cluster](https://www.ibm.com/support/knowledgecenter/SSFC4F_1.2.0/kc_welcome_cloud_pak.html)

* [IBM Multicloud Manager klusterlet installed](https://www.ibm.com/support/knowledgecenter/SSFC4F_1.2.0/mcm/installing/install_k8s_cloud.html)


## Breaking Changes
NA

## Documentation
[ICAM klusterlet installation instructions](https://www.ibm.com/support/knowledgecenter/SS8G7U_19.4.0/com.ibm.app.mgmt.doc/content/install_mcm_klusterlet.html?cp=SSFC4F_1.2.0).

[ICAM klusterlet uninstallation instructions](https://www.ibm.com/support/knowledgecenter/SS8G7U_19.4.0/com.ibm.app.mgmt.doc/content/uninstall_mcm_klusterlet.html?cp=SSFC4F_1.2.0).

___
## Version History
| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- |
| 1.0.0 | June, 2019 | >=1.11.0 | 1.0.0-* | None | Support for MCM 3.2 |
| 1.1.0 | Sep, 2019 | >=1.11.0 | 1.0.0-* | None | Support for MCM 3.2.1 |
| 1.2.0 | Dec, 2019 | >=1.11.0 | 1.0.0-* | None | Support for MCM 3.2 |
| 1.2.1 | Mar, 2020 | >=1.11.0 | 1.0.0-* | None | Support to set pull secret |
