# What’s new in Chart Version  1.6.4

 *  New sch 1.2.14
 
 *  Good with CV lint 2.0.7
 
 *  Port names changed in rabbitmq headful type service

# Fixes

# Prerequisites

# Breaking Changes

* Port names changed in rabbitmq headful type service

# Documentation

# Version History

| Chart | Date | Kubernetes Version Required | Breaking Changes | Details |
| ----- | ---- | --------------------------- | ---------------- | ------- |
| 1.6.4 | November 12, 2019 | >=1.11 | Port names changed in rabbitmq headful type service |new sch 1.2.14, good with cv lint 2.0.7 | 
| 1.6.2| September 3, 2019| >=1.11 | none | upgrading sch to 1.2.11 and removed a linter override, New images with redhat certified and cve fixes, cv lint 1.4.5 fixes, support for openshift restricted scc and cv lint 1.4.4 fixes.|
| 1.5.0 | June 20, 2019| >=1.12 | New images | New images, changing secret names, cv lint fixes, cv tests, updated Readme| 
| 1.4.0 | June 14, 2019 | >=1.12 | new images, changes to image paramters in values.yaml |  cv lint 1.4.2 fixes, readme fixes |
| 1.3.0 | May 17, 2019 | >= 1.12 | Running as Non root user | Base image changed to UBI, SCH integration, CV lint fixes|
| 1.2.0 | November 19, 2018 | >= 1.9 | none | added secret isolation|
| 1.1.1 | October 22, 2018 | >= 1.9 | none | Can Deploy in any namespace |
| 1.1.0 | October 21, 2018 | >= 1.9 | none | Enabled SSL for UI and amqp |
| 1.0.0 | October 19, 2018 | >= 1.9 | none | Upgraded to 3.7.8 version, Enabled Cluster mode (HA) |