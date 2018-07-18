# What’s new in  Rook Ceph cluster Version 0.1.1

With Rook Ceph cluster Chart on IBM Cloud Private 2.1.0.3, the following new
features are available:

* This Helm chart deploys a Rook Ceph cluster that uses block storage.
* This Helm chart also creates its storage pool and a StorageClass.
* Bug fix: Fixed tag for ibmcom/hyperkube image.
* Bug fix: Corrected post installation messages in NOTES.txt.

# Prerequisites
1. IBM Cloud Private version 2.1.0.3
2. The Rook Operator deployment must be pre-deployed on ICP cluster. This deployment must bring up one Rook Operator Pod in your cluster and a Rook Agent Pod on each of the nodes.
3. In storageNodes parameter, either disks or directories can be specified against a storage node. If disk devices are specified, they must not have any file system present.
4. The path, specified as dataDirHostPath cluster settings, must not have any pre-existing entries from previous cluster installation. Stale keys and other configurations existing from previous installation will fail the installation.

# Version History

| Chart | Date        | ICP Required | Image(s) Supported | Details |
| ----- | ----------- | ------------ | ------------------ | ------- |
| 0.1.0 | May 25, 2018| >=2.1.0.3    | ibmcom/hyperkube:v1.10.0-ce | Initial Chart for integrating Ceph block storage using ROOK operator on ICP Cluster |
| 0.1.1 | July 17, 2018| >=2.1.0.3    | ibmcom/hyperkube:v1.10.0 | Bug fixes |
