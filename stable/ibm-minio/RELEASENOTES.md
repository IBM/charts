### What's new in v2.0.0

* New Image for opencontent-minio - includes bug fixes available in mini package and cve fixes 
* Added possiblity to delete chart without deletion of the minio instance (pods, services, ...). Configured by .Values.keep. After helm delete minio will be still running in cluster and will be usable (but not managed by helm any more).
* Added PodDisruptionBudget to improve stability in case of cluster maintenance.
* Added possibility to bind PV to PVC using labels (persistence.selector) to more precisely control the storage binding. Useful for local-storage.
* Separate affinity for minio statefulset. Supports templates (to be able to conditionally enable podAntiAffinity).
* BREAKING CHANGE: StatefulSetUpdate.updateStrategy has been renamed to updateStrategy to follow helm recommendations on camelCase naming convention. If you changed the default value "RollingUpdate" during the helm installation/upgrade, then you have to add parameter --set updateStrategy=YOUR_VALUE for helm upgrade command to preserve yours settings.
* BREAKING CHANGE: environment entries keys changed to camelCase format (follows recommended naming convention for helm). If you changed/specified any value under the environment during helm installation/upgrade, see values.yaml file for new key names and use --set parameter in case of upgrade to preserve your settings. E.g., helm upgrade --set environmen.newKeyName=ValueToPreserve
* Changed the way service account and role/rolebinding is configured. Added rbac.create for Role and RoleBinding creation. The semantics of serviceAccount.create changed, if specified, it creates only service account and not Role/RoleBinding.
* Fix: serviceAccount.name is used if specified. In older chart releases it was ignored and {{ Release.Name }}-ibm-minio service account was always used (either created or assumed to be provided)
* Added support for generation of SSE secret.
* FIX: Support for numeric secret names.
* Adding support for templates in following values: clusterDomain, repicas, global.metering.*, persistence.*, defaultBucket.*, buckets.*, networkPolicy.*
* Updated instructions in notes.txt
* New sch 1.2.14,

### Prerequisites

* Tiller 2.9.0
* Kubernetes 1.11

### Documentation


### Version History

| Chart | Date | Kubernetes Version Required | Breaking Changes | Details |
| ----- | ---- | --------------------------- | ---------------- | ------- |
| 2.0.0| November 18th, 2019 | >=1.11 | * StatefulSetUpdate.updateStrategy has been renamed to updateStrategy to follow helm recommendations on camelCase naming convention. If you changed the default value "RollingUpdate" during the helm installation/upgrade, then you have to add parameter --set updateStrategy=YOUR_VALUE for helm upgrade command to preserve yours settings. </br> * Environment entries keys changed to camelCase format (follows recommended naming convention for helm).  If you changed/specified any value under the environment during helm installation/upgrade, see values.yaml file for new key names and use --set parameter in case of upgrade to preserve your settings. E.g., helm upgrade --set environmen.newKeyName=ValueToPreserve | * New Image for opencontent-minio - includes bug fixes available in mini package and cve fixes. Added possiblity to delete chart without deletion of the minio instance (pods, services, ...). Configured by .Values.keep. After helm delete minio will be still running in cluster and will be usable (but not managed by helm any more). </br> * Added PodDisruptionBudget to improve stability in case of cluster maintenance. </br> * Added possibility to bind PV to PVC using labels (persistence.selector) to more precisely control the storage binding. Useful for local-storage. Separate affinity for minio statefulset. </br> * Supports templates (to be able to conditionally enable podAntiAffinity). changed the way service account and role/rolebinding is configured. </br> * Added rbac.create for Role and RoleBinding creation. The semantics of serviceAccount.create changed, if specified, it creates only service account and not Role/RoleBinding. </br> * Fix: serviceAccount.name is used if specified. In older chart releases it was ignored and {{ Release.Name }}-ibm-minio service account was always used (either created or assumed to be provided). Added support for generation of SSE secret. </br> * FIX: Support for numeric secret names. Adding support for templates in following values: clusterDomain, repicas, global.metering.*, persistence.*, defaultBucket.*, buckets.*, networkPolicy.*   |
| 1.0.3 | August 21st, 2019 | >=1.11 | none | New CV tests, Readmes fixes, removed service monitor, modified role to minium requirement. New sch 1.2.14. |
| 1.0.2 | August 12th, 2019 | >=1.11 | none | New helm test, New images with Redhat certification and CVE fixes, CV lint 1.4.5 fixes, Rules ignored in lintoverrides, Readme fixes |
| 1.0.1 | August 12th, 2019 | >=1.11 | none | Introducing two new parameters `deploymentForDev` and `deploymentForProd` replicas |
| 1.0.0 | August 9th, 2019 | >=1.11 | none | Initial release of ibm-minio chart. Original source code of this chart is taken from the community helm/charts repo and has been modified to IBM standards. |

### Fixes


### Breaking Changes
