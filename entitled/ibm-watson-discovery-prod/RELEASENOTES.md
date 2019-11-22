# What’s new in Chart Version 2.0.1

- IBM® Cloud Private for Data is now IBM® Cloud Pak for Data
- Easily switch between Development or Production (HA) deployment configurations through the `deploymentType` parameter
- Now available on OpenShift 
- Simplified installation process with the new bundled deploy script

# Breaking Changes

No breaking changes are present in this release

# Limitations

- Watson Discovery can currently run only on Intel 64-bit architecture.
- This chart should only use the default image tags provided with the chart. Different image versions might not be compatible with different versions of this chart.
- Watson Discovery deployment supports a single service instance.
- The chart must be installed through the cli.
- The chart must be installed by a ClusterAdministrator see [Pre-install steps](#pre-install-steps) in the readme.
- This chart currently does not support upgrades or rollbacks. Please see the [product documentation](https://cloud.ibm.com/docs/services/discovery-data?topic=discovery-data-backup-restore) on backup and restore procedures.
- Release names cannot be longer than 20 characters
- To take advantage of metering for CP4D, Watson Discovery must be deployed within the cluster's `zen` namespace. Watson Discovery may still be installed to other namespaces (custom made or default), but they __will not__ support metering.

# Fixes

## Prerequisites

- IBM® Cloud Pak for Data 2.1.0.1

# Documentation

For detailed installation instructions go to the [documentation](https://docs-icpdata.mybluemix.net/docs/content/SSQNUZ_current/com.ibm.icpdata.doc/watson/discovery-install.html)


# Version History

| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- |
| 2.0.1 | August 30, 2019 | >=1.11.0 | This chart consists of a number of versioned images. The combination of images in use must not be changed from those shipped by the release. | | IBM® Cloud Private -> IBM® Cloud Pak
| 2.0.0 | June 28, 2019 | >=1.12.4 | This chart consists of a number of versioned images. The combination of images in use must not be changed from those shipped by the release. |  | Now available on IBM® Cloud Private for Data |