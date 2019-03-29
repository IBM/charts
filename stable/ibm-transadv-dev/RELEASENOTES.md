# What’s new in Chart Version 1.9.4
### Analysis Enhancements
 - Analysis now displays relationships between Applications and Shared Libraries/MQ QueueManagers even if these targets have not been scanned

### Data Collector Enhancements
 - Support for collection of Apache Tomcat installations and applications
 - Support for collection on AIX systems without the need for bash to be installed
 - Enhanced support for WAS ND configurations:
   - Notification when shared libraries are referenced by applications but do not exist on the machine being scanned
   - Notification when a managed node is being scanned to ensure that it is the most appropriate location for the scan
 - Prompting for username/password if these are not provided (no need to specify them on the command line)
 - Support for the --exclude-files parameter to exclude irrelevant large files that are impacting performance
 - Support for the --verbose parameter to help trouble shoot any scanning issues
 - Defaulting to the Java that traditional WebSphere uses when it is appropriate to do so
 - Data Collector now uses the binaryScanner v19.0.0.2

### Migration Enhancements
 - Liberty Helm charts are now configured automatically to use Ingress in ICP when the original application has only a single context route
 - Instructions are provided for migrating to traditional WebSphere base running on containers

### Configuration Enhancements
 - Transformation Advisor now supports the definition of a public facing proxy with private masters and nodes in ICP

# Fixes

# Breaking Changes

# Documentation

# Prerequisites
* IBM Cloud Private version 2.1.0.1+

# Version History
| Chart | Date | ICP Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- |
| 1.9.4 | Mar 29, 2019| >=2.1.0.3 | ibmcom/transformation-advisor-db:1.9.4 ibmcom/transformation-advisor-server:1.9.4 ibmcom/transformation-advisor-ui:1.9.4 | None | Apache Tomcat Analysis     |
| 1.9.3 | Feb 11, 2019| >=2.1.0.3 | ibmcom/transformation-advisor-db:1.9.3 ibmcom/transformation-advisor-server:1.9.3 ibmcom/transformation-advisor-ui:1.9.3 | None | Data Collector Patch       |
| 1.9.2 | Feb 05, 2019| >=2.1.0.3 | ibmcom/transformation-advisor-db:1.9.2 ibmcom/transformation-advisor-server:1.9.2 ibmcom/transformation-advisor-ui:1.9.2 | None | Add Shared Libs, MQManagers|
| 1.9.1 | Dec 13, 2018| >=2.1.0.3 | ibmcom/transformation-advisor-db:1.9.1 ibmcom/transformation-advisor-server:1.9.1 ibmcom/transformation-advisor-ui:1.9.1 | None | DC Enhancements            |
| 1.9.0 | Nov 15, 2018| >=2.1.0.3 | ibmcom/transformation-advisor-db:1.9.0 ibmcom/transformation-advisor-server:1.9.0 ibmcom/transformation-advisor-ui:1.9.0 | None | Improved MQ Analysis       |
| 1.8.1 | Oct 26, 2018| >=2.1.0.1 | ibmcom/transformation-advisor-db:1.8.1 ibmcom/transformation-advisor-server:1.8.1 ibmcom/transformation-advisor-ui:1.8.1 | None | Data Collector Patch       |
| 1.8.0 | Oct 01, 2018| >=2.1.0.1 | ibmcom/transformation-advisor-db:1.8.0 ibmcom/transformation-advisor-server:1.8.0 ibmcom/transformation-advisor-ui:1.8.0 | None | MQ Analysis                | 
| 1.7.2 | Sep 04, 2018| >=2.1.0.1 | ibmcom/transformation-advisor-db:1.7.2 ibmcom/transformation-advisor-server:1.7.2 ibmcom/transformation-advisor-ui:1.7.2 | None | Complexity Fix             |
| 1.7.1 | Aug 24, 2018| >=2.1.0.1 | ibmcom/transformation-advisor-db:1.7.1 ibmcom/transformation-advisor-server:1.7.1 ibmcom/transformation-advisor-ui:1.7.1 | None | Patch for new Micro Climate|
| 1.7.0 | Aug 22, 2018| >=2.1.0.1 | ibmcom/transformation-advisor-db:1.7.0 ibmcom/transformation-advisor-server:1.7.0 ibmcom/transformation-advisor-ui:1.7.0 | None | Migrate JBoss and WebLogic |
| 1.6.0 | Jul 02, 2018| >=2.1.0.1 | ibmcom/transformation-advisor-db:1.6.0 ibmcom/transformation-advisor-server:1.6.0 ibmcom/transformation-advisor-ui:1.6.0 | None | Add authentication         |
| 1.5.1 | Jun 05, 2018| >=2.1.0.1 | ibmcom/transformation-advisor-db:1.5.1 ibmcom/transformation-advisor-server:1.5.1 ibmcom/transformation-advisor-ui:1.5.1 | None | Patch for new Micro Climate|
| 1.5.0 | May 21, 2018| >=2.1.0.1 | ibmcom/transformation-advisor-db:1.5.0 ibmcom/transformation-advisor-server:1.5.0 ibmcom/transformation-advisor-ui:1.5.0 | None | Automate migration         |
| 1.4.0 | Mar 13, 2018| >=2.1.0.1 | ibmcom/transformation-advisor-db:1.4.0 ibmcom/transformation-advisor-server:1.4.0 ibmcom/transformation-advisor-ui:1.4.0 | None | Add deployment artifacts   |
| 1.3.0 | Feb 07, 2018| >=2.1.0.1 | ibmcom/transformation-advisor-db:1.3.0 ibmcom/transformation-advisor-server:1.3.0 ibmcom/transformation-advisor-ui:1.3.0 | None | Configurable dev costs     |
| 1.2.0 | Jan 11, 2018| >=2.1.0.1 | ibmcom/transformation-advisor-db:1.2.0 ibmcom/transformation-advisor-server:1.2.0 ibmcom/transformation-advisor-ui:1.2.0 | None | Helper migration artifacts |
| 1.1.0 | Nov 28, 2017| >=2.1.0.1 | ibmcom/transformation-advisor-db:1.1.0 ibmcom/transformation-advisor-server:1.1.0 ibmcom/transformation-advisor-ui:1.1.0 | None | DC for multiple OSs        |
| 1.0.0 | Oct 24, 2017| >=2.1.0.1 | klaemo/couchdb:2.0.0 ibmcom/icp-transformation-advisor-dc:1.1.0 ibmcom/icp-transformation-advisor-ui:1.1.0               | None | Initial catalog entry      |
