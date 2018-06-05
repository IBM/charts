# What’s new in IBM Netcool Probe for Kubernetes Chart (Limited Use) Version 1.0.0

With IBM Netcool Probe for Kubernetes Chart (Limited Use) Version 1.0.0, the following new
features are available:

* New chart release with latest probe docker image for non-production use. This version is licensed under the IBM International License Agreement for Non-Warranted Programs.

## Prerequisites

1. This solution requires IBM Tivoli Netcool/OMNIbus ObjectServer to be created and running prior to installing the probe. To create and run the IBM Tivoli Netcool/OMNIbus ObjectServer, see installation instructions at [IBM Knowledge Center - Creating and running ObjectServers](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ_8.1.0/com.ibm.netcool_OMNIbus.doc_8.1.0/omnibus/wip/install/task/omn_con_creatingsettingupobjserv.html).
2. Scope-based Event Grouping automation is installed and enabled, see installation instructions at [IBM Knowledge Center - Installing scope-based event grouping](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ_8.1.0/com.ibm.netcool_OMNIbus.doc_8.1.0/omnibus/wip/install/task/omn_con_ext_installingscopebasedegrp.html)
3. Kubernetes 1.9.
4. Logstash 5.5.1.
5. Prometheus 2.0.0.
6. Prometheus Alert Manager 0.13.0.

## Version History

| Chart | Date | ICP Required | Image(s) Supported | Details |
| ----- | ---- | ------------ | ------------------ | ------- |
| 1.0.0 | June 4, 2018| >=2.1.0.2 | ibmcom/netcool-probe-messagebus:7.0 | Initial Version  |

## Changes in Version 1.0.0

Initial version of the Limited Use Edition of the `ibm-netcool-probe` chart.

* Minimum Kubernetes Version updated to 1.9.
* Use Shared Configurable Helpers (SCH) to aid in resource template value assignments.
* Resource names such as Deployment, ConfigMap, Service, etc are made consistent.
* Probe configuration and probe rules files are placed in separate ConfigMaps to ease rules file customization.
