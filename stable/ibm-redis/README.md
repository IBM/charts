# ibm-redis

[Redis](https://redis.io) is an open source (BSD licensed), in-memory data structure store, used as a database, cache and message broker.

## Introduction

This chart bootstraps a high availability [Redis](https://redis.io) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Upgrading the Chart

Please note that there have been a number of changes simplifying the redis management strategy (for better failover and elections) in the 3.x version of this chart. These changes allow the use of official [redis](https://hub.docker.com/_/redis/) images that do not require special RBAC or ServiceAccount roles. As a result when upgrading from version >=1.3.1 to >=2.0.0 of this chart, `Role`, `RoleBinding`, and `ServiceAccount` resources should be deleted manually.

## Chart Details

This chart bootstraps a [Redis](https://redis.io) highly available master/slave statefulset in a [Kubernetes](http://kubernetes.io) cluster using the Helm package manager.

By default this chart install 3 pods total:
 * one pod containing a redis master and sentinel containers
 * two pods each containing redis slave and sentinel containers.

This chart allows for most redis or sentinel config options to be passed as a key value pair through the `values.yaml` under `redis.config` and `sentinel.config`. See links below for all available options.

[Example redis.conf](http://download.redis.io/redis-stable/redis.conf)
[Example sentinel.conf](http://download.redis.io/redis-stable/sentinel.conf)

For example `repl-timeout 60` would be added to the `redis.config` section of the `values.yaml` as:

```yml
   repl-timeout: "60"
```

Sentinel options supported must be in the the `sentinel <option> <master-group-name> <value>` format. For example, `sentinel downAfterMilliseconds 30000` would be added to the `sentinel.config` section of the `values.yaml` as:

```yml
   downAfterMilliseconds: 30000
```

If more control is needed from either the redis or sentinel config then an entire config can be defined under `redis.customConfig` or `sentinel.customConfig`. Please note that these values will override any configuration options under their respective section. For example, if you define `sentinel.customConfig` then the `sentinel.config` is ignored.

## Encryption

This chart requires the adopter to encrypt data prior or the cluster owner to enable ipsec

## Prerequisites

- Kubernetes 1.10
- Tiller 2.9.1 or later
- PV support on the underlying infrastructure
- Persistent Volume is required if persistence is enabled. Currently, only volumes created via dynamic provisioning are supported.

## Configuration

The following tables lists the configurable parameters of the Redis chart and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `arch.amd64`                     | Preference to run on amd64 architecture               | `2 - No preference`                                       |
| `arch.ppc64le`                   | Preference to run on ppc64le architecture             | `2 - No preference`                                       |
| `arch.s390x`                   | Preference to run on s390x architecture             | `2 - No preference`                                       |
| `image.name` | Docker image to be pulled for Redis. | release/opencontent-redis-5 |
| `image.tag` | A tag is a label applied to a image in a repository. Tags are how various images in a repository are distinguished from each other. | 2019-07-25-22.00.28-621121e |
| `image.pullPolicy` | Always, Never, or IfNotPresent. Defaults to IfNotPresent | IfNotPresent |
| `creds.image.name` | Docker image to be pulled for creds. | release-master/opencontent-common-utils |
| `creds.image.tag` | A tag is a label applied to a image in a repository. Tags are how various images in a repository are distinguished from each other. | 1.1.2 |
| `creds.image.pullPolicy` | Always, Never, or IfNotPresent. Defaults to IfNotPresent | IfNotPresent |
| `global.image.repository` | Docker registry to pull all the images from. |  |
| `global.image.pullSecret` | Image pull secret to be used globally for all images |  |
| `global.environmentSize` | Controls resource sizing. Size0 is a minimal spec for evaluation purposes. Use 'custom' to set sizing in values.yaml | size0 |
| `global.persistence.enabled` | Select this checkbox to store redis server data on a persistent volume so that the data is preserved if the pod is stopped. | false |
| `global.persistence.supplementalGroups` | Provide the gid of the volumes as list (required for NFS). |  |
| `global.persistence.useDynamicProvisioning` | Select this checkbox to allow the cluster to automatically provision new storage resource and create PersistentVolume objects. | true |
| `global.persistence.storageClassName` | storage - class name | |
| `global.persistence.storageClassOption.redisdata` | redis storage class option | default |
| `global.sch.enabled` | Set to false only is upstream chart provides ibm-sch chart | true |
| `affinity` | JSON Format. |  |
| `affinityRedis` | Affinity settings influencing only Redis server statefulset. JSON Format. |  |
| `auth.enabled` | If disabled redis servers will require any client authentication | true |
| `auth.authSecretName` | Secret that has the redis password. If not provided, a secret with random password will be generated |  |
| `persistence.storageClassName` | The name of StorageClass to be used to create persistent volume claim |  |
| `persistence.size` | Storage Size for persistent volume to be created | 2Gi |
| `dataPVC.name` | The prefix of the created Persistent Volume Claims. The defaults to data | data |
| `dataPVC.selector.label` | If useDynamicProvisioning is disabled, this specifies labels that needs to have the Persistent Volumes to be used. Defaults to null |  |
| `dataPVC.selector.value` | Specifies value assigned to the label that needs to have the Persistent Volumes to be used. Defaults to null |  |
| `resources.server.requests.cpu` | The minimum required CPU core. Specify integers, fractions (e.g. 0.5), or millicore values(e.g. 100m, where 100m is equivalent to .1 core). | 100m |
| `resources.server.requests.memory` | The minimum memory in bytes. Specify integers with one of these suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki. | 200Mi |
| `resources.server.limits.cpu` | The upper limit of CPU core. Specify integers, fractions (e.g. 0.5), or millicores values(e.g. 100m, where 100m is equivalent to .1 core). | 100m |
| `resources.server.limits.memory` | The memory upper limit in bytes. Specify integers with suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki. | 700Mi |
| `resources.sentinel.requests.cpu` | The minimum required CPU core. Specify integers, fractions (e.g. 0.5), or millicore values(e.g. 100m, where 100m is equivalent to .1 core). | 100m |
| `resources.sentinel.requests.memory` | The minimum memory in bytes. Specify integers with one of these suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki. | 200Mi |
| `resources.sentinel.limits.cpu` | The upper limit of CPU core. Specify integers, fractions (e.g. 0.5), or millicores values(e.g. 100m, where 100m is equivalent to .1 core). | 100m |
| `resources.sentinel.limits.memory` | The memory upper limit in bytes. Specify integers with suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki. | 200Mi |
| `redisPodSecurityContext` | Pod Security Context to the redis server/sentinel pods in yaml format | `yaml` |
| `redisContainerSecurityContext` | Container Security Context to the redis server/sentinel pods in yaml format | `yaml`|
| `replicas` | The number of replicas for the statefulset desired (mininum of 3) | 3 |
| `maxReplicas` | The total number of redis replicas that can be scaled up to | 6 |
| `sentinel.port` | Sentinel port number (default 26379) | 26379 |
| `sentinel.quorum` | The number of Sentinels that need to agree about the fact the master is not reachable (default 2) | 2 |
| `sentinel.config.downAfterMilliseconds` | Number of milliseconds the master should be unreachable in order to consider it in S_DOWN state (Subjectively Down) (default 10000) | 10000 |
| `sentinel.config.failoverTimeout` | Specifies the failover timeout in milliseconds (default 180000) | 180000 |
| `sentinel.config.parallelSyncs` | How many replicas we can reconfigure to point to the new replica simultaneously during the failover (default 5) | 5 |
| `redis.port` | Redis port number (default 6379) | 6379 |
| `redis.masterGroupName` | Identifies a group of instances, composed of a master and a variable number of slaves (default mymaster) | mymaster |
| `redis.config.maxMemory` | Set a memory usage limit to the specified amount of bytes (default 0) | 0 |
| `redis.config.maxMemoryPolicy` | how Redis will select what to remove when maxmemory is reached (default volatile-lru) | volatile-lru |
| `redis.config.minSlavesMaxLag` | If there are at least N slaves, with a lag less than M seconds, then the write will be accepted (default 5) | 5 |
| `redis.config.minSlavesToWrite` | If there are at least N slaves, with a lag less than M seconds, then the write will be accepted (default 1) | 1 |
| `redis.config.rdbChecksum` | Since version 5 of RDB a CRC64 checksum is placed at the end of the file (default yes) | yes |
| `redis.config.rdbCompression` | Compress string objects using LZF when dump .rdb databases (default yes) | yes |
| `redis.config.replDisklessSync` | Replication SYNC strategy: disk or socket (default yes) | yes |
| `redis.config.save` | Will save the DB if both the given number of seconds and the given number of write operations against the DB occurred (default 900 1) | 900 1 |


Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,


The above command sets the Redis server within  `default` namespace.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,


> **Tip**: You can use the default values.yaml

## Features

- Supports redis version 5.0.5 only with the mentioned image
- Supports Authentication
- Supports High Availability
- Supports Redis Cache Mode
- Supports Configuration Parameters to be passed while installing
- Supports to restore data from rdb file

## Limitations

- No SSL support as Redis does not support SSL

## Resources Required

By Default the chart deploys pods consuming minimum resources as specified in the resources configuration parameter (default: Memory: 200Mi, CPU: 100m)
If using `envrionmentSize` settings refer to the table below:

| Size     | Memory       | CPU      | Replication  |
| -------- | ------------ | -------- | ------------ |
| Size 0   | 200Mi        | 50m      | 1            |
| Size 1   | 350Mi        | 200m     | 3            |

## Known Issues

None

## PodSecurityPolicy Requirements

The predefined PodSecurityPolicy name [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart. If your target namespace is bound to this PodSecurityPolicy, you can proceed to install the chart.

This chart also defines a custom PodSecurityPolicy which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom PodSecurityPolicy using the user interface or the supplied instructions/scripts in the pak_extension pre-install directory.

- From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy
  - Custom PodSecurityPolicy definition:

    ```yaml
    apiVersion: extensions/v1beta1
    kind: PodSecurityPolicy
    metadata:
      name: ibm-redis-psp
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

  - Custom ClusterRole for the custom PodSecurityPolicy:

    ```yaml
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: ibm-redis-psp
    rules:
    - apiGroups:
      - extensions
      resourceNames:
      - ibm-chart-dev-psp
      resources:
      - podsecuritypolicies
      verbs:
      - use
    ```

## Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a `SecurityContextConstraints` to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined `SecurityContextConstraints` name: [`ibm-restricted-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this `SecurityContextConstraints` resource you can proceed to install the chart.

### Creating the required resources

This chart defines a custom `SecurityContextConstraints` which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom `SecurityContextConstraints` resource using the supplied instructions or scripts in the `ibm_cloud_pak/pak_extensions/prereqs` directory.

* From the user interface, you can copy and paste the following snippets to enable the custom `SecurityContextConstraints`
  * Custom SecurityContextConstraints definition:

  ```yaml
  apiVersion: security.openshift.io/v1
  kind: SecurityContextConstraints
  metadata:
    annotations:
      kubernetes.io/description: "This policy is the most restrictive,
        requiring pods to run with a non-root UID, and preventing pods from accessing the host."
      cloudpak.ibm.com/version: "1.0.0"
    name: ibm-restricted-scc
  allowHostDirVolumePlugin: false
  allowHostIPC: false
  allowHostNetwork: false
  allowHostPID: false
  allowHostPorts: false
  allowPrivilegedContainer: false
  allowPrivilegeEscalation: false
  allowedCapabilities: []
  allowedFlexVolumes: []
  allowedUnsafeSysctls: []
  defaultAddCapabilities: []
  defaultPrivilegeEscalation: false
  forbiddenSysctls:
    - "*"
  fsGroup:
    type: MustRunAs
    ranges:
    - max: 65535
      min: 1
  readOnlyRootFilesystem: false
  requiredDropCapabilities:
  - ALL
  runAsUser:
    type: MustRunAsNonRoot
  seccompProfiles:
  - docker/default
  seLinuxContext:
    type: RunAsAny
  supplementalGroups:
    type: MustRunAs
    ranges:
    - max: 65535
      min: 1
  volumes:
  - configMap
  - downwardAPI
  - emptyDir
  - persistentVolumeClaim
  - projected
  - secret
  priority: 11 # default anyuid has priority 10
  ```

* From the command line, you can run the setup scripts included under `ibm_cloud_pak/pak_extensions/prereqs` to create namespace and apply `SecurityContextConstraints` to the namespace
  * `ibm_cloud_pak/pak_extensions/prereqs/createSccAndNamespace.sh --namespace [namespace]`

## Installing the Chart

Clone this repo and execute the below command from the root directory of it.

```shell
helm install .  --name <releasename> --tls
```

or

```shell
helm install ibm-redis-2.0.0.tgz --name <releasename> --tls
```

## Verifying the Chart

- To list the resources created by this chart use the flag
`-l release=<releasename>`

- To list the redis-role of the pods deployed by this chart use the below command

```shell
kubectl get pods -l release=<releasename> -L redis-role
```

- To get the password

```shell
kubectl get secret <releasename>-ibm-redis-authsecret -o "jsonpath={.data['password']}" | base64 --decode
```

- To test connection execute shell in any of the redis containers in the same cluster as the redis deployment

```shell
kubectl exec -it <releasename>-ibm-redis-server-0 bash

$ redis-cli -h <releasename>-ibm-redis.<namespace>.svc -a <password> -p <sentinel-port> sentinel get-master-addr-by-name <mastername>
$ redis-cli -h  <master-ip> -a <password>

> set <key> <value>
> get <key>
```

## Uninstalling the Chart

```shell
helm delete <releasename> --purge --tls
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Backup & Restore

**To Backup:**

dump.rdb is updated periodically, to get the current data in your backup save it before taking backup.
```
$ redis-cli -h  <releasename>-ibm-redis-master-svc -a <password>

> save
```

Simply copy the dump.rdb file from redis master pod and store it in your desired place.

```shell
kubectl cp <namespace>/<podname>:/home/appuser/redis-master-data/dump.rdb local/path/dump.rdb
```

**To Restore:**

Restore data in a new deployment, if not the data available before the restoration process in the deployment will be lost after the restoration process.

1. Need to create a new redis deployment with the following configuration.

- Persistent Volume enabled.
- AOF disabled (set parameter `appendonly no` )

2. Copy the dump file to all of your redis server pods that belongs to that release

```shell
kubectl cp local/path/dump.rdb <namespace>/<podname>:/home/appuser/redis-master-data/dump.rdb
```

3. After copying the dump file to each redis server pods that belongs to that release, Delete all the redis server pods

```shell
kubectl delete pod <podname>
```

4. Wait till all the redis pods are recreated and then connect to redis master service

```shell
$ redis-cli -h  <releasename>-ibm-redis-master-svc -a <password>

> keys *
```

  verify the data is restored

5. Enable AOF

```shell
> config set appendonly yes
> config get appendonly
```
