
# What’s new in Chart Version 1.5.0

With Transformation Advisor on IBM Cloud Private 2.1.0.1, the following new features are available:

### Automated Migration
 - The migration bundle can now be used to deploy your application to IBM Cloud Private at the click of a button!  
 - The bundle is pushed into Git and then MicroClimate running on IBM Cloud Private creates a pipeline that builds your image and deploys it into IBM Cloud Private
### Enhanced Recommendations
 - The recommendations now match clearly to your designated preferences  
 - Usability has been enhanced with a new layout, quick filtering options and inline access to your preferences  
### IBM Cloud Private Enhancements
 - Transformation Advisor now integrates with IBM Cloud Private Ingress capabilities  
 - Transformation Advisor now appears in the IBM Cloud Private hamburger menu (for ICP >=2.1.0.3)   
### Platform Enhancements
Transformation Advisor server can now run on POWER
### Data Collector Enhancements
 - Incorporates WAMT binary scanner version 18.0.0.1  
 - Enhanced robustness and fail early enhancements means issues are detected sooner (and there are fewer of them)  
 
# Prerequisites

* IBM Cloud Private version 2.1.0.1

# Version History

| Chart | Date | ICP Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- | 
| 1.5.0 | May 21, 2018| >=2.1.0.1 | ibmcom/transformation-advisor-db:1.5.0 ibmcom/transformation-advisor-server:1.5.0 ibmcom/transformation-advisor-ui:1.5.0 | None | Chart updates |
| 1.4.0 | Mar 13, 2018| >=2.1.0.1 | ibmcom/transformation-advisor-db:1.4.0 ibmcom/transformation-advisor-server:1.4.0 ibmcom/transformation-advisor-ui:1.4.0 | None | Chart updates |
| 1.3.0 | Feb 07, 2018| >=2.1.0.1 | ibmcom/transformation-advisor-db:1.3.0 ibmcom/transformation-advisor-server:1.3.0 ibmcom/transformation-advisor-ui:1.3.0 | None | Chart updates |
| 1.2.0 | Jan 11, 2018| >=2.1.0.1 | ibmcom/transformation-advisor-db:1.2.0 ibmcom/transformation-advisor-server:1.2.0 ibmcom/transformation-advisor-ui:1.2.0 | None | Chart updates |
| 1.1.0 | Nov 28, 2017| >=2.1.0.1 | ibmcom/transformation-advisor-db:1.1.0 ibmcom/transformation-advisor-server:1.1.0 ibmcom/transformation-advisor-ui:1.1.0 | None | Chart updates |
| 1.0.0 | Oct 24, 2017| >=2.1.0.1 | klaemo/couchdb:2.0.0 ibmcom/icp-transformation-advisor-dc:1.1.0 ibmcom/icp-transformation-advisor-ui:1.1.0  | None | Initial Catalog Entry |
