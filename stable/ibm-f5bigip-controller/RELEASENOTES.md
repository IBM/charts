# What’s new in F5 BIGIP Controller Chart Version 1.0.0

With F5 BIGIP Controller Chart on IBM Cloud Private 2.1.0.3, the following new
features are available:

* Integrates F5 BIGIP Device to the ICP Cluster

# Prerequisites
1. IBM Cloud Private version >= 2.1.0.3.
2. The F5 BIGIP Device must be setup as per need
3. The F5 BIGIP Device must be added as a BGP Peer to the Calico Cluster
4. Create a partition on your BIG-IP device for the BIG-IP Controller to manage. The Controller cannot manage objects in the /Common partition.

# Version History

| Chart | Date        | ICP Required | Image(s) Supported | Details |
| ----- | ----------- | ------------ | ------------------ | ------- |
| 1.0.0 | May 10, 2018| >=2.1.0.3    | f5networks/k8s-bigip-ctlr:1.4.2 | Initial Chart for integrating F5 BIGIP Device to the ICP Cluster |

