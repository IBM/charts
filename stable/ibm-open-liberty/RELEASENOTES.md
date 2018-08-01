# What’s new... 

## Latest: Chart Version 1.5.0

1. RELEASENOTES.md
1. Hazelcast session caching 
1. Host support for Ingress configuration
1. Protocol support for IIOP and JMS 
1. Multi-architecture support 

## Older Releases 

### v1.3.0, v1.4.0

Skipped these releases.  v1.5.0 is now update to date with commercial Liberty chart.

### v1.2.0

Sync with commercial chart.

### v1.1.0 

Initial release.  Includes updates for JSON logging.

## Breaking Changes
  - None 

## Fixes
  - None

## Prerequisites
  - Tiller v2.7.0
  - For all others, refer to [Requirements in README.md](/stable/ibm-websphere-liberty/README.md)

## Known Issues

1. Upgrade from all versions except v1.0.0 is supported.
1. If upgrading from earlier chart releases, you must re-specify all custom configuration values you specified in the previous deployment.  Otherwise only default values are applied to the upgrade. 
1. If your application uses IIOP, you must remove the iiopEndpoint configuration from your server.xml before building the Docker image you intend to deploy via this Helm chart. Failure to do so will prevent port values you specify through this Helm chart from overriding those specified in your server.xml. 
1. If your deployment enables IIOP and/or JMS endpoints, they will be erroneously displayed in the Launch button dropdown on the Helm Releases page of the ICP console. The Launch button only works with HTTP/S endpoints, so launching IIOP or JMS endpoints obviously will result in errors. 
1. If you enable ingress during deployment _and_ specify a host value, the Launch button will return error 404. 
1. If deploying to the IBM Kubernetes Service on the IBM Public Cloud, you can only create one ingress resource per host. 
1. The createClusterSSLConfiguration option is not supported on z/Linux. To use the useClusterSSLConfiguration option for a deployment targeting z/Linux, you must first do a deployment on a non-z/Linux node in the same cluster, specifying the createClusterSSLConfiguration option in order to establish the cluster-scope SSL configuration.

## Version History

| Chart | Date         | IBM Cloud Private Supported | Details                      |
| ----- | ------------ | --------------------------- | ---------------------------- |
| 1.1.0 | Mar 26, 2018 | >=2.1.0.1                   | None                         |
| 1.2.0 | Apr 11, 2018 | >=2.1.0.1                   | None                         |
| 1.3.0 | N/A          | N/A                         | Skipped this release         |
| 1.4.0 | N/A          | N/A                         | Skipped this release         |
| 1.5.0 | Jul 11, 2018 | >=2.1.0.2                   | None                         |
