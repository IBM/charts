# Configure a BGP Peer Resource to the Kubernetes Calico Cluster

## Introduction

A BGP peer resource (`BGPPeer`) represents a remote BGP peer with which the node(s) in a Calico 
cluster will peer.  Configuring BGP peers allows you to peer a 
Calico network with your datacenter fabric (e.g. ToR). For more 
information on cluster layouts, see Calico's documentation on 
[L3 Topologies](https://docs.projectcalico.org/v3.1/reference/private-cloud/l3-interconnect-fabric).

A peer can be added as a Global Peer where the added BGP Agent peers with every calico node in the cluster.
Or BGP peerings can be configured on a per-node basis, i.e., configured as node-specific peers. 

## Chart Details

This chart will do the following:

* Creates a ConfigMap that contains the Calico BGP Peer configuration
* Runs a Job to add a BGP Peer to the K8S Calico Cluster
* On deletion, the chart first runs a Job that removes the added Peer. If the removal of Peer is successful, the chart deletes the ConfigMap, the Job that added the BGP Peer and the Job that removed the BGP Peer

## Prerequisites

- Already have (`calico`) provisioned and running in your ICP cluster

## Installing the Chart

You should provide the IP address of the BGP Agent to be added as a peer and the calico etcd endpoint url (Example: https://master-node-ip:4001).
You should also provide the name of the k8s secret object that contains the key, client certificate and Certificate Authority to connect to the provided calico etcd endpoint.

The k8s secret object must be created in the `kube-system` namespace with three keys: etcd-ca, etcd-cert and etcd-key as shown in the following structure: 
```
apiVersion: v1
kind: Secret
metadata:
  name: etcd-secret
  namespace: kube-system
type: Opaque
data:
  etcd-ca: LS0......
    .......
	.......
	..tLQ==
  etcd-cert: LS0......
    .......
	.......
	..tLQ==
  etcd-key: LS0......
    .......
	.......
	..tsde2
```
> **Note**: The k8s secret object containing the etcd credentials must be created in the `kube-system` namespace.

You can provide the AS number (`default: 64512`) and Node IP address of the node in the ICP cluster when BGP Peer needs to be configured on a per-node basis. When the Node IP address is specified, the scope is node level, otherwise the scope is global.

To install the chart with the release name `my-release`:

```bash
$ helm install --name my-release add-bgp-peer --set bgpPeer=1.2.3.4 --set etcd.endpoint=https://2.3.4.5:4001 --set etcd.secret=etcd-secret
```

The command adds the BGP Agent 1.2.3.4 as a global peer to the Calico Cluster. The Configuration section lists the parameters that can be configured during installation.


> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release --purge
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the Calico BGP Peer chart and their default values.

|          Parameter           |                Description                 |                   Default                   |
| ---------------------------- | ------------------------------------------ | ------------------------------------------- |
| `peerIp`                     | IP address of the BGP Agent to be added as peer (Required)| `nil`			                  |
| `asNumber`                   | The global default node AS number is the AS number used by the BGP agent (Required)| `65412`        |
| `node`                       | The hostname of the node to which this peer applies. If specified, the scope is node level, otherwise the scope is global (Optional) | `nil`       |
| `etcd.endpoint`	       | Calico etcd endpoint details. Example: https://calico-etcd-ip:calico-etcd-port (Required) | `nil`			  |
| `etcd.secret`		       | Name of the k8s secret object containing the key, client certificate and Certificate Authority to connect to the calico etcd endpoint (Required) | `nil` |
| `image.repository`           | `calicoctl` image repository (Required)    | `calico/ctl`                         |
| `image.tag`                  | `calicoctl` image tag (Required)           | `v3.1.3`                                    |
| `image.pullPolicy`           | Image pull policy (Required)               | `IfNotPresent`                              |

For more information refer to the [Configuring BGP Peers](https://docs.projectcalico.org/v3.1/usage/configuration/bgp) documentation.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml add-bgp-peer
```

> **Tip**: You can use the default values.yaml

## Resources Required

The Chart deploys a ConfigMap and a Job to add the BGP Peer to the Calico Cluster. As the Job executes and completes running, the resources required is only transient in nature.

## Limitations

* This Chart works only with IBM Cloud Private
* This Chart can run on any of the three architecture types
* This Chart supports calico/ctl versions v3.1.3
* Cluster Admin Access is needed to run this Chart as the objects are created in the restricted kube-system namespace
