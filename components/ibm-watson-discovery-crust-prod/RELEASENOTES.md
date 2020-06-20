# What's new in IBM Watson Discovery v2.1.3

- Watson Discovery is now offered as a Cloud Pak for Data Assembly to be installed using the Courier (also known as `cpd`) install utility.

# Breaking Changes

Watson Discovery 2.1.3 does not support IBM Cloud Private Foundations as an install target, and can only be installed on RedHat OpenShift running IBM Cloud Pak for Data 2.5 or 3.0.1.

# Limitations

- Watson Discovery can currently run only on hardware using the x86-64 instruction set
- These charts can only be installed using the default image tags specified in the values.yaml files
- These charts must be installed via the command-line
- Watson Discovery must be deployed in the same namespace as Cloud Pak for Data.

# Fixes

- General stability and performance concerns in previous releases

# Prerequisites

- IBM® Cloud Pak for Data 2.1.0.1 or IBM® Cloud Pak for Data 2.5.0.0


# Documentation

For detailed installation instructions go to the [documentation](https://docs-icpdata.mybluemix.net/docs/content/SSQNUZ_current/com.ibm.icpdata.doc/watson/discovery-install.html)


# Version History

| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- |
| 2.1.3 | 19 June, 2020 | >-1.11.0 | This chart consists of a number of versioned images. The combination of images in use must not be changed from those shipped by the release. | IBM Cloud Private is no longer supported | |
| 2.1.2 | 31 March, 2020 | >=1.11.0 | This chart consists of a number of versioned images. The combination of images in use must not be changed from those shipped by the release. | | |
| 2.1.1 | 24 January, 2020 | >=1.11.0 | This chart consists of a number of versioned images. The combination of images in use must not be changed from those shipped by the release. | | |
| 2.1.0 | 15 November, 2019 | >=1.11.0 | This chart consists of a number of versioned images. The combination of images in use must not be changed from those shipped by the release. | | |
| 2.0.1 | 30 August, 2019 | >=1.11.0 | This chart consists of a number of versioned images. The combination of images in use must not be changed from those shipped by the release. | | IBM® Cloud Private -> IBM® Cloud Pak
| 2.0.0 | 28 June, 2019 | >=1.12.4 | This chart consists of a number of versioned images. The combination of images in use must not be changed from those shipped by the release. |  | Now available on IBM® Cloud Private for Data |
