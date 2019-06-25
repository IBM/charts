# Breaking Changes

- Now runs as user ID 888. If you are upgrading from a previous release, you need to set `security.initVolumeAsRoot` to `true` to enable changes to persistent file ownership.  You should then perform another upgrade to remove this setting.
- You must now create a new [Secret](https://kubernetes.io/docs/concepts/configuration/secret/) in the target namespace that contains the 'admin' user password and optionally the 'app' user password to use for messaging.  If you are upgrading from a previous release, you need to set `queueManager.dev.secret.name` to the `name` of your new secret and `queueManager.dev.secret.adminPasswordKey` to the secret `key` that contains the 'admin' user password.  If you previously also set an 'app' user password you must set `queueManager.dev.secret.appPasswordKey` to the secret `key` that contains the 'app' user password.
- MQSC files supplied will be verified before being run. Files containing invalid MQSC will cause the container to fail to start.

# What’s new in the MQ Advanced for Developers Chart, Version 4.0.x

- Added support for multi-instance queue managers
- Custom labels
- Image is now based on Universal Base Image (UBI) version 7
- Added ability to supply TLS Certificates to image for use within queue manager and MQ Console
- Added ability to enable debug output

# Fixes

- None

# Prerequisites

- The following IBM Platform Core Service is required: `tiller`

# Documentation

- [What's new and changed in IBM MQ Version 9.1.x](https://www.ibm.com/support/knowledgecenter/en/SSFKSJ_9.1.0/com.ibm.mq.pro.doc/q113110_.htm)
- When upgrading from a previous version of this chart, you will experience a short outage, while the old Queue Manager container is replaced.  Client applications which are set to automatically reconnect should recover within seconds or minutes.

# Version History

| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- |
| 4.0.0 | June 2019 | >= 1.11.0 | = MQ 9.1.2.0 | Now runs as user ID 888; Password secret required; Verification of MQSC files | Added support for multi-instance queue managers; Custom labels; Image based on UBI; Added TLS certificates mechanism |
| 3.0.1 | March 2019 | >= 1.9 | = MQ 9.1.2.0 | None | Fix capabilities when running init volume as root |
| 3.0.0 | March 2019 | >= 1.9 | = MQ 9.1.2.0 | Set initVolumeAsRoot on IKS | Updated to IBM MQ 9.1.2; Improved security (including running as non-root); Additional IBM Cloud Pak content; Added ILMT annotations; README updates; Kibana dashboard fix |
| 2.2.0 | November 2018 | >= 1.9 | = MQ 9.1.1.0 | None | Updated to IBM MQ 9.1.1 |
| 2.1.0 | September 2018 | >= 1.9 | = MQ 9.1.0.0  | None | Declaration of securityContext; Configurable service account name; New IBM Cloud Pak content |
| 2.0.2 | August 2018 | >= 1.9 | = MQ 9.1.0.0  | None | Fixed error in service selector for helm tests |
| 2.0.1 | July 2018 | >= 1.9 | = MQ 9.1.0.0  | None | Reverted statefulset to apps/v1beta2 to prevent deletion failures |
| 2.0.0 | July 2018    | >= 1.9 | = MQ 9.1.0.0  | New Kubernetes resource names and labels | Added metrics service |
| 1.3.0 | May 2018     | >= 1.6 | = MQ 9.0.5.0  | None | Added POWER and z/Linux support |
| 1.2.1 | Apr 30, 2018 | >= 1.6 | >= MQ 9.0.4.0 | None | README fixes |
| 1.2.0 | Apr 3, 2018  | >= 1.6 | >= MQ 9.0.4.0 | None | Added liveness and readiness probes; Optional JSON logging; New README format |
| 1.0.2 | Nov 6, 2017  | >= 1.6 | >= MQ 9.0.3.0 | None | Updates for MQ 9.0.4.0 |
| 1.0.1 | Oct 25, 2017 | >= 1.6 | MQ 9.0.3.0    | None | Initial version |
