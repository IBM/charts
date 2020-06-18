# ibm-etcd
A helm chart for creating an etcd cluster.

## Introduction
etcd is a distributed key value store that provides a reliable way to store data across a cluster of machines. It’s open-source and available on GitHub. etcd gracefully handles leader elections during network partitions and will tolerate machine failure, including the leader.

## Prerequisites

Kubernetes 1.9.0+
Helm/Tiller 2.9.0+

[Official Hardware Recommendation](https://github.com/etcd-io/etcd/blob/master/Documentation/op-guide/hardware.md)

### PV
If using dynamic provisioning, PVs will automatically be created for your deployment if a StorageClass that exists is inputed in values.yaml, otherwise if the values.yaml field is left blank, the default StorageClass will be used as long as one is selected as default on the kubernetes cluster.
If not using dynamic provisioning, create your desired Persistent Volume with the size specified in GB matching the size in the Persistent Volume Claim (default 1GB)

### SSL
If TLS Encryption is enabled and no TLS secret provided, the chart will generate certs to be used and stored in `/var/etcd/certs`.
If you have existing certificates and want to use them, they must be provided in a kubernetes secret, and the name of the secret be put in `existingTlsSecret` in `values.yaml`.

# Encryption at rest
This chart does not support Encryption at rest by default, in order to have data encrypted at rest the user must set up special encrypted PVs for the chart to use.

### Authentication
If Authentication is enabled and no rootSecret provided, the chart will automatically create the root user with a randomly generated password kept in the kubernetes rootSecret, base64 encoded.
If you want to use custom credentials, you must provide the credentials, base64 encoded, in a kubernetes secret and then provide the name of the secret in `existingRootSecret` in `values.yaml`.

## Resources Required
At least 1GB of persistent storage, minimum 150m CPU and 256MB memory available for resource requests.

## Installing the Chart
This chart can be installed with helm using the following command

```
helm install --name [optional release name] --namespace [optional release namespace] ibm-etcd-x.x.x.tgz --tls
```

### Request Size Limit
etcd supports RPC requests with up to 1MB of data.

### Storage Size Limit
The default storage size limit is 2GB. At the moment this chart does not support configuring this value.

## Chart Details
This chart creates an etcd 3.3.3 cluster by creating pods with the etcd runtime and ensuring that each node (pod) can access each other. Before the pods are created certificates and auth details are created via job and then then mounted to the etcd node pods when they spin up. Access to the etcd cluster is only provided within the kubernetes cluster in which it is deployed.

## Configuration
| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `replicaCount` | Number of etcd nodes | `5` |
| `nameOverride` | Changes the name of created kubernetes objects after the the release name. If empty (the default value) the ibm-wcd-etcd is used | `` |
| `keep` | If true, don't delete the datastore objects during a helm delete | `true` |
| `affinity` | Block to add node affinity configuration | `{}` |
| `affinityEtcd` | Affinities for Etcd stateful set. Overrides the generated affinities if provided | `{}` |
| `antiAffinity.policy`| Policy for anti affinity of the StatefulSet. If **soft** is set, the scheduler tries to create the pods on nodes (with the default topology key) not to co-locate them, but it will not be guaranteed. If **hard**, the scheduler tries to create the pods on nodes not to co-locate them and will not create the pods in case of co-location. If the other value, anti affinity is disabled. | `soft` |
| `antiAffinity.topologyKey` | Key for the node label that the system uses to denote a topology domain. | `kubernetes.io/hostname` |
| `backoffLimit.credGen` | Backoff limit for credGen job | `5` |
| `backoffLimit.enableAuth` | Backoff limit for enable auth job | `5` |
| `activeDeadlineSeconds.credGen` | Active deadline seconds for cred gen job | `300` |
| `activeDeadlineSeconds.enableAuth` | Active deadline seconds for enable auth job | `300` |
| `image.name` | Docker repository | `opencontent-etcd-3` |
| `image.tag` | Docker image tag | `1.0.1` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `certgen.image.name` | Docker repository for the cert generation image | `icp-cert-gen-ubi` |
| `certgen.image.tag` | Docker image tag for cert gen image | `1.0.4` |
| `certgen.image.pullPolicy` | Image pull policy for cert gen image | `IfNotPresent`|
| `resources.requests.cpu` | CPU request | `150m` |
| `resources.requests.memory` | Memory request | `256Mi` |
| `resources.limits.cpu` | CPU limit | `150m` |
| `resources.limits.memory` | Memory limit | `256Mi` |
| `maxEtcdThreads` | Maximum Number of Threads Etcd Can Use | `12` |
| `autoCompaction.retention` | Auto compaction retention for mvcc key value store in hour. 0 means disable auto compaction. | `0` |
| `autoCompaction.mode` | Interpret 'auto-compaction-retention' one of: 'periodic', 'revision'. 'periodic' for duration based retention, defaulting to hours if no time unit is provided (e.g. '5m'). 'revision' for revision number based retention. | `periodic` |
| `auth.enabled` | Enable Authentication | `true` |
| `auth.existingRootSecret` | Name of an existing kubernetes secret containing auth information | `` |
| `rbac.create` | Specifies if RBAC resources should be created  | `true`                                                       |
| `serviceAccount.create` | If `true`, service account is created                                     | `true`                                              |
| `serviceAccount.name` | Name of the service account to use (and create if specified). If empty the default name `{{ .Release.Name }}-ibm-etcd` is used. | `` |
| `persistence.enabled` | Enables use of Persistent Volumes | `true` |
| `persistence.useDynamicProvisioning` | Enables dynamic binding of Persistent Volume Claims to Persistent Volumes | `true` |
| `dataPVC.name` | Prefix that gets the created Persistent Volume Claims | `data` |
| `dataPVC.accessMode` | Access Mode for the Persistent Volume | `ReadWriteOnce` |
| `dataPVC.size` | Size of the Persistent Volume Claim | `1Gi` |
| `dataPVC.storageClassName` | In case the persistence is enabled. The StorageClass for created persistent volumes claims that holds etcd data. If empty value is used, the default StorageClass will be used. | `` |
| `dataPVC.selector.label` | In case the persistence is enabled and useDynamicProvisioning is disabled the labels can be used to automatically bound persistent volumes claims to precreated persistent volumes. The persistent volumes to be used must have the specified label. Disabled if label is empty. | `` |
| `dataPVC.selector.value` | In case the persistence is enabled and useDynamicProvisioning is disabled the labels can be used to automatically bound persistent volumes claims to precreated persistent volumes. The persistent volumes to be used must have label with the specified value. | `` |
| `tls.enabled` | Enables TLS Encryption | `true` |
| `tls.existingTlsSecret` | Name of an existing kubernetes secret containing tls information | `` |
| `readinessProbe.initialDelaySeconds` | Number of seconds after the container has started before the probe is initiated | `5` |
| `readinessProbe.timeoutSeconds` | Number of seconds after which the probe times out | `1` |
| `readinessProbe.failureThreshold` | Number of failures to accept before giving up and marking the pod as Unready | `5` |
| `readinessProbe.periodSeconds` | How often (in seconds) to perform the probe | `10` |
| `readinessProbe.successThreshold` | Minimum consecutive successes for the probe to be considered successful after having failed | `1` |
| `livenessProbe.initialDelaySeconds` | Number of seconds after the container has started before the probe is initiated | `3` |
| `livenessProbe.timeoutSeconds` | Number of seconds after which the probe times out | `5` |
| `livenessProbe.failureThreshold` | Number of failures to accept before giving up and marking the pod as Unready | `5` |
| `livenessProbe.periodSeconds` | How often (in seconds) to perform the probe | `10` |
| `livenessProbe.successThreshold` | Minimum consecutive successes for the probe to be considered successful after having failed | `1` |
| `metering` | Permits to specify custom metering annotations for etcd pods | `{}` |
| `topologySpreadConstraints.enabled` | Specifies whether the topology spread contraints should be added to etcd statefulset | `false` |
| `topologySpreadConstraints.maxSkew`  | How much the availability zones can differ in number of etcd pods. | `1` |
| `topologySpreadConstraints.topologyKey`  | Label of nodes defining availability/failure zone  | `failure-domain.beta.kubernetes.io/zone` |
| `topologySpreadConstraints.whenUnsatisfiable` | Action in case new pod cannot be scheduled because of topology contraints. | `ScheduleAnyway` |

## PodSecurityPolicy Requirements

The predefined PodSecurityPolicy name [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart. If your target namespace is bound to this PodSecurityPolicy, you can proceed to install the chart.

Custom PodSecurityPolicy definition:
```

apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  annotations:
    kubernetes.io/description: "This policy is the most restrictive,
      requiring pods to run with a non-root UID, and preventing pods from accessing the host."
    #apparmor.security.beta.kubernetes.io/allowedProfileNames: runtime/default
    #apparmor.security.beta.kubernetes.io/defaultProfileName: runtime/default
    seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
    seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
  name: ibm-restricted-psp-etcd
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

## Red Hat OpenShift SecurityContextConstraints Requirements

This chart is supported on Red Hat OpenShift. The predefined SecurityContextConstraint name [`restricted`](https://ibm.biz/cpkspec-scc) has been verified for this chart.

Custom SecurityContextConstraints definition:
```
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: "This policy is the most restrictive,
      requiring pods to run with a non-root UID, and preventing pods from accessing the host."
    cloudpak.ibm.com/version: "1.0.0"
  name: ibm-restricted-scc-etcd
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
priority: 0
```

## Connecting to ETCD
The service type for this chart is ClusterIP, meaning ETCD will only be available from inside the cluster.

To test connection exec into another pod in the cluster and test with the ETCDCTL command line tool.

```
etcdctl --endpoints=https://[service name].[namespace].svc.cluster.local:2379 --cacert=/var/etcd/certs/server.cacrt --user=[user]:[password] member list -w table
```

## Backup and Restore
Please follow the official [etcd documentation regarding backup and restore](https://github.com/etcd-io/etcd/blob/v3.3.3/Documentation/op-guide/recovery.md) practices.

## Limitations

## Cluster Resiliency
ibm-etcd has been tested for basic pod resiliency, if one pod fails it will restart itself and recover, however if an entire node fails the pods on that node will most likely not be able to recover. Etcd needs a minimum of three pods up to maintain quorum, therefore it is recommended that this chart is deployed with a minimum of 5 or 7 replicas.

## Scaling Etcd
ibm-etcd does not support `kubectl scale statefulset` for replicas more than the initial number. However, the etcd cluster can be scaled manually by creating a new pod with the etcd image, and running `etcdctl member add [name of new pod] --peer-urls=[http://[pod-0]-ibm-etcd.default.cluster.local:2380,...]` inside the pod. However, the statefulset can be scaled down with `kubectl scale statefulset`. Please note that you should not scale down to below three pods, as this will cause etcd to lose quorum and become unhealthy, and that etcd should always maintain an odd number of replicas.
