# Skydive

## Introduction
This is Helm chart for Skydive. Skydive is an open source real-time network topology and protocols analyzer.
It aims to provide a comprehensive way of understanding what is happening in the network infrastructure.

Skydive agents collect topology informations and flows and forward them to a central agent for further analysis. All the informations are stored in an Elasticsearch database.

Skydive is SDN-agnostic but provides SDN drivers in order to enhance the topology and flows informations.

![](https://github.com/skydive-project/skydive.network/raw/images/overview.gif)

## Prerequisites
* IBM Cloud Private 2.1.0.1 or higher
* Kubernetes cluster 1.7 or higher

- Persistent volume is needed only if you want to "look back in time" with skydive (that is, if you are interested in the monitoring history); if you don't , then it is not required (an elastic search container will not be created). You can create a persistent volume via the IBM Cloud Private interface or through a yaml file. For example:

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: <persistent volume name>
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: <PATH>
```

## Installing the Chart
To install the chart with the release name `my-release`:

```bash
$ helm install --name my-release stable/skydive
```

The command deploys skydive on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

## Verifying the Chart
See NOTES.txt associated with this chart for verification instructions

## Uninstalling the Chart
To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Security implications
This chart deploys privileged kubernetes daemon-set. The implications are automatically creation of privileged container per kubernetes node capable of monitoring network and system behavior and used to capture Linux OS level information. The daemon-set also uses hostpath feature interacting with Linux OS, capturing info on network components.

## Configuration
The following tables lists the configurable parameters of skydive chart and their default values.

| Parameter                            | Description                                     | Default                                                    |
| ----------------------------------   | ---------------------------------------------   | ---------------------------------------------------------- |
| `global.image.secretName`            | Image secret for private repository             | Empty                                                      |
| `image.repository`                   | Skydive image repository                        | `ibmcom/skydive`                                           |
| `image.tag`                          | Image tag                                       | `0.18`                                                     |
| `image.imagePullPolicy`              | Image pull policy                               | `IfNotPresent`                                             |
| `resources`                          | CPU/Memory resource requests/limits             | Memory: `8192Mi`, CPU: `2000m`                             |
| `service.name`                       | service name                                    | `skydive`                                                  |
| `service.type`                       | k8s service type (e.g. NodePort, LoadBalancer)  | `NodePort`                                                 |
| `service.port`                       | TCP port                                        | `8082`                                                     |
| `analyzer.topology.fabric`           | Fabric connecting k8s nodes                     | `TOR1->*[Type=host]/eth0`                                  |
| `env`                                | Extended environment variables                  | Empty                                                      |
| `storage.elasticsearch.host`         | ElasticSearch end-point                         | `127.0.0.1:9200`                                           |
| `storage.flows.indicesToKeep`        | Number of flow indices to keep in storage       | `10`                                                       |
| `storage.flows.indexEntriesLimit`    | Number of flow records to keep per index        | `10000`                                                    |
| `storage.topology.indicesToKeep`     | Number of topology indices to keep in storage   | `10`                                                       |
| `storage.topology.indexEntriesLimit` | Number of topology records to keep per index    | `10000`                                                    |
| `persistence.enabled`                | Use a PVC to persist data                       | `false`                                                    |
| `persistence.useDynamicProvisioning` | Specify a storageclass or leave empty           | `false`                                                    |
| `dataVolume.name`                    | Name of the PVC to be created                   | `datavolume`                                               |
| `dataVolume.existingClaimName`       | Provide an existing PersistentVolumeClaim       | `nil`                                                      |
| `dataVolume.storageClassName`        | Storage class of backing PVC                    | `nil`                                                      |
| `dataVolume.size`                    | Size of data volume                             | `10Gi`                                                     |

## Chart details
Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

## Topology fabric
The chart allows definition of static interfaces and links to be added to skydive topology view by setting the `analyzer.topology.fabric` parameter. This is useful to define external fabric resources like : TOR, Router, etc.
Details on this parameter field are available under the analyzer.topology.Fabric section in the following link: 
[https://github.com/skydive-project/skydive/blob/master/etc/skydive.yml.default](https://github.com/skydive-project/skydive/blob/master/etc/skydive.yml.default)

## Env
The chart allows definition of extended environment variables to be used by Skydive components. The list of configuration parameters is available on [https://github.com/skydive-project/skydive/blob/master/etc/skydive.yml.default](https://github.com/skydive-project/skydive/blob/master/etc/skydive.yml.default). Use upper-case/underline semantics of a configuration parameter prefixed by `SKYDIVE_` to use as an environment variable. For example, to enable debug add to the deployment .yml file:  
```
env:
  # Enable debug
  - name: SKYDIVE_LOGGING_LEVEL
    value: "DEBUG"
```
 
## Resources Required
The chart deploys pods and daemon-set consuming minimum resources as specified in the `resources` configuration parameter (default: Memory: `512Mi`, CPU: `100m`)

## Limitations

Refer to section [Security implications](#security-implications)

## Persistence
Skydive analyzer uses elasticsearch to store data at the `/usr/share/elasticsearch/data` path of the Analyzer container.

The chart mounts a [Persistent Volume](http://kubernetes.io/docs/user-guide/persistent-volumes/) at this location. User need to create a PV before chart deployed, or enable dynamic volume provisioning in chart configuration.

## Documentation
Skydive documentation can be found here:

* [http://skydive-project.github.io/skydive](http://skydive-project.github.io/skydive)

## Contributing
Your contributions are more than welcome. Please check
[https://github.com/skydive-project/skydive/blob/master/CONTRIBUTING.md](https://github.com/skydive-project/skydive/blob/master/CONTRIBUTING.md)
to know about the process.

## Contact and Support
* IRC: #skydive-project on [irc.freenode.net](https://webchat.freenode.net/)
* Mailing list: [https://www.redhat.com/mailman/listinfo/skydive-dev](https://www.redhat.com/mailman/listinfo/skydive-dev)
* Issues: [https://github.com/skydive-project/skydive/issues](https://github.com/skydive-project/skydive/issues)
