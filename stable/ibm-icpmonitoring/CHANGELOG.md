## 1.1.1/2018-06
* [CHANGE] Change the memory.limit for prometheus from 512M to 2048M
* [CHANGE] Use useDynamicProvisioning parameter to indicate whether provision persistent volume dynamically
* [CHANGE] Change default value of storageClass from "-" to ""
* [ENHANCEMENT] Add readiness/liveness probes
* [ENHANCEMENT] Add helm test pods
* [ENHANCEMENT] To support use existing persistent volume claims
* [ENHANCEMENT] Use initContainers to chmod for storage path of prometheus, without run prometheus as root
* [BUGFIX] Fix the bug that the home page is not accessible in prometheus console

