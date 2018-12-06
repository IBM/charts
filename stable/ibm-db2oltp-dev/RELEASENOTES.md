# What’s new in Db2 Developer-C Chart Version 3.2.0

ROLLING UPGRADES FROM PREVIOUS CHART RELEASES ARE NOT SUPPORTED

With Db2 Developer-C Edition on Chart Version 3.2.0, the following new
features are available:

* Update to the latest version of Db2 - 11.1.4.4- [Mod Pack and Fix Pack Updates](https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.1.0/com.ibm.db2.luw.wn.doc/doc/c0061179.html)
* Out of the box configuration for [Db2 HADR](https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.1.0/com.ibm.db2.luw.admin.ha.doc/doc/c0011267.html)
  - Currently configurable as HA only (within the same Data Center)
* Custom scripts for creating a PodSecurityPolicy and Security Context Constraint on Red Hat OpenShift. 

## Breaking Changes

* None

## Documentation

Please refer to [README.md](README.md)

# Fixes
* Latest Db2 code base (11.1.4.4)

# Prerequisites
1. Kubernetes version >= 1.8.3.
2. Three persistent volumes are required if dynamic provision is not available. 
3. IBM Cloud Private version >= 2.1.0.1

# Version History

| Chart | Date        | Kubernetes Required | Image(s) Supported         | Details                                                             |
| ----- | ----------- | ------------------- | -------------------------- | ------------------------------------------------------------------- | 
| 3.2.0 | Dec  6, 2018| >= 1.8.3            | db2_developer_c:11.1.4.4   | Update to 11.1.4.4                                                  |
| 3.1.0 | Sep 28, 2018| >= 1.8.3            | db2_developer_c:11.1.3.3b  | Update to 11.1.3.3 iFix002                                          |
| 3.0.0 | Jun 22, 2018| >= 1.8.3            | db2_developer_c:11.1.3.3a  | Update to 11.1.3.3 iFix001                                          |
| 2.0.1 | Apr 18, 2018| >= 1.8.3            | db2_developer_c:11.1.3.3x  | Fix for db2support issue - http://www-01.ibm.com/support/docview.wss?uid=swg22015393 |
| 2.0.0 | Mar 14, 2018| >= 1.8.3            | db2_developer_c:11.1.3.3   | Support for Db2 HADR feature (single data center only) |
| 1.1.3 | Feb 23, 2018| >= 1.8.3            | db2_developer_c:11.1.2.2b  | Migration to Docker Store hosting |
| 1.1.2 | Feb 23, 2018| >= 1.8.3            | db2server_dec: 11.1.2.2b   | Architecture preferences on install and values metadata. Deprecated version |
| 1.1.1 | Jan 25, 2018| >= 1.8.3            | db2server_dec: 11.1.2.2b   | iFix 002 for Db2 11.1.2.2 |
| 1.1.0 | Nov 30, 2017| >= 1.7.3            | db2server_dec: 11.1.2.2a   | Multi-platform support and base OS security fixes |
| 1.0.0 | Oct 24, 2017| >= 1.7.3            | db2server_dec: 11.1.2.2a   | iFix 001 for Db2 11.1.2.2 |
| 0.1.1 | Oct 24, 2017| >= 1.7.3            | db2server_dec: 11.1.2.2    | Chart fixes |
| 0.1.0 | Oct 24, 2017| >= 1.7.3            | db2server_dec: 11.1.2.2    | Db2 11.1.2.2 |

