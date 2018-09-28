# Breaking Changes


# What’s new in Chart Version 1.1.0

With Hazelcast 1.1.0 on IBM Cloud, the following new
features are available:
* Deployment type changed to StatefulSet
* hazelcast/hazelcast Docker image 3.10.5
* Update readiness and liveness probes to new endpoint


# Fixes


# Prerequisites
1. IBM Cloud Private version 2.1.0.1+ or IBM Cloud Container Service.
2. amd64

# Documentation


# Version History

| Chart | Date | ICP Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- | 
| 1.1.0 | September 28, 2018 | >=2.1.0.1 | hazelcast/hazelcast | | Change deployment type to StatefulSet. Update hazelcast supported docker image, version, and probes. |
| 1.0.0 | June 22, 2018 | >=2.1.0.1 | hazelcast/hazelcast-kubernetes | | Initial release. |
