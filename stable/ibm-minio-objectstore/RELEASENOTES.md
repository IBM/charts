# Release notes: ibm-minio-objectstore

# What’s new in ibm-minio-objectstore V 1.6.2

The following new features are available with this release:

* This Helm chart deploys Minio object store server
* SSL is enabled for Minio servers.

# Fixes
* Security vulnerability ibmcom/minio image.
* Added pod security policy related requirements.

## Breaking Changes
* The Minio docker image has been upgraded.

# Prerequisites
1. IBM Cloud Private version  >= 3.1.0

# Documentation
Check the  README file provided with the chart for detailed installation instructions.

# Version History

| Chart | Date        | IBM Cloud Private version Required | Image(s) Supported | Details |
| ----- | ----------- | ---------------------------------- | ------------------ | ------- |

| 1.6.2 | January 8, 2019 | >=3.1.0    | ibmcom/minio:RELEASE.2018-11-30T03-56-59Z ibmcom/minio-mc:RELEASE.2018-11-30T01-52-08Z | Security vulnerability fix in Minio docker image |
| 1.6   | September 20, 2018| >=2.1.0.3    | ibmcom/minio:RELEASE.2018-08-21T00-37-20Z, ibmcom/minio-mc:RELEASE.2018-07-13T00-53-22Z | Chart for installing Minio object store server on ICP |
| 1.3.4 | June 27, 2018| >=2.1.0.3    | minio/minio:RELEASE.2018-06-09T03-43-35Z, minio/mc:RELEASE.2018-06-09T02-18-09Z | Chart for installing Minio object store server on IBM Cloud Private |
