# Readme

Helm Chart for IBM&reg; Sterling Transformation Extender for Red Hat OpenShift 11.0.1
<br>&copy; Copyright IBM Corporation 2024, 2025 All rights reserved.
<br>Program Number : 5724-Q23 

# Introduction

IBM&reg; Sterling Transformation Extender (ITX) provides a unified solution for data transformation and integration. It enables complex validation, transformation and integration across a wide range of data sources and data formats. The transformation functionality is packaged into deployable and modular objects called maps. The maps can in turn be wired together into flows, which enable greater integrations and new transformation capabilities.

IBM&reg; Sterling Transformation Extender for Red Hat OpenShift (RHOS) is a containerized distribution of ITX. It enables maps and flows to be executed via REST API endpoints. Another name for IBM Sterling Transformation Extender for Red Hat OpenShift is ITX Runtime Server (ITX RS). Maps are designed using ITX Design Studio and flows are created using ITX Design Server. Both ITX Design Studio and Design Server are components that are separate from ITX RS. They must be installed and run locally on a Windows host. When you obtain access to the ITX RS component, you will be provided with instructions on how to obtain the ITX Design Studio and Design Server components as well.

For additional high-level overview of the ITX Runtime Server product, refer to this [support page](https://www.ibm.com/support/pages/node/7166685).

# Chart Details

## Prerequisites

The Red Hat OpenShift Container Platform project must have access to a currently supported version of Redis to run maps in fenced or asynchronous mode. Redis major version 7.x or later from a trusted and reputable source meets this requirement. By default, the Helm chart configures ITX to run maps synchronously in unfenced mode, which does not require Redis.     

Installing a PodDisruptionBudget

The configured deployment does not specify a disruption budget. Each consumer of this transformation logic should consider how disruption might impact any specific process.

### Sample Pod Disruption Budget

``` { .yaml }
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: ibm-itx-rs-pdb
spec:
  minAvailable: 1
  selector:
    matchLabels:
      helm.sh/chart: "ibm-itx-rs-prod"
```
## Resources Required

### SecurityContextConstraints Requirements

This chart requires a specific type of `SecurityContextConstraints` to be defined and bound to the user or service account of the installation. The predefined `SecurityContextConstraints`, [`nonroot-v2`](https://docs.openshift.com/container-platform/4.18/authentication/managing-security-context-constraints.html), has been verified for this chart.  If your user or service account is bound to this `SecurityContextConstraints` resource, you can proceed to install the chart.

Below is a `SecurityContextConstraints` (SCC) which can be used for finer control of the permissions and capabilities needed to install this chart. It is modeled after the predefined `nonroot-v2` SCC but with the added restriction of only permitting user and group ID, 1001, which is required by ITX Runtime Server.

Custom SecurityContextConstraints definition:
```
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: "This policy allows a single, non-root user"
  name: ibm-itx-rs-scc
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegedContainer: false
allowPrivilegeEscalation: false
allowedCapabilities: 
- NET_BIND_SERVICE
allowedFlexVolumes: null
allowedUnsafeSysctls: null
defaultAddCapabilities: null
defaultAllowPrivilegeEscalation: false
readOnlyRootFilesystem: false
requiredDropCapabilities:
- ALL
seccompProfiles:
- runtime/default
runAsUser:
  type: MustRunAsRange
  uidRangeMin: 1001
  uidRangeMax: 1001
fsGroup:
  type: MustRunAs
  ranges:
  - max: 1001
    min: 1001
supplementalGroups:
  type: RunAsAny
seLinuxContext:
  type: MustRunAs
volumes:
- configMap
- csi
- downwardAPI
- emptyDir
- ephemeral
- nfs
- persistentVolumeClaim
- projected
- secret
priority: 0
```
From the command line, save the YAML object to a file and run the following command.

``` { .shell }
oc apply -f <file_name>
```
## Installing the Chart

Follow the chart installation instructions provided in the CASE README for IBM&reg; Sterling Transformation Extender for Red Hat Openshift. 

## Configuration

Configuration settings supported by ITX Runtime Server have been listed in the CASE README for IBM&reg; Sterling Transformation Extender for Red Hat Openshift. 

## Limitations

Limitations of ITX Runtime Server have been mentioned in the CASE README for IBM&reg; Sterling Transformation Extender for Red Hat Openshift.

## Parameters

### License parameter

| Parameter                              | Description                                                     | Default         |
| -------------------------------------- | --------------------------------------------------------------- | --------------- |
| `license`              | License acceptance                                           | `false`  |

### Global parameters

| Parameter                              | Description                                                     | Default         |
| -------------------------------------- | --------------------------------------------------------------- | --------------- |
| `global.itxImageRegistry`              | Container image registry and namespace                          | `"cp.icr.io/cp"`   |
| `global.itxImagePullSecret`            | Container registry pull secret                                  | `"ibm-encryption-key"` |
| `global.persistence.rwxStorageClassV3` | Optional storage class with RWX mode to use for PV provisioning | `""`            |
|                                        |                                                                 |                 |

### Shared parameters

| Parameter            | Description                                                                         | Default    |
| -------------------- | ----------------------------------------------------------------------------------- | ---------- |
| `displayName`        | Display name for ITX RS deployment                       | `"IBM Sterling Transformation Extender for Red Hat OpenShift"`  |
| `nameOverride`       | Name override for the install                            | `""`       |
| `fullnameOverride`   | Full name override for the install                       | `""`       |
| `itxImageRegistry`   | Container image registry and namespace                   | `"cp.icr.io/cp"` |
| `itxImagePullSecret` | Container registry pull secret                           | `"ibm-encryption-key"`       |
|                       |                                                             |                                                                |

### REST V1-based deployment parameters

| Parameter                                 | Description                                              | Default                 |
| ----------------------------------------- | -------------------------------------------------------- | ----------------------- |
| `restV1.deploy`                           | Deploy **restV1** component                              | `true`              |
| `restV1.runMode`                          | Run mode (`"fenced"`, `"unfenced"`)                      | `"unfenced"`              |
| `restV1.redisStem`                        | Redis stem                                               | `"tx-rest-v1"`           |
| `restV1.cacheType`                        | Cache type                                               | `"internal"`              |
| `restV1.replicas`                         | Replicas                                                 | `1`              |
| `restV1.inbound.http.enabled`             | Enable HTTP inbound connection                           | `true`                  |
| `restV1.inbound.https.enabled`            | Enable HTTPS inbound connection                          | `false`                 |
| `restV1.inbound.https.secret`             | TLS secret for the inbound HTTPS connection              | `""`                    |
| `restV1.inbound.https.serviceServingCertificates`| RHOS provisioned certificate              | `false`                    |
| `restV1.inbound.https.clientAuth`                | Enforce caller authentication (mTLS)      | `false`                 |
| `restV1.serviceAccount.create`                 | Create **restV1** service account                                  | `false`                 |
| `restV1.serviceAccount.annotations`            | Annotations to add to the **restV1** service account               | `""`                    |
| `restV1.serviceAccount.existingName`           | Name of pre-existing **restV1** service account                     | `""`                    |
| `restV1.service.type`                          | Service type (`"ClusterIP"`, `"NodePort"`, `"LoadBalancer"`)              | `"ClusterIP"`             |
| `restV1.service.port.http`                     | Service port for HTTP inbound connection                            | `8080`                  |
| `restV1.service.port.https`                    | Service port for HTTPS inbound connection                           | `8443`                  |
| `restV1.synchronousTimeout`                    | Timeout (in seconds) for synchronous REST API v2 calls              | 300                     |
| `restV1.extraEnvConfigMap`                     | ConfigMap with custom environment variables                         | `""`                    |
| `restV1.extraEnvSecret`                        | Secret with custom environment variables                            | `""`                    |
| `restV1.probes.liveness.enabled`               | Enable liveness probe                                               | `true`                  |
| `restV1.probes.liveness.initialDelaySeconds`   | Delay in seconds for initial liveness probe                         | `35`                    |
| `restV1.probes.liveness.periodSeconds`         | Duration in seconds between liveness probes                         | `20`                    |
| `restV1.probes.liveness.successThreshold`      | Liveness probe success threshold                                    | `1`                     |
| `restV1.probes.liveness.failureThreshold`      | Liveness probe failure threshold                                    | `3`                     |
| `restV1.probes.readiness.enabled`              | Enable readiness probe                                              | `true`                  |
| `restV1.probes.readiness.initialDelaySeconds`  | Delay in seconds for initial readiness probe                        | `35`                    |
| `restV1.probes.readiness.periodSeconds`        | Duration in seconds between readiness probes                        | `20`                    |
| `restV1.probes.readiness.successThreshold`     | Readiness probe success threshold                                   | `1`                     |
| `restV1.probes.readiness.failureThreshold`     | Readiness probe failure threshold                                   | `3`                     |
| `restV1.resources.requests.cpu`                | Mimimum CPU resources                                               | `"250m"`                  |
| `restV1.resources.requests.memory`             | Minimum memory resources                                            | `"700Mi"`                 |
| `restV1.resources.limits.cpu`                  | Maximum CPU resources                                               | `"4000m"`                 |
| `restV1.resources.limits.memory`               | Maximum memory resouces                                             | `"8Gi"`                   |
| `restV1.nodeSelector`                          | Node selector map                                                   | `{}`                    |
| `restV1.tolerations`                           | Tolerations array                                                   | `[]`                    |
| `restV1.affinity`                              | Pod and Node affinity map                                           | `{}`                    |
| `restV1.autoscaling.enabled`                   | Horizontal pod autoscaling enabled                                  | `false`                 |
| `restV1.autoscaling.minReplicas`               | Minimum pod count                                                   | `1`                 |
| `restV1.autoscaling.maxReplicas`               | Maximum pod count                                                   | `10`                 |
| `restV1.autoscaling.cpu.enabled`               | CPU utilization monitoring                                          | `true`                 |
| `restV1.autoscaling.cpu.averageUtilization`    | CPU average utilization threshold                                   | `80`                 |
| `restV1.autoscaling.memory.enabled`            | Memory utilization monitoring                                       | `true`                 |
| `restV1.autoscaling.memory.averageUtilization` | Memory average utilization threshold                                | `80`                 |
| `restV1.autoscaling.custom.enabled`            | Custom metric type monitoring                                       | `false`              |
| `restV1.autoscaling.custom.types`              | Custom metric type definitions                                      | `[]`                 |
| `restV1.autoscaling.behavior`                  | Behavior policies for scaling up or down                            | `{}`                 |
|                                                |                                                                     |                      |

### REST V2-based deployment parameters

| Parameter<sup>1</sup>                          | Description                                                           | Default                 |
| ---------------------------------------------- | --------------------------------------------------------------------- | ----------------------- |
| `rest.deploy`                                  | Deploy **rest** component                    | `false`                     |
| `rest.image.repository`                        | Container image registry & repository        | `"cp.icr.io/cp/ibm-itx-rs"` |
| `rest.image.tag`                               | Container image tag                          | `"11.0.1.1.20251121"`       |
| `rest.image.digest`                            | Container image digest                       | `"sha256:c797ee0bb36fa344f058ebd950ea020413ed24b35e6e1c3dcde47aa86d149822"`    |
| `rest.image.pullPolicy`                        | Container image pull policy                              | `"IfNotPresent"`          |
| `rest.image.pullPolicyOverride`                | Container image pull policy override                     | `false`          |
| `rest.mapFileExtension`                        | Compiled map file extension                              | `"mmc"`                   |
| `rest.redisStem`                               | Redis stem                                               | `"tx-rest"`                   |
| `rest.cacheType`                               | Cache type                                               | `"external"`              |
| `rest.persistence.data.enabled`                | Persistence volume exists for **data** volume            | `true`                |
| `rest.persistence.data.existingClaim`          | Existing PVC for the **data** volume                     | `""`                    |
| `rest.persistence.data.useDynamicProvisioning` | Enables dynamic provisioning for the **data** PVC        | `false`                 |
| `rest.persistence.data.storageClass`           | Storage class name for the **data** PVC                  | `""`                    |
| `rest.persistence.data.accessMode`             | Access mode for the **data** PVC                         | `"ReadWriteOnce"`         |
| `rest.persistence.data.size`                   | Requested storage size for the **data** PVC              | `"20Gi"`                  |
| `rest.persistence.data.annotations`            | Annotations for the **data** PVC                         | `{}`                    |
| `rest.persistence.logs.enabled`                | Persistence volume exists for **logs** volume            | `true`                |
| `rest.persistence.logs.existingClaim`          | Existing PVC for the **logs** volume                     | `""`                    |
| `rest.persistence.logs.useDynamicProvisioning` | Enables dynamic provisioning for the **logs** PVC        | `false`                 |
| `rest.persistence.logs.storageClass`           | Storage class name for the **logs** PVC                  | `""`                    |
| `rest.persistence.logs.accessMode`             | Access mode for the **logs** PVC                         | `"ReadWriteOnce"`         |
| `rest.persistence.logs.size`                   | Requested storage size for the **logs** PVC              | `"100Mi"`                 |
| `rest.persistence.logs.annotations`            | Annotations for the **logs** PVC                         | `{}`                    |
| `rest.inbound.http.enabled`                    | Enable HTTP inbound connection                           | `true`                  |
| `rest.inbound.https.enabled`                   | Enable HTTPS inbound connection                          | `false`                 |
| `rest.inbound.https.secret`                    | TLS secret for the inbound HTTPS connection              | `""`                    |
| `rest.inbound.https.serviceServingCertificates`| RHOS provisioned certificate              | `false`                    |
| `rest.inbound.https.clientAuth`                | Enforce caller authentication (mTLS)      | `false`                 |
| `rest.serviceAccount.create`                   | Create **rest** service account                                     | `false`                 |
| `rest.serviceAccount.annotations`              | Annotations to add to the **rest** service account                  | `""`                    |
| `rest.serviceAccount.existingName`             | Name of pre-existing **rest** service account                       | `""`                    |
| `rest.service.type`                            | Service type (`"ClusterIP"`, `"NodePort"`, `"LoadBalancer"`)              | `"ClusterIP"`             |
| `rest.service.port.http`                       | Service port for HTTP inbound connection                            | `8080`                  |
| `rest.service.port.https`                      | Service port for HTTPS inbound connection                           | `8443`                  |
| `rest.synchronousTimeout`                      | Timeout (in seconds) for synchronous REST API v2 calls              | 300                     |
| `rest.groupId`                                 | Logical id for aggregating dashboard reports of **rest** instances  | `"1"`                   |
| `rest.extraEnvConfigMap`                       | ConfigMap with custom environment variables                         | `""`                    |
| `rest.extraEnvSecret`                          | Secret with custom environment variables                            | `""`                    |
| `rest.probes.liveness.enabled`                 | Enable liveness probe                                               | `true`                  |
| `rest.probes.liveness.initialDelaySeconds`     | Delay in seconds for initial liveness probe                         | `35`                    |
| `rest.probes.liveness.periodSeconds`           | Duration in seconds between liveness probes                         | `20`                    |
| `rest.probes.liveness.successThreshold`        | Liveness probe success threshold                                    | `1`                     |
| `rest.probes.liveness.failureThreshold`        | Liveness probe failure threshold                                    | `3`                     |
| `rest.probes.readiness.enabled`                | Enable readiness probe                                              | `true`                  |
| `rest.probes.readiness.initialDelaySeconds`    | Delay in seconds for initial readiness probe                        | `35`                    |
| `rest.probes.readiness.periodSeconds`          | Duration in seconds between readiness probes                        | `20`                    |
| `rest.probes.readiness.successThreshold`       | Readiness probe success threshold                                   | `1`                     |
| `rest.probes.readiness.failureThreshold`       | Readiness probe failure threshold                                   | `3`                     |
| `rest.resources.requests.cpu`                  | Mimimum CPU resources                                               | `"250m"`                  |
| `rest.resources.requests.memory`               | Minimum memory resources                                            | `"700Mi"`                 |
| `rest.resources.limits.cpu`                    | Maximum CPU resources                                               | `"4000m"`                 |
| `rest.resources.limits.memory`                 | Maximum memory resouces                                             | `"8Gi"`                   |
| `rest.deployPackages.enabled`                  | If Cloud Object Storage is used, deploy packages                    | `true`                   |
| `rest.deployPackages.directory`                | Directory used to search for packages                    | `"/data/maps"`                |
| `rest.deployPackages.archiveDir`               | Directory used to move packages after successful deploy  | `"/data/packages"`                |
| `rest.deployPackages.secret.keyName`           | TLS key from external.secrets.data                       | `""`                |
| `rest.deployPackages.secret.crtName`           | TLS certificate from external.secrets.data               | `""`                |
| `rest.nodeSelector`                            | Node selector map                                                   | `{}`                    |
| `rest.tolerations`                             | Tolerations array                                                   | `[]`                    |
| `rest.affinity`                                | Pod and Node affinity                                               | `{}`                    |
|                                                |                                                                    |                         |

<sup>1</sup> Container image, map extension and data persistence settings also apply to REST V1 deployment.

### Executor deployment parameters

| Parameter                                      | Description                                            | Default                     |
| ---------------------------------------------- | ------------------------------------------------------ | --------------------------- |
| `executor.serviceAccount.create`               | Create **executor** service account                    | `false`                     |
| `executor.serviceAccount.annotations`          | Annotations to add to the **executor** service account | `{}`                        |
| `executor.serviceAccount.existingName`         | Name of pre-existing **executor** service account      | `""`                        |
| `executor.replicas`                                | Number of executor pod replicas                    | `1`                         |
| `executor.probes.liveness.enabled`                 | Enable liveness probe                              | `true`                      |
| `executor.probes.liveness.initialDelaySeconds`     | Delay in seconds for initial liveness probe        | `30`                        |
| `executor.probes.liveness.periodSeconds`           | Duration in seconds between liveness probes        | `20`                        |
| `executor.probes.liveness.successThreshold`        | Liveness probe success threshold                   | `1`                         |
| `executor.probes.liveness.failureThreshold`        | Liveness probe failure threshold                   | `3`                         |
| `executor.probes.readiness.enabled`                | Enable readiness probe                             | `true`                      |
| `executor.probes.readiness.initialDelaySeconds`    | Delay in seconds for initial readiness probe       | `30`                        |
| `executor.probes.readiness.periodSeconds`          | Duration in seconds between readiness probes       | `20`                        |
| `executor.probes.readiness.successThreshold`       | Readiness probe success threshold                  | `1`                         |
| `executor.probes.readiness.failureThreshold`       | Readiness probe failure threshold                  | `3`                         |
| `executor.resources.requests.cpu`                  | Mimimum CPU resources                              | `"250m"`                      |
| `executor.resources.requests.memory`               | Minimum memory resources                           | `"700Mi"`                     |
| `executor.resources.limits.cpu`                    | Maximum CPU resources                              | `"4000m"`                     |
| `executor.resources.limits.memory`                 | Maximum memory resouces                            | `"4Gi"`                       |
| `executor.nodeSelector`                            | Node selector map                                  | `{}`                        |
| `executor.tolerations`                             | Tolerations array                                  | `[]`                        |
| `executor.affinity`                                | Node and pod affinity map                          | `{}`                        |
| `executor.autoscaling.enabled`                     | Horizontal pod autoscaling enabled                 | `false`                        |
| `executor.autoscaling.minReplicas`                 | Minimum pod count                                                   | `1`                 |
| `executor.autoscaling.maxReplicas`                 | Maximum pod count                                                   | `10`                 |
| `executor.autoscaling.cpu.enabled`                 | CPU utilization monitoring                                        | `true`                 |
| `executor.autoscaling.cpu.averageUtilization`      | CPU average utilization threshold                                 | `80`                 |
| `executor.autoscaling.memory.enabled`              | Memory utilization monitoring                                     | `true`                 |
| `executor.autoscaling.memory.averageUtilization`   | Memory average utilization threshold                              | `80`                 |
| `executor.autoscaling.custom.enabled`              | Custom metric type monitoring                                     | `false`              |
| `executor.autoscaling.custom.types`                | Custom metric type definitions array                              | `[]`                 |
| `executor.autoscaling.behavior`                    | Behavior policies for scaling up or down                          | `{}`                 |
|                                                    |                                                                   |                      |

### External integration parameters

| Parameter                                      | Description                                                    | Default                     |
| ---------------------------------------------- | -------------------------------------------------------------- | --------------------------- |
| `external.data.volume.path`       | Path used to mount ConfigMap and secret files                            | `"/xdata"` |
| `external.data.volume.size`       | Size of the volume                                                       | `"50Mi"` |
| `external.data.secret.subpath`    | Subdirectory path of secret files                                        | `"sec"` |
| `external.data.configMap.subpath` | Subdirectory path of configMap files                                     | `"cfg"` |
| `external.data.map.subpath`       | Subdirectory path of map files                                           | `"map"` |
| `external.mq.secret`              | Name of the secret that contains MQ client channel table                 | `""` |
| `external.mq.chlTab`              | Key of the MQ secret                                                     | `""` |
| `external.mq.chlLib`              | Directory path of the MQCHLLIB environment variable                      | `"/xdata/sec"` |
| `external.mq.sslKeyPath`          | Full path file name to the repository of MQ trusted certificates         | `""` |
| `external.mq.dataPath`            | Full path used to set the MQ_OVERRIDE_DATA_PATH environment variable     | `"/tmp"` |
| `external.secrets`                | Array of secret names and keys to get mounted                            | `[]` |
| `external.configMaps`             | Array of ConfigMap names and keys to get mounted                         | `[]` |
| `external.maps`                   | Maps in a ConfigMap that are mounted and ready for REST V1 execution     | `[]` |
| `external.hostAliases`            | Array of host aliases that are needed in a pod                           | `[]` |
| `external.env`                    | Array of environment variables for use during map execution              | `[]` |
| `external.cos.enabled`            | Cloud Object Storage is enabled for map and flow download and setup      | `false` |
| `external.cos.name`               | Name of the zip object to download and unzip from COS                    | `"maps.zip"` |
| `external.cos.bucket`             | Bucket that contains the zip file                                        | `"itx"` |
| `external.cos.targetDir`          | Destination directory where maps are unzipped                            | `"/data/maps"` |
| `external.cos.platform`           | Cloud platform ("s3", "gcp")                                             | `"s3"` |
| `external.cos.gcp.cf`             | If "gcp" platform, points to the name of the mounted credentials file    | `"cf.json"` |
| `external.cos.s3.accessKey`       | If "s3" platform, points to the name of the mounted access key           | `""` |
| `external.cos.s3.region`          | If "s3" platform, name of the region                                     | `"us-east-1"` |
| `external.cos.s3.endpoint`        | If "s3" platform, URL of S3 compatible storage service                   | `""` |
|                                   |                                                                          |         |

### Redis component parameters

| Parameter                          | Description                                                        | Default      |
| ---------------------------------- | ------------------------------------------------------------------ | ------------ |
| `itxRedis.host`                    | Host name of the externally provided Redis                         | `"redis-master"`   |
| `itxRedis.port`                    | Port name of the externally provided Redis                         | `6379`       |
| `itxRedis.database`                | Database number in the externally provided Redis                   | `0`          |
| `itxRedis.password.secret`         | Name of the secret which contains the Redis password               | `""`         |
| `itxRedis.password.key`            | Key in the secret which contains the Redis password                | `""`         |
| `itxRedis.tls.enabled`             | TLS communication with Redis is enabled                            | `false`      |
| `itxRedis.tls.clientSecret`        | If using mTLS, name of the TLS client secret                       | `""`      |
| `itxRedis.tls.certFilename`        | If using mTLS, name of the certificate in the TLS client secret    | `""`      |
| `itxRedis.tls.certKeyFilename`     | If using mTLS, name of the private key in the TLS client secret    | `""`      |
| `itxRedis.tls.clientCaConfigMap`   | Name of the ConfigMap which contains the Redis server's CA         | `""`      |
| `itxRedis.tls.certCAFilename`      | Key in the ConfigMap which contains the Redis server's CA          | `""`      |
| `itxRedis.tls.sni`                 | Server Name Indication host name, if needed by Redis Server        | `""`      |
| `itxRedis.maxStatisticCount`       | Maximum number of flow instances to retain in the statistics       | `100000`  |
| `itxRedis.statusExpiration`        | Number of day when flow status message expires                     | `7`  |
|                                    |                                                                    |              |

### Route V2-based parameter when deploying to RHOS

| Parameter             | Description                               | Default |
| --------------------- | ----------------------------------------- | ------- |
| `route.deploy`        | Define route when `rest.deploy` is true   | `true`  |
| `route.host`          | Use an explicit route hostname.           | `""`    |
| `route.annotations`   | Add route annotation for backend timeout  | `{}`    |

### Route V1-based parameter when deploying to RHOS

| Parameter             | Description                               | Default |
| --------------------- | ----------------------------------------- | ------- |
| `routeV1.deploy`      | Define route when `restV1.deploy` is true | `true`  |
| `routeV1.host`        | Use an explicit route hostname.           | `""`    |
| `routeV1.annotations` | Add route annotation for backend timeout  | `{}`    |

### Ingress V2-based REST parameters

| Parameter             | Description                               | Default |
| --------------------- | ----------------------------------------- | ------- |
| `ingress.deploy`      | Deploy ingress                            | `false` |
| `ingress.annotations` | Annotations for the ingress               | `{}`    |
| `ingress.className`   | Sets the "ingressClassName"               | `"openshift-default"`    |
| `ingress.hosts`       | Array of host definitions for the ingress | `[]`    |
| `ingress.tls`         | Array of TLS definitions for the ingress  | `[]`    |
| `ingress.default.enabled` | REST service is used when no rules or match exists | `true`    |
|                       |                                           |         |

### Ingress V1-based REST parameters

| Parameter             | Description                               | Default |
| --------------------- | ----------------------------------------- | ------- |
| `ingressV1.deploy`      | Deploy ingress                            | `false` |
| `ingressV1.annotations` | Annotations for the ingress               | `{}`    |
| `ingressV1.className`   | Sets the "ingressClassName"               | `"openshift-default"`    |
| `ingressV1.hosts`       | Array of host definitions for the ingress | `[]`    |
| `ingressV1.tls`         | Array of TLS definitions for the ingress  | `[]`    |
| `ingressV1.default.enabled` | REST service is used when no rules or match exists | `true`    |
|                       |                                           |         |

### Configuration parameters used in "config.yaml" for REST and Executor deployments

| Parameter                                | Description                                                   | Default                     |
| ---------------------------------------- | ------------------------------------------------------------- | --------------------------- |
| `config.runtime.connectionsManager.idle` | Time in seconds before an idle connection is closed           | `60` |
| `config.runtime.connectionsManager.sLim` | Number of connections of a given type that can be kept idle   | `4` |
| `config.runtime.externalJarFiles`        | Array of externally loaded jar files before invoking Java     | `[]` |
| `config.runtime.externalJarDirectories`  | Array of directories used to load jar files                   | `[]` |
| `config.runtime.jvmOptions`              | JVM options in array format for Map and Flow executions       | `[]` |
| `config.runtime.trace`                   | Log to Kubernetes or set to "" for file logging               | `"stdout"` |
| `config.runtime.locale`                  | Locale values: de,en,es,fr,it,ja,ko,pt_BR,ru,zh_CN,zh_TW      | `"en"` |
| `config.rest.logging.level`              | Logging levels: ALL,TRACE,INFO,ERROR,NONE                     | `"ERROR"` |
| `config.rest.logging.header`             | Display column header                                         | `true` |
| `config.rest.logging.columns.time`       | Display time column                                           | `1` |
| `config.rest.logging.columns.uuid`       | Display the UUID of each instance                             | `false` |
| `config.rest.logging.columns.rc`         | Display return code                                           | `true` |
| `config.rest.logging.columns.rcText`     | Display text description of return code                       | `false` |
| `config.rest.logging.columns.msgID`      | Display trace message ID                                      | `false` |
| `config.rest.logging.columns.flowName`   | Display flow, node or adapter name of generated message       | `true` |
| `config.rest.logging.columns.msg`        | Display trace message                                         | `true` |
| `config.rest.logging.columns.funcName`   | Display function name (for internal debugging only)           | `false` |
| `config.rest.logging.columns.sourceInfo` | Display source file and line (for internal debugging only)    | `false` |
| `config.rest.logging.trigger`            | Frequency of execution logs: ALWAYS,ON_ERROR,NEVER            | `"ALWAYS"` |
| `config.rest.logging.addWebServerConsoleLogging` | Enable Kubernetes logging from REST Server            | `true` |
| `config.rest.logging.disableWebServerAccessLogging` | Disable logging of REST requests                   | `false` |
| `config.rest.logging.rotation.fileCount` | Max number of log files in rotation                           | `5` |
| `config.rest.logging.rotation.fileSize` | Max size in kilobytes of each log file                         | `20000` |
| `config.rest.logging.rotation.fileAge` | Min number of days after which logs are deleted                 | `30` |
| `config.rest.resources.mapThreads`     | Max number of threads for executing maps                        | `10` |
| `config.rest.resources.flowThreads`    | Max number of threads for executing flows                       | `10` |
| `config.rest.listeners.adapter.jvmOptions` | JVM options in string format for java-based listener        | `""` |
| `config.rest.listeners.file.zone` | Unique zone name for File Listener in multi-regional deployment      | `""` |
| `config.rest.listeners.file.cooperativeMode` | Multiple file listeners use the same watch                | `false` |
| `config.patch.directory` | Directory of fixes to patch runtime modules  | `""` |
| `config.patch.manifest` | Manifest that lists 'cksum' values of fixes   | `"/xdata/cfg/patchmanifest.txt"` |
|                                            |                                                                   |                             |

## HTTPS and TLS considerations

A set of parameters is provided to enable configuring inbound **rest** connections. One or both of `http` and `https` can be enabled, using the `rest.inbound.http.enabled` and `rest.inbound.https.enabled` boolean parameters.

For `https` connections, a TLS configuration can be defined by using the parameters in the sections listed in this table:

| Traffic                   | Section                  | Description                                                                              |
| ------------------------- | ------------------------ | ---------------------------------------------------------------------------------------- |
| rest inbound              | `rest\|restV1.inbound`  | REST calls arriving to **rest** from Design Server and external REST clients (e.g. curl)    |
|                           |                          |                                                                                          |

The most important parameter is the `secret`. The name of the secret points to a Kubernetes Secret object, which must contain a PEM encoded custom CA certificate chain, the REST server certificate and the REST server key. The certificates and keys are used to prove identity when using mutual TLS (mTLS) authentication. The Kubernetes secret object must have the following keys and corresponding values:

| Key       | Value                            |
| --------- | -------------------------------- |
| `ca.crt`  | PEM encoded CA certificate chain |
| `tls.crt` | PEM encoded certificate          |
| `tls.key` | PEM encoded private key          |

The Kubernetes secrets can be automatically created using a certificate management tool, such as the RHOS service serving certificates, or they can be manually created to use the existing CA, certificate and key values. For example, the following kubectl command, when invoked from a directory that contains PEM encoded `ca.crt`, `server.crt` and `server.key` files will create a generic Kubernetes secret with the name `itx-server-secret`:

```bash
kubectl create secret generic itx-server-secret --from-file=ca.crt=ca.crt --from-file=tls.crt=server.crt --from-file=tls.key=server.key
```

## Storage considerations

ITX RS requires persistent volumes (PVs) in the cluster to store maps, flows and execution results. The following table lists the persistent volume claims (PVCs) used in the ITX RS installation to provision and reference the necessary PVs. The values shown in the `PVC` column represent suffixes of the names given to the PVCs when they are created automatically by the ITX RS installation. The full generated PVC names will vary from one installation to another and will be based on the release name provided in the `helm install` command.

| PVC                           | Component        | Container Mount Point     | Primary Use                                                      |
| ----------------------------- | ---------------- | ------------------------- | ---------------------------------------------------------------- |
| `rest-data` (see note)      | restV1, rest, executor   | `/data`       | REST API uploaded files, Map and Flow Engine files |   
| `rest-logs` (see note)      | restV1, rest, executor   | `/logs`       | ITX system logs |   

Note: Both PVCs are shared between the **rest** and **executor** pods. In the case of a REST V1 only deployment, which is the default, only the **restV1** pods that are started will share the PVCs.  

If ITX RS is installed using default chart parameters, the necessary PVCs are created. The PVs to which those PVCs bind are dynamically provisioned with the `Delete` reclaim policy. This in turn results in the automatic deletion of those PVCs and PVs when ITX is subsequently uninstalled. 

To prevent the storage from being automatically deleted when ITX RS is uninstalled, you can choose to provision and configure the storage separately before installing ITX RS and then point to that storage in the `helm install` command. To accomplish that, you can perform the following steps:

* Prepare the required PVCs and PVs prior to installing ITX (see [here](#preparing-pvcs-and-pvs) for details)
* Reference the prepared PVCs when installing ITX RS (see [here](#referencing-existing-pvcs) for details)

## Preparing PVCs and PVs

When installing **rest** as part of your ITX RS installation (`rest.deploy=true`) and/or (`restV1.deploy=true`), which is the case by default, create and bind the `rest-data` and `rest-logs` PVCs that will be used by **rest** and **executor** pods for storing files.

To maximize the flexibility for scheduling ITX's **rest** and **executor** pods that share the `rest-data` and `rest-logs` PVCs, it is recommended, although not required, to use a storage provider that supports `ReadWriteMany` (`RWX`) access mode and use it for the `rest-data` and  `rest-logs` storage. Kubernetes clusters often do not provide such support by default, and an external storage provider needs to be installed and configured in the cluster to provide the support.

Refer to the official Kubernetes documentation for detailed information on creating PVCs in the cluster. Cluster administrators are typically tasked with provisioning PVs using the available storage providers and making them available for claims by the application's PVCs.

The following set of steps is provided for illustration purposes and demonstrates how a PVC can be created and configured in preparation for the ITX RS installation. The steps are for the `rest-data` PVC in ITX RS, but the same steps can be followed to prepare the `rest-logs` PVC that is required by ITX RS. Refer to [this section](#storage-considerations) for information about the PVCs and PVs used in ITX RS.

Start by running the following command to create the `rest-data` PVC:

```bash
cat <<EOF | kubectl apply -f - 
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: rest-data
spec:
  accessModes:
  - ReadWriteMany
  storageClassName: nfs
  resources:
    requests:
      storage: 10Gi
EOF
```

The command will create a PVC based on the "nfs" storage class in the cluster. If a "nfs" storage class is not available, this line can be omitted to choose the "default" storage class, which may not support scaling across multiple worker nodes. 

Once the PVC is created, a PV that meets this request will be dynamically provisioned in the cluster and bound to the PVC. To confirm that the PVC was created and was bound to the PV, and to find out the name of the PV, issue the command:

```bash
kubectl get pvc rest-data
```

The output will display information about the `rest-data` PVC, including its name under the `NAME` column and the name of the PV to which it was bound under the `VOLUME` column.

The remaining steps shown here refer to the PV name via the `PVNAME` shell variable, so before running the remaining steps store the PV name in that shell variable by running this command:

```bash
PVNAME=`(kubectl get -o template pvc rest-data --template={{.spec.volumeName}})`
--------------------------------------------------------------------------------
```

Ensure that the value was stored successfully:

```bash
echo $PVNAME
```

To confirm that the reclaim policy for the PV was set to `Delete` issue the command:

```
kubectl get pv $PVNAME
```

Check the value under the `RECLAIM POLICY` column and confirm that it is set to `Delete`.

If you were to delete the `rest-data` PVC at this time, the PV would be automatically deleted along with its underlying storage contents.

Change the reclaim policy for the PV from `Delete` to `Retain` by running the command:

```bash
kubectl patch pv $PVNAME -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
```

Re-issue the `kubectl get pv $PVNAME` command and confirm that the `RECLAIM POLICY` for the PV was changed to `Retain`.

At this point you will have a PVC that you can reference in the new ITX RS installation.  For example, the command line option `--set rest.persistence.data.existingClaim="rest-data"` and `--set restV1.persistence.data.existingClaim="rest-data"` can be used to ensure that the ITX RS v1 and v2 APIs use the same PVC.  

As an extra check to make sure the PV will remain in place after deleting the bound PVC, you can now delete the `rest-data` PVC:

```bash
kubectl delete pvc rest-data
```

Re-issue the `kubectl get pv $PVNAME` command and notice that the PV is still present, that its `STATUS` column shows `Released`, and that its `CLAIM` column still indicates that the PV is claimed by the `rest-data` PVC.

Before you can claim this PV again, you need to remove the claim reference from it, which you can do by running the command: 

```bash
kubectl patch pv $PVNAME --type json -p '[{"op": "remove", "path": "/spec/claimRef"}]'
```

You can now create `rest-data` PVC again and bind it directly to the $PVNAME PV:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: rest-data
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
  volumeName: $PVNAME
EOF
```

Re-issue the command `kubectl get pvc rest-data` to ensure the PVC is created and is bound to the `$PVNAME` PV.

Notice that the `volumeName: $PVNAME` element was included in the `spec` section in the previous command to require binding the PVC to the specific PV (referenced by the `PVNAME` shell variable). If a PV was available all along with `Retain` reclaim policy set on it, such as for example if it was previously provisioned by the cluster administrator, you would be able to run the command like the one above to create a PVC and bind it to that PV without having to first go through the steps for dynamically provisioning a PV.

## Referencing existing PVCs

To reference existing PVCs when installing the ITX RS chart, override the chart parameters shown in this table:

| PVC              | Chart Parameter                          |
| ---------------- | ---------------------------------------- |
| `rest-data`      | `rest.persistence.data.existingClaim`    |
| `rest-logs`      | `rest.persistence.logs.existingClaim`    |

The following steps are an example of running the `helm install` command to install ITX RS and reference the existing PVCs. The steps assume that the `rest-data` and `rest-logs` PVCs were previously created and are bound to PVs. The PVC names can be different from the ones shown in this example, and if that is the case adjust the command accordingly.

Before running the command below replace the `[release-name]`, `[chart-dire]` and `[secret-name]` placeholders with the actual values, as follows:

`[release-name]` - the name you choose for the release, for example `ibm`
`[chart-dir]` - path to the ITX product chart directory, or `.` if running the command directly from the chart directory
`[secret-name]` - Kubernetes pull secret with the IBM container registry login credentials

The command is:

```bash
helm install [release-name] [chart-dir] \
--set itxImagePullSecret=[secret-name] \
--set rest.persistence.data.existingClaim=rest-data \
--set rest.persistence.data.existingClaim=rest-logs
```

After the ITX RS installation completes and you start using it and creating artifacts such as maps and flows, those artifacts will be saved in the storage represented by the PVs. The contents of the storage will be retained after uninstalling ITX RS, along with the PV and PVC resources that represent it. The same or different version of ITX RS can then be installed again and pointed to those existing PVCs as shown in the above command, and after ITX is installed the previously created artifacts will again be available for use in ITX RS.

## Identifying dynamically provisioned PVs

If you have previously installed ITX using default chart parameters, the PVCs were automatically created by the install, and the PVs for those PVCs were dynamically provisioned in the cluster with the default `Delete` reclaim policy.

If you plan to uninstall ITX RS and at the same time preserve the artifacts stored in those PVs so that you can reuse them in a future ITX installation, then prior to uninstalling ITX you must change the reclaim policy of those PVs from `Delete` to `Retain`. 

The default, generic names given to the dynamically provisioned PVs in ITX RS will not by themselves indicate the role that they play in ITX and the ITX components that use them. The name of the PVCs bound to the PVs will on the other hand contain that information. Run the `kubectl get pv` command which will display the names of all the PVs. Look at the `NAME` and `CLAIM` columns. For each row, the `NAME` column will indicate the name of the `PV` and the `CLAIM` column will indicate the name of the PVC bound to that PV. The PVC names created by the ITX RS helm install will have `rest-data` and `rest-logs` suffixes. Refer to [this section](#storage-considerations) for more information on the PVs and PVCs used in ITX RS.

 Once you have captured which PV is used for which PVC, you can update (patch) the PVs to change their reclaim policy to `Retain`, uninstall ITX and update the PVs one more time to remove their claim references. Then you can create new PVCs and bind them to the PVs, making sure to bind the right PVC with correct PV identified earlier. Refer to [this section](#preparing-pvcs-and-pvs) for more information and examples. Reference those PVCs when installing ITX RS the next time, as described in [this section](#referencing-existing-pvcs).

## Upgrade and Rollback considerations

ITX RS 3.0.2 Helm chart has the major version `3` (`3.x.y`). To move between ITX RS installations with different minor or patch chart versions, `helm upgrade` and `helm rollback` commands can be used.

Upgrading and rolling back ITX by default preserves the ITX RS PVCs and PVs and their contents. It is however recommended to back up ITX files before performing upgrade or rollback operations. If direct access to the storage provisioned for ITX is available, you can choose to copy the files to an alternative location so that they can be restored later if necessary.

Use the following command to upgrade from an older version of the chart to a newer version, and create a new revision for the ITX RS release:

```bash
helm upgrade [release-name] [chart-dir] --set ...
```

The `[release-name]` should be set to match the existing ITX RS release that is being upgraded. You can use `helm list` command to list all releases in the cluster.

The `[chart-dir]` should be set to match the path of the ITX chart directory of the chart to which to upgrade, or `.` if running the command directly from that chart directory.

The remaining `--set` command arguments should be set to the same values that were used for installing the ITX RS revision that is being upgraded. At the minimum this includes the parameters for specifying the Kubernetes secret with credentials for the container registry. You can use `helm get values` command to obtain the values that were provided by the user for the current install that is being upgraded.

To roll back to a previous revision of ITX RS, issue the command:

```bash
helm rollback [release-name]
```

You can `helm upgrade` and `helm rollback` commands with the `--help` flag for more information about these two commands and all the flags they support, including the `--atomic` flag for the `helm upgrade` command which results in automatic rollback in case of a failed upgrade.

Note that ITX RS does not support rolling upgrade for the **rest** and **executor** components, so for each of them the `helm upgrade` operation will result in terminating the existing replicas before creating the replacement replicas.

As a reference, this table lists all ITX RS product versions and their corresponding Helm chart versions:

| ITX product version    | Helm chart version |
| ---------------------- | ------------------ |
| `11.0.1`               | `3.0.*`            |

---
