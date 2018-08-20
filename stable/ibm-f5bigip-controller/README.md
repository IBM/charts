# F5 BIGIP Controller

[F5 BIGIP Controller](http://clouddocs.f5.com/containers/v2/kubernetes/) configures BIG-IP objects for applications in a Kubernetes cluster, serving North-South traffic.	

## Introduction

The F5 BIG-IP Controller for Kubernetes runs in a Kubernetes Pod. It uses F5 Resources to determine:
- what objects to configure on your BIG-IP system, and
- to which Kubernetes Service those objects belong

The k8s-bigip-ctlr watches the Kubernetes API for the creation, modification, or deletion of Kubernetes objects. For some Kubernetes objects, the Controller responds by creating, modifying, or deleting objects in the BIG-IP system.

## Chart Details

This chart will do the following:

* The chart creates a Deployment for one Pod containing the k8s-bigip-ctlr and its supporting RBAC resources.
* Can be created in any namespace
* More than one release can be created from this Chart to allow the F5 BIGIP admin to create multiple controllers to connect to multiple F5 BIGIP Devices
* One release can be created to watch over one or more namespaces.

## Prerequisites

- Kubernetes 1.6+ with Beta APIs enabled
- Already have a `BIG-IP device` licensed and provisioned for your requirements
- Already have `calico` provisioned and running in your Kubernetes cluster
- Already have the `BIG-IP device` added as a Calico BGP Global Peer to the Calico Node Mesh

## Resources Required

The k8s-bigip-ctlr container has the following default resource requests and limits:

| Container                  | Memory Request        | Memory Limit          | CPU Request           | CPU Limit             |
| -----------------------    | ------------------    | ------------------    | ------------------    | ------------------    |
| k8s-bigip-ctlr             | 128Mi                 | 256Mi                 | 100m                  | 200m                  |

## Installing the Chart

You should create a new partition on your BIG-IP system. The BIG-IP Controller can not manage objects in the `/Common` partition.

> **Note**: Make sure that one partition is managed from one F5 BIGIP k8s Controller. Managing the same partition from mutiple F5 BIGIP k8s Controllers may lead to unexpected behavior

To install the chart with the release name `my-release`:

```bash
$ helm install --name my-release f5-bigip-controller --namespace kube-system --set bigIp.url=1.2.3.4 --set bigIp.partitionName=myPartition --set bigIp.username=admin --set bigIp.password=password
```

The command deploys F5 BIG-IP Controller on the Kubernetes cluster with the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Note**: When integrating the F5 BIG-IP Controller with IBM Cloud Private, if you wish to host the k8s-bigip-ctlr on the master node, provide the following values for `nodeSelector` and `tolerations`.

> nodeSelector: 
```
{"role": "master"}
```
> tolerations: 
```
[{"key":"dedicated","operator":"Exists","effect":"NoSchedule"},{"key":"CriticalAddonsOnly","operator":"Exists"}]
```


> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the F5 BIG-IP Controller chart and their default values.

|          Parameter           |                Description                 |                   Default                   |
| ---------------------------- | ------------------------------------------ | ------------------------------------------- |
| `bigIp.url`                  | BIG-IP admin IP address			        | `nil`						                  |
| `bigIp.partitionName`        | BIG-IP partition in which to configure objects| `nil`                          		  |
| `bigIp.username`             | BIG-IP iControl REST username  			| `nil`                                       |
| `bigIp.password`             | BIG-IP iControl REST password   			| `nil`                                       |
| `bigIp.poolMemberType`       | The type of BIG-IP pool members you want to create - cluster or nodeport | `cluster`	|
| `bigIp.defaultIngressIp`     | The controller configures a virtual server at this IP address for all Ingresses with the annotation: `virtual-server.f5.com/ip: 'controller-default'`| `nil`|
| `bigIp.namespaces`           | List of Kubernetes namespace(s) to watch. Example: ["ns1","ns2"] 		| []				|
| `bigIp.nodeLabelSelector`    | Tells the k8s-bigip-ctlr to watch only nodes with this label | `nil`			|
| `bigIp.extraArgs`            | Rest of the k8s-bigip-ctlr options. Provide a map in the form of {"key":"val", ...}	| {}	|
| `image.repository`           | `k8s-bigip-ctlr` image repository  		    | `f5networks/k8s-bigip-ctlr`                         |
| `image.tag`                  | `k8s-bigip-ctlr` image tag  		    | `1.6.0`                                    |
| `image.pullPolicy`           | Image pull policy                          | `IfNotPresent`                              |
| `nodeSelector`       	       | Constrain the controller to only be able to run on particular node| `{}`                              |
| `tolerations`                | Schedule controller onto a node with matching taints| `[]`                                      |
| `affinity	`		           | Allow controller to be attracted to a set of nodes| `{}`                          |

For more information please refer to the [F5 BIG-IP Controller for Kubernetes](http://clouddocs.f5.com/products/connectors/k8s-bigip-ctlr/v1.4/)  documentation.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml f5-bigip-controller
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## Limitations

* This Chart works only with IBM Cloud Private
* This Chart can run only on amd64 architecture type.
