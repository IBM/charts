# What’s new... 

## Latest: Chart Version 1.0.0

1. Initial release of the Open Liberty Spring chart with support for ingress, persistence, monitoring, autoscaling and extensions.

## Breaking Changes

* None

## Fixes

* None

## Prerequisites

* Tiller v2.8.0
* For all others, refer to prerequisites in [README.md](https://github.com/IBM/charts/tree/master/stable/ibm-open-liberty-spring/README.md).

## Documentation

Please refer to [README.md](https://github.com/IBM/charts/tree/master/stable/ibm-open-liberty-spring/README.md).

## Known Issues

1. If you enable ingress during deployment _and_ specify a host value, the Launch button will return error 404. 
1. If deploying to the IBM Kubernetes Service on the IBM Public Cloud, you can only create one ingress resource per host. 
1. The createClusterSSLConfiguration option is not supported on z/Linux. To use the useClusterSSLConfiguration option for a deployment targeting z/Linux, you must first do a deployment on a non-z/Linux node in the same cluster, specifying the createClusterSSLConfiguration option in order to establish the cluster-scope SSL configuration.

## Limitations 

The chart does not yet provide an out of the box secure configuration for the Metrics endpoint. The Metrics endpoint is served only via HTTP since Prometheus in IBM Cloud Private is not able to scrape secured endpoints at this time. 

## Version History

| Chart | Date         | IBM Cloud Private Supported | Details                      |
| ----- | ------------ | --------------------------- | ---------------------------- |
| 1.0.0 | May 20, 2019 | >=3.1.0                     | Initial release              |
