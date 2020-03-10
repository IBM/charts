# Breaking Changes
None

# What’s new in Chart Version 1.1.4

With ibm-object-storage-plugin chart version 1.1.4, the following new
features are available:
* Enabled support for `auto_cache` option from pvc spec.

# Fixes
* Upgraded s3fs-fuse version to commit d34475d.
* Resolved security issue CVE-2020-1712.

# Prerequisites
Install [Helm client v3](https://cloud.ibm.com/docs/containers?topic=containers-helm#install_v3) on your local machine.

**NOTE:** For IBM Cloud Kubernetes Service(IKS), it is strongly recommended to [migrate from helm v2 to v3](https://cloud.ibm.com/docs/containers?topic=containers-helm#migrate_v3). For IBM Cloud Private(ICP), no need to update the helm client.

# Documentation
For install/upgrade, follow instructions [here](https://cloud.ibm.com/docs/containers?topic=containers-object_storage#object_storage).

# Version History

| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- |
| 1.1.4 | Mar 10, 2020| >=1.10.1 | 1.8.13 | None | Resolved security issue CVE-2020-1712, Updated s3fs-fuse to use latest commit, Enabled support for 'auto_cache' option from pvc spec, GoLang: v1.13.4 |
| 1.1.3 | Feb 13, 2020| >=1.10.1 | 1.8.12 | None | Resolved security issues CVE-2019-13734 and CVE-2019-18408, Updated `ibmc` helm plugin to support object-storage plugin installation/upgradation with `helm v2` and `helm v3`, Updated helm chart to auto-recreate plugin pods when upgrading plugin, GoLang: v1.13.4 |
| 1.1.2 | Dec 09, 2019| >=1.10.1 | 1.8.11 | None | Non-root user access broken for K8S >= 1.15.4, GoLang: v1.13.4 |
| 1.1.1 | Nov 22, 2019| >=1.10.1 | 1.8.10 | None | Golang update to version 1.13.4, Gosec enabled in plugin code; GoLang: v1.13.4, PSIRT image vulnerability fix |
| 1.1.0 | Oct 25, 2019| >=1.10.1 | 1.8.9 | None | Updated helm chart to support plugin deployment on `VPC` clusters, Updated `ibmc` helm plugin to detect VPC cluster and deploy plugin accordingly, Disabled mounting of `/` directory inside object-storage-plugin driver pods; GoLang: v1.12.9 |
| 1.0.9 | Sep 09, 2019| >=1.10.1 | 1.8.8 | None | Upgraded GoLang to v1.12.9 for fixing GoLang vulnerability issue, Setting 'default_acl=private' in driver, when using HMAC credentials; GoLang: v1.12.9 |
| 1.0.8 | Jun 24, 2019| >=1.10.1 | 1.8.7 | None | Updated chart to set cpu and memory limits for object-storage plugin pods, Updated registry URL to `icr.io`, Updated helm repo from `iks-charts` to `ibm-charts`, Updated chart to create storageclasses with `tls-cipher-suite` as per worker node's operating system family(`Debian/Red Hat`), Updated `ibmc` plugin to use `--set workerOS=<debian / redhat>` while installing/upgrading object-storage plugin depending on worker node's operating system family, Build images on Red Hat UBI (Universal Base Image) for red-hat-openshift support, README Update; Readiness probes configured in driver/plugin containers; GoLang: v1.12.1 |
| 1.0.7 | May 17, 2019| >=1.10.1 | 1.8.6 | None | Allow late binding and dynamic provisioning of volume, Updated helm chart to deploy on managed openshift on IBM Kubernetes Service(IKS), Updated `ibmc` plugin to install/uninstall chart `without tiller`, Updated `ibmc` plugin to install specific version of the chart, Updated `ibmc` plugin to fix the issue while installing the chart with lower version of `kubectl` client; GoLang: v1.12.1 |
| 1.0.6 | May 02, 2019| >=1.10.1 | 1.8.6 | None | Use ibm-cos-sdk instead of AWS SDK; Mask IAM credentials in driver log; Change helm repo from ibm to iks-charts  |
| 1.0.5 | Apr 18, 2019| >=1.10.1 | 1.8.5 | None | Mount bucket as per AccessMode defined in PVC; Exposed s3fs options from PVC, like use-xattr and readwrite-timeout; Enabled deployment on RHEL and CentOS; GoLang: v1.12.1 |
| 1.0.4 | Apr 05, 2019| >=1.9.1 | 1.8.4 | None | Updated COS endpoints; updated storageclass templates for `Mexico` datacenter; drop `ALL` capabilities from plugin containers; replaced beta apiVersion with stable apiVersion for underlying plugin components; added option `useCustomPSP` to install plugin using custom PSP for ICP; updated `ibmc` helm plugin upgrade logic; replaced deprecated `kubernetes-incubator/external-storage` package with `kubernetes-sigs/sig-storage-lib-external-provisioner`; added support to override `tls-cipher-suite` through PVC annotations; updated Golang version to 1.12.1 for security fixes; restore original sshd_config file on worker nodes after installing driver binary; README update. |
| 1.0.3 | Feb 21, 2019| >=1.9.1 | 1.8.3 | None | Enabled deployment of custom PSP for cos volume plugin for ICP; enabled deployment of plugin under custom namespace for ICP;  added support to have secret and PVC in different namespace; added support to override `curldbg`, `dbglevel`, `connect_timeout`, `readwrite_timeout`, `stat_cache_expire` and `use_xattr` options through PVC annotations; README update. |
| 1.0.2 | Jan 11, 2019| >=1.9.1 | 1.8.2 | None | Storageclass templates update for `San Jose`, `Tokyo`, `Milan` and `London` datacenters; update chart to conform to Hybrid Content Standards and Guidelines; enhance `ibmc` helm plugin to support ICP and IKS. |
| 1.0.1 | Sep 10, 2018| >=1.9.1 | 1.8 | None | Modify storageclasses templates and installation doc updates. |
| 1.0.0 | Aug 31, 2018| >=1.8.3 | 1.8 | None | Installation doc updates. |
| 0.0.2 | Aug 03, 2018| >=1.8.3 | 1.8 | None  | Added --update option to ibmc helm plugin for helm plugin upgrade support and installation doc updates. |
| 0.0.1 | Jul 23, 2018| >=1.8.3 | 1.8 | None | Chart includes dynamic provisioner (ibmcloud-object-storage-plugin), driver (ibmcloud-object-storage-driver) and Storageclasses (ibmc-s3fs...). |
