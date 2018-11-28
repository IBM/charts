# What's new in 1.3.0
* [CHANGE] Revise existing grafana dashboards
* [CHANGE] Containers will run using non-root user except the init and router containers
* [FEATURE] Add helm release label support for container metrics from cAdvisor
* [ENHANCEMENT] Add out-of-box alert rules
* [ENHANCEMENT] Add more out-of-box grafana dashboards
* [BUGFIX] Source url use internal address in alert notifications #1538

# Fixes

# Prerequisites
1. IBM Cloud Private 2.1.0.3 or higher for managed mode deployment.
2. PV provisioner support in the underlying infrastructure if need persistent volume to store data


# Version history
| Chart | Date | ICP Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- |
| 1.3.0 | Nov 2018 | >= 3.1.1 | | | out-of-box grafana dashboards/alert rules, containers run using non-root user
| 1.2.0 | Sep 2018 | >= 3.1 | | | components upgrade; rbac support; OpenShift support
| 1.1.1 | Jun 2018 | >= 2.1.0.3 | | | chart test stuff and probes
| 1.1.0 | May 2018 | >= 2.1.0.3 | | | support managed mode
