# Breaking Changes (migrating from versions prior to 3.0.0)

* Version 3.0.0 of this chart introduced Routes to support handling HTTP and HTTPS traffic on OpenShift 4.2. This has resulted in the removal of the "Proxy Node IP or FQDN" for specifying the proxy address used to access the endpoints of deployed integrations. Instead a Route is created which generates a hostname.
* Custom ports can no longer be specified via the Helm UI and must be configured by customising the charts
* Version 3.0.0 of this chart introduced the string `designerFlowsOperationMode` to replace the boolean `designerFlowsEnabled` from Versions 2.x of this chart in order to introduce more options for deployment of App Connect Designer flows. Users of Versions 2.x who had `designerFlowsEnabled` set to true can reuse existing values when upgrading to 3.1.0, but must select one of the two new options to continue deploying the additional sidecars for Designer flows.

# What’s new in IBM App Connect Enterprise certified container Version 3.1.0

In this version of IBM App Connect Enterprise certified container, the following new features are available:

* New interface for creating integration servers without leaving the dashboard. Simplifies the user experience, so fewer steps are required and advanced configuration is hidden until necessary.
* You can now delete an integration server from within the dashboard interface.
* Ability to update a BAR file, including when used in Deployments and StatefulSets.

# Fixes

None

# Prerequisites

* Requires Red Hat OpenShift Container Platform 4.2

# Documentation

For more information go to [IBM App Connect Enterprise Knowledge Center](https://ibm.biz/ACEv11ContainerDocs)

# Version History

| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ----| ------------------- | ------------------ | ---------------- | ------- |
| 3.1.0 | Mar 2020 | >=v1.14.0 | = ACE 11.0.0.8-r1 | none | Update BAR files, New create server interface, Delete servers in dashboard |
| 3.0.0 | Nov 2019 | >=v1.11.0 | = ACE 11.0.0.6.1 | Removal of proxy node IP or FQDN value, custom port changes, `designerFlowsEnabled` replaced | Support for OpenShift 4.2, `log.format` now defaults to basic |
| 2.2.0 | Oct 2019 | >=v1.11.0 | = ACE 11.0.0.6 | none | Updates ACE version, Operational Dashboard Tracing |
| 2.1.0 | Sept 2019 | >=v1.11.0 | = ACE 11.0.0.5.1 | none | New image includes MQ client, Supports MQ 9.1.3, Operational Dashboard support, Support for configuring Switch ports, Support for configuring custom ports |
| 2.0.0 | July 2019 | >=v1.11.0 | = ACE 11.0.0.5 | Now runs as user ID 888 when using MQ, Verification of MQSC files, Some values renamed | 11.0.0.5 FP Update, Image based on UBI, Supports MQ 9.1.2 |
| 1.1.2 | May 2019 | >=v1.11.1 | = ACE 11.0.0.4 | none  | Fix issues with release name length, Updates ACE version |
| 1.1.1 | May 2019 | >=v1.11.1 | = ACE 11.0.0.4  | none | Updates ACE version, Import of odbc files fixed, RestAPI viewer update to present correct hostname & port |
| 1.1.0 | Jan 2019 | >=v1.11.1 | = ACE 11.0.0.3 | Secrets moved out of helm  | Updates ACE version |
| 1.0.0 | Nov 2018 | >=v1.11.1 | = ACE 11.0.0.2 | none |  Initial Chart |
