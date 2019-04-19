
# What’s new in Chart Version 1.2.0

1. Added support for ingress hosts.
1. Added support for securing ingress by specifying a secret that contains a TLS private key and certificate.
1. Added security extension points for pod and image.
1. Updated Kibana dashboards.

## Breaking Changes

* None

## Fixes

* None

## Prerequisites

* Tiller >= v2.9.1
* For all others, refer to prerequisites in README.md

## Documentation

Please refer to README.md

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

* Upgrading to version 1.2.0:
   
  Currently provided Docker images are run using user with UID of `1001` (was) and GID of `0` (root). To avoid other issues please make sure you are using latest version of base image.

  When 1.1.0 version of Helm chart is used, container is forced to run as user `1000` and `persistence.fsGroupID` is `1000`. It is recommened to set `persistence.fsGroupID` to `""` when upgrading.
  
  If persistence of logs is enabled in previous helm release and you encounter errors such as `java.io.FileNotFoundException: /opt/IBM/WebSphere/AppServer/profiles/AppSrv01/logs/server1/logViewer.pos (Permission denied)` after upgrade then set `pod.security.securityContext.runAsUser` to `1000` in order to be able to access persistent files.

  If your pod fails to start after upgrade and your Docker image is still running as UID `1000` then set `pod.security.securityContext.runAsUser` to `1000` during upgrade.

## Version History

| Chart | Date          | IBM Cloud Private Supported | Details                      |
| ----- | ------------- | --------------------------- | ---------------------------- |
| 1.2.0 | APR 19, 2019   | >=3.1.0                     | Added support for ingress hosts and secret name; Updated Kibana dashboards; Added security extension points for pod and image |
| 1.1.0 | JAN 31, 2019   | >=3.1.0                     | Added support for more configurable parameters; Added Kibana dashboards |
| 1.0.0 | NOV 16, 2018   | >=3.1.0                     | Initial release              |
