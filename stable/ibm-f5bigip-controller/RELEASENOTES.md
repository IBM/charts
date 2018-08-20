# What’s new in F5 BIGIP Controller Chart Version 1.1.0

1. Support for k8s-bigip-ctlr:1.6.0

## Older Releases

### v1.0.0

Integrates F5 BIGIP Device to the ICP Cluster

# Prerequisites
1. IBM Cloud Private version >= 2.1.0.3.
2. The F5 BIGIP Device must be setup as per need
3. The F5 BIGIP Device must be added as a BGP Peer to the Calico Cluster
4. Create a partition on your BIG-IP device for the BIG-IP Controller to manage. The Controller cannot manage objects in the /Common partition.

## Fixes
  - None

# Version History

| Chart | Date        | ICP Required | Image(s) Supported | Details |
| ----- | ----------- | ------------ | ------------------ | ------- |
| 1.1.0 | August 20, 2018| >=2.1.0.3    | f5networks/k8s-bigip-ctlr:1.6.0 | Updated chart with support for k8s-bigip-ctlr image version 1.6.0 |
| 1.0.0 | May 10, 2018| >=2.1.0.3    | f5networks/k8s-bigip-ctlr:1.4.2 | Initial Chart for integrating F5 BIGIP Device to the ICP Cluster |
