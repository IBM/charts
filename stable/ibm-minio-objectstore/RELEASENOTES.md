# Release notes: ibm-minio-objectstore

# What’s new in ibm-minio-objectstore V 2.4.7

The following new features are available with this release:

* The IBM® Cloud Private Certificate manager service is used to issue and manage certificates for Minio service
* Multiple buckets can be created along with chart installation
* IBM® Z architecture support

# Fixes
* Security vulnerability ibmcom/minio image
* Default bucket creation when using SSL for Minio service
* Ingress configuration can be specified in web UI
* Performance improvement from community


## Breaking Changes
* The Minio docker image has been upgraded.

# Prerequisites
1. IBM Cloud Private version  >= 3.1.0

# Documentation
Check the README file provided with the chart for detailed installation instructions.

# Version History

| Chart | Date            | IBM Cloud Private version Required | Image(s) Supported                            | Details |
| ----- | --------------- | ---------------------------------- | --------------------------------------------- | ------- |
| 2.4.7 | May 22, 2019 | >=3.1.0                            | ibmcom/minio:RELEASE.2019-04-09T01-22-30Z.1, ibmcom/minio-mc:RELEASE.2019-04-03T17-59-57Z.1     | Security vulnerability fix in Minio docker image, performance improvement from community. |
| 1.6.2 | January 8, 2019 | >=3.1.0                            | ibmcom/minio:RELEASE.2018-11-30T03-56-59Z     | Security vulnerability fix in Minio docker image |
|       |                 |                                    | ibmcom/minio-mc:RELEASE.2018-11-30T01-52-08Z  |         |
|       |                 |                                    |                                               |         |
| 1.6   | September 20, 2018| >=2.1.0.3                        | ibmcom/minio:RELEASE.2018-08-21T00-37-20Z     | Chart for installing Minio object store server on ICP |
|       |                 |                                    | ibmcom/minio-mc:RELEASE.2018-07-13T00-53-22Z  |         |
|       |                 |                                    |                                               |         |
| 1.3.4 | June 27, 2018   | >=2.1.0.3                          | minio/minio:RELEASE.2018-06-09T03-43-35Z      | Chart for installing Minio object store server on IBM Cloud Private |
|       |                 |                                    | minio/mc:RELEASE.2018-06-09T02-18-09Z         |         |
|       |                 |                                    |                                               |         |
