# What's new in Helm chart 21.3.0
The version 21.3.0 of the Helm chart installs version 8.11.0 of IBM Operational Decision Manager. For a complete list of new features in this release, go to [What's new](https://www.ibm.com/docs/en/odm/8.11.0?topic=notes-whats-new)

# Prerequisites
1. Kubernetes 1.19 or higher, with Helm 3.2 or higher.
2. For the internal database, create a persistent volume or use dynamic provisioning.

# Documentation
For more information go to [Operational Decision Manager on Certified Kubernetes knowledge center](https://www.ibm.com/docs/en/odm/8.11.0?topic=operational-decision-manager-certified-kubernetes-8110)

# Breaking Changes
* None

# Upgrading
- When you upgrade the ibm-odm-dev chart from one version to another, if you want to keep your existing data, you must uncheck the "Populate sample data" option.

  Otherwise, the database is recreated with the original sample data and you lose the data generated with the previous version of the chart (reports on the sample project, new decision services...).

- Default users password
  You must now define a password to be used by the default user **odmAdmin**. Set the parameter `usersPassword` in your `helm install` command.

# Fixes
[Operational Decision Manager Interim Fixes](http://www.ibm.com/support/docview.wss?uid=swg21640630)

# Version History
| Chart | Date     | Details                           |
| ----- | -------- | --------------------------------- |
| 21.3.0 | Dec 2021 | ODM 8.11.0 release - Update Liberty version, Require password for default user access, Add user access configuration, Update default repository to `icr.io/odm-k8s`, Define ephemeral storage default values |
| 21.2.0 | June 2021 | ODM 8.10.5.1 release |
| 21.1.0 | March 2021 | Bug fixing, Default values update, Helm Chart values validation with JSON Schemas |
| 20.3.0 | Dec 2020 | ODM 8.10.5 release - Require license acceptation, Add default custom serviceAccount, Support `restricted` scc in Openshift, Digest support, Automate route creation for Openshift |
| 20.2.0 | June 2020 | ODM 8.10.4 release - Update Liberty version |
| 2.3.0 | Dec 2019 | Bug fixing |
| 2.2.1 | Sept 2019 | Network policy security isolation |
| 2.2.0 | June 2019 | ODM 8.10.2 release - UBI base image |
| 2.1.0 | March 2019 | ODM 8.10.1 release - Support for non-root  |
| 2.0.0 | Dec 2018 | New release ODM 8.10.0.0               |
| 1.1.0 | July 2018 | Fix pack 8.9.2.1                |
| 1.0.0 | March 2018 | First full release ODM 8.9.2.0               |
