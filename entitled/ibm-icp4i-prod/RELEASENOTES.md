## Breaking Changes
None

## What’s new...
* Support for entitled registry
* Support for global cloud catalog
* Automatically set the `vm.max_map_count` sysctl setting to a minimum of 1048576 on worker nodes

## Fixes
None

## Prerequisites
* Red Hat OpenShift version 3.11.
* IBM Cloud Private fix pack 3.2.0.1907.
* A user with cluster administrator role is required to install the chart.

## Documentation
See [README.md](README.md).

## Version History
| Chart Version | Date Released  | Kubernetes Required | Images Supported                                                   | Breaking Changes | Details                                                                   |
| ------------- | -------------- | ------------------- | ------------------------------------------------------------------ | ---------------- | ------------------------------------------------------------------------- |
| 2.1.2         | Oct 4th, 2019  | \>=1.11             | icip-navigator:2.1.1, icip-configurator:2.1.1, icip-services:2.1.1 | N/A              | Updated license                                                           |
| 2.1.1         | Sep 27th, 2019 | \>=1.11             | icip-navigator:2.1.0, icip-configurator:2.1.0, icip-services:2.1.0 | N/A              | Fixes                                                                     |
| 2.1.0         | Sep 27th, 2019 | \>=1.11             | icip-navigator:2.1.0, icip-configurator:2.1.0, icip-services:2.1.0 | N/A              | Support for entitled registry and global cloud catalog.                   |
| 2.0.0         | Jul 26th, 2019 | \>=1.11             | icip-navigator:2.0.0, icip-configurator:2.0.0, icip-services:2.0.0 | N/A              | Support IBM Cloud Private 3.2                                             |
| 1.2.0         | Jun 28th, 2019 | \>=1.10             | icip-navigator:1.2.0, icip-configurator:1.2.0, icip-services:1.2.0 | N/A              | Add platform asset repository. Rename from ibm-cip-prod to ibm-icp4i-prod |
| 1.1.0         | May 31st, 2019 | \>=1.11             | icip-navigator:1.1.0, icip-configurator:1.1.0, icip-services:1.1.0 | N/A              | Add Datapower and Aspera to the Navigator                                 |
| 1.0.0         | Jan 25th, 2019 | \>=1.11             | icip-navigator:1.0.0, icip-configurator:1.0.0                      | N/A              | Initial release                                                           |
