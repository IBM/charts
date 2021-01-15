# Breaking Changes
None

# What’s new in Chart Version 2.0.6

With ibm-object-storage-plugin chart version 2.0.6, the following new
features are available:
* Enabled optional default parameters like secret name, bucket name and other for storage class

# Fixes
* GoLang update to 1.15.5
* Fixed CVEs CVE-2020-28362, CVE-2020-28367, CVE-2020-28366
* Enabled image signing and updated images labels

# Prerequisites
Install [Helm client v3](https://cloud.ibm.com/docs/containers?topic=containers-helm#install_v3) on your local machine.

**NOTE:** For IBM Cloud Kubernetes Service(IKS), it is strongly recommended to [migrate from helm v2 to v3](https://cloud.ibm.com/docs/containers?topic=containers-helm#migrate_v3). For IBM Cloud Private(ICP), no need to update the helm client.

# Documentation
For install/upgrade, follow instructions [here](https://cloud.ibm.com/docs/containers?topic=containers-object_storage#object_storage).

# Version History

| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- |
| 2.0.6 | Dec 19, 2020| >=1.10.1-0 | 1.8.23 | None | Enabled optional default parameters like secret name, bucket name and other for storage class, GoLang update to 1.15.5, Enabled image signing and updated images labels  and Fixed CVE-2020-28362 CVE-2020-28367 CVE-2020-28366 |
| 2.0.5 | Nov 25, 2020| >=1.10.1-0 | 1.8.22 | None | Fixed NilPointer error and CVEs CVE-2018-20843 CVE-2019-13050 CVE-2019-13627 CVE-2019-14889 CVE-2019-1551 CVE-2019-15903 CVE-2019-16168 CVE-2019-16935 CVE-2019-19221 CVE-2019-19906 CVE-2019-19956 CVE-2019-20218 CVE-2019-20386 CVE-2019-20387 CVE-2019-20388 CVE-2019-20454 CVE-2019-20907 CVE-2019-5018 CVE-2020-10029 CVE-2020-13630 CVE-2020-13631 CVE-2020-13632 CVE-2020-14422 CVE-2020-1730 CVE-2020-1751 CVE-2020-1752 CVE-2020-6405 CVE-2020-7595 CVE-2020-8177 |
| 2.0.4 | Oct 07, 2020| >=1.10.1-0 | 1.8.21 | None | Updated s3fs-fuse to fix IAM Apikey token refresh issue, Upgraded Golang to v1.15.2 for fixing CVE-2020-24553 |
| 2.0.3 | Sep 23, 2020| >=1.10.1-0 | 1.8.20 | None | Enabled Bucket AccessPolicy for VPC-Gen2 clusters, Upgraded Golang to v1.13.15 for fixing CVE-2020-16845 and CVE-2020-24553, Upgraded UBI base image to 8.2-349 for fixing CVE-2020-14352 |
| 2.0.2 | Aug 06, 2020| >=1.10.1-0 | 1.8.19 | None | Upgraded Golang to v1.13.14 for fixing CVE-2020-15586 and CVE-2020-14039, Fix for plugin deployment in custom namespace for IKS cluster |
| 2.0.1 | July 10, 2020| >=1.10.1 | 1.8.18 | None | Update UBI base Image, Set default values for `auto-create-bucket`, `auto-delete-bucket` and `bucket` annotations in PVC |
| 2.0.0 | June 16, 2020| >=1.10.1 | 1.8.17 | None | Cert 2.0 Certification, Restrict COS Access Secret for selected namespaces, Allowed re-using existing bucket with `auto-create-bucket: true`, GoLang: v1.13.5 |
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
