# IBM MQ Advanced for Developers

## Introduction

This chart deploys a single IBM® MQ Advanced for Developers server (Queue Manager).  IBM MQ is messaging middleware that simplifies and accelerates the integration of diverse applications and business data across multiple platforms.  It uses message queues to facilitate the exchanges of information and offers a single messaging solution for cloud, mobile, Internet of Things (IoT) and on-premises environments.

## Chart Details

This chart will do the following:

* Create a single MQ server (Queue Manager) using a [StatefulSet](http://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/) with exactly one replica.  Kubernetes will ensure that if it fails for some reason, it will be restarted, possibly on a different worker node.
* Create a [Service](https://kubernetes.io/docs/concepts/services-networking/service/).  This is used to ensure that MQ client applications have a consistent IP address to connect to, regardless of where the Queue Manager is actually running.
* Create a [Secret](https://kubernetes.io/docs/concepts/configuration/secret/).  This is used to store passwords used for the default developer configuration.

## Prerequisites

- Kubernetes 1.6 or greater, with beta APIs enabled
- If persistence is enabled (see [configuration](#configuration)), then you either need to create a PersistentVolume, or specify a Storage Class if classes are defined in your cluster.

## Resources Required

This chart uses the following resources by default:

- 0.5 CPU core
- 0.5 Gi memory
- 2 Gi persistent volume.

See the [configuration](#configuration) section for how to configure these values.

## Installing the Chart

You can install the chart with the release name `foo` as follows:

```sh
helm install --name foo stable/ibm-mqadvanced-server-dev --set license=accept
```

This command accepts the [IBM MQ Advanced for Developers license](LICENSES/LICENSE_ILAN) and deploys an MQ Advanced for Developers server on the Kubernetes cluster. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: See all the resources deployed by the chart using `kubectl get all -l release=foo`

### Uninstalling the Chart

You can uninstall/delete the `foo` release as follows:

```sh
helm delete foo
```

The command removes all the Kubernetes components associated with the chart, except any Persistent Volume Claims (PVCs).  This is the default behavior of Kubernetes, and ensures that valuable data is not deleted.  In order to delete the Queue Manager's data, you can delete the PVC using the following command:

```sh
kubectl delete pvc -l release=foo
```

## Configuration
The following table lists the configurable parameters of the `ibm-mqadvanced-server-dev` chart and their default values.

| Parameter                       | Description                                                     | Default                                    |
| ------------------------------- | --------------------------------------------------------------- | ------------------------------------------ |
| `license`                       | Set to `accept` to accept the terms of the IBM license          | `"not accepted"`                           |
| `image.repository`              | Image full name including repository                            | `ibmcom/mq`                |
| `image.tag`                     | Image tag                                                       | `9`         |
| `image.pullPolicy`              | Image pull policy                                               | `IfNotPresent`                             |
| `image.pullSecret`              | Image pull secret, if you are using a private Docker registry   | `nil`                                      |
| `persistence.enabled`           | Use persistent volumes for all defined volumes                  | `true`                                     |
| `persistence.useDynamicProvisioning` | Use dynamic provisioning (storage classes) for all volumes | `true`                                     |
| `dataPVC.name`                  | Suffix for the PVC name                                         | `"data"`                                   |
| `dataPVC.storageClassName`      | Storage class of volume for main MQ data (under `/var/mqm`)     | `""`                                       |
| `dataPVC.size`                  | Size of volume for main MQ data (under `/var/mqm`)              | `2Gi`                                      |
| `service.name`                  | Name of the Kubernetes service to create                        | `"qmgr"`                                   |
| `service.type`                  | Kubernetes service type exposing ports, e.g. `NodePort`         | `ClusterIP`                                |
| `resources.limits.cpu`          | Kubernetes CPU limit for the Queue Manager container | `500m`                                                   |
| `resources.limits.memory`       | Kubernetes memory limit for the Queue Manager container | `512Mi`                                              |
| `resources.requests.cpu`        | Kubernetes CPU request for the Queue Manager container | `500m`                                                 |
| `resources.requests.memory`     | Kubernetes memory request for the Queue Manager container | `512Mi`                                            |
| `queueManager.name`              | MQ Queue Manager name                           | Helm release name                                          |
| `queueManager.dev.adminPassword` | Developer defaults - administrator password     | Random generated string.  See the notes that appear when you install for how to retrieve this.                            |
| `queueManager.dev.appPassword`   | Developer defaults - app password   | `nil` (no password required to connect an MQ client)  
                |
| `nameOverride`                  | Set to partially override the resource names used in this chart | `ibm-mq`                                   |
| `livenessProbe.initialDelaySeconds` | The initial delay before starting the liveness probe. Useful for slower systems that take longer to start the Queue Manager. | 60 |
| `livenessProbe.periodSeconds` | How often to run the probe | 10 |
| `livenessProbe.timeoutSeconds` | Number of seconds after which the probe times out | 5 |
| `livenessProbe.failureThreshold` | Minimum consecutive failures for the probe to be considered failed after having succeeded | 1 |
| `readinessProbe.initialDelaySeconds` | The initial delay before starting the readiness probe | 10 |
| `readinessProbe.periodSeconds` | How often to run the probe | 5 |
| `readinessProbe.timeoutSeconds` | Number of seconds after which the probe times out | 3 |
| `readinessProbe.failureThreshold` | Minimum consecutive failures for the probe to be considered failed after having succeeded | 1 |
| `log.format`                    | Error log format on container's console.  Either `json` or `basic` | `basic`                          |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart.

> **Tip**: You can use the default [values.yaml](values.yaml)

## Storage
The chart mounts a [Persistent Volume](http://kubernetes.io/docs/user-guide/persistent-volumes/) for the storage of MQ configuration data and messages.  By using a Persistent Volume based on network-attached storage, Kubernetes can re-schedule the MQ server onto a different worker node.  You should not use "hostPath" or "local" volumes, because this will not allow moving between nodes.

Performance requirements will vary widely based on workload, but as a guideline, use a Storage Class which allows for at least 200 IOPS (based on 16 KB block size with a 50/50 read/write mix).

## Limitations

It is not generally recommended that you change the number of replicas in the StatefulSet from the default value of 1.  Setting the number of replicas creates multiple Queue Managers.  The recommended way to scale MQ is by deploying this chart multiple times and connecting the Queue Managers together using MQ configuration — see [Architectures based on multiple queue managers](https://www.ibm.com/support/knowledgecenter/en/SSFKSJ_9.0.0/com.ibm.mq.pla.doc/q004720_.htm).  If you choose to set a different number of replicas on the StatefulSet, connections to each Queue Manager will be routed via a single IP address from the Kubernetes Service.  Connections to multiple replicas via a Service are load balanced, typically on a round-robin basis.  If you do this, you need to take great care not to create an affinity between an MQ client and server, because a client might get disconnected, and then re-connect to a different server.  See Chapter 7 of the [IBM MQ as a Service Redpaper](https://www.redbooks.ibm.com/redpapers/pdfs/redp5209.pdf)

It is not recommended to change the number of replicas in the StatefulSet after initial deployment.  This will cause the addition or deletion of Queue Managers, which can result in loss of messages.

Validated to run on IBM Cloud Private.  JSON logging requires IBM Cloud Private V2.1.0.2 or later.

## Documentation

### JSON log output

By default, the MQ container output for the MQ Advanced for Developers image is in a basic human-readable format.  You can change this to JSON format, to better integrate with log aggregation services.

### Connecting to the web console

The MQ Advanced for Developers image includes the MQ web server.  The web server runs the web console, and the MQ REST APIs.  By default, the MQ server deployed by this chart is accessible via a `ClusterIP` [Service](https://kubernetes.io/docs/concepts/services-networking/service/), which is only accessible from within the Kubernetes cluster.  If you want to access the web console from a web browser, then you need to select a different type of Service.  For example, a `NodePort` service will expose the web console port on each worker node.

## Copyright

© Copyright IBM Corporation 2017, 2018
