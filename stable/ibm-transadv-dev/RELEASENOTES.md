
# What’s new in Chart Version 1.6.0
With Transformation Advisor on IBM Cloud Private 2.1.0.1, the following new features are available:
### Platform Enhancements
 - Integrates with IBM Cloud Private authentication
 - Improved integration with IBM Cloud Private logging
### Automated Migration
 - Integration with MicroClimate v1.3.0
### Data Collector Enhancements
 - Improved migration artifacts for applications
 - Incorporates WAMT binary scanner version 18.0.0.2

# Fixes
* Fixed Nullpointer exception thrown by data collector for certain WAS Network Deployment configurations
* Fixed Sorting of the complexity column 
* Fixed bread crumb in migration steps page

# Prerequisites
* IBM Cloud Private version 2.1.0.1

# Version History
| Chart | Date | ICP Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- | 
| 1.6.0 | Jul 02, 2018| >=2.1.0.1 | ibmcom/transformation-advisor-db:1.6.0 ibmcom/transformation-advisor-server:1.6.0 ibmcom/transformation-advisor-ui:1.6.0 | None | Chart updates |
| 1.5.1 | Jun 05, 2018| >=2.1.0.1 | ibmcom/transformation-advisor-db:1.5.1 ibmcom/transformation-advisor-server:1.5.1 ibmcom/transformation-advisor-ui:1.5.1 | None | Chart updates |
| 1.5.0 | May 21, 2018| >=2.1.0.1 | ibmcom/transformation-advisor-db:1.5.0 ibmcom/transformation-advisor-server:1.5.0 ibmcom/transformation-advisor-ui:1.5.0 | None | Chart updates |
| 1.4.0 | Mar 13, 2018| >=2.1.0.1 | ibmcom/transformation-advisor-db:1.4.0 ibmcom/transformation-advisor-server:1.4.0 ibmcom/transformation-advisor-ui:1.4.0 | None | Chart updates |
| 1.3.0 | Feb 07, 2018| >=2.1.0.1 | ibmcom/transformation-advisor-db:1.3.0 ibmcom/transformation-advisor-server:1.3.0 ibmcom/transformation-advisor-ui:1.3.0 | None | Chart updates |
| 1.2.0 | Jan 11, 2018| >=2.1.0.1 | ibmcom/transformation-advisor-db:1.2.0 ibmcom/transformation-advisor-server:1.2.0 ibmcom/transformation-advisor-ui:1.2.0 | None | Chart updates |
| 1.1.0 | Nov 28, 2017| >=2.1.0.1 | ibmcom/transformation-advisor-db:1.1.0 ibmcom/transformation-advisor-server:1.1.0 ibmcom/transformation-advisor-ui:1.1.0 | None | Chart updates |
| 1.0.0 | Oct 24, 2017| >=2.1.0.1 | klaemo/couchdb:2.0.0 ibmcom/icp-transformation-advisor-dc:1.1.0 ibmcom/icp-transformation-advisor-ui:1.1.0  | None | Initial Catalog Entry |
