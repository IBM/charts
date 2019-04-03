# Breaking Changes
None

# What’s new in Chart Version 1.0.4

With ibm-object-storage-plugin chart version 1.0.4, the following new
features are available:
* Updated COS endpoints.
* Updated storageclass templates for `Mexico` datacenter.
* Drop `ALL` capabilities from plugin containers.
* Replaced beta apiVersion with stable apiVersion for underlying plugin components.
* Added option `useCustomPSP` to install plugin using custom PSP for ICP.
* Updated `ibmc` helm plugin upgrade logic.
* README update.

# Fixes
* Replaced deprecated `kubernetes-incubator/external-storage` package with `kubernetes-sigs/sig-storage-lib-external-provisioner`.
* Added support to override `tls-cipher-suite` through PVC annotations.
* Updated Golang version to 1.12.1 for security fixes.
* Restore original sshd_config file on worker nodes after installing driver binary.

# Prerequisites
Install tiller with service-account due to some RBAC issue (helm version: >=2.9.1). Follow instructions [here](https://cloud.ibm.com/docs/containers/cs_integrations.html#helm).

**Note:** To install Tiller with the service account and cluster role binding in the `kube-system` namespace, you must have the [cluster-admin role](https://cloud.ibm.com/docs/containers/cs_users.html#access_policies).

# Documentation
For install/upgrade, follow instructions [here](https://cloud.ibm.com/docs/containers?topic=containers-object_storage#object_storage).

# Version History

| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- |
| 1.0.4 | Apr 05, 2019| >=1.9.1 | 1.8.4 | None | Updated COS endpoints; updated storageclass templates for `Mexico` datacenter; drop `ALL` capabilities from plugin containers; replaced beta apiVersion with stable apiVersion for underlying plugin components; added option `useCustomPSP` to install plugin using custom PSP for ICP; updated `ibmc` helm plugin upgrade logic; replaced deprecated `kubernetes-incubator/external-storage` package with `kubernetes-sigs/sig-storage-lib-external-provisioner`; added support to override `tls-cipher-suite` through PVC annotations; updated Golang version to 1.12.1 for security fixes; restore original sshd_config file on worker nodes after installing driver binary; README update.
| 1.0.3 | Feb 21, 2019| >=1.9.1 | 1.8.3 | None | Enabled deployment of custom PSP for cos volume plugin for ICP; enabled deployment of plugin under custom namespace for ICP;  added support to have secret and PVC in different namespace; added support to override `curldbg`, `dbglevel`, `connect_timeout`, `readwrite_timeout`, `stat_cache_expire` and `use_xattr` options through PVC annotations; README update.
| 1.0.2 | Jan 11, 2019| >=1.9.1 | 1.8.2 | None | Storageclass templates update for `San Jose`, `Tokyo`, `Milan` and `London` datacenters; update chart to conform to Hybrid Content Standards and Guidelines; enhance `ibmc` helm plugin to support ICP and IKS. |
| 1.0.1 | Sep 10, 2018| >=1.9.1 | 1.8 | None | Modify storageclasses templates and installation doc updates. |
| 1.0.0 | Aug 31, 2018| >=1.8.3 | 1.8 | None | Installation doc updates. |
| 0.0.2 | Aug 03, 2018| >=1.8.3 | 1.8 | None  | Added --update option to ibmc helm plugin for helm plugin upgrade support and installation doc updates. |
| 0.0.1 | Jul 23, 2018| >=1.8.3 | 1.8 | None | Chart includes dynamic provisioner (ibmcloud-object-storage-plugin), driver (ibmcloud-object-storage-driver) and Storageclasses (ibmc-s3fs...). |
