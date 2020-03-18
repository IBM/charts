# Breaking Changes

None

# What’s new in IBM App Connect Enterprise Chart Version 3.0.0

With IBM App Connect Enterprise dashboard Chart for Kubernetes environments, the following new features are available:

* Support for Red Hat OpenShift Container Platform 4.2
* Dashboard can now use IAM to authenticate users and assign roles

# Fixes

* None

# Prerequisites

* Requires Red Hat OpenShift Container Platform 4.2
* Requires IBM Cloud Pak Foundation 3.2.2

# Documentation

For more information go to [IBM App Connect Enterprise Knowledge Center](https://ibm.biz/ACEv11ContainerDocs)

# Version History

| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------------- | ------------------ | ---------------- | ------- |
| 3.0.0 | Nov 2019 | >=v1.11.0 | = ACE 11.0.0.6.1 | none | IAM authentication for different roles; `log.format` now defaults to basic |
| 2.2.0 | Oct 2019 | >=v1.11.0 | = ACE 11.0.0.6 | none | No changes to the Dashboard |
| 2.1.0 | Sept 2019 | >=v1.11.0 | = ACE 11.0.0.5.1 | Images specified with tag, `fsGroupGid` moved under security catagory | Support for running as an administrator (to allow Push To API Connect) |
| 2.0.0 | July 2019 | >=v1.11.0 | = ACE 11.0.0.5 | Now runs as user ID 888 when using MQ, Verification of MQSC files | 11.0.0.5 FP Update, Images based on UBI, Supports MQ 9.1.2 |
| 1.1.2 | May 2019 | >=v1.11.1 | = ACE 11.0.0.4 | none  | Fix issues with release name length, Updates ACE version |
| 1.1.1 | May 2019 | >=v1.11.1 | = ACE 11.0.0.4  | none | Updates ACE version |
| 1.1.0 | Jan 2019 | >=v1.11.1 | = ACE 11.0.0.3 | Secrets moved out of helm  | Updates ACE version |
| 1.0.0 | Nov 2018 | >=v1.11.1 | = ACE 11.0.0.2 | none |  Initial Chart |