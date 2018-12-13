# What’s new in Chart Version 1.9.1
### Data Collector Enhancements
 - Configurable heap sizes for analysis of large systems
 - Support for -java-home parameter
 - Support for execution as user other than wsadmin owner
 - Improved handling of SOAP Timeout issues
 - Improved robustness of handling outside file locations
 - Improved handling of unexpected files during upload

# Fixes
### Analysis Enhancements
 - Applications without technologies are now handled correctly
 - Fixed incorrectly detected technologies
 - Fixed bugs around complexity tags

# Breaking Changes

# Documentation

# Prerequisites
* IBM Cloud Private version 2.1.0.1+

# Version History
| Chart | Date | ICP Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- |
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
