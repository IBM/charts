# What’s new in GlusterFS Storage cluster Version 1.1.0

With GlusterFS Storage cluster chart, the following new
features are available:

* Deploys a GlusterFS Storage cluster that uses block storage.
* Creates a Heketi deployment to manage GlusterFS Storage cluster.
* Creates its storage class.
* Heketi DB is backed up as a kubernetes secret.

# Fixes
* GlusterFS and Heketi Image upgrades
* Volume expansion capability
* Prometheus Monitoring Support
* Added pod priority
* GlusterFS deployment on dedicated nodes

# Prerequisites
1. You must use at least three nodes to configure GlusterFS Storage cluster.
2. The storage device that is used for GlusterFS must have a capacity of at least 25 GB.
3. The storage devices that you use for GlusterFS must be raw disks. They must not be formatted, partitioned, or used for file system storage needs.
4. The selected nodes must be labelled as storage nodes.
5. Ensure that the ports that are used by GlusterFS daemon (24007), GlusterFS management(24008) and Bricks port range  (49152:49251) are added to the firewall.
6. Install the GlusterFS client and configure the dm_thin_pool kernel module on the nodes in your cluster that might use a GlusterFS volume.
7. Ensure that the GlusterFS client version is the same as GlusterFS server version that is installed.
8. Pre create a secret for the Heketi authentication

# Version History

| Chart | Date           | ICP Required |        Image(s) Supported       | Details       |
| ----- | -------------- | ------------ | ------------------------------- | ------------- |
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
