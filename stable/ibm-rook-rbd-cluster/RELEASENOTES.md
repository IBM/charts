# What’s new in  Rook Ceph cluster Version v0.8.3

With Rook Ceph cluster Chart on IBM Cloud Private, the following new
features are available:

* Community Beta Release
* Added pod placement configuration for all services
* Added pod tolerations for all services
* Added configuration for pool to use replicated or erasure-coded mechanism for resiliency

# Fixes
* Added pre-validation settings and used ibmcom/icp-storage-util image instead of hyperkube.


## Breaking Changes
* This is Beta release. No upgrade from 0.1.1 and 0.1.0 is supported.

# Prerequisites
1. IBM Cloud Private version >= 3.1.0
2. The Rook Operator deployment must be pre-deployed on ICP cluster. This deployment must bring
   up one Rook Operator Pod in your cluster and a Rook Agent Pod on each of the nodes.
3. In storageNodes parameter, either disks or directories can be specified against a storage node.
   If disk devices are specified, they must not have any file system present.
4. The path, specified as dataDirHostPath cluster settings, must not have any pre-existing entries
   from previous cluster installation. Stale keys and other configurations existing from previous
    installation will fail the installation.

# Documentation
Check the  README file provided with the chart for detailed installation instructions.

# Version History

| Chart | Date        | ICP Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ----------- | ------------ | ------------------ | ---------------- |---------|
| 0.8.3 | Nov 12, 2018|  >=3.1.0 | ibmcom/icp-storage-util:3.1.0 | None  | Community Beta Release |
| 0.1.1 | July 17, 2018| >=2.1.0.3    | ibmcom/hyperkube:v1.10.0 | None | Bug fixes |
| 0.1.0 | May 25, 2018| >=2.1.0.3    | ibmcom/hyperkube:v1.10.0-ce | None |Initial Chart for integrating Ceph block storage using ROOK operator on ICP Cluster |
