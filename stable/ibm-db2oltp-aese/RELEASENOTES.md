# What’s new in Db2 Advanced Enterprise Edition Chart Version 3.2.0

ROLLING UPGRADES FROM PREVIOUS CHART RELEASES ARE NOT SUPPORTED

With Db2 Advanced Enterprise Edition the following features are available:

* Update to the latest version of Db2 - 11.1.4.4 - [Mod Pack and Fix Pack Updates] (https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.1.0/com.ibm.db2.luw.wn.doc/doc/c0061179.html)
* Out of the box configuration for [Db2 HADR] (https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.1.0/com.ibm.db2.luw.admin.ha.doc/doc/c0011267.html)
  - Currently configurable as HA only (within the same Data Center)

# Fixes
* Latest Db2 code base (11.1.4.4)

# Prerequisites
1. Kubernetes version >= 1.8.3.
2. Three persistent volumes are required if dynamic provision is not available. See README.md for details.
3. IBM Cloud Private version >= 2.1.0.1
4. Pod Security Policy applied to new or existing namespace. See README.md for details.

# Version History

| Chart | Date        | Kubernetes Required | Image(s) Supported          | Details                                                             |
| ----- | ----------- | ------------------- | --------------------------- | ------------------------------------------------------------------- |
| 3.2.0 | Nov 27, 2018| >= 1.8.3            | db2server_aese: 11.1.4.4    | Update to 11.1.4.4                                                  |
| 3.1.0 | Sep 28, 2018| >= 1.8.3            | db2server_aese: 11.1.3.3b   | Update to 11.1.3.3 iFix002                                          |
| 3.0.0 | Jun 22, 2018| >= 1.8.3            | db2server_aese: 11.1.3.3a   | Update to 11.1.3.3 iFix001                                          | 
| 2.0.1 | Apr 18, 2018| >= 1.8.3            | db2server_aese: 11.1.3.3x   | Fix for db2support issue - http://www-01.ibm.com/support/docview.wss?uid=swg22015393 |
| 2.0.0 | Mar 14, 2018| >= 1.8.3            | db2server_aese: 11.1.3.3    | Support for Db2 HADR feature (single data center only) |
| 1.1.0 | Dec 15, 2017| >= 1.7.3            | db2server_aese: 11.1.2.2b   | Multi-platform support and base OS security fixes |
| 1.0.0 | Oct 24, 2017| >= 1.7.3            | db2server_aese: 11.1.2.2a   | iFix 001 for Db2 11.1.2.2 |
