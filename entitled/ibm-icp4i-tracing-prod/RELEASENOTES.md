## Breaking Changes

Changes to the helm charts mean that in-place upgrades to 1.0.2 will not work.
Users will need to re-install Operations Dashboard, including documented manual steps before installation.

## What’s new 

* Support for OpenShift 4.3
* New tracing support between Event Streams & App Connect (ACE) Kafka Nodes (requires ACE 11.0.0.8+).
* Visualize Tracing between Application and Cloud Pak for Integration Software.
* Improved trace drilldown page.
* Improved user experience - Reworked trace drilldown page user experience. Reworked trace drilldown page user experience. New debug log page.


## Fixes
None

## Prerequisites
* Red Hat OpenShift version 4.2 or 4.3
* Cloud Pak Foundation fix pack 3.2.4
* A user with cluster Operator role is required to install the chart

## Documentation
The IBM Cloud Pak for Integration Knowledge center can be found [here](https://www.ibm.com/support/knowledgecenter/SSGT7J_20.1/op_dashboard.html).

## Version History
| Chart Version | Date Released   | Kubernetes Required | Images Supported                                   | Breaking Changes | Details         |
| ------------- | --------------  | ------------------- | -------------------------------------------------- | ---------------- | --------------- |
| 1.0.0         | Oct 28th, 2019  | \>=1.11             | IBM Cloud Pak for Integration Operations Dashboard Add On consists of a number of versioned images. The combination of images in use must not be changed from those shipped by the release | N/A           | Initial release |
| 1.0.1         | Nov 18th, 2019  | \>=1.11             | IBM Cloud Pak for Integration Operations Dashboard Add On consists of a number of versioned images. The combination of images in use must not be changed from those shipped by the release | Ability to Add/Edit custom reports and alerts, support OCP 4.2  |           |
| 1.0.2         | Mar 27th, 2020  | \>=1.14             | IBM Cloud Pak for Integration Operations Dashboard Add On consists of a number of versioned images. The combination of images in use must not be changed from those shipped by the release | Support for ACE kafka node, support for external applications, support OCP 4.3  |           |

