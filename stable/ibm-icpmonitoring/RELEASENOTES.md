# What's new in 1.2.0
* [CHANGE] Upgrade the version for some components: prometheus(2.3.1), alertmanager(0.15.0), grafana(5.2.0), node-exporter(0.16.0),collectd-exporter(0.4.0), kube-state-metrics(1.3.0), configmap-reload(0.2.2)
* [CHANGE] Use cert manager to generate the security certs for tls enablement
* [CHANGE] Delete the job which used to create data source in grafana, and use config file now.
* [ENHANCEMENT] Add rbac support
* [ENHANCEMENT] Add tls support between prometheus and exporters
* [ENHANCEMENT] Support installation in OpenShift

# Fixes

# Prerequisites
1. IBM Cloud Private 2.1.0.3 or higher for managed mode deployment.
2. PV provisioner support in the underlying infrastructure if need persistent volume to store data


# Version history
| Chart | Date | ICP Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- |
| 1.2.0 | Sep 2018 | >= 3.1 | | | components upgrade; rbac support; OpenShift support
| 1.1.1 | Jun 2018 | >= 2.1.0.3 | | | chart test stuff and probes
| 1.1.0 | May 2018 | >= 2.1.0.3 | | | support managed mode
