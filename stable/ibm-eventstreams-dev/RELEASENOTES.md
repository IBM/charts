# What's new in Chart Version 1.3.0
* Support for IBM Cloud Private version 3.2.
* Support for schemas to define the structure of message data, and an Event Streams Schema Registry to manage schemas.
* Enhanced support for Kafka Connect to help integrate external systems with Event Streams.
* Connector catalog for supported and community-provided connectors.
* Option to encrypt inter-pod communication by using TLS to enhance security.
* Updated Kafka version to 2.2.0.
* Default [resource requirements](https://ibm.github.io/event-streams/installing/prerequisites/#helm-resource-requirements) have changed.
* For more information about new features, see the [documentation](https://ibm.github.io/event-streams/about/whats-new/).

# Fixes

For fixes included in this release, see the following [list of issues](https://github.com/IBM/event-streams/issues?utf8=%E2%9C%93&q=is%3Aissue+label%3Abug+label%3A2019.2.1).

# Prerequisites
* IBM Cloud Private 3.1.2 or later.

# Documentation
* [Event Streams documentation](https://ibm.github.io/event-streams/).
* [Upgrade instructions](https://ibm.github.io/event-streams/installing/upgrading/).

# Version History
| Chart | Date               | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ------------------ | ------------------- | ------------------ | ---------------- | ------- |
| 1.3.0 | June 28, 2019      | >=1.11.0  | IBM Event Streams consists of a number of versioned images. The combination of images in use must not be changed from those shipped by the release.  | None.  | Updated Kafka version to 2.2.0  |
| 1.2.0 | March 29, 2019     | >=1.11.0            | IBM Event Streams consists of a number of versioned images. The combination of images in use must not be changed from those shipped by the release.  | Kafka 2.1.1 upgrade.  |Updated Kafka version to 2.1.1.  |
| 1.1.0 | December 14, 2018  | >=1.11.0            | IBM Event Streams consists of a number of versioned images. The combination of images in use must not be changed from those shipped by the release. | None. | Added Linux on IBM Z support and updated Kafka version to 2.0.1.
| 1.0.0 | September 28, 2018 | >=1.11.0            | IBM Event Streams consists of a number of versioned images. The combination of images in use must not be changed from those shipped by the release. | None. | First release.
