# What’s new in openebs V 0.7.0

With openebs Chart on IBM Cloud Private 2.1.0.3, the following new
features are available:

* This Helm chart deploys cloud native OpenEBS storage.
* Node Disk Manager that helps with discovering block devices attached to nodes
* **Alpha** support for cStor Storage Engines
* Updated CRDs for supporting cStor as well as pluggable storage control plane
* Jiva Storage Pool called `default` and StorageClass  called `openebs-jiva-default`
* cStor Storage Pool Claim called `cstor-sparse-pool` and StorageClass called `openebs-cstor-sparse`
* There has been a change in the way volume storage policies can be specified with the addition of new policies like:
  * Number of Data copies to be made
  * Specify the nodes on which the Data copies should be persisted
  * Specify the CPU or Memory Limits per PV
  * Choice of Storage Engine : cStor or Jiva

# Prerequisites

1. IBM Cloud Private version 2.1.0.3+
2. Kubernetes 1.9.7+
3. iSCSI Initiator installed on the Kubernetes nodes.
4. NDM helps in discovering the devices attached to Kubernetes nodes, which can be used to create storage pools. If you like to exclude some of the disks from getting discovered, update the filters on NDM to exclude paths before installing OpenEBS.
5. If [Container Image Security](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.0/manage_images/image_security.html) is enabled then Docker hub Container Registry must be added to the list of trusted registries by following the instructions described under the section [Customizing your policy (post installation)](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.0/manage_images/image_security.html).


# Version History

| Chart | Date        | ICP Required | Image(s) Supported | Details |
| ----- | ----------- | ------------ | ------------------ | ------- |
| 0.7.0 | Sep 08, 2018| >=2.1.0.3    | openebs/m-apiserver, openebs/openebs-k8s-provisioner, openebs/snapshot-controller, openebs/snapshot-provisioner, openebs/node-disk-manager-amd64, openebs/jiva, openebs/cstor-pool, openebs/cstor-pool-mgmt, openebs/cstor-istgt, openebs/cstor-volume-mgmt, openebs/m-exporter | Initial Chart for installing OpenEBS storage on ICP |
