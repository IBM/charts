# ibm-postgresql
## Introduction

The purpose of this helm chart is to deploy a highly available postgresql cluster with TLS. This helm chart deploys postgres server pods, sentinel pods and proxy pods for which the number of replicas can be passed as a parameter. Sentinels are used to decide which postgres pod is the master and point them to proxy. The suggested number of replicas for Sentinel is 3 (odd number).

## Prerequisites
* Kubernetes 1.11.0
* helm version 2.9.0
* PV support on the underlying infrastructure

## Resources Required

* Memory: 2Gi
* CPU: 1 Core

## Red Hat OpenShift SecurityContextConstraints Requirements
The predefined SCC name [`restricted`](https://ibm.biz/cpkspec-scc) has been verified for this chart. If your target namespace is bound to this SCC, you can proceed to install the chart.

Custom SecurityContextConstraints definition:

```yaml
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegeEscalation: true
allowPrivilegedContainer: false
allowedCapabilities: null
apiVersion: security.openshift.io/v1
defaultAddCapabilities: null
fsGroup:
  type: MustRunAs
groups:
- system:authenticated
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: restricted denies access to all host features and requires
      pods to be run with a UID, and SELinux context that are allocated to the namespace.  This
      is the most restrictive SCC and it is used by default for authenticated users.
  name: restricted
priority: null
readOnlyRootFilesystem: false
requiredDropCapabilities:
- KILL
- MKNOD
- SETUID
- SETGID
runAsUser:
  type: MustRunAsRange
seLinuxContext:
  type: MustRunAs
supplementalGroups:
  type: RunAsAny
users: []
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
```

## PodSecurityPolicy Requirements

The predefined PodSecurityPolicy name [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart. If your target namespace is bound to this PodSecurityPolicy, you can proceed to install the chart.

This chart also defines a custom PodSecurityPolicy which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom PodSecurityPolicy using the user interface or the supplied instructions/scripts in the pak_extension pre-install directory.

From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy
Custom PodSecurityPolicy definition:
```yml
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  name: ibm-postgresql-psp
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
Custom ClusterRole for the custom PodSecurityPolicy:
```yml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ibm-postgresql-psp
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

## StatefulSet Details
* https://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/

## StatefulSet Caveats
* https://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/#limitations

## Stolon Chart Known Issue

When the persistent volume type hostpath or local volume is used, if the slave keeper pod goes down, it keeps crashing. When the master pod goes down, another slave pod is elected as master and the old master pod becomes slave. 

## Chart Details
This is chart taken from stolon repo.

- [sorintlab/stolon](https://github.com/sorintlab/stolon)
- [lwolf/stolon-chart](https://github.com/lwolf/stolon-chart)

## Chart dependencies
* etcd from http://storage.googleapis.com/kubernetes-charts-incubator

## Limitations
* HostPath and glusterfs type Persistent Volumes are not supported. 

## Configuration

The following tables lists the configurable parameters of the helm chart and their default values.

| Parameter                               | Description                                    | Default                                                      |
| --------------------------------------- | ---------------------------------------------- | ------------------------------------------------------------ |
| `postgres.image.name`          | postgres image name                     | `opencontent-postgres-stolon` |
| `postgres.image.tag`      | postgres image tag                             | `1.1.1`|
| `creds.image.name`      | creds gen image name                      | `opencontent-icp-cert-gen-1` |
| `creds.image.tag`        | creds gen image tag                             | `1.1.1`|
| `global.image.repository`  | Image pull repository to be used globally inside the chart | `` |
| `global.image.pullSecret`                              | Image pull secret to be used globally inside the chart                             | ``|
| `global.image.pullPolicy`                              | Image pull policy to be used globally inside the chart                             | `IfNotPresent`|
| `global.sch.enabled`                              | to include sch sub chart                           | `true`|
| `max_connections`                       | `connection limit`                             | `100`                                                        |
| `clusterName`                           | Name of the cluster                            | `<releasename>-<chartname>`                                  |
| `debug`                                 | Debug mode                                     | `false`                                                      |
| `store.backend`                         | Store backend to use (etcd/consul/kubernetes)  | `kubernetes`  |
| `store.endpoints`                       | Store backend endpoints                        | ``   |
| `store.kubeResourceKind`                | Kubernetes resource kind (only for kubernetes) | `configmap`                                                  |
| `auth.pgReplUsername`                   | Repl username                                  | `repluser`                                                   |
| `auth.pgSuperuserName`                  | Postgres Superuser name                        | `stolon`                                                     |
| `auth.authSecretName`                   | Name of the secret with password for repluser (`pg_repl_password`) and superuser (`pg_su_password`) password. If empty, the secret (by default named `{{ .Release.Name }}-ibm-postgresql-authsecret`) with randomly generated passwords is automaticaly generated.    | ``                                         |
| securityContext.postgres.runAsUser  | The User ID that needs to be run as by all postgres containers. This applies only when installed on non-openshift clusters.  |   `1000` |
| securityContext.postgres.runAsGroup   | The Group ID that needs to be run as by all postgres containers. This applies only when installed on non-openshift clusters. | `3000` |
| securityContext.postgres.fsGroup  | The FS Group ID that needs to be run as by all postgres containers. This applies only when installed on non-openshift clusters.  | `2000` |
| securityContext.creds.runAsUser  | The User ID that needs to be run as by all creds job containers. This applies only when installed on non-openshift clusters. | `523` |
| `rbac.create`                           | Specifies if RBAC resources should be created  | `true`                                                       |
| `serviceAccount.create`                 | If `true`, service account is created                                     | `true`                                              |
| `serviceAccount.name`                   | Name of the service account to use (and create if specified). If empty the default name `{{ .Release.Name }}-ibm-postgresql` is used. | `` |
| `tls.enabled` | Enabled TLS security on communications ports |  true |
| `tls.tlsSecretName` | Existing tls secret name |  generated by the chart|
| `keep`                                  | If `true` helm delete will preserve the postgres instance running. (pods,secrets, ...). The kuberneter objects will not be managed by helm any more. | `false` |
| `sentinel.replicas`                     | Number of sentinel nodes                       | `3`                                                          |
| `sentinel.resources`                    | Sentinel resource requests/limit               | Memory: `256Mi`, CPU: `100m`                                 |
| `sentinel.affinity`                     | Affinity settings for sentinel pod assignment  | `{}`                                                         |
| `sentinel.nodeSelector`                 | Node labels for sentinel pod assignment        | `{}`                                                         |
| `sentinel.tolerations`                  | Toleration labels for sentinel pod assignment  | `[]`                                                         |
| `proxy.replicas`                        | Number of proxy nodes                          | `2`                                                          |
| `proxy.resources`                       | Proxy resource requests/limit                  | Memory: `256Mi`, CPU: `100m`                                 |
| `proxy.affinity`                        | Affinity settings for proxy pod assignment     | `{}`                                                         |
| `proxy.nodeSelector`                    | Node labels for proxy pod assignment           | `{}`                                                         |
| `proxy.tolerations`                     | Toleration labels for proxy pod assignment     | `[]`                                                         |
| `keeper.replicas`                       | Number of keeper nodes                         | `3`                                                          |
| `keeper.resources`                      | Keeper resource requests/limit                 | Memory: `256Mi`, CPU: `100m`                                 |
| `keeper.affinity`                       | Affinity settings for keeper pod assignment    | `{}`                                                         |
| `keeper.nodeSelector`                   | Node labels for keeper pod assignment          | `{}`                                                         |
| `keeper.tolerations`                    | Toleration labels for keeper pod assignment    | `[]`                                                         |
| `persistence.enabled`                   | Use a PVC to persist data                      | `false`                                                      |
| `persistence.useDynamicProvisioning`    | Enables dynamic binding of Persistent Volume Claims to Persistent Volumes | `true` |
| `persistence.storageClassName`          | Storage class name of backing PVC              | `local-storage`                                              |
| `persistence.accessMode`                | Use volume as ReadOnly or ReadWrite            | `ReadWriteOnce`                                              |
| `persistence.size`                      | Size of data volume                            | `10Gi`                                                       |
| `dataPVC.name`                          | Prefix that gets the created Persistent Volume Claims | `stolon-data`                                                |
| `dataPVC.selector.label`                | In case the persistence is enabled and useDynamicProvisioning is disabled the labels can be used to automatically bound persistent volumes claims to precreated persistent volumes. The persistent volumes to be used must have the specified label. Disabled if label is empty. | ``|
| `dataPVC.selector.value`                | In case the persistence is enabled and useDynamicProvisioning is disabled the labels can be used to automatically bound persistent volumes claims to precreated persistent volumes. The persistent volumes to be used must have label with the specified value.                  | ``|
| `metering`                              | Metering annotations                           | `{}`                                                         |

## Installing the Chart
Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name <releasename> -f values.yaml .
```
## Verifying the Chart

To list the services created by this helm chart
```
kubectl get service -l release=<releasename>
```

To list the pods created by this helm chart

```
kubectl get pods -l release=<releasename>
```

Execute bash in any of the postgres-keeper pods and execute the below command to test the connection:
```
kubectl exec -it <postgres-keeper-podname> bash

psql "host=<proxy-service> user=stolon dbname=postgres"
```

To get password

`kubectl get secret \<releasename\>-ibm-postgresql-auth-secret  -o json | jq -r .data.pg_su_password | base64 -D `

## Persistent Volume

You can create a persistent volume through a yaml file. For example:

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: <persistent volume name>
spec:
  capacity:
    storage: 8Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: standard
  hostPath:
    path: /tmp
```

## TLS

- This charts supports deploying postgressql with TLS encryption. 
- By Default the TLS encryption is enabled, please make sure tls.enabled is set true to enable it. 
- By Default the cert files are generated by the chart, cert files can also be provided by passing the content as mentioned below in the values.yaml file. 
- Does not support Client Authentication. 

```
tls:
  enabled: true
  tlsSecretName: ""
```
  
## Backup & Restore

pg_dumpall command can be executed from the postgresql keeper pod iteself, or if you have the pg_dumpall command in your local, you can port-forward the svc to local and then execute it from your local.

**pg_dumpall method**

```
pg_dumpall -h <host> -U <super user> > <dump filename>

kubectl cp <namespace>/< source pod name>:/path/to/dump  </local/path>

kubectl cp <local/path/to/dump>  <namespace>/<destination pod name>:/path/to/dump

psql -h <host> -U <super user> -f <dump filename> postgres (dbname)
```

It is not important to which database you connect here since the script file created by pg_dumpall will contain the appropriate commands to create and connect to the saved databases.

## Monitoring 

- The monitoring dashboard template is available in additionalFiles directory. 
- Replace the string `HELMRELEASE` with your helm release name.
- Import the json file in grafana to view the dashboard. 

## Logging 

Logs are sent to STDERR. Logs can be viewed in kibana dashboard. 

