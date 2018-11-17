
# What’s new in Chart Version 1.0.0

Initial release of WebSphere Application Server traditional Base edition helm chart.

## Breaking Changes

* None

## Fixes

* None

## Prerequisites

* Tiller >= v2.9.1
* For all others, refer to [Requirements in README.md](README.md)

## Documentation

Please refer to [README.md](README.md)

## Limitations

* Redirects (30x):

  When there are server initiated redirects the `Location` header might use container port (eg. 9443) instead of Ingress 
  or NodePort one. The `ibmcom/websphere-traditional` image from Docker Hub already enables custom WebContainer properties
  `trusthostheaderport=true` and `com.ibm.ws.webcontainer.extractHostHeaderPort=true`.
  
  These properties will force server to use and trust the port from the `Host` header. 
  However, even with these properties enabled, server needs to be able to match incoming ports with a
  Virtual Host alias. Default Virtual Host aliases are configured for these ports: `9080, 9443, 443, 80`. 
  
  In case the port in the Host header is different than these ports there 
  will be `SRVE0255E: A WebGroup/Virtual Host to handle host:port has not been defined.` error message.
  
## Known Issues

* None

## Version History

| Chart | Date          | IBM Cloud Private Supported | Details                      |
| ----- | ------------- | --------------------------- | ---------------------------- |
| 1.0.0 | NOV 16, 2018   | >=3.1.0                     | Initial release              |
