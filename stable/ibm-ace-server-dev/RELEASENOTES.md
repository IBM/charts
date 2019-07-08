# Breaking Changes

When using the ACE & MQ image:
  * This runs as user ID 888. If you are upgrading from a previous release, you need to set security.initVolumeAsRoot to true to enable changes to persistent file ownership. You should then perform another upgrade to remove this setting.
  * MQSC files supplied will be verified before being run. Files containing invalid MQSC will cause the container to fail to start.
* When upgrading from previous versions, if values for paramters are copied, some parameters will need to be manually updated to match your existing deployment.

| Previous parameter  | Current parameter                     |
|---------------------|---------------------------------------|
| fsGroupGid          | integrationServer.fsGroupGid          |
| configurationSecret | integrationServer.configurationSecret |
| replicaCount        | aceonly.replicaCount                  |
| queueManager.name   | acemq.qmname                          |

# What’s new in Chart Version 2.0.0

With IBM App Connect Enterprise Chart for Kubernetes environments, the following new features
are available:

* Image based on UBI
* Supports MQ 9.1.2 images
* Uses App Connect Enterprise v11.0.0.5

# Fixes

FIXES TBC

# Prerequisites

* The following IBM Platform Core Service is required: tiller

# Documentation

For more information go to [App Connect Enterprise Knowledge Center](https://www.ibm.com/support/knowledgecenter/en/SSTTDS_11.0.0/com.ibm.etools.mft.doc/bz91410_.htm)


# Version History

| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------------- | ------------------ | ---------------- | ------- |
| 2.0.0 | July 2019 | >=v1.11.0 | = ACE 11.0.0.5 | Now runs as user ID 888 when using MQ<br>Verification of MQSC files<br>Some values renamed | 11.0.0.5 FP Update<br>Image based on UBI <br>Supports MQ 9.1.2 |
| 1.1.2 | May 2019 | >=v1.11.1 | = ACE 11.0.0.4 | none  | Pick up bug fix |
| 1.1.1 | May 2019 | >=v1.11.1 | = ACE 11.0.0.4  | none | Updates ACE version<br>Import of odbc files fixed<br>RestAPI viewer update to present correct hostname & port<br>Fix issues with release name length |
| 1.1.0 | Jan 2019 | >=v1.11.1 | = ACE 11.0.0.3 | Secrets moved out of helm  | Updates ACE version |
| 1.0.0 | Nov 2018 | >=v1.11.1 | = ACE 11.0.0.2 | none |  Initial Chart |