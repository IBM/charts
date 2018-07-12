# What’s New in Chart Version 1.5.0

1. RELEASENOTES.md
1. Hazelcast session caching 
1. Host support for Ingress configuration
1. Protocol support for IIOP and JMS 
1. Multi-architecture support 

## Older Releases 

### v1.4.0

Added support for optional JSON format logging.

### v1.3.0

- Added metadata to all the values.
- Added the ability to persist regular logs.

### v1.2.0

Enhanced transactional persistence support.

### v1.1.0

- added SSL support (generating SSL artifacts in ICP and using them in the helm chart)
- added MP Health support
- z Linux support

### v1.0.1 

- Small bug fixes from WebSphere Liberty helm chart version 1.0.0
- Introduction of the Open Liberty helm chart version 1.0.0

### v1.0.0 

Initial release. Supports auto-scaling, ingress and persistence logs.

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
1. If use enable ingress during deployment _and_ specify a host value, the Launch button will return error 404. 
1. If deploying to the IBM Kubernetes Service on the IBM Public Cloud, you can only create one ingress resource per host. 

## Version History

| Chart | Date          | IBM Cloud Private Supported | Details                      |
| ----- | ------------- | --------------------------- | ---------------------------- |
| 1.0.0 | Dec 10, 2017  | >=2.1.0                     | None                         |
| 1.0.1 | Dec 10, 2017  | >=2.1.0                     | None                         |
| 1.1.0 | Dec 10, 2017  | >=2.1.0                     | None                         |
| 1.2.0 | Feb 13, 2018  | >=2.1.0.1                   | None                         |
| 1.3.0 | Feb 13, 2018  | >=2.1.0.1                   | None                         |
| 1.4.0 | Mar 20, 2018  | >=2.1.0.1                   | None                         |
| 1.5.0 | Jul 11, 2018  | >=2.1.0.2                   | None                         |
