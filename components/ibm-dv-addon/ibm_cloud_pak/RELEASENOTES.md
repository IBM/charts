# IBM Data Virtualization

## What's new in Data Virtualization 1.5.0

* Images based on RedHat Red Hat Universal Base Image
* Data Virtualization images certified in Red Hat Customer Portal 
* Multi worker support
* Backup and restore support 
* Adding caching functionalities
* New installer logic
* Integration with serviceability framework provided by the platform 
* Deployment in OpenShift fully supported

## Fixes

* Advanced Security Hardening 
* Reduce images size and deployment time
* Accept SELinux enforcing 
* Containers running as non root user

## Prerequisites

1. OpenShift Version >= 3.11
1. Tiller version >= 2.9.0
3. IBM Cloud Pak for Data >= 3.5.0

## Version History

| Chart | Date        |     OpenShift Version      | Image(s) Supported                                        | Details                                                                              |
| ----- | ----------- | --------------- | --------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| 1.3.0.0 | Oct 17, 2019 | = 3.11      | dv-addon:1.3.0.0,  dv-service-provider:1.3.0.0| First release for Cloud Pak certification       |
| 1.4.0   | May 5, 2020| >= 3.11     | dv-addon:1.4.0.0,  dv-service-provider:1.4.0.0| 1.4.0 chart release for Cloud Pak certification |
| 1.4.1   | June 19th, 2020| >= 3.11     | dv-addon:1.4.1.0,  dv-service-provider:1.4.1.0| 1.4.1 chart release for Cloud Pak certification |
| 1.5.0   | Nov, 2020| >= 3.11     | dv-addon:1.5.0.0,  dv-service-provider:1.5.0.0| 1.5.0 chart release for Cloud Pak certification |

## Breaking Changes

* Data Virtualization does not support provisioning an instance using preexisting persistent volume claims.

## Documentation

https://docs-icpdata.mybluemix.net/docs/content/SSQNUZ_current/com.ibm.icpdata.doc/dv/dv_overview.html
