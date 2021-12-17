# What's new in Helm chart 21.3.0
The version 21.3.0 of the Helm chart installs version 8.11.0 of IBM Operational Decision Manager. For a complete list of new features in this release, go to [What's new](https://www.ibm.com/docs/en/odm/8.11.0?topic=notes-whats-new).

# Prerequisites
1. Kubernetes 1.19 or higher, with Helm 3.2 or higher.
2. For the internal database, create a persistent volume or use dynamic provisioning.
3. To secure access to the database, create a secret that encrypts the database user and password.

# Documentation
For more information, go to [Operational Decision Manager on Certified Kubernetes knowledge center](https://www.ibm.com/docs/en/odm/8.11.0?topic=operational-decision-manager-certified-kubernetes-8110)

# Fixes
[Operational Decision Manager Interim Fixes](http://www.ibm.com/support/docview.wss?uid=swg21640630)

# Upgrading

For details about how to upgrade, see [Upgrading ODM releases](https://www.ibm.com/docs/en/odm/8.11.0?topic=kubernetes-upgrading-odm-releases-certified)


# Breaking Changes
 None

# Version History
| Chart | Date     | Details                           |
| ----- | -------- | --------------------------------- |
| 21.3.0 | Dec 2021 | ODM 8.11.0 release - Update Liberty version, Profiles documentation, Add Decision Server Runtime `web.xml` configuration, Define ephemeral storage default values, Bug fixes |
| 21.2.0 | June 2021 | ODM 8.10.5.1 release - Support airgap installation with entitled registry, Bug fixes |
| 21.1.0 | March 2021 | ODM 8.10.5 IFix 03 release - Add trusted certificate list management, Default service type update if route enabled |
| 20.3.0 | Dec 2020 | ODM 8.10.5 release - Add default custom serviceAccount, Support `restricted` scc in Openshift, Microsoft SQL Server 2019 support, PostgreSQL version 12 support, Digest support, Automate Ingress creation to access ODM services, Decision Server Console title configuration |
| 20.2.1 | Sept 2020 | Security update, Bug fixes |
| 20.2.0 | June 2020 | ODM 8.10.4 release - Update Liberty version, OpenID integration, Xu configuration, Automate route creation for Openshift, Improve NetworkPolicies, Ability to populate sample data |
| 2.3.0 | Dec 2019 | Add logging / jvm options customization. - Change minimum memory for Decision Center |
| 2.2.1 | Sept 2019 | Network policy security isolation |
| 2.2.0 | June 2019 | ODM 8.10.2 release - UBI base image |
| 2.1.0 | March 2019 | ODM 8.10.1 release - Support for non-root  |
| 2.0.0 | Dec 2018 | ODM 8.10.0 release - Monitoring and HA improvements |
| 1.1.0 | July 2018 | ODM 8.9.2.1 release - Logging improvement and PVU pricing                |
| 1.0.1 | March 2018 | ODM 8.9.2.0 interim fix - ZLinux support (s390)               |
| 1.0.0 | March 2018 | First full release ODM 8.9.2.0                |
