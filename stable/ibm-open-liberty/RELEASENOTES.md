# What’s new... 

## Latest: Chart Version 1.7.0

1. The value service.name is now used as the service metadata name and DNS A record. If unspecified, it will default to the generated `fullname`. The DNS SRV port name will be assigned as `http` or `https` respectively if ssl is enabled.
1. Removed the value jmsService.name. The DNS SRV port name will be assigned as `jms` or `jmss` respectively if ssl is enabled.
1. Removed the value iiopService.name. The DNS SRV port name will be assigned as `iiop` or `iiops` respectively if ssl is enabled.
1. Defined the most restrictive PodSecurityPolicy for the chart and provided scripts to create the required Kubernetes resources.
1. Added more configurable parameters to values.yaml, such as environment variables, ingress annotations, readiness and liveness probes.
1. Updated minimum `kubeVersion` of chart to ensure patch for [CVE-2018-1002105](https://github.com/kubernetes/kubernetes/issues/71411) is installed.
1. Unlinked visualizations from liberty all search, and set default time range (15 minutes) for efficiency.
1. Sort dashboard searches by @timestamp to avoid timeout error, include searches sorted by Sequence for proper ordering.

## Breaking Changes

* None

## Fixes

* None

## Prerequisites

* Tiller v2.7.0
* For all others, refer to prerequisites in [README.md](https://github.com/IBM/charts/tree/master/stable/ibm-open-liberty/README.md).

## Documentation

Please refer to [README.md](https://github.com/IBM/charts/tree/master/stable/ibm-open-liberty/README.md).

## Known Issues

1. Upgrade from all versions except v1.0.0 is supported.
1. If upgrading using the ICP console from earlier chart releases, you must re-specify all custom configuration values you specified in the previous deployment.  Otherwise only default values are applied to the upgrade. 
1. If your application uses IIOP, you must remove the iiopEndpoint configuration from your server.xml before building the Docker image you intend to deploy via this Helm chart. Failure to do so will prevent port values you specify through this Helm chart from overriding those specified in your server.xml. 
1. If your deployment enables IIOP and/or JMS endpoints, they will be erroneously displayed in the Launch button dropdown on the Helm Releases page of the ICP console. The Launch button only works with HTTP/S endpoints, so launching IIOP or JMS endpoints obviously will result in errors. 
1. If you enable ingress during deployment _and_ specify a host value, the Launch button will return error 404. 
1. If deploying to the IBM Kubernetes Service on the IBM Public Cloud, you can only create one ingress resource per host. 
1. The createClusterSSLConfiguration option is not supported on z/Linux. To use the useClusterSSLConfiguration option for a deployment targeting z/Linux, you must first do a deployment on a non-z/Linux node in the same cluster, specifying the createClusterSSLConfiguration option in order to establish the cluster-scope SSL configuration.

## Limitations 

The chart does not yet provide an out of the box secure configuration for the /metrics endpoint.  The /metrics endpoint is served only via HTTP without authentication since prometheus in IBM Cloud Private is not able to scrape secured endpoints at this time. 

## Version History

| Chart | Date         | IBM Cloud Private Supported | Details                      |
| ----- | ------------ | --------------------------- | ---------------------------- |
| 1.7.0 | Jan 31, 2019 | >=2.1.0.2                   | Defined the most restrictive PodSecurityPolicy; Added support for more configurable parameters; Changed HTTP, JMS and IIOP service names     |
| 1.6.0 | Sep 28, 2018 | >=2.1.0.2                   | Added support to serve `/metrics` on HTTP port; New and updated Grafana and Kibana dashboards; IBM Certified Cloud Pak manifest     |
| 1.5.1 | AUG 22, 2018 | >=2.1.0.2                   | Added metering annotations                                  |
| 1.5.0 | Jul 11, 2018 | >=2.1.0.2                   | Hazelcast session caching; Host support for Ingress configuration; Protocol support for IIOP and JMS; Multi-architecture support  |
| 1.4.0 | N/A          | N/A                         | Skipped this release                                         |
| 1.3.0 | N/A          | N/A                         | Skipped this release                                         |
| 1.2.0 | Apr 11, 2018 | >=2.1.0.1                   | Sync with commercial chart.                                  |
| 1.1.0 | Mar 26, 2018 | >=2.1.0.1                   | Initial release. Includes JSON logging.                      |
