# Hazelcast
* [Hazelcast](https://www.hazelcast.org) is an open source in-memory data grid

## Introduction
This chart installs Hazelcast, and in-memory data grid cache.  
This chart installs the [hazelcast/hazelcast-kubernetes](https://hub.docker.com/r/hazelcast/hazelcast-kubernetes/) Docker image.  

## Chart Details
* Deployment: hazelcast-kubernetes image includes a discovery plugin, allowing for autodiscovery of replicas within a namespace
* ConfigMap: contains the hazelcast.xml server configuration

## Prerequisites
* Kubernetes Level: Kubernetes 1.8

## Resources Required
* CPU (default): 500m
* MEM (default) 768Mi

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install --name my-release stable/ibm-hazelcast-dev
```

The command deploys ibm-hazelcast-dev on the Kubernetes cluster in the default configuration. The [configuration](#Configuration) section lists the parameters that can be configured during installation.



> **Tip**: List all releases using `helm list`


### Verifying the Chart
See NOTES.txt associated with this chart for verification instructions

### Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release --purge
```

The command removes all the Kubernetes components associated with the chart and deletes the release.  


## Configuration

The following tables lists the configurable parameters of the ibm-hazelcast-dev chart and their default values.

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
| `replicaCount`             | Number of deployment replicas                   | `1`                                                        |
| `image.repository`         | `Hazelcast` image repository.                   | `hazelcast/hazelcast-kubernetes`                           |
| `image.pullPolicy`         | Image pull policy                               | `Always` if `imageTag` is `latest`, else `IfNotPresent`    |
| `image.tag`                | `Hazelcast` image tag                           | `3.10`                                                     |
| `service.type`             | k8s service type exposing ports, e.g. `NodePort`| `ClusterIP`                                                |
| `service.externalPort`     | External TCP Port for this service              | `5701`                                                     |
| `resources.requests.memory`| Memory resource requests                        | `576Mi`                                                    |
| `resources.requests.cpu`   | CPU resource requests                           | `500m`                                                     |
| `resources.limits.memory`  | Memory resource limits                          | `768Mi`                                                    |
| `resources.limits.cpu`     | CPU resource limits                             | `500m`                                                     |
| `rbac.install`             | Install RBAC. Set to `true` if using a namespace with RBAC. | `true`                                         |
| `heap.minHeapSize`         | JVM Minimum Heap Size                           | `128m`                                                     |
| `heap.maxHeapSize`         | JVM Maximum Heap Size                           | `256m`                                                     |
| `javaOpts`                 | JVM Options                                     |                                                            |

A subset of the above parameters map to the environmental variables defined for the hazelcast-kubernetes Docker image. For more information please refer to the [Hazelcast](https://hub.docker.com/r/hazelcast/hazelcast-kubernetes/) image documentation.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release --set javaOpts="-Dhazelcast.diagnostics.enabled=true" stable/ibm-hazelcast-dev
```

> **Tip**: You can use the default values.yaml


## Security

Port 5701 is exposed unencrypted within the container network, and by default as a ClusterIP service.  

To encrypt traffic within the container network, consider [IPsec mesh encryption](https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0.2/installing/ipsec_mesh.html).


## Limitations
* Requires x86_64 arch


## Documentation
See the [Liberty documentation](https://www.ibm.com/support/knowledgecenter/en/SSAW57_liberty/as_ditamaps/was900_welcome_liberty_ndmp.html) for configuring Hazelcast as a session cache provider.

See the [Hazelcast documentation](http://docs.hazelcast.org/docs/latest-dev/manual/html-single/index.html) for configuration options for deploying the Hazelcast server.

## Privacy
See the [IBM Privacy Policy](https://www.ibm.com/privacy/)

See the [Hazelcast Privacy Policy](https://hazelcast.org/privacy/)