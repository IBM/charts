# What's new in 1.1.1
* [CHANGE] Change the memory.limit for prometheus from 512M to 2048M
* [CHANGE] Use useDynamicProvisioning parameter to indicate whether provision persistent volume dynamically
* [CHANGE] Change default value of storageClass from "-" to ""
* [ENHANCEMENT] Add readiness/liveness probes
* [ENHANCEMENT] Add helm test pods
* [ENHANCEMENT] To support use existing persistent volume claims
* [ENHANCEMENT] Use initContainers to chmod for storage path of prometheus, without run prometheus as root
* [BUGFIX] Fix the bug that the home page is not accessible in prometheus console

# Prerequisites
1. IBM Cloud Private 2.1.0.3 or higher for managed mode deployment.
2. PV provisioner support in the underlying infrastructure if need persistent volume to store data


# Version history
| Chart | Date | ICP Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- |
| 1.1.0 | May 2018 | >= 2.1.0.3 | | | support managed mode
| 1.1.1 | Jun 2018 | >= 2.1.0.3 | | | chart test stuff and probes
