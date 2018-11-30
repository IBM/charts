# What's new in Helm chart 2.0.0
The version 2.0.0 of the Helm chart installs version 8.10.0.0 of IBM Operational Decision Manager. For a complete list of new features in this release, go to https://www.ibm.com/support/knowledgecenter/en/SSQP76_8.10.0/com.ibm.odm.distrib.overview/shared_whatsnew_topics/con_whats_new.html

# Prerequisites
1. Kubernetes 1.10 or higher, with Helm 2.7.2 or higher.
1. For the internal database, create a persistent volume or use dynamic provisioning.

# Upgrading
When you upgrade the ibm-odm-dev chart from one version to another, if you want to keep your existing data, you must uncheck the "Populate sample data" option.
Otherwise, the database is recreated with the original sample data and you lose the data generated with the previous version of the chart (reports on the sample project, new decision services...).

# Fixes
[Operational Decision Manager Interim Fixes](https://www-01.ibm.com/support/docview.wss?uid=ibm10715925)

# Version history
| Chart | Date     | Details                           |
| ----- | -------- | --------------------------------- |
| 2.0.0 | Dec 2018 | New release ODM 8.10.0.0               |
| 1.1.0 | July 2018 | Fix pack 8.9.2.1                |
| 1.0.0 | March 2018 | First full release ODM 8.9.2.0               |
