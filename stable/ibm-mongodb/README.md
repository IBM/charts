# IBM MongoDB Replica Helm Chart

## Introduction

MongoDB is a NoSQL document-oriented database that stores JSON-like documents with dynamic schemes, simplifying the 
integration of data in content-driven applications. Replica Set in MongoDB is a group of MongoDB processes that 
maintain the same data set. Replica sets provide redundancy and high availability.

## Prerequisites
* Kubernetes 1.11 with Beta APIs enabled.

## Resources Required
* PV support on the underlying infrastructure.

## MongoDB Documentation Version in this doc

As MongoDB Documentation may vary from versions. This readme is using the `v3.4` MongoDB Documentation.

## Chart Details

This chart implements a dynamically scalable [MongoDB replica set](https://docs.mongodb.com/v3.4/tutorial/deploy-replica-set/)
using Kubernetes StatefulSets and Init Containers.

## Scaling 

This chart creates a statefulset to deploy mongodb cluster. The no. of replicas in this statefulset can be scaled down or scaled up after installing the chart.

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
  creationTimestamp: 2019-10-14T03:09:11Z
  name: restricted
  resourceVersion: "85"
  selfLink: /apis/security.openshift.io/v1/securitycontextconstraints/restricted
  uid: fed08f16-ee2f-11e9-b929-ac1f6bc4fe1e
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
  name: ibm-mongodb-psp
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
```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ibm-mongodb-psp
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

## Installing the Chart

### On UI

[Deploying Helm charts in the Catalog](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/app_center/create_release.html )

### Via helm CLI

To install the chart with the release name `my-release`:

```console
$ helm install ibm-mongodb-1.6.0.tgz --name my-release --tls
```

## Configuration

The following table lists the configurable parameters of the mongodb chart and their default values.

| Parameter                            | Description                                                                                                                                         | Default                                                       |
| ------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------- |
| `replicas`                           | Number of replicas in the replica set                                                                                                               | `3`                                                           |
| `replicaSetName`                     | The name of the replica set                                                                                                                         | `rs0`                                                         |
| `podDisruptionBudget`                | Pod disruption budget                                                                                                                               | `{}`                                                          |
| `port`                               | MongoDB port                                                                                                                                        | `27017`                                                       |
| `creds.image.repository`             | Repository for pulling the creds container. If not specified defaults to `global.image.repository`.                                                 | `{{ tpl ( .Values.global.image.repository  | toString ) . }}` |
| `creds.image.name`                   | Image name for the creds container                                                                                                                  | `opencontent-icp-cert-gen-1`                                  |
| `creds.image.tag`                    | Image tag for the creds container                                                                                                                   | `1.1.1`                                                       |
| `creds.image.pullPolicy`             | Image pull policy for pulling the creds container. If not specified defaults to `global.image.pullPolicy`.                                          | `{{ tpl ( .Values.global.image.pullPolicy | toString ) . }}`  |
| `config.image.repository`            | Repository for pulling theb copy config container. If not specified defaults to `global.image.repository`.                                          | `{{ tpl ( .Values.global.image.repository  | toString ) . }}` |
| `config.image.name`                  | Image name for the copy config container                                                                                                            | `opencontent-mongodb-config-copy`                             |
| `config.image.tag`                   | Image tag for the copy config container                                                                                                             | `1.1.1`                                                       |
| `config.image.pullPolicy`            | Image pull policy for pulling the copy config container. If not specified defaults to `global.image.pullPolicy`.                                    | `{{ tpl ( .Values.global.image.pullPolicy | toString ) . }}`  |
| `mongodbInstall.image.repository`    | Repository for pulling the install container. If not specified defaults to `global.image.repository`.                                               | `{{ tpl ( .Values.global.image.repository  | toString ) . }}` |
| `mongodbInstall.image.name`          | Image name for the install container                                                                                                                | `opencontent-mongodb-install`                                 |
| `mongodbInstall.image.tag`           | Image tag for the install container                                                                                                                 | `1.1.1`                                                       |
| `mongodbInstall.image.pullPolicy`    | Image pull policy for pulling the install container. If not specified defaults to `global.image.pullPolicy`.                                        | `{{ tpl ( .Values.global.image.pullPolicy | toString ) . }}`  |
| `mongodb.image.repository`           | Repository for pulling the MongoDB container. If not specified defaults to `global.image.repository`.                                               | `{{ tpl ( .Values.global.image.repository  | toString ) . }}` |
| `mongodb.image.name`                 | MongoDB image name                                                                                                                                  | `opencontent-mongodb-3`                                       |
| `mongodb.image.tag`                  | MongoDB image tag                                                                                                                                   | `1.1.2`                                                       |
| `mongodbInstall.image.pullPolicy`    | Image pull policy for pulling the MongoDB container. If not specified defaults to `global.image.pullPolicy`.                                        | `{{ tpl ( .Values.global.image.pullPolicy | toString ) . }}`  |
| `test.image.repository`              | Repository for pulling the Bats Test framework container. If not specified defaults to `global.image.repository`.                                   | `{{ tpl ( .Values.global.image.repository  | toString ) . }}` |
| `test.image.name`                    | Bat Test framework  image name                                                                                                                      | `opencontent-bats`                                            |
| `test.image.tag`                     | Bat Test framework  image tag                                                                                                                       | `1.1.1`                                                       |
| `test.image.pullPolicy`              | Image pull policy for pulling the Bat Test framework container. If not specified defaults to `global.image.pullPolicy`.                             | `{{ tpl ( .Values.global.image.pullPolicy | toString ) . }}`  |
| `metrics.enabled`                    | Enable Prometheus compatible metrics for pods and replicasets                                                                                       | `false`                                                       |
| `metrics.image.repository`           | Repository for pulling the metrics exported container. If not specified defaults to `global.image.repository`.                                      | `{{ tpl ( .Values.global.image.repository  | toString ) . }}` |
| `metrics.image.name`                 | Image name for metrics exporter                                                                                                                     | `opencontent-mongodb-exporter`                                |
| `metrics.image.tag`                  | Image tag for metrics exporter                                                                                                                      | `1.1.1`                                                       |
| `metrics.image.pullPolicy`           | Image pull policy for pulling the metrics exporter container. If not specified defaults to `global.image.pullPolicy`.                               | `{{ tpl ( .Values.global.image.pullPolicy | toString ) . }}`  |
| `metrics.port`                       | Port for metrics exporter                                                                                                                           | `9216`                                                        |
| `metrics.path`                       | URL Path to expose metrics                                                                                                                          | `/metrics`                                                    |
| `metrics.socketTimeout`              | Time to wait for a non-responding socket                                                                                                            | `3s`                                                          |
| `metrics.syncTimeout`                | Time an operation with this session will wait before returning an error                                                                             | `1m`                                                          |
| `metrics.prometheusServiceDiscovery` | Adds annotations for Prometheus ServiceDiscovery                                                                                                    | `true`                                                        |
| `global.image.repository`            | Image registry to be gloablly used in the chart                                                                                                     | `hyc-cp-opencontent-docker-local.artifactory.swg-devops.com`  |
| `global.image.pullSecret`            | Image pull secret to be gloablly used in the chart                                                                                                  | ``                                                            |
| `global.image.pullPolicy`            | Image pull policy to be gloablly used in the chart                                                                                                  | `IfNotPresent`                                                |
| `global.sch.enabled`                 | Specifies if ibm-sch chart is used as required subchart. If set to `false`, the umbrella chart has to provide this dependency                       | `true`                                                        |
| `keep`                               | If `true` helm delete will preserve the mongodb instance running. (pods,secrets, ...). The kuberneter objects will not be managed by helm any more. | `false`                                                       |
| `podAnnotations`                     | Annotations to be added to MongoDB pods                                                                                                             | `{}`                                                          |
| securityContext.mongodb.runAsUser    | The User ID that needs to be run as by all mongodb containers. This applies only when installed on non-openshift clusters.                          |   `999`                                                       |
| securityContext.mongodb.runAsGroup   | The Group ID that needs to be run as by all mongodb containers. This applies only when installed on non-openshift clusters.                         | `998`                                                         |
| securityContext.mongodb.fsGroup      | The FS Group ID that needs to be run as by all mongodb containers. This applies only when installed on non-openshift clusters.                      | `998`                                                         |
| securityContext.creds.runAsUser      | The User ID that needs to be run as by all creds job containers. This applies only when installed on non-openshift clusters.                        | `523`                                                         |
| `resources`                          | Pod resource requests and limits                                                                                                                    | `{}`                                                          |
| `persistentVolume.enabled`           | If `true`, persistent volume claims are created                                                                                                     | `true`                                                        |
| `persistentVolume.storageClass`      | Persistent volume storage class                                                                                                                     | ``                                                            |
| `persistentVolume.accessMode`        | Persistent volume access modes                                                                                                                      | `[ReadWriteOnce]`                                             |
| `persistentVolume.size`              | Persistent volume size                                                                                                                              | `10Gi`                                                        |
| `persistentVolume.annotations`       | Persistent volume annotations                                                                                                                       | `{}`                                                          |
| `auth.enabled`                       | If `true`, keyfile access control is enabled                                                                                                        | `true`                                                        |
| `auth.key`                           | Key for internal authentication                                                                                                                     | `keycontent`                                                  |
| `auth.keySecretName`                 | If set, an existing secret with this name for the key is used                                                                                       | ``                                                            |
| `auth.authSecretName`                | If set, and existing secret with this name is used for the admin user                                                                               | ``                                                            |
| `auth.metrcisSecretName`             | If set, and existing secret with this name is used for the metrics  auth                                                                            | ``                                                            |
| `tls.enabled`                        | Enable MongoDB TLS support including authentication                                                                                                 | `true`                                                        |
| `tls.tlsSecretName`                  | If set, and existing secret with this name is used for TLS                                                                                          | ``                                                            |
| `rbac.create`                        | If `true`, rbac (Role and RoleBinding) is created                                                                                                   | `true`                                                        |
| `serviceAccount.create`              | If `true`, service account is created                                                                                                               | `true`                                                        |
| `serviceAccount.name`                | Name of the service account to use (and create if specified). If empty the default name `{{ .Release.Name }}-ibm-mongodb` is used.                  | ``                                                            |
| `wiredTigerCacheSizeGb`              | With WiredTiger, MongoDB utilizes both the WiredTiger internal cache and the filesystem cache                                                       |  `0.256`                                                      |
| `oplogSizeMB`                        | The maximum size in megabytes for the replication operation log                                                                                     |  `1000`                                                       |
| `serviceAnnotations`                 | Annotations to be added to the service                                                                                                              | `{}`                                                          |
| `configmap`                          | Content of the MongoDB config file                                                                                                                  | See in `values.yaml`                                          |
| `nodeSelector`                       | Node labels for pod assignment                                                                                                                      | `{}`                                                          |
| `affinity`                           | Node/pod affinities. If specified replaces the default affinity to run on any amd64 node.                                                           | `{}`                                                          |
| `affinityMongodb`                    | Node/pod affinities for Mongodb statefulset only. If specified overrides default affinity to run on any amd64 node.                                 | `{}`                                                          |
| `tolerations`                        | List of node taints to tolerate                                                                                                                     | `[]`                                                          |
| `livenessProbe`                      | Liveness probe configuration                                                                                                                        | See below                                                     |
| `readinessProbe`                     | Readiness probe configuration                                                                                                                       | See below                                                     |
| `extraVars`                          | Set environment variables for the main container                                                                                                    | `{}`                                                          |
| `extraLabels`                        | Additional labels to add to resources                                                                                                               | `{}`                                                          |
| `metering`                           | Metering annotations                                                                                                                                | `{}`                                                          |
| `clusterDomain`                      | Cluster domain used by Kubernetes Cluster (the suffix for internal KubeDNS names).                                                                  | `cluster.local`                                               |

*MongoDB config file*

All options that depended on the chart configuration are supplied as command-line arguments to `mongod`. By default, 
the chart creates an empty config file. Entries may be added via  the `configmap` configuration value. 

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```console
$ helm install ibm-mongodb-1.6.0.tgz --name my-release -f your_values.yaml --tls
```

> **Tip**: You can use the default values.yaml

Once you have all 3 nodes in running, you can run the "test.sh" script in this directory, which will insert a key into 
the primary and check the secondaries for output. This script requires that the `$RELEASE_NAME` environment variable 
be set, in order to access the pods.

## TLS, Authentication and Authorization

### Using TLS

#### Server Side Config

To enable full TLS encryption, you may create your own CA by executing:

```console
$ openssl genrsa -out ca.key 2048
$ openssl req -x509 -new -nodes -key ca.key -days 10000 -out ca.crt -subj "/CN=your-domain.com"
```

After that you can base64 encode it and paste it here:

```console
$ cat ca.key | base64 -w0
$ cat ca.crt | base64 -w0
```

Then, modify `tls` section, paste the base64 encoded cert and key into the fields:

```yml
tls:
  enabled: true
  cacert: LSxxxxx==
  cakey: LSxxxx==
```

And in `configmap` section:

```yml
configmap:
  ...
  net:
    ...
    ssl:
      mode: requireSSL
      CAFile: /data/configdb/tls.crt
      PEMKeyFile: /work-dir/mongo.pem
      allowConnectionsWithoutCertificates: true
  ...
```

Note that, [`allowConnectionsWithoutCertificates: true`](https://docs.mongodb.com/v3.4/reference/configuration-options/#net.ssl.allowConnectionsWithoutCertificates) is to allow client connection without present a Client Cert. 
However, the connection is still encrypted.

#### Client Side Configuration

Easy way to connect, using `mongo` client to connect with SSL and without Client Certificate:

```console
mongo databaseName --host kube.dns.mongodb-rs-ssl.default.local --ssl --sslCAFile /path/to/ca.crt
```

Optionally, you can choose to present client certificate by generating your own one:

```console
$ cat >openssl.cnf <<EOL
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = $HOSTNAME1
DNS.1 = $HOSTNAME2
EOL
$ openssl genrsa -out mongo.key 2048
$ openssl req -new -key mongo.key -out mongo.csr -subj "/CN=$HOSTNAME" -config openssl.cnf
$ openssl x509 -req -in mongo.csr \
    -CA $MONGOCACRT -CAkey $MONGOCAKEY -CAcreateserial \
    -out mongo.crt -days 3650 -extensions v3_req -extfile openssl.cnf
$ rm mongo.csr
$ cat mongo.crt mongo.key > mongo.pem
$ rm mongo.key mongo.crt
```

Please ensure that you exchange the `$HOSTNAME` with your actual hostname and the `$HOSTNAME1`, `$HOSTNAME2`, etc. with
alternative hostnames you want to allow access to the MongoDB replicaset. You should now be able to connect to the
mongodb with your `mongo.pem` certificate using TLS:

```console
$ mongo --host kube.dns.mongodb-rs-ssl.default.local --ssl --sslCAFile=ca.crt --sslPEMKeyFile=mongo.pem"
```

> MongoDB Documentation [SSL Config for Client](https://docs.mongodb.com/v3.4/tutorial/configure-ssl-clients/)

### Enable Authentication and Authorization

**If no existing secret is provided, chart will generate its own one with Kube Job.**

Authentication & Authorization can be enabled using `auth` config section with customized `configmap`:

```yml
auth:
  enabled: true
  # existingKeySecret:
  # existingAdminSecret:

...
configmap:
  security:
    keyFile: /data/configdb/key.txt
...
```

Once enabled, keyfile access control is set up and an admin user with [`root privileges`](https://docs.mongodb.com/v3.4/core/security-built-in-roles/#superuser-roles) is created, specific for `admin` database. It can be
used to create additional users with more specific for any other databses[**Authorization** permissions](https://docs.mongodb.com/v3.4/core/authorization/). **Note that, for security reasons, this `root` user cannot be used for access other databases other than `admin`.**The keyfile is used for
authenticate among replica set members, see [here](https://docs.mongodb.com/v3.4/core/security-internal-authentication/#keyfiles) for more details.

Alternatively, existing `Kube Secrets` may be provided. **The secret for the admin user must contain the
keys `user` and `password`, that for the key file must contain `key.txt`.**

## Logging
MongoDB Log will be output to console automatically. You will be able to get is by using:

```console
kubectl logs (-f) mongodb-pod-name
```

You may fine tune the logging levels and format in `configmap` section:

```yml
...

configmap:
  systemLog:
    component:
      replication:
        verbosity: 5
      accessControl:
        verbosity: 5

...
```

> [MongoDB Logging Config](https://docs.mongodb.com/v3.4/reference/log-messages/)

## Prometheus metrics

Enabling the metrics as follows will allow for each replicaset pod to export Prometheus compatible metrics
on server status, individual replicaset information, replication oplogs, and storage engine.

**If no existing secret is provided, chart will generate its own one with Kube Job.**


Alternatively, existing `Kube Secrets` may be provided for metrics auth. **The secret for the metrics must contain the keys `user` and `password`**.

More information on [MongoDB Exporter](https://github.com/percona/mongodb_exporter) metrics available.

### Metrics Dashboard

Import the dashboard JSON under `ibm_cloud_pak/pak_extensions` to Grafana. 

Most of the metrics prefix with `mongodb_mongod`, you can query Prometheus API for all the available metrics too:

```
GET api/v1/series?match[]={__name__ =~"mongodb_mongod.*"}
```

## Backup and Restore

Please refer to [MongoDB Offical Backup and Restore Documentation](https://docs.mongodb.com/v3.4/tutorial/backup-and-restore-tools/)

## Readiness probe
The default values for the readiness probe are:

```yaml
readinessProbe:
  initialDelaySeconds: 5
  timeoutSeconds: 1
  failureThreshold: 3
  periodSeconds: 10
  successThreshold: 1
```

## Liveness probe
The default values for the liveness probe are:

```yaml
livenessProbe:
  initialDelaySeconds: 30
  timeoutSeconds: 5
  failureThreshold: 3
  periodSeconds: 10
  successThreshold: 1
```

## Limitations

Hostpath is not supported

### StatefulSet 

* Details: https://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/
* Caveats: https://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/#limitations

### Persistent Volume with Hostpath and Local Volume

Local Volume are not portable, which mean you will loose data volume if you loose that Kubernetes Node.

To prevent that, you may use GlusterFS or Block storage, portworx, etc. 

### keep 

keep - if set to true, helm delete does not remove the generated resources (the mongodb will continue to run in kubernetes but will not be managedd by the helm.) 

To delete all the resources which were not delete as part for helm delete command, please use the below command. 

```bash
export RELEASENAME=<releasename>; \
kubectl delete secret $RELEASENAME-ibm-mongodb-auth-secret; \
kubectl delete secret $RELEASENAME-ibm-mongodb-tls-secret; \
kubectl delete cm $RELEASENAME-ibm-mongodb-init; \
kubectl delete cm $RELEASENAME-ibm-mongodb-mongod; \
kubectl delete role $RELEASENAME-ibm-mongodb; \
kubectl delete rolebinding $RELEASENAME-ibm-mongodb; \
kubectl delete sa $RELEASENAME-ibm-mongodb; \
kubectl delete svc $RELEASENAME-ibm-mongodb-headless-svc; \
kubectl delete statefulset $RELEASENAME-ibm-mongodb; \
kubectl delete PodDisruptionBudget $RELEASENAME-ibm-mongodb; 
```
