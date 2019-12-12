### What's new in v1.1.1

* Updated instructions in notes.txt
* New sch 1.2.14, 
* Good with cv lint 2.0.7

### Prerequisites

* Tiller 2.9.0
* Kubernetes 1.11

### Documentation


### Version History

| Chart | Date | Kubernetes Version Required | Breaking Changes | Details |
| ----- | ---- | --------------------------- | ---------------- | ------- |
| 1.1.1 |  10/30/2019 | >=1.11 |  None   | New sch 1.2.14, fixes in notes.txt, good with cv lint 2.0.7   |
| 1.1.0 |  10/14/2019 | >=1.11 |  Changes in values.yaml   | Support for PodDisruptionBudget, Support for generation of SSE secret, Images with current VA fixes, support templating values for few more parameters, bind pvc using labels, CV linter 2.0.3 fixes, new sch 1.2.13   |
| 1.0.3 | August 21st, 2019 | >=1.11 | none | New CV tests, Readmes fixes, removed service monitor, modified role to minium requirement |
| 1.0.2 | August 12th, 2019 | >=1.11 | none | New helm test, New images with Redhat certification and CVE fixes, CV lint 1.4.5 fixes, Rules ignored in lintoverrides, Readme fixes |
| 1.0.1 | August 12th, 2019 | >=1.11 | none | Introducing two new parameters `deploymentForDev` and `deploymentForProd` replicas |
| 1.0.0 | August 9th, 2019 | >=1.11 | none | Initial release of ibm-minio chart. Original source code of this chart is taken from the community helm/charts repo and has been modified to IBM standards. |

### Fixes


### Breaking Changes
