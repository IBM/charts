# What’s new in ibm-minio-objectstore V 1.6

The following new features are available with this release:

* This Helm chart deploys minio object store server
* SSL is enabled for Minio servers.

# Fixes
* This Helm chart has bucket notification features enabled.
* Added support for Linux® on Power® 64-bit LE.
* Security vulnerability ibmcom/minio image.

# Prerequisites
1. IBM Cloud Private version 2.1.0.3 and higher.

# Version History

| Chart | Date        | ICP Required | Image(s) Supported | Details |
| ----- | ----------- | ------------ | ------------------ | ------- |
| 1.6   | September 20, 2018| >=2.1.0.3    | ibmcom/minio:RELEASE.2018-08-21T00-37-20Z, ibmcom/minio-mc:RELEASE.2018-07-13T00-53-22Z | Chart for installing minio object store server on ICP |
| 1.3.4 | June 27, 2018| >=2.1.0.3    | minio/minio:RELEASE.2018-06-09T03-43-35Z, minio/mc:RELEASE.2018-06-09T02-18-09Z | Chart for installing minio object store server on ICP |
