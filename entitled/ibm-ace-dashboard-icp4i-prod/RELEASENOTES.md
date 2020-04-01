# Breaking Changes

None

# What’s new in IBM App Connect Enterprise certified container Version 3.1.1

In this version of IBM App Connect Enterprise certified container, the following new features are available:

* New interface for creating integration servers without leaving the dashboard. Simplifies the user experience, so fewer steps are required and advanced configuration is hidden until necessary.
* You can now delete an integration server from within the dashboard interface.
* Ability to update a BAR file, including when used in Deployments and StatefulSets.

# Fixes

* None

# Prerequisites

* Requires Red Hat OpenShift Container Platform 4.2

# Documentation

For more information go to [IBM App Connect Enterprise Knowledge Center](https://ibm.biz/ACEv11ContainerDocs)

# Version History

| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------------- | ------------------ | ---------------- | ------- |
| 3.1.1 | Mar 2020 | >=v1.14.0 | = ACE 11.0.0.8-r1 | none | Fix image references |
| 3.1.0 | Mar 2020 | >=v1.14.0 | = ACE 11.0.0.8-r1 | none | Update BAR files, New create server interface, Delete servers in dashboard |
| 3.0.0 | Nov 2019 | >=v1.11.0 | = ACE 11.0.0.6.1 | none | IAM authentication for different roles; `log.format` now defaults to basic |
| 2.2.0 | Oct 2019 | >=v1.11.0 | = ACE 11.0.0.6 | none | No changes to the Dashboard |
| 2.1.0 | Sept 2019 | >=v1.11.0 | = ACE 11.0.0.5.1 | Images specified with tag, `fsGroupGid` moved under security catagory | Support for running as an administrator (to allow Push To API Connect) |
| 2.0.0 | July 2019 | >=v1.11.0 | = ACE 11.0.0.5 | Now runs as user ID 888 when using MQ, Verification of MQSC files | 11.0.0.5 FP Update, Images based on UBI, Supports MQ 9.1.2 |
| 1.1.2 | May 2019 | >=v1.11.1 | = ACE 11.0.0.4 | none  | Fix issues with release name length, Updates ACE version |
| 1.1.1 | May 2019 | >=v1.11.1 | = ACE 11.0.0.4  | none | Updates ACE version |
| 1.1.0 | Jan 2019 | >=v1.11.1 | = ACE 11.0.0.3 | Secrets moved out of helm  | Updates ACE version |
| 1.0.0 | Nov 2018 | >=v1.11.1 | = ACE 11.0.0.2 | none |  Initial Chart |