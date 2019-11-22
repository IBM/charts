### What's new in v1.0.2

* New helm test
* New images with Redhat certification and CVE fixes
* CV lint 1.4.5 fxes and Rules ingored in lintoverrides
* Readme fixes

### Fixes

* CVE fixes for all the images
* CV lint 1.4.5 fixes for the ibm-minio chart

### Breaking Changes

None 

### Prerequisites

* Tiller 2.9.0
* Kubernetes 1.11

### Documentation


### Version History

| Chart | Date | Kubernetes Version Required | Breaking Changes | Details |
| ----- | ---- | --------------------------- | ---------------- | ------- |
| 1.0.2 | August 12th, 2019 | >=1.11 | none | New helm test, New images with Redhat certification and CVE fixes, CV lint 1.4.5 fxes, Rules ingored in lintoverrides, Readme fixes |
| 1.0.1 | August 12th, 2019 | >=1.11 | none | Introducing two new parameters `deploymentForDev` and `deploymentForProd` replicas |
| 1.0.0 | August 9th, 2019 | >=1.11 | none | Initial release of ibm-minio chart. Original source code of this chart is taken from the community helm/charts repo and has been modified to IBM standards. |

