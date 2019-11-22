MinIO
=====

[MinIO](https://min.io) is a distributed object storage service for high performance, high scale data infrastructures. It is a drop in replacement for AWS S3 in your own environment. It uses erasure coding to provide highly resilient storage that can tolerate failures of upto n/2 nodes. It runs on cloud, container, kubernetes and bare-metal environments. It is simple enough to be deployed in seconds, and can scale to 100s of peta bytes. MinIO is suitable for storing objects such as photos, videos, log files, backups, VM and container images.

MinIO supports [distributed mode](https://docs.minio.io/docs/distributed-minio-quickstart-guide). In distributed mode, you can pool multiple drives (even on different machines) into a single object storage server.

# Introduction

This chart bootstraps MinIO deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

-   Kubernetes 1.11 with Beta APIs enabled to run MinIO in [distributed mode](#distributed-minio).
-	PV provisioner support in the underlying infrastructure.

# Installing the Chart

Install this chart using:

```bash
$ helm install ibm-minio-1.0.2.tgz --name <ReleaseName>
```

The command deploys MinIO on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

### Release name

An instance of a chart running in a Kubernetes cluster is called a release. Each release is identified by a unique name within the cluster. Helm automatically assigns a unique release name after installing the chart. You can also set your preferred name by:

### Access and Secret keys

By default a pre-generated access and secret key will be used. To avoid that, pass an existing secret with the keys `accesskey` and `secretkey`. 

### Updating MinIO configuration via Helm

[ConfigMap](https://kubernetes.io/docs/user-guide/configmap/) allows injecting containers with configuration data even while a Helm release is deployed.

To update your MinIO server configuration while it is deployed in a release, you need to

1. Check all the configurable values in the MinIO chart using `helm inspect values ibm-minio-1.0.2.tgz`.
2. Override the `minio_server_config` settings in a YAML formatted file, and then pass that file like this `helm upgrade -f config.yaml stable/minio`.
3. Restart the MinIO server(s) for the changes to take effect.

You can also check the history of upgrades to a release using `helm history my-release`. Replace `my-release` with the actual release name.

# Uninstalling the Chart

Assuming your release is named as `my-release`, delete it using the command:

```bash
$ helm delete <ReleaseName> --purge
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

# Upgrading the Chart

You can use Helm to update MinIO version in a live release. Assuming your release is named as `my-release`, get the values using the command:

```bash
$ helm get values my-release > old_values.yaml
```

Then change the field `image.tag` in `old_values.yaml` file with MinIO image tag you want to use. Now update the chart using

```bash
$ helm upgrade -f old_values.yaml my-release ibm-minio-1.0.2.tgz
```

Default upgrade strategies are specified in the `values.yaml` file. Update these fields if you'd like to use a different strategy.

# Configuration

The following table lists the configurable parameters of the MinIO chart and their default values.

| Parameter                  | Description                         | Default                                                 |
|----------------------------|-------------------------------------|---------------------------------------------------------|
| `clusterDomain`                      | Cluster domain used by Kubernetes Cluster (the suffix for internal KubeDNS names). | `cluster.local` |
| `minio.image.name`                 | Image name for the minio container                                  | `release/opencontent-minio`         |
| `minio.image.tag`                  | Image tag for the minio container                                   | `2019-07-24-06.48.26-15ade37`                                             |
| `minioClient.image.name`         | Image name for the minioClient container                                      | `stage/opencontent-minio-client`         |
| `minioClient.image.tag`          | Image tag for the minioClient container                                       | `e524c15-amd64`                                      |
| `creds.image.name`                  | Image name for the creds container                                        | `opencontent-icp-cert-gen-1`      |
| `creds.image.tag`                   | Image tag for the creds container                                         | `1.1.0`                                             |
| `global.deploymentType` | A deployment type of either `Development|Production`. To enable this, set `replicas` to `0`. | `""`                          |
| `global.image.repository`           | Image registry to be gloablly used in the chart                           | `hyc-cp-opencontent-docker-local.artifactory.swg-devops.com` |
| `global.image.pullSecret`           | Image pull secret to be gloablly used in the chart                        | `` |
| `global.image.pullPolicy`           | Image pull policy to be gloablly used in the chart                        | `IfNotPresent` |
| `global.sch.enabled`                | Specifies if ibm-sch chart is used as required subchart. If set to `false`, the umbrella chart has to provide this dependency | `true` |                                               |
| securityContext.minio.runAsUser  | The User ID that needs to be run as by all minio containers. This applies only when installed on non-openshift clusters.  |   `999` |
| securityContext.creds.runAsUser  | The User ID that needs to be run as by all creds job containers. This applies only when installed on non-openshift clusters. | `523` |
| `replicas`                 | Number of nodes (applicable only for MinIO distributed mode). Should be 4 <= x <= 32 | `4`    |
| `replicasForDev`           | When `global.deploymentType` is set to `Development` this will be the replica value.  Should be 4 <= x <= 32   | `4` |
| `replicasForProd`          | When `global.deploymentType` is set to `Production` this will be the replica value.  Should be 4 <= x <= 32   | `4` |
| `existingSecret`           | Name of existing secret with access and secret key.| `""`                                     |
| `configPath`               | Default config file location        | `/workdir/home/.minio/`                                              |
| `configPathmc`             | Default config file location for MinIO client - mc | `/workdir/home/.mc/`                                  |
| `mountPath`                | Default mount location for persistent drive| `/workdir/data`                                        |
| `clusterDomain`            | domain name of kubernetes cluster where pod is running.| `cluster.local`                      |
| `service.port`             | Kubernetes port where service is exposed| `9000`                                              |
| `serviceAccount.create`    | Toggle creation of new service account | `true`                                               |
| `serviceAccount.name`      | Name of service account to create and/or use | `""`                                           |
| `sse.enabled`              | Enable SSE-S3 via a direct master key | `false`                                               |
| `sse.masterKeyName`        | Name of the key within the secret to get the master key | `sseMasterKey`                      |
| `sse.masterKeySecret`      | Secret where the master key is found | `""`                                                   |
| `persistence.enabled`      | Use persistent volume to store data | `true`                                                  |
| `persistence.size`         | Size of persistent volume claim     | `10Gi`                                                  |
| `persistence.existingClaim`| Use an existing PVC to persist data | `nil`                                                   |
| `persistence.storageClass` | Storage class name of PVC           | `nil`                                                   |
| `persistence.accessMode`   | ReadWriteOnce or ReadOnly           | `ReadWriteOnce`                                         |
| `persistence.subPath`      | Mount a sub directory of the persistent volume if set | `""`                                  |
| `resources`                | CPU/Memory resource requests/limits | Memory: `256Mi`, CPU: `100m`                            |
| `priorityClassName`        | Pod priority settings               | `""`                                                    |
| `nodeSelector`             | Node labels for pod assignment      | `{}`                                                    |
| `affinity`                 | Affinity settings for pod assignment | `{}`                                                   |
| `tolerations`              | Toleration labels for pod assignment | `[]`                                                   |
| `podAnnotations`           | Pod annotations                      | `{}`                                                   |
| `tls.enabled`              | Enable TLS for MinIO server | `false`                                                         |
| `tls.certSecret`           | Kubernetes Secret with `public.crt` and `private.key` files. | `""`                           |
| `livenessProbe.initialDelaySeconds`  | Delay before liveness probe is initiated        | `5`                               |
| `livenessProbe.periodSeconds`        | How often to perform the probe                  | `30`                              |
| `livenessProbe.timeoutSeconds`       | When the probe times out                        | `1`                               |
| `livenessProbe.successThreshold`     | Minimum consecutive successes for the probe to be considered successful after having failed. | `1` |
| `livenessProbe.failureThreshold`     | Minimum consecutive failures for the probe to be considered failed after having succeeded.   | `3` |
| `readinessProbe.initialDelaySeconds` | Delay before readiness probe is initiated       | `5`                               |
| `readinessProbe.periodSeconds`       | How often to perform the probe                  | `15`                              |
| `readinessProbe.timeoutSeconds`      | When the probe times out                        | `1`                               |
| `readinessProbe.successThreshold`    | Minimum consecutive successes for the probe to be considered successful after having failed. | `1` |
| `readinessProbe.failureThreshold`    | Minimum consecutive failures for the probe to be considered failed after having succeeded.   | `3` |
| `defaultBucket.enabled`    | If set to true, a bucket will be created after MinIO install | `false`                        |
| `defaultBucket.name`       | Bucket name                         | `bucket`                                                |
| `defaultBucket.policy`     | Bucket policy                       | `none`                                                  |
| `defaultBucket.purge`      | Purge the bucket if already exists  | `false`                                                 |
| `buckets`                  | List of buckets to create after MinIO install  | `[]`                                         |
| `environment`              | Set MinIO server relevant environment variables in `values.yaml` file. MinIO containers will be passed these variables when they start. | `MINIO_BROWSER: "on"` |
| `metrics.serviceMonitor.enabled`          | Set this to `true` to create ServiceMonitor for Prometheus operator                   | `false` |
| `metrics.serviceMonitor.additionalLabels` | Additional labels that can be used so ServiceMonitor will be discovered by Prometheus | `{}`    |
| `metrics.serviceMonitor.namespace`        | Optional namespace in which to create ServiceMonitor                                  | `nil`   |
| `metrics.serviceMonitor.interval`         | Scrape interval. If not set, the Prometheus default scrape interval is used           | `nil`   |
| `metrics.serviceMonitor.scrapeTimeout`    | Scrape timeout. If not set, the Prometheus default scrape timeout is used             | `nil`   |
Some of the parameters above map to the env variables defined in the [MinIO DockerHub image](https://hub.docker.com/r/minio/minio/).

You can specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
$ helm install --name my-release \
  --set persistence.size=100Gi \
    stable/minio
```

The above command deploys MinIO server with a 100Gi backing persistent volume.

Alternately, you can provide a YAML file that specifies parameter values while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml ibm-minio-1.0.2.tgz
```

> **Tip**: You can use the default [values.yaml](values.yaml)

# Chart Details

## Distributed MinIO

This chart provisions a MinIO server in [distributed mode](https://docs.minio.io/docs/distributed-minio-quickstart-guide) by default. 

This provisions MinIO server in distributed mode with 4 nodes. To change the number of nodes in your distributed MinIO server, set the `replicas` field,

```bash
$ helm install --set replicas=8 ibm-minio-1.0.2.tgz
```

This provisions MinIO server in distributed mode with 8 nodes. Note that the `replicas` value should be an integer between 4 and 16 (inclusive).

### StatefulSet [limitations](http://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/#limitations) applicable to distributed MinIO

1. StatefulSets need persistent storage, so the `persistence.enabled` flag is ignored when `mode` is set to `distributed`.
2. When uninstalling a distributed MinIO release, you'll need to manually delete volumes associated with the StatefulSet.

## Persistence

This chart provisions a PersistentVolumeClaim and mounts corresponding persistent volume to default location `/export`. You'll need physical storage available in the Kubernetes cluster for this to work. If you'd rather use `emptyDir`, disable PersistentVolumeClaim by:

```bash
$ helm install --set persistence.enabled=false ibm-minio-1.0.2.tgz
```

> *"An emptyDir volume is first created when a Pod is assigned to a Node, and exists as long as that Pod is running on that node. When a Pod is removed from a node for any reason, the data in the emptyDir is deleted forever."*

## Existing PersistentVolumeClaim

If a Persistent Volume Claim already exists, specify it during installation.

1. Create the PersistentVolume
2. Create the PersistentVolumeClaim
3. Install the chart

```bash
$ helm install --set persistence.existingClaim=PVC_NAME ibm-minio-1.0.2.tgz
```

## NetworkPolicy

To enable network policy for MinIO,
install [a networking plugin that implements the Kubernetes
NetworkPolicy spec](https://kubernetes.io/docs/tasks/administer-cluster/declare-network-policy#before-you-begin),
and set `networkPolicy.enabled` to `true`.

For Kubernetes v1.5 & v1.6, you must also turn on NetworkPolicy by setting
the DefaultDeny namespace annotation. Note: this will enforce policy for _all_ pods in the namespace:

    kubectl annotate namespace default "net.beta.kubernetes.io/network-policy={\"ingress\":{\"isolation\":\"DefaultDeny\"}}"

With NetworkPolicy enabled, traffic will be limited to just port 9000.

For more precise policy, set `networkPolicy.allowExternal=true`. This will
only allow pods with the generated client label to connect to MinIO.
This label will be displayed in the output of a successful install.

## Existing secret

Instead of having this chart create the secret for you, you can supply a preexisting secret, much
like an existing PersistentVolumeClaim.

First, create the secret:
```bash
$ kubectl create secret generic my-minio-secret --from-literal=accesskey=foobarbaz --from-literal=secretkey=foobarbazqux
```

Then install the chart, specifying that you want to use an existing secret:
```bash
$ helm install --set existingSecret=my-minio-secret ibm-minio-1.0.2.tgz
```

The following fields are expected in the secret
1. `accesskey` - the access key ID
2. `secretkey` - the secret key

## Configure TLS

To enable TLS for MinIO containers, acquire TLS certificates from a CA or create self-signed certificates. While creating / acquiring certificates ensure the corresponding domain names are set as per the standard [DNS naming conventions](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#pod-identity) in a Kubernetes StatefulSet (for a distributed MinIO setup). Then create a secret using

```bash
$ kubectl create secret generic tls-ssl-minio --from-file=path/to/private.key --from-file=path/to/public.crt
```

Then install the chart, specifying that you want to use the TLS secret:

```bash
$ helm install --set tls.enabled=true,tls.certSecret=tls-ssl-minio ibm-minio-1.0.2.tgz
```

## Pass environment variables to MinIO containers

To pass environment variables to MinIO containers when deploying via Helm chart, use the below command line format

```bash
$ helm install --set environment.MINIO_BROWSER=on,environment.MINIO_DOMAIN=domain-name ibm-minio-1.0.2.tgz
```

You can add as many environment variables as required, using the above format. Just add `environment.<VARIABLE_NAME>=<value>` under `set` flag.

## Create buckets after install

Install the chart, specifying the buckets you want to create after install:

```bash
$ helm install --set buckets[0].name=bucket1,buckets[0].policy=none,buckets[0].purge=false ibm-minio-1.0.2.tgz
```

Description of the configuration parameters used above - 
1. `buckets[].name` - name of the bucket to create, must be a string with length > 0
2. `buckets[].policy` - Can be one of none|download|upload|public
3. `buckets[].purge` - Purge if bucket exists already

# Resources Required 
 
 Minimum of 
 * Memory: 1Gi  
 * CPU: 1core 

# Limitations

* Minimum number of replicas needed is 4 and deployment cannot be made with less than 4 replicas. 

* Does not support Hostpath type storage

# Storage
The image stores the minIO data and configurations at the /workdir/data path of the container.

The chart mounts a Persistent Volume volume at this location. By default, you must create the persistent volume ahead of time as shown in step 1 of the Installing the Chart section above. If you have dynamic provisioning set up, you can install the helm chart with persistence.useDynamicProvisioning=true. An existing PersistentVolumeClaim can also be defined.

# PodSecurityPolicy Requirements

The predefined PodSecurityPolicy name [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart. If your target namespace is bound to this PodSecurityPolicy, you can proceed to install the chart.

This chart also defines a custom PodSecurityPolicy which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom PodSecurityPolicy using the user interface or the supplied instructions/scripts in the pak_extension pre-install directory.

From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy
Custom PodSecurityPolicy definition:

```

apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  annotations:
    kubernetes.io/description: "This policy is the most restrictive,
      requiring pods to run with a non-root UID, and preventing pods from accessing the host."
    seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
    seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
  name: ibm-restricted-psp-minio
spec:
  allowPrivilegeEscalation: false
  forbiddenSysctls:
  - '*'
  fsGroup:
    ranges:
    - max: 65535
      min: 1
    rule: MustRunAs
  requiredDropCapabilities:
  - ALL
  runAsUser:
    rule: MustRunAsNonRoot
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    ranges:
    - max: 65535
      min: 1
    rule: MustRunAs
  volumes:
  - configMap
  - emptyDir
  - projected
  - secret
  - downwardAPI
  - persistentVolumeClaim
```

# Red Hat OpenShift SecurityContextConstraints Requirements

The predefined SCC name [`restricted`](https://ibm.biz/cpkspec-scc) has been verified for this chart. If your targer namespace is bound to this SCC, you can proceed to install the chart.



