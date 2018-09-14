## 1.1.1/2018-06
* [CHANGE] Change the memory.limit for prometheus from 512M to 2048M
* [CHANGE] Use useDynamicProvisioning parameter to indicate whether provision persistent volume dynamically
* [CHANGE] Change default value of storageClass from "-" to ""
* [ENHANCEMENT] Add readiness/liveness probes
* [ENHANCEMENT] Add helm test pods
* [ENHANCEMENT] To support use existing persistent volume claims
* [ENHANCEMENT] Use initContainers to chmod for storage path of prometheus, without run prometheus as root
* [BUGFIX] Fix the bug that the home page is not accessible in prometheus console

## 1.2.0/2018-06
* [CHANGE] Upgrade the version for some components: prometheus(2.3.1), alertmanager(0.15.0), grafana(5.2.0), node-exporter(0.16.0),collectd-exporter(0.4.0), kube-state-metrics(1.3.0), configmap-reload(0.2.2)
* [CHANGE] Use cert manager to generate the security certs for tls enablement
* [CHANGE] Delete the job which used to create data source in grafana, and use config file now.
* [ENHANCEMENT] Add rbac support
* [ENHANCEMENT] Add tls support between prometheus and exporters
* [ENHANCEMENT] Support installation in OpenShift