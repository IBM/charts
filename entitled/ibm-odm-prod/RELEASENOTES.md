# What's new in Helm chart 2.2.1
The version 2.2.1 of the Helm chart installs version 8.10.2.1 of IBM Operational Decision Manager. For a complete list of new features in this release, go to [What's new](https://www.ibm.com/support/knowledgecenter/en/SSQP76_8.10.x/com.ibm.odm.icp/topics/con_whats_new8102.html).

# Prerequisites
1. Kubernetes 1.11 or higher, with Helm 2.9.1 or higher.
1. For the internal database, create a persistent volume or use dynamic provisioning.
1. To secure access to the database, create a secret that encrypts the database user and password.

# Documentation
For more information, go to [Operational Decision Manager knowledge center](https://www.ibm.com/support/knowledgecenter/en/SSQP76_8.10.x/com.ibm.odm.icp/kc_welcome_odm_icp.html)

# Fixes
[Operational Decision Manager Interim Fixes](http://www.ibm.com/support/docview.wss?uid=swg21640630)

# Upgrading
Upgrading from version 2.x.0 to 2.2.1 is transparent.
For details about how to upgrade, see [Upgrading ODM releases](https://www.ibm.com/support/knowledgecenter/SSQP76_8.10.x/com.ibm.odm.icp/topics/tsk_upgrading.html)

# Breaking Changes
* None

# Version History
| Chart | Date     | Details                           |
| ----- | -------- | --------------------------------- |
| 2.2.1 | Sept 2019 | Network policy security isolation |
| 2.2.0 | June 2019 | ODM 8.10.2 release - UBI base image |
| 2.1.0 | March 2019 | ODM 8.10.1 release - Support for non-root  |
| 2.0.0 | Dec 2018 | ODM 8.10.0 release - Monitoring and HA improvements |
| 1.1.0 | July 2018 | ODM 8.9.2.1 release - Logging improvement and PVU pricing                |
| 1.0.1 | March 2018 | ODM 8.9.2.0 interim fix - ZLinux support (s390)               |
| 1.0.0 | March 2018 | First full release ODM 8.9.2.0                |
