# Breaking Changes
* Brand new release of Java Acceleration as a new offering of IBM product.

# What’s new in Chart Version 1.0.0

This is the first demo/trial version release of IBM Java Acceleration. IBM Java Acceleration is based on OpenJ9 JIT Server technology. This helps improve performance of java applications in constrained container environments and helps improve scaling.

# Fixes
* Simplify deployment template to use less resources
* Simplify values.yaml

# Prerequisites on OpenShift
1. OpenShift Container Platform version 3.11.0 or later
2. OpenShift Container Platform services:  `helm tiller`
3. OpenShift Container Platform project administrator permission

# Prerequisites on Native Kubernetes
1. Kubernetes version 1.11.0 or later
2. Kubernetes namespace administrator permission

# Documentation
* See openj9 repo: https://github.com/eclipse/openj9/tree/jitaas
* See openj9 docs: https://github.com/eclipse/openj9-docs
* See openj9 website: https://www.eclipse.org/openj9/index.html 

# Version History

| Chart | Date         | Kubernetes Required | Image(s) Supported      | Breaking Changes         | Details |
| ----- | ------------ | ------------------- | ----------------------- | ------------------------ | ------- |
| 1.0.0 | Oct 31, 2019 | >=1.11.0            | java-acceleration-amd64 | Initial offering release |         |

