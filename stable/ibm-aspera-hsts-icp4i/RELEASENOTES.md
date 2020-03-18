# Release Notes: IBM Aspera High-Speed Transfer Server

___

## What's new

* Metering annotations

## Fixes

* None

## Breaking Changes

* None

## Prerequisites

1. Kubernetes version >= 1.9.1
2. IBM Cloud Private version >= 3.1.0
3. See the client secret requirements in README.md.

## Documentation

For detailed information on the HSTS, see the IBM Aspera High-Speed Transfer Server Admin Guide at https://downloads.asperasoft.com/en/downloads/1.

___

## Version History

| Chart | Date        | Kubernetes Required | Image(s) Supported         | Details                                                             |
| ----- | ----------- | ------------------- | -------------------------- | ------------------------------------------------------------------- |
| 1.2.4 | November 30, 2019 | >= 1.9.1         | aspera-hsts-*  | Metering annotations |
| 1.2.3 | October 31, 2019 | >= 1.9.1         | aspera-hsts-*  | Secret generation flag fix |
| 1.2.2 | September 29, 2019 | >= 1.9.1         | aspera-hsts-*  | Entitled Registry support |
| 1.2.1 | July 5, 2019 | >= 1.9.1         | aspera-hsts-*  | All deployments updated to support multiple replicas, default secret generation |
| 1.2.0 | June 11, 2019 | >= 1.9.1         | aspera-hsts-*  | Support for IBM Cloud Private on OpenShift |
| 1.1.1 | March 12, 2019 | >= 1.11.1         | aspera-hsts-*  | Support for IBM Cloud Private 3.1.2 nginx controller, securityContext additions for initContainers|
| 1.1.0 | February 6, 2019 | >= 1.11.1         | aspera-hsts-*  | Add redis subchart, ConfigMap checksum annotations|
| 1.0.0 | December 14, 2018 | >= 1.11.1         | aspera-hsts-*  | Initial Release |
