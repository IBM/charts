# What’s new in IBM Spectrum Conductor Version 0.13.x

With IBM Spectrum Conductor Chart on IBM Cloud Private 2.1.0.3/3.1.x, the following new
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
 * Support IBM Cloud Private 3.1.x

# Breaking Changes

# Documentation
To learn more about using IBM Spectrum Conductor, see the online [IBM Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSZU2E_2.3.0/icp/conductor_icp.html).

# Prerequisites
1. IBM Cloud Private version 2.1.x or 3.1.x

# Fixes

# Version History

| Chart   | Date        | ICP Required | Image(s) Supported              | Details            |
| ------- | ----------- | ------------ | ------------------------------- | ------------------ |
| 0.13.18 | Nov 06, 2018| =3.1.0.0     | ibmcom/spectrum-conductor:2.3   | Beta Edition, evaluation purpose only |
| 0.13.17 | Aug 25, 2018| =2.1.0.3     | ibmcom/spectrum-conductor:2.3   | Evaluation Edition |
| 0.13.16 | Mar 23, 2018| =2.1.0.1     | ibmcom/spectrum-conductor:2.2.1 | Technical Preview  |
