# Breaking Changes

- To upgrade from an existing 9.1.4 Queue Manager, you will need to add the 888 group as a supplemental group prior to the upgrade. This is to allow file permissions to be updated in line with no longer running as a user in the MQM group. To upgrade from an existing installation called `my-release`, you can upgrade with the following command:
```
helm upgrade --reuse-values my-release ibm-entitled-charts/ibm-mqadvanced-server-prod --version 5.0.0 --set security.context.supplementalGroups={888} && \
helm upgrade my-release ibm-entitled-charts/ibm-mqadvanced-server-prod --version 6.0.0
```
*This assumes that you have previously added the entitled Helm repository as a remote Helm repository. If you have not yet added the entitled Helm repository as a remote Helm repository, you can do so by running the following command:*
```
helm repo add ibm-entitled-charts https://raw.githubusercontent.com/IBM/charts/master/repo/entitled
```

To remove the 888 supplemental group from your upgraded Helm release, you can run the following command:
```
helm upgrade --reuse-values my-release ibm-entitled-charts/ibm-mqadvanced-server-prod --version 6.0.0 --set security.context.supplementalGroups={}
```

# What’s new in the MQ Advanced Chart, Version 6.0.x

- Updated to IBM MQ 9.1.5
- No longer required to run as MQM user, can run as a random UID
- Added an option to enable MQ trace on the startup of the queue manager
- Added an option to modify the pod termination grace period

# Fixes

- None

# Prerequisites

- OpenShift Container Platform v3.11, v4.2 and v4.3 (Kubernetes 1.11, 1.14 & 1.16) on AMD64

# Documentation

- [What's new and changed in IBM MQ Version 9.1.x](https://www.ibm.com/support/knowledgecenter/en/SSFKSJ_9.1.0/com.ibm.mq.pro.doc/q113110_.htm)
- When upgrading from a previous version of this chart, you will experience a short outage, while the old Queue Manager container is replaced.  Client applications which are set to automatically reconnect should recover within seconds or minutes.

# Version History

| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- |
| 6.0.0 | April 2020 | >= 1.11.0 | = MQ 9.1.5.0 | Run as a random UID | Updated to IBM MQ 9.1.5; No longer required to run as MQM user, can run as a random UID; Added an option to enable MQ trace on the startup of the queue manager; Added an option to modify the pod termination grace period |
| 5.0.0 | December 2019 | >= 1.11.0 | = MQ 9.1.4.0 | Use OpenShift Routes instead of NodePorts | Updated to IBM MQ 9.1.4; Entitled Catalog & Registry; Added an OpenShift Route for the queue manager; Added a Service Account; `log.format` now defaults to `basic` |
| 4.1.2 | September 2019 | >= 1.11.0 | = MQ 9.1.3.0 | None | Updated go-toolset to version 1.11.13 |
| 4.1.1 | August 2019 | >= 1.11.0 | = MQ 9.1.3.0 | None | Updated UBI 7 base image |
| 4.1.0 | July 2019 | >= 1.11.0 | = MQ 9.1.3.0 | None | Updated to IBM MQ 9.1.3 |
| 4.0.0 | June 2019 | >= 1.11.0 | = MQ 9.1.2.0 | Now runs as user ID 888; Verification of MQSC files | Added support for multi-instance queue managers; Custom labels; Image based on UBI; Added TLS certificates mechanism |
| 3.0.2 | April 2019 | >= 1.9 | = MQ 9.1.2.0 | None | Security fixes, Dashboard fixes, large MQSC fixes |
| 3.0.1 | March 2019 | >= 1.9 | = MQ 9.1.2.0 | None | Fix capabilities when running init volume as root |
| 3.0.0 | March 2019 | >= 1.9 | = MQ 9.1.2.0 | Set initVolumeAsRoot on IKS | Updated to IBM MQ 9.1.2; Improved security (including running as non-root); Additional IBM Cloud Pak content; Added ILMT annotations; README updates; Kibana dashboard fix |
| 2.2.2 | January 2019 | >= 1.9 | = MQ 9.1.1.0  | None | Security fixes |
| 2.2.1 | December 2018 | >= 1.9 | = MQ 9.1.1.0  | None | Security fixes |
| 2.2.0 | November 2018 | >= 1.9 | = MQ 9.1.1.0  | None | Updated to IBM MQ version 9.1.1 |
| 2.1.0 | September 2018 | >= 1.9 | = MQ 9.1.0.0  | None | Declaration of securityContext; Configurable service account name; New IBM Cloud Pak content |
| 2.0.2 | August 2018 | >= 1.9 | = MQ 9.1.0.0  | None | Fixed error in service selector for helm tests |
| 2.0.1 | July 2018 | >= 1.9 | = MQ 9.1.0.0  | None | Reverted statefulset to apps/v1beta2 to prevent deletion failures |
| 2.0.0 | July 2018 | >= 1.9 | = MQ 9.1.0.0  | New Kubernetes resource names and labels | Added metrics service |
| 1.3.0 | May 2018  | >= 1.6 | = MQ 9.0.5.0  | None | Added POWER and z/Linux support |
| 1.2.2 | Apr 2018  | >= 1.6 | >= MQ 9.0.4.0 | None | README fixes |
| 1.2.1 | Apr 2018  | >= 1.6 | >= MQ 9.0.4.0 | None | README fixes |
| 1.2.0 | Mar 2018  | >= 1.6 | >= MQ 9.0.4.0 | None | Added JSON logging; New README format |
| 1.1.0 | Nov 2017  | >= 1.6 | >= MQ 9.0.3.0 | None | Updates for MQ 9.0.4.0 |
| 1.0.1 | Oct 2017  | >= 1.6 | MQ 9.0.3.0    | None | Initial version |
