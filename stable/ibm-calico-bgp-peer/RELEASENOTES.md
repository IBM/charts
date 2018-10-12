# What’s new in Calico BGP Peer Chart Version 1.1.0

1. Support for ICP 3.1.0
2. Runs the calico peer addition job in the kube-system namespace

## Older Releases

### v1.0.0

With Calico BGP Peer Chart on IBM Cloud Private 2.1.0.3, the following new
features are available:

* Configure a BGP Peer to your IBM Cloud Private Calico Cluster
* Support for calico/ctl v1.6.3 and v2.0.2

For IBM Cloud Private 2.1.0.3, use the calico-ctl version v2.0.2

# Prerequisites
1. IBM Cloud Private version >= 2.1.0.3.
2. Calico must be provisioned and running as the CNI Plugin 

## Fixes
  - None

# Version History

| Chart | Date        | ICP Required | Image(s) Supported | Details |
| ----- | ----------- | ------------ | ------------------ | ------- |
| 1.1.0 | Oct 10, 2018| >=3.1.0      | calico/ctl:v3.1.3 | Support for ICP 3.1.0 and calico/ctl:v3.1.3 |
| 1.0.0 | May 10, 2018| >=2.1.0.3    | ibm/calico-ctl:v1.6.3 and ibm/calico-ctl:v2.0.2 | Initial Chart for adding BGP Peer to your Calico Cluster |
