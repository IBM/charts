# Breaking Changes (Prior to 2.1.0)

* Version 2.1.0 of this chart replaced the 'Local default Queue Manager' checkbox (used in versions 1.0.0-2.0.0) with a 'Which type of image to run' dropown list. That's because the chart now comes with an additional Docker image, the 'App Connect Enterprise with MQ client' image. Users of releases 2.0.0 and earlier of this chart can reuse existing values when upgrading to 2.2.0, but must ensure that the new option has the correct value to maintain your image selection, where 'App Connect Enterprise with MQ server' is the equivalent of selecting 'Local default Queue Manager'.

* Version 2.1.0 of this chart changed the way we specify images. In versions 1.0.0 through to 2.0.0 we used a common tag across all images. In version 2.1.0 we moved to including the tag with the name of the image. If you have customised the image name you will need to make sure that when upgrading you include the image tag on the appropriate image value.

* There are no breaking changes when upgrading from version 2.1.0 to 2.2.0

# What’s new in Chart Version 2.2.0

With IBM App Connect Enterprise Chart for Kubernetes environments, the following new features
are available:

* IBM App Connect Enterprise 11.0.0.6
* IBM Cloud Pak for Integration Operational Dashboard Tracing support

# Fixes

# Prerequisites

* The following IBM Platform Core Service is required: tiller
* Requires IBM Cloud Private 3.2.0.1906 (Fix Pack 1)

# Documentation

For more information go to [IBM App Connect Enterprise Knowledge Center](https://ibm.biz/ACEv11ContainerDocs)

# Version History

| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ----| ------------------- | ------------------ | ---------------- | ------- |
| 2.2.0 | Oct 2019 | >=v1.11.0 | = ACE 11.0.0.6 | none | Updates ACE version, Operational Dashboard Tracing |
| 2.1.0 | Sept 2019 | >=v1.11.0 | = ACE 11.0.0.5.1 | none | New image includes MQ client, Supports MQ 9.1.3, Operational Dashboard support, Support for configuring Switch ports, Support for configuring custom ports |
| 2.0.0 | July 2019 | >=v1.11.0 | = ACE 11.0.0.5 | Now runs as user ID 888 when using MQ, Verification of MQSC files, Some values renamed | 11.0.0.5 FP Update, Image based on UBI, Supports MQ 9.1.2 |
| 1.1.2 | May 2019 | >=v1.11.1 | = ACE 11.0.0.4 | none  | Fix issues with release name length, Updates ACE version |
| 1.1.1 | May 2019 | >=v1.11.1 | = ACE 11.0.0.4  | none | Updates ACE version, Import of odbc files fixed, RestAPI viewer update to present correct hostname & port |
| 1.1.0 | Jan 2019 | >=v1.11.1 | = ACE 11.0.0.3 | Secrets moved out of helm  | Updates ACE version |
| 1.0.0 | Nov 2018 | >=v1.11.1 | = ACE 11.0.0.2 | none |  Initial Chart |
