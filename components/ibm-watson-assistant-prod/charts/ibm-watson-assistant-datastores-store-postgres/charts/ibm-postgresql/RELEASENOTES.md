## What's new in 1.6.1

- New parameter `global.license`, which needs to be set true to install 

- Parameter `global.image.repository` changed to `global.dockerRegistryPrefix`

- Parameter `persistence.storageClassName` changed to `global.storageClassName`

- Parameter `metering` changed to `global.metering.productName`, `global.metering.productID`, `global.metering.productVersion`, `global.metering.productMetric`, `global.metering.productChargedContainers`, `global.metering.cloudpakName`, `global.metering.cloudpakId`, `global.metering.cloudpakVersion` are added to support metering annotations. 

- New images with CVE fixes

- Added possibility to specify pod disruption budgets

- Added support for [topologySpreadConstraints](https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/)
  Note that:
   - it is alpha feature in kube 1.16 (has to be enabled manually)
   - it graduated to beta in kube 1.18 (enabled by default)
   - Notice that we see issues with kube scheduler if enabled in kube 1.16 ( in OpenShift 4.3)

## Fixes
- Fixed metering Annotation


## Prerequisites

## Documentation

## Breaking Changes

- New parameter `global.license`, which needs to be set true to install 

- Parameter `global.image.repository` changed to `global.dockerRegistryPrefix`

- Parameter `persistence.storageClassName` changed to `global.storageClassName`

- Parameter `metering` changed to `global.metering.productName`, `global.metering.productID`, `global.metering.productVersion`, `global.metering.productMetric`, `global.metering.productChargedContainers`, `global.metering.cloudpakName`, `global.metering.cloudpakId`, `global.metering.cloudpakVersion` are added to support metering annotations. 


## Version History

| Chart | Date              | Kubernetes Version Required | Breaking Changes | Details |
| ----- | ----------------- | --------------------------- | ---------------- | ------- |
| 1.6.1 | May 12, 2020 | >=1.11 |  - New parameter `global.license`, which needs to be set true to install </br> - Parameter `global.image.repository` changed to `global.dockerRegistryPrefix` </br> - Parameter `persistence.storageClassName` changed to `global.storageClassName` </br> - Parameter `metering` changed to `global.metering.productName`, `global.metering.productID`, `global.metering.productVersion`, `global.metering.productMetric`, `global.metering.productChargedContainers`, `global.metering.cloudpakName`, `global.metering.cloudpakId`, `global.metering.cloudpakVersion` are added to support metering annotations. | - New images with CVE fixes </br>  - Added possibility to specify pod disruption budgets </br> - Added support for [topologySpreadConstraints](https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/) </br> Note that: </br>  - it is alpha feature in kube 1.16 (has to be enabled manually) </br>  - it graduated to beta in kube 1.18 (enabled by default) </br>  - Notice that we see issues with kube scheduler if enabled in kube 1.16 ( in OpenShift 4.3) |
| 1.5.11 | March 6, 2020 | >=1.11 | none | Add default anti affinity configuration |
| 1.5.10 | Feb 18, 2020 | >=1.11 | none | Fix rendering issue of custom affinity |
| 1.5.9 | Feb 5, 2020 | >=1.11 | none | Configurable pod resources for jobs, configurable podManagementPolicy, new images with Jan 2020 CVE fixes, includes latest sch version 1.2.15 |
| 1.5.7 | Nov 14, 2019 | >=1.11 | none | move / into if statement so it is not used if no global.image.reposit…, Removed runAsGroup parameter from values.yaml, Replace `*` with actual verbs in role definition, new sch 1.2.14, fixes for cv lint 2.0.7, license changed to apache 2 |
| 1.5.3 | August 25, 2019 | >=1.11 |  none |Postgres slave keeper pod changes permission when restarted. Fix has been made to set permissions appropriately. |
| 1.5.2 | August 20, 2019 | >=1.11 |  none | Fixed Readme file, Removed copyright from all files, added application test |
| 1.5.1 | August 13, 2019 | >=1.11 |  none | New images that are Red hat certified and CVE fixes, CV lint 1.4.5 fixes, sch 1.2.11 is used|
| 1.5.0 | August 5, 2019 | >=1.11 |   |supports arbitrary uid and Openshift restricted scc, postgres version has been upgraded to 9.6.14, cv lint fixes for 1.4.4, Replaced old Helm test with new helm test|
| 1.4.0 | June 13, 2019 | >=1.12 | service account name values changes,  Affinities. Architecure based affinities | Uses new images with cve fixes, Improvements for sub-charting |
| 1.3.0 | May 31, 2019   | >= 1.12                     |            |  Satisfying CV Lint 1.4.1 |
| 1.2.2 | May 22, 2019   | >= 1.10                     |            |  adding postgresql-contrib package |
| 1.2.1 | May 21, 2019   | >= 1.10                     |        changed to UBI 7 image and set encoding format utf-8     |  changed to UBI 7 image and set encoding format utf-8|
| 1.2.0 | May 21, 2019   | >= 1.10                     |     Changed to UBI image and run as non root         |  Changed to UBI image and run as non root, Using SCH and cv lint fixes |
| 1.1.6 | March  29, 2019   | >= 1.10                     | None             | Improved persistent storage configuration|
