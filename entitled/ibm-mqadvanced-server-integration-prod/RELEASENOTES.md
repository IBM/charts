# Breaking Changes

- Authorization for the MQ Web Console is now controlled by IAM roles; configuring access via `sso.webAdminUsers` is no longer supported.  To access the MQ Web Console you must now either have the `administrator` role for the namespace where MQ is deployed or have the cluster-administrator role.
- The deprecated `tls.secret` configuration option has now been removed.  If you are upgrading from a previous release, and have this value set, then you must now set `pki.keys` instead.

# What’s new in the MQ Advanced for Cloud Pak for Integration Chart, Version 6.0.x

- Updated to IBM MQ 9.1.4
- Added IAM based authorization for single sign-on to the MQ Web Console
- Added an option to enable MQ trace on the startup of the queue manager
- Added an option to modify the termination grace period
- Updated to use UBI 8 base image

# Fixes

- None

# Prerequisites

- OpenShift Container Platform v4.2 and v4.3 (Kubernetes 1.14 & 1.16)
- The following IBM Platform Core Services are required: `tiller` & `auth-idp`

# Documentation

- [What's new and changed in IBM MQ Version 9.1.x](https://www.ibm.com/support/knowledgecenter/en/SSFKSJ_9.1.0/com.ibm.mq.pro.doc/q113110_.htm)
- When upgrading from a previous version of this chart, you will experience a short outage, while the old Queue Manager container is replaced.  Client applications which are set to automatically reconnect should recover within seconds or minutes.

# Version History

| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- |
| 6.0.0 | March 2020 | >= 1.14.0 | = MQ 9.1.4.0 | Authorization for the MQ Web Console; Removed `tls.secret` | Updated to IBM MQ 9.1.4; IAM based authorization for MQ Web Console; Added optional MQ trace on startup of queue manager; Added optional termination grace period setting; Updated to use UBI 8 base image |
| 5.0.0 | November 2019 | >= 1.14.0 | = MQ 9.1.3.0 | Use OpenShift Routes instead of NodePorts | Added OpenShift Routes for the web console & queue manager; `log.format` now defaults to `basic` |
| 4.1.0 | October 2019 | >= 1.11.0 | = MQ 9.1.3.0 | None | Operations Dashboard |
| 4.0.2 | October 2019 | >= 1.11.0 | = MQ 9.1.3.0 | None | SSO fix for ICP 3.2.1 IAM change; README updates |
| 4.0.1 | September 2019 | >= 1.11.0 | = MQ 9.1.3.0 | None | SSO fix for ICP IAM bug; Updated go-toolset to version 1.11.13 |
| 4.0.0 | September 2019 | >= 1.11.0 | = MQ 9.1.3.0 | ICP4I Namespace | Entitled Catalog & Registry; Header-as-a-Service |
| 3.0.1 | August 2019 | >= 1.11.0 | = MQ 9.1.3.0 | None | Updated UBI 7 base image |
| 3.0.0 | July 2019 | >= 1.11.0 | = MQ 9.1.3.0 | TLS settings; Custom PSP/SCC definitions | Updated to IBM MQ 9.1.3; Now runs as Administrator role |
| 2.0.0 | June 2019 | >= 1.10.0 | = MQ 9.1.2.0 | Now runs as user ID 888; Verification of MQSC files | Added support for multi-instance queue managers; Custom labels; Image based on UBI ;  Added TLS certificates mechanism |
| 1.2.2 | May 2019 | >= 1.11.1 | = MQ 9.1.2.0 | None | Updated license |
| 1.2.1 | April 2019 | >= 1.11.1 | = MQ 9.1.2.0 | None | Security fixes, Dashboard fixes, large MQSC fixes |
| 1.2.0 | April 2019 | >= 1.11.1 | = MQ 9.1.2.0 | None | Updated to IBM MQ 9.1.2; Improved security (including running as non-root); Additional IBM Cloud Pak content; README updates; Kibana dashboard fix |
| 1.1.2 | January 2019 | >= 1.11.1 | = MQ 9.1.1.0  | None | Security fixes |
| 1.1.1 | January 2019 | >= 1.11.1 | = MQ 9.1.1.0  | None | Updated license |
| 1.1.0 | December 2018 | >= 1.11.1 | = MQ 9.1.1.0  | None | Declaration of security context requirements; Removed unused values; Documentation updates; Security fixes |
| 1.0.0 | November 2018 | >= 1.9 | = MQ 9.1.1.0  | None | Initial version; Includes single sign-on (SSO) |
