# What’s new in GlusterFS Storage cluster Version 1.3.0

With GlusterFS Storage cluster chart, the following new
features are available:

* New GlusterFS image
* New storage-util image
* Removed minimum three GlusterFS storage nodes restriction

# Breaking Changes
* The GlusterFS docker image has been upgraded

# Fixes
* Bug Fixes

# Prerequisites
1. The default configuration is to use three storage nodes to configure GlusterFS storage cluster. However, you can use less than three storage nodes to configure GlusterFS Storage cluster. You need at least one storage node to successfully install GlusterFS.
2. In storage class configuration, if you specify `volumeType` as `replicate` with more than one replica count, or if you specify `volumeType` as `disperse` with more than one redundancy count, then you must use as many storage nodes as the specified replica or redundancy count.
3. The storage device that is used for GlusterFS must have a capacity of at least 25 GB.
4. The storage devices that you use for GlusterFS must be raw disks. They must not be formatted, partitioned, or used for file system storage needs.
5. The selected nodes must be labelled as storage nodes.
6. Ensure that the ports that are used by GlusterFS daemon (24007), GlusterFS management(24008) and Bricks port range (49152:49251) are added to the firewall.
7. Install the GlusterFS client and configure the dm_thin_pool kernel module on the nodes in your cluster that might use a GlusterFS volume.
8. Ensure that the GlusterFS client version is the same as GlusterFS server version that is installed.
9. Pre create a secret for the Heketi authentication

# Documentation

# Version History

| Chart | Date           | ICP Required |        Image(s) Supported       | Details       |
| ----- | -------------- | ------------ | ------------------------------- | ------------- |
| 1.3.0 | February 2019  | >=3.1.0      | ibmcom/gluster:v4.1.5           | New Images    |
|       |                |              | ibmcom/heketi:v8.0.0            | Bug Fixes     |
|       |                |              | ibmcom/icp-storage-util:3.1.2   |               |
|       |                |              |                                 |               |
| 1.2.0 | November 2018  | >=3.1.0      | ibmcom/gluster:v4.0.2           | New Image     |
|       |                |              | ibmcom/heketi:v8.0.0            | Bug Fixes     |
|       |                |              | ibmcom/icp-storage-util:3.1.0   |               |
|       |                |              |                                 |               |
| 1.1.0 | September 2018 | =3.1.0       | ibmcom/gluster:v4.0.2           | New Images    |
|       |                |              | ibmcom/heketi:v7.0.0            | New Features  |
|       |                |              | ibmcom/icp-storage-util:3.1.0   |               |
|       |                |              |                                 |               |
| 1.0.1 | July 2018      | >=2.1.0.3    | ibmcom/gluster:3.12.1           | Bug Fixes     |
|       |                |              | ibmcom/heketi:5                 |               |
|       |                |              | ibmcom/hyperkube:v1.10.0        |               |
|       |                |              |                                 |               |
| 1.0.0 | June 2018      | >=2.1.0.3    | ibmcom/gluster:3.12.1           | Initial Chart |
|       |                |              | ibmcom/heketi:5                 |               |
|       |                |              | ibmcom/hyperkube:v1.10.0        |               |
