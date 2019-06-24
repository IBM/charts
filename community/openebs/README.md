# OpenEBS

**It is based on Helm community chart [openebs](https://github.com/openebs/openebs/tree/master/k8s/charts/openebs)**

[OpenEBS](http://openebs.io/) is a cloud-native storage solution built with the goal of providing containerized storage for containers. Using OpenEBS, a developer can seamlessly get persistent storage for stateful applications on Kubernetes with ease.

## Introduction

This chart bootstraps OpenEBS deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites
- Kubernetes 1.10+ with RBAC enabled
- iSCSI PV support in the underlying infrastructure
- iSCSI PV support in the underlying infrastructure.
- User deploying the chart needs to have the clusterAdmin role.
- A namespace called "openebs" is created in the Cluster for running the
  below instructions: `kubectl create namespace openebs`.
- If [Container Image Security](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.0/manage_images/image_security.html) is enabled then OpenEBS location on Docker hub container registry `docker.io/openebs/*` must be added to the list of trusted registries by following the instructions described under the section [Customizing your policy (post installation)](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.0/manage_images/image_security.html).

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
helm install community/openebs --name my-release --namespace openebs
```

The command deploys OpenEBS on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Installing OpenEBS from the codebase

```shell
git clone https://github.com/openebs/openebs.git
cd openebs/k8s/charts/openebs/
helm install --name my-release --namespace openebs .
```

## Verifying the Chart

```shell
#Check the OpenEBS Management Pods are running.
kubectl get pods -n openebs
#Create a test PVC
kubectl apply -f https://raw.githubusercontent.com/openebs/openebs/master/k8s/demo/pvc.yaml
#Check the OpenEBS Volume Pods are created
kubectl get pods
#Delete the test volume and associated Volume Pods
kubectl delete -f https://raw.githubusercontent.com/openebs/openebs/master/k8s/demo/pvc.yaml

```

## Unistalling the Chart

To uninstall/delete the `my-release` deployment:

```shell
helm ls --all
# Note the my-release from above command
helm delete --purge my-release
```

## Configuration

The following table lists the configurable parameters of OpenEBS chart and their default values.

| Parameter                               | Description                                   | Default                                   |
| ----------------------------------------| --------------------------------------------- | ----------------------------------------- |
| `rbac.create`                           | Enable RBAC Resources                         | `true`                                    |
| `image.pullPolicy`                      | Container pull policy                         | `IfNotPresent`                            |
| `apiserver.image`                       | Image for API Server                          | `quay.io/openebs/m-apiserver`             |
| `apiserver.imageTag`                    | Image Tag for API Server                      | `1.0.0`                                   |
| `apiserver.replicas`                    | Number of API Server Replicas                 | `1`                                       |
| `apiserver.sparse.enabled`              | Create Sparse Pool based on Sparsefile        | `false`                                   |
| `provisioner.image`                     | Image for Provisioner                         | `quay.io/openebs/openebs-k8s-provisioner` |
| `provisioner.imageTag`                  | Image Tag for Provisioner                     | `1.0.0`                                   |
| `provisioner.replicas`                  | Number of Provisioner Replicas                | `1`                                       |
| `localProvisioner.image`                | Image for localProvisioner                    | `quay.io/openebs/provisioner-localpv`     |
| `localProvisioner.imageTag`             | Image Tag for localProvisioner                | `1.0.0`                                   |
| `localProvisioner.replicas`             | Number of localProvisioner Replicas           | `1`                                       |
| `localProvisioner.basePath`             | BasePath for hostPath volumes on Nodes        | `/var/openebs/local`                      |
| `webhook.image`                         | Image for admision server                     | `quay.io/openebs/admission-server`        |
| `webhook.imageTag`                      | Image Tag for admission server                | `1.0.0`                                   |
| `webhook.replicas`                      | Number of admission server Replicas           | `1`                                       |
| `snapshotOperator.provisioner.image`    | Image for Snapshot Provisioner                | `quay.io/openebs/snapshot-provisioner`    |
| `snapshotOperator.provisioner.imageTag` | Image Tag for Snapshot Provisioner            | `1.0.0`                                   |
| `snapshotOperator.controller.image`     | Image for Snapshot Controller                 | `quay.io/openebs/snapshot-controller`     |
| `snapshotOperator.controller.imageTag`  | Image Tag for Snapshot Controller             | `1.0.0`                                   |
| `snapshotOperator.replicas`             | Number of Snapshot Operator Replicas          | `1`                                       |
| `ndm.image`                             | Image for Node Disk Manager                   | `quay.io/openebs/node-disk-manager-amd64` |
| `ndm.imageTag`                          | Image Tag for Node Disk Manager               | `v0.4.0`                                  |
| `ndm.sparse.path`                       | Directory where Sparse files are created      | `/var/openebs/sparse`                     |
| `ndm.sparse.size`                       | Size of the sparse file in bytes              | `10737418240`                             |
| `ndm.sparse.count`                      | Number of sparse files to be created          | `1`                                       |
| `ndm.filters.excludeVendors`            | Exclude devices with specified vendor         | `CLOUDBYT,OpenEBS`                        |
| `ndm.filters.excludePaths`              | Exclude devices with specified path patterns  | `loop,fd0,sr0,/dev/ram,/dev/dm-,/dev/md`  |
| `ndm.filters.includePaths`              | Include devices with specified path patterns  | `""`                                      |
| `ndmOperator.image`                     | Image for NDM Operator                        | `quay.io/openebs/node-disk-operator-amd64`|
| `ndmOperator.imageTag`                  | Image Tag for NDM Operator                    | `v0.4.0`                                  |
| `jiva.image`                            | Image for Jiva                                | `quay.io/openebs/jiva`                    |
| `jiva.imageTag`                         | Image Tag for Jiva                            | `1.0.0`                                   |
| `jiva.replicas`                         | Number of Jiva Replicas                       | `3`                                       |
| `cstor.pool.image`                      | Image for cStor Pool                          | `quay.io/openebs/cstor-pool`              |
| `cstor.pool.imageTag`                   | Image Tag for cStor Pool                      | `1.0.0`                                   |
| `cstor.poolMgmt.image`                  | Image for cStor Pool  Management              | `quay.io/openebs/cstor-pool-mgmt`         |
| `cstor.poolMgmt.imageTag`               | Image Tag for cStor Pool Management           | `1.0.0`                                   |
| `cstor.target.image`                    | Image for cStor Target                        | `quay.io/openebs/cstor-istgt`             |
| `cstor.target.imageTag`                 | Image Tag for cStor Target                    | `1.0.0`                                   |
| `cstor.volumeMgmt.image`                | Image for cStor Volume  Management            | `quay.io/openebs/cstor-volume-mgmt`       |
| `cstor.volumeMgmt.imageTag`             | Image Tag for cStor Volume Management         | `1.0.0`                                   |
| `policies.monitoring.image`             | Image for Prometheus Exporter                 | `quay.io/openebs/m-exporter`              |
| `policies.monitoring.imageTag`          | Image Tag for Prometheus Exporter             | `1.0.0`                                   |
| `analytics.enabled`                     | Enable sending stats to Google Analytics      | `true`                                    |
| `analytics.pingInterval`                | Duration(hours) between sending ping stat     | `24h`                                     |
| `HealthCheck.initialDelaySeconds`       | Delay before liveness probe is initiated      | `30`                                      |                              | 30                                                          |
| `HealthCheck.periodSeconds`             | How often to perform the liveness probe       | `60`                                      |                            | 10                                                          |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```shell
helm install --name openebs -f values.yaml openebs-charts/openebs
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## Storage

OpenEBS follows the container attached storage (CAS) model. As a part of this approach, each volume has a dedicated controller POD and a set of replica PODs.
Please refer to [OpenEBS Architecture Documentation](https://docs.openebs.io/docs/next/architecture.html) for details on architectural concepts and considerations.

To use OpenEBS storage with your workload select an OpenEBS storage class in the persistent volume claim. Examples for various workloads such as [Cassandra](https://github.com/openebs/openebs/tree/master/k8s/demo/cassandra), [CockroachDB](https://github.com/openebs/openebs/tree/master/k8s/demo/cockroachDB), [Couchbase Server](https://github.com/openebs/openebs/tree/master/k8s/demo/couchbase), [Crunchy Postgres](https://github.com/openebs/openebs/tree/master/k8s/demo/crunchy-postgres), [Jenkins](https://github.com/openebs/openebs/tree/master/k8s/demo/jenkins), [Jupyter](https://github.com/openebs/openebs/tree/master/k8s/demo/jupyter), [Kafka](https://github.com/openebs/openebs/tree/master/k8s/demo/kafka), [Minio](https://github.com/openebs/openebs/tree/master/k8s/demo/minio), [MongoDB](https://github.com/openebs/openebs/tree/master/k8s/demo/mongodb), [Percona](https://github.com/openebs/openebs/tree/master/k8s/demo/percona), [RabbitMQ](https://github.com/openebs/openebs/tree/master/k8s/demo/rabbitmq), [Redis](https://github.com/openebs/openebs/tree/master/k8s/demo/redis) as a StatefulSet and few others are provided under OpenEBS examples repository [here](https://github.com/openebs/openebs/tree/master/k8s/demo).

For details on loss of data considerations refer to [FAQ](https://openebs.io/faq) section on OpenEBS website.

## Limitations

- For OpenEBS volumes configured with more than 1 replica, at least more than half of the replicas should be online for the Volume to allow Read and Write. In the upcoming releases, with cStor data engine, Volumes can be allowed to Read/Write when there is at least one replica in the ready state.
- This release contains a preview support for cloning an OpenEBS Volume from a snapshot. This feature only supports single replica for a cloned volume, which is intended to be used for temporarily spinning up a new application pod for recovering lost data from the previous snapshot.
- While testing for different platforms, with a three-node/replica OpenEBS volume and shutting down one of the three nodes, there was an intermittent case where one of the 2 remaining replicas also had to be restarted.
- The OpenEBS target (controller) pod depends on the Kubernetes node tolerations to reschedule the pod in the event of node failure. For this feature to work, TaintNodesByCondition alpha feature must be enabled in Kubernetes. In a scenario where OpenEBS target (controller) is not rescheduled or is back to running within 120 seconds, the volume gets into a read-only state and a manual intervention is required to make the volume as read-write.
- The current version of OpenEBS volumes are not optimized for performance sensitive applications.

For a more comprehensive list of open issues uncovered through e2e, please refer to [open issues](https://github.com/openebs/openebs/labels/release-note%2Fopen).

## Documentation

- [OpenEBS Documentation](https://docs.openebs.io/)
- [OpenEBS FAQ](https://openebs.io/faq)
- [OpenEBS Blog](https://blog.openebs.io/)
- [OpenEBS CI and E2E Dashboard](https://openebs.ci/)
- [OpenEBS Community Slack Channel](https://slack.openebs.io/)
