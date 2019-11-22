# Breaking Changes (Prior to 2.2.0)

* This chart has changed the way we specify images. In versions 1.0.0 through to 2.0.0 we used a common tag across all images. In this release (2.1.0) we have moved to including the tag with the name of the image. If you have customised the image name you will need to make sure that when upgrading you include the image tag on the appropriate image value.
* The parameter "File system group" (fsGroupGid) has been moved under the "Security" category (security.fsGroupGid) in this release (2.1.0). When upgrading from previous versions, if values for paramters are copied, this parameter will need to be manually updated to match your existing deployment.

# What’s new in IBM App Connect Enterprise Chart Version 2.2.0

With IBM App Connect Enterprise dashboard Chart for Kubernetes environments, the following new features are available:

# Fixes

- No changes to the Dashboard in this release

# Prerequisites

* The following IBM Platform Core Service is required: tiller

# Documentation

For more information go to [IBM App Connect Enterprise Knowledge Center](https://ibm.biz/ACEv11ContainerDocs)

# Version History

| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------------- | ------------------ | ---------------- | ------- |
| 2.2.0 | Oct 2019 | >=v1.11.0 | = ACE 11.0.0.6 | none | No changes to the Dashboard |
| 2.1.0 | Sept 2019 | >=v1.11.0 | = ACE 11.0.0.5.1 | Images specified with tag, fsGroupGid moved under security catagory | Support for running as an administrator (to allow Push To API Connect) |
| 2.0.0 | July 2019 | >=v1.11.0 | = ACE 11.0.0.5 | Now runs as user ID 888 when using MQ<br>Verification of MQSC files | 11.0.0.5 FP Update<br>Images based on UBI <br>Supports MQ 9.1.2 |
| 1.1.2 | May 2019 | >=v1.11.1 | = ACE 11.0.0.4 | none  | Fix issues with release name length<br>Updates ACE version |
| 1.1.1 | May 2019 | >=v1.11.1 | = ACE 11.0.0.4  | none | Updates ACE version |
| 1.1.0 | Jan 2019 | >=v1.11.1 | = ACE 11.0.0.3 | Secrets moved out of helm  | Updates ACE version |
| 1.0.0 | Nov 2018 | >=v1.11.1 | = ACE 11.0.0.2 | none |  Initial Chart |