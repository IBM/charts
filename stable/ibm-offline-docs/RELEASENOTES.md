# What’s new...

## Latest: Chart Version 1.0.0

1. This chart deploys IBM Cloud Pak for Multicloud Management versions 1.1 and 1.2 documentation. 

## Breaking Changes

* None

## Fixes

* None

## Prerequisites

Refer to the [README.md](https://github.com/IBM/charts/tree/master/stable/ibm-offline-docs/README.md).

## Documentation

Refer to [README.md](https://github.com/IBM/charts/tree/master/stable/ibm-offline-docs/README.md).

## Known Issues

1. The createClusterSSLConfiguration option is not supported when using [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) PodSecurityPolicy or the custom one defined in the README.md file. To use the useClusterSSLConfiguration option for a deployment, you must first create a deployment using [`ibm-anyuid-psp`](https://ibm.biz/cpkspec-psp) PodSecurityPolicy in the same cluster, specifying the createClusterSSLConfiguration option in order to establish the cluster-scope SSL configuration.

## Limitations
This chart is available only for the IBM Cloud Pak for Multicloud Management running on Linux® x86_64.

## Version History

| Chart | Date          | IBM Cloud Pak for Multicloud Management Supported | Details                      |
| ----- | ------------- | --------------------------- | ---------------------------- |
| 1.0.0 | December 10, 2019  | >=1.1            | Included IBM Cloud Pak for Multicloud Management versions 1.1 and 1.2   |
