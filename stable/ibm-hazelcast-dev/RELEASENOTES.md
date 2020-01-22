# Breaking Changes


# What’s new in Chart Version 1.2.1

* Remove incorrectly included qualification.yaml


# What’s new in Chart Version 1.2.0

With Hazelcast 1.2.0 on IBM Cloud, the following new
features are available:
* hazelcast/hazelcast Docker image 3.10.6
* Scoped ClusterRole to specific Role
* Workload compatible with ibm-restricted-psp Pod Security Policy
  * Container runs as UID 1001


# Fixes


# Prerequisites
1. IBM Cloud Private version 2.1.0.1+ or IBM Cloud Container Service.
2. amd64

# Documentation


# Version History

| Chart | Date | ICP Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- |
| 1.2.1 | February 12, 2019 | >=3.1.0.0 | hazelcast/hazelcast | | Remove incorrectly included qualification.yaml |
| 1.2.0 | January 28, 2019 | >=3.1.0.0 | hazelcast/hazelcast | | Update Hazelcast to 3.10.6. ibm-restricted-psp compatibility. Scoped ClusterRole to specific Role. Container run as UID 1001. |
| 1.1.0 | September 28, 2018 | >=2.1.0.1 | hazelcast/hazelcast | | Change deployment type to StatefulSet. Update hazelcast supported docker image, version, and probes. |
| 1.0.0 | June 22, 2018 | >=2.1.0.1 | hazelcast/hazelcast-kubernetes | | Initial release. |
