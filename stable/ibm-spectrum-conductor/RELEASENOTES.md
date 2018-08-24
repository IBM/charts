# What’s new in IBM Spectrum Conductor Version 0.20.x

With IBM Spectrum Conductor Chart on IBM Cloud Private 2.1.0.3, the following new
features are available:

* Split Conductor and DLI as 2 independent Applications in ICP Catalog
* Secure Helm client support
* Enable Spark Master HA
* Spark Master as a service and expose Livy as a service
* DLI 1.2 integration
* Misc.
 * Remove the constrains on IngressProxy to access Conductor and Spark UI
 * Consolidate Resource requests and limits against a SIG containers
 * Customized Jupyter notebook package
 * Integrate with ICP metering
 * New Spark version support
 * Expose debug port for ASCD


# Prerequisites
1. IBM Cloud Private version 2.1.0.3

# Fixes

# Version History

| Chart   | Date        | ICP Required | Image(s) Supported              | Details            |
| ------- | ----------- | ------------ | ------------------------------- | ------------------ |
| 0.13.17 | Aug 25, 2018| =2.1.0.3     | ibmcom/spectrum-conductor:2.3   | Evaluation Edition |
| 0.13.16 | Mar 23, 2018| =2.1.0.1     | ibmcom/spectrum-conductor:2.2.1 | Technical Preview  |
