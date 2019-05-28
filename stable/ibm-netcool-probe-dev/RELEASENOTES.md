# What’s new in IBM Netcool Probe for Kubernetes Chart (Limited Use) Version 2.0.1

This IBM Netcool Probe for Kubernetes Chart (Limited Use) is now deprecated.

On May 28th, 2019 the helm chart for IBM Tivoli Netcool/OMNIbus - Probe for monitoring Kubernetes (Limited Use) will no longer be supported and will be removed from IBM's public helm repository on github.com on June 28th, 2019. This will result in the chart no longer being displayed in the catalog. This will not impact existing deployments of the helm chart. The [commercial version](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ/omnibus/helms/kubernetes/wip/concept/kub_intro.html) of this chart is still maintained and users should use the commercial version to get new updates. The commercial chart is available on [IBM PASSPORT ADVANTAGE](https://www-01.ibm.com/software/passportadvantage/) and requires an entitlement to Netcool Operations Insight.

## Prerequisites

1. This solution requires IBM Tivoli Netcool/OMNIbus ObjectServer to be created and running prior to installing the probe. To create and run the IBM Tivoli Netcool/OMNIbus ObjectServer, see installation instructions at [IBM Knowledge Center - Creating and running ObjectServers](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ_8.1.0/com.ibm.netcool_OMNIbus.doc_8.1.0/omnibus/wip/install/task/omn_con_creatingsettingupobjserv.html).
2. Scope-based Event Grouping automation is installed and enabled, see installation instructions at [IBM Knowledge Center - Installing scope-based event grouping](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ_8.1.0/com.ibm.netcool_OMNIbus.doc_8.1.0/omnibus/wip/install/task/omn_con_ext_installingscopebasedegrp.html)
3. Kubernetes 1.9. Verified running on IBM Cloud Private version 2.1.0.2 or newer.
4. Tiller 2.7.2
5. Logstash 5.5.1.
6. Prometheus 2.0.0.
7. Prometheus Alert Manager 0.13.0.

## Version History

| Chart | Date | ICP Required | Image(s) Supported | Details |
| ----- | ---- | ------------ | ------------------ | ------- |
| 2.0.1 | May 28, 2019| >=2.1.0.2 | ibmcom/netcool-probe-messagebus:8.0 | Deprecate Limited Use chart version. Commercial version still maintained. See IBM Knowledge Center [page](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ/omnibus/helms/kubernetes/wip/concept/kub_intro.html) |
| 2.0.0 | July 27, 2018| >=2.1.0.2 | ibmcom/netcool-probe-messagebus:8.0 | Upgrade default probe image version.  |
| 1.1.1 | June 22, 2018| >=2.1.0.2 | ibmcom/netcool-probe-messagebus:7.0 | Fix icon issue.  |
| 1.1.0 | June 12, 2018| >=2.1.0.2 | ibmcom/netcool-probe-messagebus:7.0 | Update to use SCH 1.2.1 sub-chart  |
| 1.0.0 | June 4, 2018| >=2.1.0.2 | ibmcom/netcool-probe-messagebus:7.0 | Initial Version  |

## Changes in Version 2.0.0

* Chart code re-factorization. The `image.repository` parameter does not include the image name. New `image.name` parameter is introduced and fixed to `netcool-probe-messagebus`. The `image.repository` value is used to pull the probe image and `image.testRepository` is used to pull `busybox:1.28.4` image for helm test.
* New probe image version used.
  * Internal improvements in Message Bus 8.0 Webhook transport.
  * Fixed: Message Bus 8.0 fixes an issue when a payload larger than 1kB causes an error to be logged.
* Helm upgrade with a change in the probe configmap will trigger a rolling update.
* Default probe service type is now set to `ClusterIP` from `NodePort` to conform to best practices and reduce security concerns.
* Default `netcool.primaryServer`,`netcool.primaryHost` and `netcool.primaryPort` is set to `nil`. Users will have to enter the correct values for the probe to connect successfully.

## Changes in Version 1.1.1

* Fixed logo icon load issue.

## Changes in Version 1.1.0

* Minor update to upgrade to Shared Configurable Helper 1.2.1 sub-chart.
  * Chart version is removed from `chart` label in standard labels.

## Changes in Version 1.0.0

Initial version of the Limited Use Edition of the `ibm-netcool-probe` chart.

* Minimum Kubernetes Version updated to 1.9.
* Use Shared Configurable Helpers (SCH) to aid in resource template value assignments.
* Resource names such as Deployment, ConfigMap, Service, etc are made consistent.
* Probe configuration and probe rules files are placed in separate ConfigMaps to ease rules file customization.
