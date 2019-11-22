# Breaking Changes
None - Upgrading or rolling back IBM Spectrum Symphony Helm release versions is not supported.

# What’s new in Chart Version 2.0.0

With IBM Spectrum Symphony 7.2.1.1 on IBM Cloud Private 2.1.0.2 or higher, the following new features are available:
* The ibm-spectrum-symphony-prod chart is deployed in restricted mode ([`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp)) to control the security level of the pods and containers. In this restricted mode, root processes are not allowed.
* Each IBM Spectrum Symphony cluster is installed in simplified workload execution mode. In this mode, all system processes run only as the built-in cluster administrator ('egoadmin'). For details on simplified mode, see [Workload execution modes](https://www.ibm.com/support/knowledgecenter/SSZUMP_7.2.1/install_grid_sym/workload_execution_modes.html).
* For the 'egoadmin' user, the default password ('Admin') that was previously hard-coded is now disabled. With this update, the 'egoadmin' password is randomly generated and unknown. The 'cluster.generateClusterAdminPassword' and 'master.regenSSLCert' parameters are also removed. 
* Only SSH public key authentication is enabled for SSH access to the cluster. If SSH access to the client host is enabled ('client.enabled' set to true), a public key is required. If SSH access from the client host to the management and compute hosts is also enabled ('cluster.enableSSHD' set to true), the corresponding private key is also required. 
* Other miscellaneous updates include the following enhancements:
   * Use of predefined scripts to configure your cluster before and/or after cluster startup. 
   * The 'logsOnShared' parameter (which saves component logs to the mounted shared directory) is extended to compute hosts as well. With this update, the 'master.logsOnShared' parameter is removed. Instead, you must use the new 'cluster.logsOnShared' parameter.
   * A subdirectory for each deployment can now be created on the shared volume mount by setting the new 'cluster.enableSharedSubdir' parameter. 
   * The 'cluster.clusterName' parameter is now empty by default. If empty, the cluster takes the name '*release_name*-ibm-spectrum-symphony-prod'. 
   * The 'master.replicaCount' parameter (which defines the number of deployment replicas for the master) is removed. Only one deployment replica can be created for the master.

# Prerequisites
IBM Cloud Private version 2.1.0.2 or higher.

# Fixes
None for chart version 2.0.0

# Documentation
For detailed instructions, go to the [online IBM Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSZUMP_7.2.1/install_grid_sym/symphony_icp.html).

# Version History

| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- | 
|2.0.0 | Mar 22, 2019 | >=1.9.1 | ibmcom/spectrum-symphony:7.2.1.1 | None | See 'What's New' section. |
|1.0.0 	| Aug 10, 2018 	| >=1.9.1 | ibmcom/spectrum-symphony:latest |	None | Changed key system processes to run as cluster admin, made client deployment optional,  added support for Derby DB and logs on shared mount.|

