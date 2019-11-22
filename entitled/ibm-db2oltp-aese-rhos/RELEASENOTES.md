# What’s new in Db2 Advanced Enterprise Edition Chart Version 3.1.0 for RedHat OpenShift

With Db2 Advanced Enterprise Edition the following features are available:

* Latest Db2 code base (11.1.3.3 iFix002) 
* Out of the box configuration for [Db2 HADR] (https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.1.0/com.ibm.db2.luw.admin.ha.doc/doc/c0011267.html)
  - Currently configurable as HA only (within the same Data Center)

# Prerequisites
1. Kubernetes version >= 1.8.3.
2. Three persistent volumes are required if dynamic provision is not available. See [Readme](README.md) for details.
3. Security Context Constraint applied to the namespace/project. See README.md for details.

# Fixes

N/A

# Version History

| Chart | Date        | Kubernetes Required | Image(s) Supported               | Details                                                             |
| ----- | ----------- | ------------------- | -------------------------------- | ------------------------------------------------------------------- |
| 3.1.0 | Sep 28, 2018| >= 1.8.3            | db2server_aese_rhel: 11.1.3.3b   | First release on RedHat OpenShift                                   | 
