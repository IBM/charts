# Minio

## Introduction

[Minio](https://minio.io) is a high-performance distributed Object Storage server, which is designed for large-scale private cloud infrastructure. Minio aggregates persistent volumes (PVs) into scalable distributed Object Storage, by using Amazon S3 REST APIs. You can manage Minio configuration and credentials by using Kubernetes ConfigMaps and Secrets, when Minio is deployed by using a Helm Chart.

Minio supports stand-alone, distributed, and network-attached storage (NAS) Gateway mode. For more information, see [Distributed MinIO Quickstart Guide](https://docs.min.io/docs/distributed-minio-quickstart-guide) and [MinIO NAS Gateway](https://docs.min.io/docs/minio-gateway-for-nas.html). In distributed mode, you can pool multiple drives (even on different systems) into a single Object Storage server.

## Chart Details

The `ibm-minio-objectstore` chart bootstraps a Minio deployment on a [Kubernetes](http://kubernetes.io) cluster by using the [Helm](https://helm.sh) package manager.

## Limitations
- 

## Prerequisites

- Kubernetes 1.10+ with Beta APIs that are enabled for default stand-alone mode.
- Kubernetes 1.10+ with Beta APIs that are enabled to run Minio in a distributed mode.
- A supported PV provisioner in the underlying infrastructure.
- A Secret object that contains access and secret keys in base64 encoded form. For more information, see *Access and secret keys secret* section.
- Dynamic volume provisioning by using storage class is required when you use Minio in a distributed mode.

## PodSecurityPolicy Requirements
The `ibm-minio-objectstore` chart requires a pod security policy to be bound to the target namespace before installation.
You can either choose the predefined pod security policy or create your own pod security policy.

* For IBM Cloud Private Version 3.1, the predefined pod security policy name is [`ibm-privileged-psp`](https://ibm.biz/cpkspec-psp).
* for IBM Cloud Private Version 3.1.1, the predefined pod security policy name is [`ibm-anyuid-psp`](https://ibm.biz/cpkspec-psp).

If you want to create your own pod security policy, use the following definition:

### Custom PodSecurityPolicy definition:
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

## Resources Required

The minio containers have the following resource requests and limits:

| Container                  | Memory Request        | Memory Limit          | CPU Request           | CPU Limit             |
| -----------------------    | ------------------    | ------------------    | ------------------    | ------------------    |
| minio                      | 256Mi                 | 512Mi                 | 250m                  | 500m                  |


## Installing the Chart

To install by using the Helm command-line interface, add the Helm repository:

```
# The following command lists the repositories:
helm repo list

# Add the Helm repository:
helm repo add ibm-charts https://raw.githubusercontent.com/IBM/charts/master/repo/stable/

# The following command shows all the charts that are related to the repository:
helm search ibm-charts

# If you do not see the updated chart list, locally update information of available charts from the chart repositories:
helm repo update
```

### Creating access secret

The `ibm-minio-objectstore` chart uses pre-created Kubernetes secret object that contains the access and secret keys. You need to create the secret and specify the name of secret while you deploy this chart. The secret must contain accesskey (5 - 20 characters) and secretkey (8 - 40 characters) in base64 encoding.


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

**NOTE:** If you configure Minio server with a TLS certificate that you generated, make sure that the common name (CN) that you use is in the following format:

```
"/CN=*.<my-release-name>-ibm-minio-objectstore.<namespace>.svc.<cluster domain>"
```
When you install the chart, you must use the same release name that you used to generate the certificate. For more information, see *TLS configuration*.

### Updating Minio configuration by using Helm

[Configmap](https://kubernetes.io/docs/user-guide/configmap/) allows injecting containers with configuration data even while a Helm release is being deployed.

To update your Minio server configuration while it is being deployed in a release, complete these tasks:

1. Check all the configurable values in the Minio chart by using the `helm inspect values ibm-charts/ibm-minio-objectstore` command.
2. Override the `minio_server_config` settings in a YAML formatted file, and then pass that file by using the `helm upgrade -f <YAML-formatted-file-name>.yaml ibm-charts/ibm-minio-objectstore` command.
3. Restart the Minio server or servers for the changes to take effect.

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
| `arch.s390x`               | s390x scheduling preference         | `2 - No preference`                                     |
| `image.repository`         | Image repository                    | `ibmcom/minio`                                          |
| `image.tag`                | Minio image tag. For possible values, see [Tags](https://hub.docker.com/r/ibmcom/minio/tags).| `RELEASE.2019-04-09T01-22-30Z.1`|
| `image.pullPolicy`         | Image pull policy                   | `IfNotPresent`                                          |
| `mcImage.repository`       | Client image repository             | `ibmcom/minio-mc`                                       |
| `mcImage.tag`              | mc image tag. For possible values, see [Tags](https://hub.docker.com/r/ibmcom/minio-mc/tags).| `RELEASE.2019-04-03T17-59-57Z.1`|
| `mcImage.pullPolicy`       | mc image pull policy                | `IfNotPresent`                                          |
| `ingress.enabled`          | Enables ingress                     | `false`                                                 |
| `ingress.annotations`      | Ingress annotations. For example, {kubernetes.io/ingress.class: nginx, kubernetes.io/tls-acme: "true"}.                 | `nil`                                                    |
| `ingress.hosts`            | Host names accepted by ingress. For example, ["chart-example1.local", "chart-example2.local"].          | `nil`                                                    |
| `ingress.tls`              | Ingress TLS configuration. For example, [{"secretName": "chart-example-tls", "hosts": ["chart-example.local", "chart-example.local"]}].           | `nil`                                                    |
| `mode`                     | Minio server mode. Valid options are `standalone` or `distributed`.| `standalone`                               |
| `deploymentUpdate.type`    |  Deployment strategy type. Valid options are `Recreate` or `RollingUpdate`. |`RollingUpdate` |
| `deploymentUpdate.maxUnavailable` | Maximum number of pods that can be unavailable during the update process| `1` |
| `deploymentUpdate.maxSurge` | Maximum number of pods that can be created over the wanted number of pods during the update process | `1` |
| `statefulSetUpdate.updateStrategy` |Deployment strategy type. Valid options are `OnDelete` or `RollingUpdate`. |`RollingUpdate`|
| `replicas`                 | Number of nodes (applicable only to Minio distributed mode). Must be 4 <= x <= 32 | `4`    |
| `minioAccessSecret`       | Create a secret that contains base64-encoded accesskey (5 - 20 characters) and secretkey (8 - 40 characters). The keys are used to access Minio Object Server. You need to create the secret in the same namespace where you are deploying the chart. | `nil`                              |
| `configPath`               | Location of the default configuration file     | `/root/.minio`                                    |
| `configPathmc`             | Default configuration file location for Minio client (mc)     | `/root/.mc`                                    |
| `mountPath`                | Default mount path for the persistent drive| `/export`                                        |
| `service.type`             | Kubernetes service type. Allowed values are `NodePort`, `ClusterIP` or `LoadBalancer`. | `ClusterIP`    |
| `service.clusterIP`        | Kubernetes service ClusterIP. Specify whether service type is ClusterIP and whether you want to choose your own Cluster IP. | `None` |
| `service.loadBalancerIP`   | Kubernetes service loadBalancerIP. Specify whether service type is LoadBalancer and whether you want to choose your own Load Balancer IP. | `None` |
| `service.port`             | Kubernetes port on which the service is exposed| `9000`                                              |
| `service.nodePort`         | Exposes the service on IP address of the node at a static port when service type is `NodePort`  | `31311`                    |
| `service.externalIPs`      | External IP addresses of the service| `nil`                                                         |
| `service.prometheusEnable` | Enable Prometheus scrape         | `false` |
| `service.prometheusPath`   | Metrics path                        | `/minio/prometheus/metrics` |
| `service.prometheusPort`   | Port for metrics scrapping          | `9000` |
| `persistence.enabled`      | Use PV to store data | `false`                                                  |
| `persistence.size`         | Size of persistent volume claim (PVC)    | `10Gi`                                                  |
| `persistence.existingClaim`| Use an existing PVC to persist data | `nil`                                                   |
| `persistence.useDynamicProvisioning`| If enabled, the PVC will use a storageClassName to bind the volume. | `false`|
| `persistence.storageClass` | Storage Class to bind PVC. You must specify a valid storage class if you selected `useDynamicProvisioning`.     | `None`                                         |
| `persistence.accessMode`   | ReadWriteOnce or ReadOnly           | `ReadWriteOnce`                                         |
| `persistence.subPath`      | Mount a sub directory of the persistent volume, if a sub directory is set. | `""`                                  |
| `priorityClassName`        | Pod priority settings. IBM Cloud Private `system-cluster-critical` priority class is available only for `kube-system` namespace. | `""` |
| `tls.enabled`              | Enable Minio server with TLS certificates | `false` |
| `tls.type`                 | Specify whether a chart must auto-generate a TLS certificate by using cert-manager issuer or use the one that you provide. The valid values are `provided` and `cert-manager-generated`. If you are providing the certificate, you must create a secret that contains a private key, TLS certificate, and a certificate authority (CA) certificate. You provide the secret name in the `tls.minioTlsSecret` parameter. For details, see TLS configuration section. | `cert-manager-generated` |
| `tls.minioTlsSecret`      | Secret that you create and contains a private key (key private.key), TLS certificate (key public.crt), and a CA certificate (key ca.crt) to configure the Minio server with TLS certificates. You must create and specify the secret in the same namespace where you are deploying the chart. | `nil` |
| `tls.issuerRef.name`      | Name of ClusterIssuer or Issuer from which signed x509 certificates is obtained. You must specify this value if you specified the value of `tls.type` as `cert-manager-generated`. | `icp-ca-issuer` |
| `tls.issuerRef.kind`      | Kind of certificate authority from which signed x509 certificates is obtained. Valid values are `ClusterIssuer` or `Issuer`. You must specify this value if you specified the value of `tls.type` as `cert-manager-generated`. | `ClusterIssuer` |
| `tls.clusterDomain`        | Cluster domain name that is used to generate a certificate by using `cert-manager`. Specify your cluster domain name here. This parameter is applicable when `tls.type` is set as `cert-manager-generated` | `cluster.local` |
| `livenessProbe.initialDelaySeconds`  | Delay before liveness probe is initiated        | `5`                               |
| `livenessProbe.periodSeconds`        | Frequency to perform the probe                  | `30`                              |
| `livenessProbe.timeoutSeconds`       | Duration after which the probe times out                        | `1`                               |
| `livenessProbe.successThreshold`     | Minimum consecutive successes for the probe to be considered successful after it fails. | `1` |
| `livenessProbe.failureThreshold`     | Minimum consecutive failures for the probe to be considered failed after it succeeds.   | `3` |
| `readinessProbe.initialDelaySeconds` | Delay before readiness probe is initiated       | `5`                               |
| `readinessProbe.periodSeconds`       | Frequency to perform the probe                  | `15`                              |
| `readinessProbe.timeoutSeconds`      | Duration after which the probe times out                        | `1`                               |
| `readinessProbe.successThreshold`    | Minimum consecutive successes for the probe to be considered successful after it  fails. | `1` |
| `readinessProbe.failureThreshold`    | Minimum consecutive failures for the probe to be considered failed after it succeeds.   | `3` |
| `resources`                | CPU or memory resource requests or limits | Memory: `256Mi`, CPU: `100m`                            |
| `nodeSelector`             | Node labels for pod assignment. For example, `{"key":"value"}`.      | `nil`   |
| `tolerations`              | Toleration labels for pod assignment. For example, `[{"key": "key", "operator":"Equal", "value": "value", "effect":"NoSchedule"}] `.| `nil`                                                   |
| `podAnnotations`           | Pod annotations                      | `{}`                                                   |
| `defaultBucket.enabled`    | If set to true, a bucket is created after Minio installation is complete. | `false`                        |
| `defaultBucket.name`       | Bucket name                         | `bucket`                                                |
| `defaultBucket.policy`     | Bucket policy. Allowed values are `none`, `download`, `upload`, or `public`.    | `none` |
| `defaultBucket.purge`      | Purge the bucket, if exists.  | `false`                                                 |
| `buckets`                  | List of buckets to create after Minio is installed  | `[]`                                         |
| `environment`              | Set Minio server relevant environment variables in `values.yaml` file. Minio containers receive these variables when they start. | `{"name": "MINIO_BROWSER", "values": "on"}` |
| `s3gateway.enabled`        | Use Minio as an [S3 gateway](https://github.com/minio/minio/blob/master/docs/gateway/s3.md)| `false` |
| `s3gateway.replicas`       | Number of S3 gateway instances to run in parallel | `4` |
| `s3gateway.serviceEndpoint`| Endpoint to the S3-compatible service | `""` |
| `azuregateway.enabled`     | Use Minio server as an [Azure gateway](https://docs.minio.io/docs/minio-gateway-for-azure)| `false`  |
| `azuregateway.replicas`    | Number of azure gateway instances to run in parallel | `4` |
| `gcsgateway.enabled`       | Use Minio server as a [Google Cloud Storage gateway](https://docs.minio.io/docs/minio-gateway-for-gcs)| `false` |
| `gcsgateway.replicas`      | Number of Google Cloud Storage gateway instances to run in parallel. | `4` |
| `gcsgateway.gcsKeyJson`    | Credential JSON file of the service account key | `""` |
| `gcsgateway.projectId`     | Google cloud project ID             | `""` |
| `ossgateway.enabled`       | Use Minio as an [Alibaba Cloud Object Storage Service gateway](https://github.com/minio/minio/blob/master/docs/gateway/oss.md)| `false` |
| `ossgateway.replicas`      | Number of OSS gateway instances to run in parallel | `4` |
| `ossgateway.endpointURL`   | OSS server endpoint. | `""` |
| `nasgateway.enabled`       | Use Minio server as a [NAS gateway](https://docs.minio.io/docs/minio-gateway-for-nas)             | `false` |
| `nasgateway.replicas`      | Number of NAS gateway instances to be run in parallel on a PV            | `4` |
| `nasgateway.pv`            | Generally for NAS Gateway, you bind the PVC to a specific PV. To ensure that happens, label the PV that you need to bind to. Example label, `\"pv: <value>\"`. | `""` |
| `networkPolicy.enabled`              | With network policy enabled, traffic is limited to port 9000. | `false` |
| `networkPolicy.allowExternal`        | For more precise policy, enable networkPolicy.allowExternal. This configuration allows pods with the generated client label to connect to Minio. This label is displayed in the output of a successful installation. | `false` |
Some of the parameters that are listed in the table, map to the environment variables that are defined in the [Minio DockerHub image](https://hub.docker.com/r/minio/minio/).

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

By default, the `ibm-minio-objectstore` Helm chart provisions a Minio server in stand-alone mode. To provision a Minio server in distributed mode, set the `mode` field to `distributed`.

```
helm install --set mode=distributed,minioAccessSecret=minio ibm-charts/ibm-minio-objectstore --tls
```

This provisions Minio server in distributed mode with four nodes. To change the number of nodes in your distributed Minio server, set the `replicas` field.

```
helm install --set mode=distributed,replicas=8,minioAccessSecret=minio ibm-charts/ibm-minio-objectstore --tls
```

This provisions Minio server in distributed mode with eight nodes. The `replicas` value must be an integer in the range 4 - 16 (both inclusive).

### StatefulSet limitations (applicable to distributed Minio)

1. StatefulSets need persistent storage, so the `persistence.enabled` flag is ignored when `mode` is set to `distributed`.
2. For persistent storage, either existing PVC or dynamic provisioning can be used. When dynamic provisioning is enabled, you must specify a valid storage class.
3. When you uninstall a distributed Minio release, you need to manually delete volumes that are associated with the StatefulSet.

For more information, see [limitations](http://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/#limitations).

## NAS gateway

MinIO Gateway adds Amazon S3 compatibility to NAS storage. You can run multiple Minio instances on the same shared NAS volume as a distributed object gateway.

### Prerequisites

Minio in NAS Gateway mode can be used to create multiple Minio instances backed by a single PV in `ReadWriteMany` mode. Currently, few [Kubernetes volume plug-ins](https://kubernetes.io/docs/user-guide/persistent-volumes/#access-modes) support `ReadWriteMany` mode. To deploy Minio NAS gateway with a Helm chart, you need a PV running with one of the supported volume plug-ins. Network File System (NFS) is one of the supported volume plug-ins. For more information about steps to create a PV by using NFS, see [nfs](https://kubernetes.io/docs/user-guide/volumes/#nfs).

### Provision NAS gateway Minio instances

To provision Minio servers in [NAS gateway mode](https://docs.minio.io/docs/minio-gateway-for-nas), set the `nasgateway.enabled` parameter to `true`.

```
helm install --set nasgateway.enabled=true,minioAccessSecret=minio ibm-charts/ibm-minio-objectstore --tls
```

The following command provisions four Minio NAS gateway instances backed by a single storage. To change the number of instances in your Minio deployment, set the `replicas` parameter.

```
helm install --set nasgateway.enabled=true,nasgateway.replicas=8,minioAccessSecret=minio ibm-charts/ibm-minio-objectstore --tls
```

The following command provisions Minio NAS gateway with eight instances:

## Persistant storage

This chart provisions a PersistentVolumeClaim and mounts a corresponding persistent volume to the default location `/export`. Minio requires preconfigured block storage. This storage can be GlusterFS, Ceph, or any other Kubernetes supported storage provider. The block storage must be available through dynamic volume provisioning by using a storage class.  If you want to use `emptyDir`, disable PersistentVolumeClaim by running the following command:

```
helm install --set persistence.enabled=false,minioAccessSecret=minio ibm-charts/ibm-minio-objectstore --tls
```

**Note:** "An `emptyDir` volume is first created when a pod is assigned to a node, and the volume persists until that pod runs on the node. When a pod is removed from a node for any reason, the data in the `emptyDir` is deleted permanently.

## Existing PVC

If you already have a PVC, specify it during installation.

1. Create the PV.
2. Create the PVC.
3. Install the chart.

```
helm install --set persistence.existingClaim=PVC_NAME,minioAccessSecret=minio ibm-charts/ibm-minio-objectstore --tls
```

## Network policy

To enable network policy for Minio, install a networking plug-in that implements the
[Kubernetes NetworkPolicy spec](https://kubernetes.io/docs/tasks/administer-cluster/declare-network-policy#before-you-begin), and set `networkPolicy.enabled` to `true`.

With NetworkPolicy enabled, traffic is limited to port 9000.

For a more precise policy, set `networkPolicy.allowExternal=true`. This setting allows only pods with the generated client label to connect to Minio. This label is displayed in the output of a successful installation.

## TLS configuration

Minio server can be configured with TLS certificates. In the `ibm-minio-objectstore` Helm chart, TLS certificate can be specified in the following ways:

### Existing certificate

An existing set of private keys and public certificates can be specified by setting the configuration parameter `tls.type: "provided"`.

You need to create a secret with private keys and public certificates and set the `tls.minioTlsSecret` configuration parameter.

Following are the ways to create a secret that contains TLS settings:

* If the certificate is signed by a CA, `public.crt` must be the concatenation of the server's certificate, any intermediates, and root certificate of the CA.

```
kubectl create secret generic tls-ssl-minio --from-file=./private.key --from-file=./public.crt
```

* If the certificate is self-signed, you must copy `public.crt` to `ca.crt` and create a secret.

```
cp public.crt ca.crt
```

```
kubectl create secret generic tls-ssl-minio --from-file=./private.key --from-file=./public.crt --from-file=./ca.crt
```

**NOTE:** The certificate must be generated with `"/CN=*.<releasename>-ibm-minio-objectstore.<namespace>.svc.<cluster domain>".

That is, use: `"/CN=*.minio-ibm-minio-objectstore.default.svc.cluster.local"` for deploying the Minio chart with name `minio` in `default` namespace in the Kubernetes cluster domain `cluster.local`.


### Auto-generate self-signed certificate

When you set the configuration parameters as `tls.type: "cert-manager-generated"` and `tls.enabled: true`, the chart generates a certificate by using `ClusterIssuer` or `Issuer` and installs it for the Minio servers. You must set `tls.issuerRef.name` and `tls.issuerRef.kind`. You must also set the `tls.clusterDomain` configuration parameter with the value of your Kubernetes cluster domain name. The chart uses clusterDomain, namespace, and release name to generate CN for certificate generation.
