## Breaking Changes
Changes to the helm charts mean that in-place upgrades to 3.0.0 will not work and a new release will be required

## What’s new...
* Support for OpenShift 4.2
* New UI look and feel

## Fixes
None

## Prerequisites
* Red Hat OpenShift version 4.2 (3.11 on IBM Cloud Catalog only).
* Cloud Pak Foundation fix pack 3.2.2
* A user with cluster administrator role is required to install the chart

## Documentation
See [README.md](README.md).

## Version History
| Chart Version | Date Released  | Kubernetes Required | Images Supported                                                   | Breaking Changes | Details                                                                   |
| ------------- | -------------- | ------------------- | ------------------------------------------------------------------ | ---------------- | ------------------------------------------------------------------------- |
| 3.0.0         | Nov 29th, 2019 | \>=1.11             | icip-navigator:3.0.0, icip-configurator:3.0.0, icip-services:3.0.0 | N/A              | Support for OpenShift 4.2                                                 |
| 2.2.0         | Oct 28th, 2019 | \>=1.11             | icip-navigator:2.2.0, icip-configurator:2.2.0, icip-services:2.2.0 | N/A              | Support for Operations Dashboard                                          |
| 2.1.1         | Sep 27th, 2019 | \>=1.11             | icip-navigator:2.1.0, icip-configurator:2.1.0, icip-services:2.1.0 | N/A              | Fixes                                                                     |
| 2.1.0         | Sep 27th, 2019 | \>=1.11             | icip-navigator:2.1.0, icip-configurator:2.1.0, icip-services:2.1.0 | N/A              | Support for entitled registry and global cloud catalog                    |
| 2.0.0         | Jul 26th, 2019 | \>=1.11             | icip-navigator:2.0.0, icip-configurator:2.0.0, icip-services:2.0.0 | N/A              | Support Cloud Pak Foundation 3.2                                          |
| 1.2.0         | Jun 28th, 2019 | \>=1.10             | icip-navigator:1.2.0, icip-configurator:1.2.0, icip-services:1.2.0 | N/A              | Add platform asset repository. Rename from ibm-cip-prod to ibm-icp4i-prod |
| 1.1.0         | May 31st, 2019 | \>=1.11             | icip-navigator:1.1.0, icip-configurator:1.1.0, icip-services:1.1.0 | N/A              | Add Datapower and Aspera to the Navigator                                 |
| 1.0.0         | Jan 25th, 2019 | \>=1.11             | icip-navigator:1.0.0, icip-configurator:1.0.0                      | N/A              | Initial release                                                           |
