# Breaking Changes

* None

# What’s new in IBM App Connect Enterprise Chart Version 2.0.0

With IBM App Connect Enterprise dashboard Chart for Kubernetes environments, the following new
features are available:

* Images based on UBI
* New bar backup and restore capability

# Fixes

# Prerequisites

* The following IBM Platform Core Service is required: tiller

# Documentation
For more information go to [IBM App Connect Enterprise Knowledge Center](https://www.ibm.com/support/knowledgecenter/en/SSTTDS_11.0.0/com.ibm.etools.mft.doc/bz91410_.htm)

# Version History

| Chart | Date | Kubernetes Required | Image(s) Supported | Details |
| ----- | ---- | ------------------- | ------------------ | ------- |
| 2.0.0 | July 2019 | >=v1.11.0 | = ACE 11.0.0.5 | Now runs as user ID 888 when using MQ<br>Verification of MQSC files | 11.0.0.5 FP Update<br>Images based on UBI <br>Supports MQ 9.1.2 |
| 1.1.2 | May 2019 | >=v1.11.1 | = ACE 11.0.0.4 | none  | Fix issues with release name length<br>Updates ACE version |
| 1.1.1 | May 2019 | >=v1.11.1 | = ACE 11.0.0.4  | none | Updates ACE version |
| 1.1.0 | Jan 2019 | >=v1.11.1 | = ACE 11.0.0.3 | Secrets moved out of helm  | Updates ACE version |
| 1.0.0 | Nov 2018 | >=v1.11.1 | = ACE 11.0.0.2 | none |  Initial Chart |
