# What's new in Chart Version 1.1.0

* Support for IBM Cloud Private on Linux on IBM Z.
* Support for IBM Cloud Private version 3.1.1.
* Kafka version upgraded to 2.0.1.
* Kafka Connect sink connector for IBM MQ.
* Support for Kafka quotas to allow clients to be throttled.
* New design for sample application.
* Unique URLs for each page in the Event Streams UI.
* New Cluster Connection view with API Key generation.
* You must have the Cluster Administrator role to install the chart.
* Minimum Tiller version required for charts has been increased to 2.9.1.
* Default [resource requirements](https://ibm.github.io/event-streams/installing/prerequisites/#helm-resource-requirements) have changed.
* For more information about new features, see the [documentation](https://ibm.github.io/event-streams/about/whats-new/).

# Fixes
* Event Streams UI server now uses a certificate signed by the IBM Cloud Private cluster authority rather than a self-signed certificate.
* Support for accessing the Event Streams UI via the external hostname or IP address provided during installation.
* Zookeeper pods no longer restarting with OOM errors, details [here](https://github.com/IBM/event-streams/issues/7).
* Event Streams UI now accessible from both proxy and master node's IP addresses, details [here](https://github.com/IBM/event-streams/issues/8).

# Prerequisites
* IBM Cloud Private 3.1.0 or later.

# Documentation
* [Event Streams documentation](https://ibm.github.io/event-streams/).
* [Upgrade instructions](https://ibm.github.io/event-streams/installing/upgrading/).

# Version History
| Chart | Date               | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ------------------ | ------------------- | ------------------ | ---------------- | ------- |
| 1.1.0 | December 14, 2018  | >=1.11.0            | IBM Event Streams consists of a number of versioned images. The combination of images in use must not be changed from those shipped by the release. | None. | Added Linux on IBM Z support and updated Kafka version to 2.0.1.
| 1.0.0 | September 28, 2018 | >=1.11.0            | IBM Event Streams consists of a number of versioned images. The combination of images in use must not be changed from those shipped by the release. | None. | First release.
