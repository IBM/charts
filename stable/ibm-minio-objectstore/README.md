# Minio

## Introduction

[Minio](https://minio.io) is a high-performance distributed Object Storage server, which is designed for large-scale private cloud infrastructure. Minio aggregates persistent volumes (PVs) into scalable distributed Object Storage, by using Amazon S3 REST APIs. You can manage Minio configuration and credentials by using Kubernetes ConfigMaps and Secrets, when Minio is deployed by using a Helm Chart.

Minio supports [distributed mode](https://docs.minio.io/docs/distributed-minio-quickstart-guide). In distributed mode, you can pool multiple drives (even on different systems) into a single Object Storage server.

## Chart details

The `ibm-minio-objectstore`  chart bootstraps a Minio deployment on a [Kubernetes](http://kubernetes.io) cluster by using the [Helm](https://helm.sh) package manager.


## Limitations
- Minio is supported only on Linux® 64-bit cluster. Currently, it is not supported on IBM® Z clusters.

## Prerequisites

- Kubernetes 1.10+ with Beta APIs that are enabled for default stand-alone mode.
- Kubernetes 1.10+ with Beta APIs that are enabled to run Minio in a distributed mode.
- A supported PV provisioner in the underlying infrastructure.
- A Secret object that contains access and secret keys in base64 encoded form. For more information, see *Access and secret keys secret* section.
- Dynamic volume provisioning by using storage class is required when you use Minio in a distributed mode.

## PodSecurityPolicy Requirements
The `ibm-minio-objectstore` chart requires a pod security policy to be bound to the target namespace before installation.
You may either choose the predefined pod security policy or create your own pod security policy.

* For IBM Cloud Private Version 3.1, the predefined pod security policy name is `privileged`.
* for IBM Cloud Private Version 3.1.1, the predefined pod security policy name is `ibm-anyuid-psp`.

If you wish to create your own pod security policy, use the following definition:

```
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  name: minio-psp
spec:
  allowPrivilegeEscalation: true
  allowedCapabilities:
  - SETPCAP
  - AUDIT_WRITE
  - CHOWN
  - NET_RAW
  - DAC_OVERRIDE
  - FOWNER
  - FSETID
  - KILL
  - SETUID
  - SETGID
  - NET_BIND_SERVICE
  - SYS_CHROOT
  - SETFCAP
  forbiddenSysctls:
  - '*'
  fsGroup:
    rule: RunAsAny
  requiredDropCapabilities:
  - MKNOD
  runAsUser:
    rule: RunAsAny
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  volumes:
  - configMap
  - emptyDir
  - projected
  - secret
  - downwardAPI
  - persistentVolumeClaim
```

## Resources required

The minio containers have the following resource requests and limits:

| Container                  | Memory Request        | Memory Limit          | CPU Request           | CPU Limit             |
| -----------------------    | ------------------    | ------------------    | ------------------    | ------------------    |
| minio                      | 256Mi                 | 512Mi                 | 250m                  | 500m                  |


## Installing the chart

To install by using the Helm command line, add the Helm repository:

```
# The following command lists the repositories
helm repo list

# Add the helm repository
helm repo add ibm-charts https://raw.githubusercontent.com/IBM/charts/master/repo/stable/

# The following command shows all the charts that are related to the repository
helm search ibm-charts

# If you do not see the updated chart list, update information of available charts locally from the chart repositories:

helm repo update

```

### Creating access secret

The `ibm-minio-objectstore` chart uses pre-created Kubernetes secret object that contains the access and secret keys. You need to create the secret and specify the name of secret while you deploy this chart. The secret must contain accesskey (5 - 20 characters) and secretkey (8 - 40 characters) in  base64 encoding.


Encode accesskey and secretkey in base64 encoding:

```
echo -n "admin" | base64
YWRtaW4=

echo -n "admin1234" | base64
YWRtaW4xMjM0
```

Create the following secret object:

```
apiVersion: v1
kind: Secret
metadata:
  name: minio
  namespace: <namespace>
type: Opaque
data:
  accesskey: YWRtaW4=
  secretkey: YWRtaW4xMjM0

kubectl create -f secrets.yaml
```


Install the Helm chart by running the following command:

```
helm install --set minioAccessSecret=<access secret name> ibm-charts/ibm-minio-objectstore --tls
```

The command deploys a Minio Object Store server on your Kubernetes cluster by using the default configuration. The configuration parameters section lists the parameters that can be configured during installation.

You can also set your preferred name by running the following command:

```
helm install --name <my-release-name> --set minioAccessSecret=<access secret name> ibm-charts/ibm-minio-objectstore --tls
```

**NOTE:** If you configure Minio server with a TLS certificate that you generated, make sure that the CN used is in the following format:

```
"/CN=*.<my-release-name>-ibm-minio-objectstore.<namespace>.svc.<cluster domain>"
```
When you install the chart, you must use the same release name that you used to generate the certificate. For more information, see *TLS configuration*.

### Updating Minio configuration by using Helm

[Configmap](https://kubernetes.io/docs/user-guide/configmap/) allows injecting containers with configuration data even while a Helm release is being deployed.

To update your Minio server configuration while it is being deployed in a release, complete these tasks:

1. Check all the configurable values in the Minio chart by using the `helm inspect values ibm-charts/ibm-minio-objectstore` command.
2. Override the `minio_server_config` settings in a YAML formatted file, and then pass that file by using the `helm upgrade -f <YAML-formatted-file-name>.yaml ibm-charts/ibm-minio-objectstore` command.
3. Restart the Minio server(s) for the changes to take effect.

You can also check the history of upgrades to a release by using the following command:

```
helm history <my-release-name>
```

## Uninstalling the chart

To uninstall, delete the Helm release by running the following command:

```
helm delete --purge <my-release-name> --tls
```

The command removes all the Kubernetes components that are associated with the chart and deletes the release.

## Configuration


The following table lists the configurable parameters and their default values.

| Parameter                  | Description                         | Default                                                 |
|----------------------------|-------------------------------------|---------------------------------------------------------|
| `arch.amd64`               | amd64 scheduling preference         | `2 - No preference`                                     |
| `arch.ppc64le`             | ppc64le scheduling preference       | `2 - No preference`                                     |
| `arch.s390x`               | s390x scheduling preference         | `0 - Do not use`                                        |
| `image.repository`         | Image repository                    | `ibmcom/minio`                                          |
| `image.tag`                | Minio image tag. Possible values listed [here](https://hub.docker.com/r/ibmcom/minio).| `RELEASE.2018-08-21T00-37-20Z`|
| `image.pullPolicy`         | Image pull policy                   | `IfNotPresent`                                          |
| `mcImage.repository`       | Client image repository             | `ibmcom/minio-mc`                                       |
| `mcImage.tag`              | mc image tag. Possible values listed [here](https://hub.docker.com/r/ibmcom/minio-mc).| `RELEASE.2018-07-13T00-53-22Z`|
| `mcImage.pullPolicy`       | mc image pull policy                | `IfNotPresent`                                          |
| `ingress.enabled`          | Enables ingress                     | `false`                                                 |
| `ingress.annotations`      | Ingress annotations. For example, {kubernetes.io/ingress.class: nginx, kubernetes.io/tls-acme: "true"}                 | `nil`                                                    |
| `ingress.hosts`            | Host names accepted by ingress. For example, ["chart-example1.local", "chart-example2.local"]          | `nil`                                                    |
| `ingress.tls`              | Ingress TLS configuration. For example, [{"secretName": "chart-example-tls", "hosts": ["chart-example.local", "chart-example.local"]}]           | `nil`                                                    |
| `mode`                     | Minio server mode. Valid options are `standalone` or `distributed`.| `standalone`                               |
| `replicas`                 | Number of nodes (applicable only to Minio distributed mode). Must be 4 <= x <= 32 | `4`    |
| `minioAccessSecret`       | Create a secret that contains base64-encoded accesskey (5 - 20 characters) and secretkey (8 - 40 characters). The keys are used to access Minio Object Server. You need to create the secret in the same namespace where you are deploying the chart. | `nil`                              |
| `configPath`               | Location of the default configuration file     | `/root/.minio`                                    |
| `mountPath`                | Default mount path for the persistent drive| `/export`                                        |
| `service.type`             | Kubernetes service type. Allowed values are `NodePort`, `ClusterIP` or `LoadBalancer` | `ClusterIP`    |
| `service.clusterIP`        | Kubernetes service ClusterIP. Specify if service type is ClusterIP and you want to choose your own Cluster IP. | `None` |
| `service.loadBalancerIP`   | Kubernetes service loadBalancerIP. Specify if service type is LoadBalancer and you want to choose your own Load Balancer IP. | `None` |
| `service.port`             | Kubernetes port on which the service is exposed| `9000`                                              |
| `service.nodePort`         | Exposes the service on IP address of the node at a static port when service type is `NodePort`  | `31311`                    |
| `service.externalIPs`      | External IP addresses of the service| `nil`                                                         |
| `service.prometheusEnable` | Enable Prometheus scrape         | `false` |
| `service.prometheusPath`   | Metrics path                        | `/minio/prometheus/metrics` |
| `service.prometheusPort`   | Port for metrics scrapping          | `9000` |
| `persistence.enabled`      | Use persistent volume to store data | `true`                                                  |
| `persistence.size`         | Size of persistent volume claim (PVC)    | `10Gi`                                                  |
| `persistence.existingClaim`| Use an existing PVC to persist data | `nil`                                                   |
| `persistence.useDynamicProvisioning`| If enabled, the PVC will use a storageClassName to bind the volume | `false`|
| `persistence.storageClass` | Storage Class to bind PVC. You must specify a valid storage class if you have selected useDynamicProvisioning.     | `None`                                               |
| `persistence.accessMode`   | ReadWriteOnce or ReadOnly           | `ReadWriteOnce`                                         |
| `persistence.subPath`      | Mount a sub directory of the persistent volume, if a sub directory is set | `""`                                  |
| `resources`                | CPU/Memory resource requests/limits | Memory: `256Mi`, CPU: `100m`                            |
| `priorityClassName`        | Pod priority settings. ICP system-cluster-critical priority class is available only for kube-system namespace. | `""` |
| `tls.enabled`              | Enable Minio server with TLS certificates | `false` |
| `tls.type`                 | Specify whether a chart must autogenerate a self-signed TLS certificate or use the one that you provide. If you are providing the certificate, you must create a secret that contains a private key, TLS certificate, and a certificate authority (CA) certificate. You provide the secret name in the `tls.minioTlsSecret` parameter. For details, see TLS configuration section. | `selfsigned` |
| `tls.minioTlsSecret`      | Secret that you create and contains a private key (key private.key), TLS certificate (key public.crt), and a CA certificate (key ca.crt) to configure the Minio server with TLS certificates. You must create and specify the secret in the same namespace where you are deploying the chart. | `nil` |
| `tls.clusterDomain`        | Cluster domain name that is used to generate a self-signed certificate. Specify your cluster domain name here. This parameter is applicable when `tls.type` is set as `selfsigned` | `cluster.local` |
| `nodeSelector`             | Node labels for pod assignment. For example, `{"key":"value"}`.      | `nil`   |
| `tolerations`              | Toleration labels for pod assignment. For example, `[{"key": "key", "operator":"Equal", "value": "value", "effect":"NoSchedule"}] `.| `nil`                                                   |
| `defaultBucket.enabled`    | If set to true, a bucket is created after Minio installation is complete. | `false`                        |
| `defaultBucket.name`       | Bucket name                         | `bucket`                                                |
| `defaultBucket.policy`     | Bucket policy. Allowed values are `none`, `download`, `upload`, `public`    | `none` |
| `defaultBucket.purge`      | Purge the bucket, if exists.  | `false`                                                 |
| `azuregateway.enabled`     | Use Minio server as an [Azure gateway](https://docs.minio.io/docs/minio-gateway-for-azure)| `false`  |
| `gcsgateway.enabled`       | Use Minio server as a [Google Cloud Storage gateway](https://docs.minio.io/docs/minio-gateway-for-gcs)| `false` |
| `gcsgateway.gcsKeyJson`    | Credential JSON file of the service account key | `""` |
| `gcsgateway.projectId`     | Google cloud project ID             | `""` |
| `nasgateway.enabled`       | Use Minio server as a [NAS gateway](https://docs.minio.io/docs/minio-gateway-for-nas)             | `false` |
| `nasgateway.replicas`      | Number of NAS gateway instances to be run in parallel on a PV            | `4` |
| `nasgateway.pv`            | Generally for NAS Gateway, you'd like to bind the PVC to a specific PV. To ensure that happens, label the PV that you need to bind to. Example label, `\"pv: <value>\"`. | `""` |
| `minioConfig.region`       | Region is the physical location of the server. By default it is set to ``. If you are unsure, leave it unset. | `""` |
| `minioConfig.browser`      | Enable or disable access to web UI. Allowed values are `on` or `off`. | `"on"` |
| `minioConfig.domain`       | Enable virtual-host-style requests | `""`  |
| `minioConfig.worm`         | Enable this parameter to turn on Write-Once-Read-Many. Specify `off` to disable and `on` to enable. | `"off"`  |
| `minioConfig.storageClass.standardStorageClass` | Value for standard storage class. Format is `EC:Parity`. For example, to set four disk parity for standard storage class objects, set this field to EC:4. | `""`  |
| `minioConfig.storageClass.reducedRedundancyStorageClass` | Value for reduced redundancy storage class. Format is `EC:Parity`. For example, to set three disk parity for reduced redundancy storage class objects, set this field to EC:3. | `""`  |
| `minioConfig.cache.drives` | List of mounted file system drives with `atime` support enabled. For example, [/mnt/drive1,/mnt/drive2] | `[]`  |
| `minioConfig.cache.expiry` | Days to cache expiry.| `90`  |
| `minioConfig.cache.maxuse` | Percentage of disk available to cache.| `80`  |
| `minioConfig.cache.exclude` |  List of wildcard patterns for prefixes to exclude from cache.| `[]`  |
| `minioConfig.aqmp.enable` | Whether the server endpoint configuration is active or enabled. | `false`  |
| `minioConfig.aqmp.url` | AMQP server endpoint. For example, amqp://myuser:mypassword@localhost:5672. | `""`  |
| `minioConfig.aqmp.exchange` | Name of the exchange. | `""`  |
| `minioConfig.aqmp.routingKey` | Routing key for publishing. | `""`  |
| `minioConfig.aqmp.exchangeType` |  Kind of exchange. | `""`  |
| `minioConfig.aqmp.deliveryMode` | Delivery mode for publishing. 1 - transient; 2 - persistent. | `1`  |
| `minioConfig.aqmp.mandatory` | Publishing-related bool | `false`  |
| `minioConfig.aqmp.immediate` | Exchange declaration-related bool | `false`  |
| `minioConfig.aqmp.durable` | Exchange declaration-related bool | `false`  |
| `minioConfig.aqmp.internal` | Exchange declaration-related bool| `false`  |
| `minioConfig.aqmp.noWait` | Exchange declaration-related bool| `false`  |
| `minioConfig.aqmp.autoDeleted` | Exchange declaration-related bool | `false`  |
| `minioConfig.nats.enable` | Whether the server endpoint configuration is active or enabled. | `false` |
| `minioConfig.nats.address` | Address. For example, 0.0.0.0:4222.   | `""` |
| `minioConfig.nats.subject` | Subject string. For example, bucketevents.  | `""` |
| `minioConfig.nats.username` | User name  | `""` |
| `minioConfig.nats.password` | Password  | `""` |
| `minioConfig.nats.token"` | Token  | `""` |
| `minioConfig.nats.secure` | Whether NAT is secure or not  | `false` |
| `minioConfig.nats.pingInterval` | Ping interval   | `0` |
| `minioConfig.nats.enableStreaming` |  Enable streaming  | `false` |
| `minioConfig.nats.clusterID` |  Cluster ID  | `""` |
| `minioConfig.nats.clientID` |  Client ID | `""` |
| `minioConfig.nats.async` | Whether async is enabled or not  | `false` |
| `minioConfig.nats.maxPubAcksInflight` |  Maximum number of outstanding acknowledgements. Used for rate limiting. | `0` |
| `minioConfig.elasticsearch` | Whether the server endpoint configuration is active or enabled.   | `false` |
| `minioConfig.elasticsearch.format"` | Allowed values are `namespace` or `access`.  | `namespace` |
| `minioConfig.elasticsearch.url` | The Elasticsearch server's address, with optional authentication information. For example, http://localhost:9200. Or, with authentication information: http://elastic:MagicWord@127.0.0.1:9200.  | `""` |
| `minioConfig.elasticsearch.index` | The name of an Elasticsearch index where Minio stores documents.   | `""` |
| `minioConfig.redis.enable` | Whether the server endpoint configuration is active or enabled.  | `false` |
| `minioConfig.redis.format` | Allowed values are `namespace` or `access`. | `namespace` |
| `minioConfig.redis.address` | The Redis server's address. For example: localhost:6379.  | `""` |
| `minioConfig.redis.password` |  The Redis server's password. | `""` |
| `minioConfig.redis.password` |  The name of the Redis key that is used to store events. A hash is used when the key is in namespace format and a list is used when the key is in access format. | `""` |
| `minioConfig.postgresql.enable` | Whether the server endpoint configuration is active or enabled. | `false` |
| `minioConfig.postgresql.format` | Allowed values are `namespace` or `access`.  | `namespace` |
| `minioConfig.postgresql.connectionString` | Connection string parameters for the PostgreSQL server. For example, it can be used to set sslmode.  | `""` |
| `minioConfig.postgresql.table` | Table name where events are stored or updated. If the table does not exist, the Minio server creates a table at start-up.  | `""` |
| `minioConfig.postgresql.host` | Host name of the PostgreSQL server. Defaults to localhost.` | `""`|
| `minioConfig.postgresql.port` | Port on which to connect to PostgreSQL server. Defaults to 5432.  | `""` |
| `minioConfig.postgresql.user` | Database user name. Defaults to user that runs the server process.  | `""` |
| `minioConfig.postgresql.password` | Database password  | `""` |
| `minioConfig.postgresql.database` | Database name  | `""` |
| `minioConfig.kafka.enable` | Whether the server endpoint configuration is active or enabled.  | `false` |
| `minioConfig.kafka.brokers` | List of brokers. For example, `[\"localhost:9092\"]`.  | `[]` |
| `minioConfig.kafka.topic` | The topic that is used by Kafka.  | `""` |
| `minioConfig.webhook.enable` | Whether the server endpoint configuration is active or enabled.   | `false` |
| `minioConfig.webhook.endpoint` | Endpoint is the server that listens for webhook notifications.  | `""` |
| `minioConfig.mysql.enable` | Whether the server endpoint configuration is active or enabled.  | `false` |
| `minioConfig.mysql.format` | Allowed values are `namespace` or `access`.  | `namespace` |
| `minioConfig.mysql.dsnString` | Data-Source-Name connection string for the MySQL server. If not specified, the connection information that is specified by the host, port, user, password, and database parameters are used.  | `""` |
| `minioConfig.mysql.table` | Table name where events are stored or updated. If the table does not exist, the Minio server creates a table at start-up.  | `""` |
| `minioConfig.mysql.host` | Host name of the MySQL server (used only if dsnString is empty).  | `""` |
| `minioConfig.mysql.port` | Port on which to connect to the MySQL server (used only if dsnString is empty).  | `""` |
| `minioConfig.mysql.user` | Database user name (used only if dsnString is empty).  | `""` |
| `minioConfig.mysql.password` | Database password (used only if dsnString is empty).  | `""` |
| `minioConfig.mysql.database` | Database name (used only if dsnString is empty).  | `""` |
| `minioConfig.mqtt.enable` | Whether the server endpoint configuration is active or enabled.  | `false` |
| `minioConfig.mqtt.broker` | MQTT server endpoint. For example, tcp://localhost:1883.  | `""` |
| `minioConfig.mqtt.topic` | Name of the MQTT topic to publish on. For example, minio.  | `""` |
| `minioConfig.mqtt.qos` | Set the quality of service(QoS) Level.  | `0` |
| `minioConfig.mqtt.clientId` | Unique ID for the MQTT broker to identify Minio.  | `""` |
| `minioConfig.mqtt.username"` |  Username to connect to the MQTT server (if required). | `""` |
| `minioConfig.mqtt.password` | Password to connect to the MQTT server (if required).  | `""` |
| `minioConfig.mqtt.reconnectInterval` | Reconnect interval  | `0` |
| `minioConfig.mqtt.keepAliveInterval` | Keepalive interval  | `0` |
| `networkPolicy.enabled`              | With network policy enabled, traffic is limited to just port 9000. | `false` |
| `networkPolicy.allowExternal`        | For more precise policy, enable networkPolicy.allowExternal. This configuration allows pods with the generated client label to connect to Minio. This label is displayed in the output of a successful installation. | `false` |
Some of the parameters that are listed in the table map to the environment variables that are defined in the [Minio DockerHub image](https://hub.docker.com/r/minio/minio/).

You can specify each parameter by adding the `--set key=value[,key=value]` argument to the `helm install` command. See the following example:

```
helm install --name my-release \
  --set persistence.size=100Gi,minioAccessSecret=<access secret name> \
    ibm-charts/ibm-minio-objectstore --tls
```

The command deploys a Minio server that is backed by a 100Gi persistent volume.

Alternately, you can provide a YAML file with the parameter values while you install the chart. See the following example:

```
helm install --name <release name> -f values.yaml ibm-charts/ibm-minio-objectstore --tls
```

## Distributed Minio


By default, this Helm chart provisions a Minio server in stand-alone mode. To provision a Minio server in [distributed mode](https://docs.minio.io/docs/distributed-minio-quickstart-guide), set the `mode` field to `distributed`.

```
helm install --set mode=distributed,minioAccessSecret=minio ibm-charts/ibm-minio-objectstore --tls
```

This provisions Minio server in distributed mode with four nodes. To change the number of nodes in your distributed Minio server, set the `replicas` field.

```
helm install --set mode=distributed,replicas=8,minioAccessSecret=minio ibm-charts/ibm-minio-objectstore --tls
```

This provisions Minio server in distributed mode with eight nodes. The `replicas` value must be an integer in the range 4 - 16 (inclusive).

### StatefulSet limitations (applicable to distributed Minio)

1. StatefulSets need persistent storage, so the `persistence.enabled` flag is ignored when `mode` is set to `distributed`.
2. For persistent storage, either existing PVC or dynamic provisioning can be used. When dynamic provisioning is enabled, you must specify a valid storage class.
3. When you uninstall a distributed Minio release, you need to manually delete volumes that are associated with the StatefulSet.

For more information, see [limitations](http://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/#limitations).

## NAS gateway


### Prerequisites

Minio in [NAS gateway mode](https://docs.minio.io/docs/minio-gateway-for-nas) can be used to create multiple Minio instances backed by a single PV in `ReadWriteMany` mode. Currently, few [Kubernetes volume plug-ins](https://kubernetes.io/docs/user-guide/persistent-volumes/#access-modes) support `ReadWriteMany` mode. To deploy Minio NAS gateway with a Helm chart, you need a PV running with one of the supported volume plug-ins. [This document](https://kubernetes.io/docs/user-guide/volumes/#nfs) outlines steps to create a PV using NFS which is one of the supported volume plug-ins.

### Provision NAS gateway Minio instances

To provision Minio servers in [NAS gateway mode](https://docs.minio.io/docs/minio-gateway-for-nas), set the `nasgateway.enabled` parameter to `true`.

```
helm install --set nasgateway.enabled=true,minioAccessSecret=minio ibm-charts/ibm-minio-objectstore --tls
```

This command provisions four Minio NAS gateway instances backed by single storage. To change the number of instances in your Minio deployment, set the `replicas` parameter.

```
helm install --set nasgateway.enabled=true,nasgateway.replicas=8,minioAccessSecret=minio ibm-charts/ibm-minio-objectstore --tls
```

This command provisions Minio NAS gateway with eight instances.

## Persistant storage

This chart provisions a PersistentVolumeClaim and mounts a corresponding persistent volume to the default location `/export`. Minio requires preconfigured block storage. This storage can be GlusterFS, Ceph, or any other Kubernetes supported storage provider. The block storage must be available through dynamic volume provisioning by using a storage class.  If you want to use `emptyDir`, disable PersistentVolumeClaim by running the following command:

```
helm install --set persistence.enabled=false,minioAccessSecret=minio ibm-charts/ibm-minio-objectstore --tls
```

> *"An `emptyDir` volume is first created when a Pod is assigned to a Node, and it persists until that pod runs on the node. When a pod is removed from a node for any reason, the data in the `emptyDir` is deleted permanently."*

## Existing PersistentVolumeClaim

If you already have a Persistent Volume Claim, specify it during installation.

1. Create the PersistentVolume
2. Create the PersistentVolumeClaim
3. Install the chart

```
helm install --set persistence.existingClaim=PVC_NAME,minioAccessSecret=minio ibm-charts/ibm-minio-objectstore --tls
```

## NetworkPolicy

To enable network policy for Minio, install a networking plug-in that implements the
[Kubernetes NetworkPolicy spec](https://kubernetes.io/docs/tasks/administer-cluster/declare-network-policy#before-you-begin),
and set `networkPolicy.enabled` to `true`.

With NetworkPolicy enabled, traffic is limited to port 9000.

For a more precise policy, set `networkPolicy.allowExternal=true`. This setting allows only pods with the generated client label to connect to Minio. This label is displayed in the output of a successful installation.

## TLS configuration

Minio server can be configured with TLS certificates. In this Helm chart, TLS certificate can be specified in the following ways:

### Existing certificate

An existing set of private keys and public certificates can be specified by setting the configuration parameter `tls.type: "provided"`.

You need to create a secret with private keys and public certificates and set the `tls.minioTlsSecret` configuration parameter.

Following are ways to create a secret that contains TLS settings:

* If the certificate is signed by a certificate authority (CA), public.crt should be the concatenation of the server's certificate,
any intermediates, and the CA's root certificate.

```
kubectl create secret generic tls-ssl-minio --from-file=./private.key --from-file=./public.crt
```

* If the certificate is self signed,  you must copy `public.crt` to `ca.crt` and create a secret.

```
cp public.crt ca.crt
```

```
kubectl create secret generic tls-ssl-minio --from-file=./private.key --from-file=./public.crt --from-file=./ca.crt
```

**NOTE:** The certificate must be generated with `"/CN=*.<releasename>-ibm-minio-objectstore.<namespace>.svc.<cluster domain>"

That is, use: `"/CN=*.minio-ibm-minio-objectstore.default.svc.cluster.local"` for deploying the Minio chart with name `minio` in `default` namespace
in the Kubernetes cluster domain `cluster.local`.


### Auto-generate self-signed certificate

When you set the configuration parameters as `tls.type: "selfsigned"` and `tls.enabled: true`, the chart generates a self-signed certificate and installs it for the Minio servers. You must also set the `tls.clusterDomain` configuration parameter with the value of your Kubernetes cluster domain name. The chart
uses clusterDomain, namespace, and release name to generate CN for certificate generation.
