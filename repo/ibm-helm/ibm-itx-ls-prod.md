# Name

Helm Chart for IBM&reg; Sterling Transformation Extender Launcher Container 11.0.2
<br>&copy; Copyright IBM Corporation 2025 All rights reserved.
<br>Program Number : 5724-Q23

## Introduction

IBM&reg; Sterling Transformation Extender (ITX) provides a unified solution for data transformation and integration. It enables complex validation, transformation and integration across a wide range of data sources and data formats. The transformation functionality is packaged into modular objects called maps. The maps are included in systems, which are deployed and then triggered by time, file or source input events.

IBM&reg; Sterling Transformation Extender Launcher Container, also referred to as ITX Launcher Server (ITX LS), is a containerized distribution of ITX. It enables maps and systems to be executed within a cluster of worker nodes on the cloud. Maps are designed using ITX Design Studio and systems are defined with ITX Integration Flow Designer. Both ITX Design Studio and Integration Flow Designer are components that are separate from ITX LS. They must be installed and run locally on a Windows host. When you obtain access to the ITX LS component, you will be provided with instructions on how to obtain the ITX Design Studio and Integration Flow Designer components as well.

For additional high-level overview of the ITX Launcher Container product, refer to this [support page](https://www.ibm.com/support/pages/node/7244607).

## Features

The following is a list of high-level features provided by the ITX LS:

- Runtime execution of compiled maps and system flows
- Deployment of maps and systems via Cloud Object Storage
- Automated configuration of certificates, users and passwords that are used during Launcher execution
- Horizontal pod autoscaling support of custom metrics and behavior policies
- Multiple deployments within any cluster namespace
- Customized configurations of all Launcher settings from Helm command line overrides
- System related file deployments from multiple Cloud Object Storage locations
- Kubernetes console logging of Launcher startup, configuration and runtime messages
- Graceful and monitored shutdown of launcher systems 

## Prerequisites

ITX LS supports Red Hat OpenShift cluster version 4.18. It runs on Linux 64 clusters only. When compiling maps in ITX Design Studio, you must choose the option to compile them for Linux 64 platform. Alternatively, you can use multi-platform composite maps, at the cost of increased map size. 

### Installing a PodDisruptionBudget

The ITX LS helm chart does not specify a pod disruption budget. Each consumer of this transformation logic should consider how disruption might impact any specific process.

### Sample Pod Disruption Budget

``` { .yaml }
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: ibm-itx-ls-pdb
spec:
  minAvailable: 1
  selector:
    matchLabels:
      helm.sh/chart: "ibm-itx-ls-prod"
```
### SecurityContextConstraints Requirements

This chart requires a specific type of `SecurityContextConstraints` to be defined and bound to the user or service account of the installation. The predefined `SecurityContextConstraints`, [`nonroot-v2`](https://docs.openshift.com/container-platform/4.18/authentication/managing-security-context-constraints.html), has been verified for this chart.  If your user or service account is bound to this `SecurityContextConstraints` resource, you can proceed to install the chart.

Below is a `SecurityContextConstraints` (SCC) which can be used for finer control of the permissions and capabilities needed to install this chart. It is modeled after the predefined `nonroot-v2` SCC but with the added restriction of only permitting user and group ID, 1001, which is required by ITX Launcher Server.

Custom SecurityContextConstraints definition:
```
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: "This policy allows a single, non-root user"
  name: ibm-itx-ls-scc
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
### Resources Required

The requested and the maximum Memory and CPU size as well as the storage capacity can be specified when configuring an ITX LS instance. The following requested values are selected by default:

| Memory (Gi) | CPU (millicores) | Disk (Gi) | Nodes |
| ----------- | ---------------- | --------- | ----- |
| 4           | 1000             | 10        | 1     |

The storage class of the disk that you choose to use for persistent volumes must be of **filesystem** type.

Following table shows different configuration profiles, the minimum configuration advisable to set up for the ITX LS: 

| Profile     | Memory (Gi) | CPU (millicores) | Disk (Gi) | Nodes                        |
| ----------- | ----------- | ---------------- | --------- | ---------------------------- |
| Starter     | 4           | 1000             | 10        | 1 (master and worker node)   |
| Development | 4           | 2000             | 25        | 3 (1 master, 2 worker nodes) |
| Production  | 16          | 4000             | 50        | 5 (2 master, 3 worker nodes) |

NOTE: The above suggested configuration settings should be adjusted based on your transformation needs by updating the '[resources](#resources-parameters)' and '[persistence](#persistence-parameters)' sections in the "values.yaml" file.

## Limitations

* ITX Launcher Server is supported on OpenShift 4.18, and on Linux 64 only. This means that any maps designed to run on other platforms, such as those using adapters supported on Windows operating system only, will not be able run in ITX LS.
* Because of the unique characteristics of running workloads in Kubernetes environments compared to running them in on-prem environments, existing ITX maps may require adjustments before they can be run in ITX LS, especially if they rely on invoking custom tools or applications, or are making assumptions about the underlying host's operating system, network, local storage or other system-level resources.
* Any files referenced by the maps must assume /data/maps path as the map directory. If a map writes to a file without specifying its path, the file will be created in the /data/maps directory.

## Installing the Chart

ITX Launcher Server can be installed in an online (connected) cluster using command line tools. Download and install `oc` and `helm` command line tools. 

  - [oc](https://docs.openshift.com/container-platform/4.18/cli_reference/openshift_cli/getting-started-cli.html) - for interacting with the OpenShift Cluster
  - [helm](https://helm.sh/docs/intro/install/) - for installing and configuring the embedded chart

Run the following command, after replacing the `<target_namespace>` placeholder with the name of the namespace to which you wish to install the helm chart.

```bash
helm install ibm-itx-ls               \
    --namespace <target_namespace>    \
    --set license=false               \
    ./charts/ibm-itx-ls-prod
```

NOTE: You must read and accept the product licensing terms by using "--set license=true" in the above command line. The product will not operate until this value is set to "true".

## Chart Details
The configuration settings of the Helm chart's "values.yaml" file are listed below. For further details on all ITX LS configuration settings, see the "values.yaml" file. The parameters in the `config` section of the "values.yaml" file enables the ITX configuration settings in the "config.yaml" file to be overridden with values that are specifically tailored for each installation. Each "config.yaml" setting is referenced under the `config` section of the "values.yaml" file according to camel case convention, whereby the first letter of a named setting is lowercase while any remaining words in the name start with a capital letter.

Whenever changes are made to the below parameters during a Helm upgrade, the pods that are associated with the existing installation will not automatically restart - unless the change affects the actual deployment manifest. For example, an update to the image name or resource metrics will change the deployment manifest of the installation, which in turn will trigger an automatic restart of the pods. However, a basic change to a parameter that is linked to the ITX "config.yaml" file, such as the logging level, will not trigger an automatic restart. The restart would need to take place manually, as provided by the Kubernetes scale command.

### License parameter

| Parameter                              | Description                                                     | Default         |
| -------------------------------------- | --------------------------------------------------------------- | --------------- |
| `license`                              | License acceptance                                              | `false`  |

### General parameter

| Parameter                              | Description                                                     | Default         |
| -------------------------------------- | --------------------------------------------------------------- | --------------- |
| `general.replicaCount`                 | Defines number of Launcher instances to start                   | `1`             |
|                                        |                                                                 |                 |

### Image parameters

| Parameter                              | Description                                                     | Default         |
| -------------------------------------- | --------------------------------------------------------------- | --------------- |
| `image.registry`                       | Image registry and namespace                                    | `"cp.icr.io/cp"`   |
| `image.repository`                     | Image repository                                                | `"ibm-itx-ls"` |
| `image.digest`                         | Image digest                                                    | `"sha256:77c7a91a8537ff45a126a51e4d82c410cdc0e12b10f4bfb6eb9a79541298426c"` |
| `image.tag`                            | Image tag                                                       | `"11.0.2.0.20250926"` |
| `image.pullSecret`                     | Image pull secret                                               | `"ibm-encryption-key"` |
| `image.pullPolicy`                     | Image pull policy                                               | `"Always"`       |
| `image.pullPolicyOverride`             | Use pullPolicy instead of 'Always' when using tag               | `false`       |
|                                        |                                                                 |               |

### Security parameter

| Parameter                              | Description                                                     | Default         |
| -------------------------------------- | --------------------------------------------------------------- | --------------- |
| `securityContext.runasUser`            | User ID of the launcher process                                 | `1001` |
|                                        |                                                                 |        |

### Environment parameters 

| Parameter                              | Description                                                     | Default |
| -------------------------------------- | --------------------------------------------------------------- | --------------- |
| `envVariables.userDefined`             | Name of configmap containing environment variables              | `""` |
| `envVariables.commandLine`             | Array of environment variables defined on the command line      | `[]` |
| `envVariables.commandLine.name`        | Name of the environment variable                                | `""` |
| `envVariables.commandLine.value`       | Value of the environment variable                               | `""` |
|                                        |                                                                 |      |

### Launcher parameters 

| Parameter                              | Description                                                     | Default |
| -------------------------------------- | --------------------------------------------------------------- | --------------- |
| `launcher.terminationGracePeriodSeconds` | Number of seconds to gracefully shutdown Launcher             | `90` |
| `launcher.resourceRegistry`            | The MRC file to be used during startup                          | `""` |
| `launcher.admin.username`              | Login name of Launcher user                                     | `"admin"` |
| `launcher.admin.secretFile`            | File name of password, as per [external.secrets.data](#external-integration-parameters) | `""` |
|                                        |                                                                 |      |

### Persistence parameters 

| Parameter                              | Description                                                     | Default |
| -------------------------------------- | --------------------------------------------------------------- | --------------- |
| `persistence.fsGroup`                  | Numeric group id of files in mounted volumes                    | `1001` |
| `persistence.data.capacity`            | Size of the **data** PVC                                        | `"10Gi"` |
| `persistence.data.accessMode`          | Access mode of the **data** PVC                                 | `"ReadWriteMany"` |
| `persistence.data.useDynamicProvisioning` | Enables dynamic provisioning for the **data** PVC            | `true` |
| `persistence.data.storageClassName`    | Storage class name for the **data** PVC                         | `""`                    |
| `persistence.data.matchVolumeLabel.name`  | Select a static PV with matching label name                   | `""`                    |
| `persistence.data.matchVolumeLabel.value` | Select a static PV with matching label value                  | `""`                    |
| `persistence.data.enabled`             | Persistence volume exists for **data** PVC                      | `true`                |
| `persistence.data.existingClaim`       | Existing PVC for the **data** volume                            | `""`                    |
| `persistence.logs.capacity`            | Size of the **logs** PVC                                        | `"10Gi"` |
| `persistence.logs.accessMode`          | Access mode of the **logs** PVC                                 | `"ReadWriteMany"` |
| `persistence.logs.useDynamicProvisioning` | Enables dynamic provisioning for the **logs** PVC            | `true` |
| `persistence.logs.storageClassName`    | Storage class name for the **logs** PVC                         | `""`                    |
| `persistence.logs.matchVolumeLabel.name`  | Select a static PV with matching label name                   | `""`                    |
| `persistence.logs.matchVolumeLabel.value` | Select a static PV with matching label value                  | `""`                    |
| `persistence.logs.enabled`             | Persistence volume exists for **logs** PVC                      | `true`                |
| `persistence.logs.existingClaim`       | Existing PVC for the **logs** volume                            | `""`                    |
|                                        |                                                                 |                                                                |

### HTTP Listener parameters 

| Parameter                              | Description                                                     | Default |
| -------------------------------------- | --------------------------------------------------------------- | --------------- |
| `httpListener.enabled`                 | Enables startup of HTTP Listener                                | `true` |
| `httpListener.ssl.enabled`             | Enables TLS/SSL communication                                   | `false` |
| `httpListener.ssl.certificate.http`    | Name of server certificate for external HTTP/S clients          | `""` |
| `httpListener.ssl.certificate.launcher` | Name of server certificate for internal Launcher clients       | `""` |
| `httpListener.audit`                   | Activate audit of map executions and connection requests        | `false`  |
| `httpListener.logLevel`                | Set log level to none, standard or verbose                      | `"none"` |
| `httpListener.users`                   | Users permitted to trigger http/s adapter watches               | `[]`     |
| `httpListener.users.name`              | Name of authorized user who may login                           | `""`     |
| `httpListener.users.secretFile`        | File name of password, as per [external.secrets.data](#external-integration-parameters) | `""`     |
| `httpListener.users.admin`             | True if user is an administrator                                | `false`  |
| `httpListener.users.paths`             | Array of URL paths that the user is permitted to access         | `[]`     |
| `httpListener.users.paths.name`        | Specific URL that the user may access                           | `""`     |
|                                        |                                                                 |          |

### Service parameters 

| Parameter                              | Description                                                     | Default |
| -------------------------------------- | --------------------------------------------------------------- | --------------- |
| `service.type`                         | Service type of ClusterIP, NodePort or LoadBalancer             | `"ClusterIP"` |
| `service.port.http`                    | Service port for inbound HTTP connections                       | `5017` |
| `service.port.https`                   | Service port for inbound HTTPS connections                      | `5017` |
|                                        |                                                                 |                                                                |

### Service Account parameters 

| Parameter                              | Description                                                     | Default |
| -------------------------------------- | --------------------------------------------------------------- | --------------- |
| `serviceAccount.create`                | Create service account                                          | `false` |
| `serviceAccount.annotations`           | Annotations to add to the service account                       | `{}` |
| `serviceAccount.existingName`          | Name of pre-existing service account                            | `""` |
|                                        |                                                                 |                                                                |

### Route parameters 

| Parameter                              | Description                                                     | Default |
| -------------------------------------- | --------------------------------------------------------------- | --------------- |
| `route.enabled`                        | Create route for outside access to the service                  | `true` |
| `route.host`                           | Explicit host name of the route                                 | `""` |
|                                        |                                                                 |                                                                |

### Ingress parameters 

| Parameter                              | Description                                                     | Default |
| -------------------------------------- | --------------------------------------------------------------- | --------------- |
| `ingress.enabled`                      | Create ingress for outside access to the service                | `false` |
| `ingress.annotations`                  | Annotations for the ingress                                     | `{}` |
| `ingress.className`                    | Sets the "ingressClassName"                                     | `"openshift-default"` |
| `ingress.hosts`                        | Array of host definitions for the ingress                       | `{}` |
| `ingress.tls`                          | Array of TLS definitions for the ingress                        | `{}` |
| `ingress.default.enabled`              | Service is used by default when no rules or match exists        | `true` |
|                                        |                                                                 |                                                                |

### Resources parameters 

| Parameter                              | Description                                                     | Default |
| -------------------------------------- | --------------------------------------------------------------- | --------------- |
| `resources.enabled`                    | Set resource requests and limits                                | `true`          |
| `resources.requests.cpu`               | Mimimum CPU resources                                           | `"1000m"`       |
| `resources.requests.memory`            | Minimum memory resources                                        | `"4Gi"`         |
| `resources.requests.ephemeralStorage`  | Minimum size of ephemeral storage                               | `""`            |
| `resources.limits.cpu`                 | Maximum CPU resources                                           | `"4000m"`       |
| `resources.limits.memory`              | Maximum memory resouces                                         | `"16Gi"`        |
| `resources.limits.ephemeralStorage`    | Maximum size of ephemeral storage                               | `""`            |
|                                        |                                                                 |                                                                |

### Probes parameters 

| Parameter                              | Description                                                     | Default |
| -------------------------------------- | --------------------------------------------------------------- | --------------- |
| `probes.liveness.enabled`              | Activate liveness probe                                         | `false`         |
| `probes.liveness.initialDelaySeconds`  | Initial delay in seconds                                        | `30`            |
| `probes.liveness.periodSeconds`        | Polling period in seconds                                       | `60`            |
| `probes.liveness.timeoutSeconds`       | Timeout in seconds                                              | `45`            |
| `probes.readiness.enabled`             | Activate readiness probe                                        | `false`         |
| `probes.readiness.initialDelaySeconds` | Initial delay in seconds                                        | `30`            |
| `probes.readiness.periodSeconds`       | Polling period in seconds                                       | `60`            |
| `probes.readiness.timeoutSeconds`      | Timeout in seconds                                              | `45`            |
|                                        |                                                                 |                                                                |

### Autoscaling parameters 

| Parameter                              | Description                                                     | Default |
| -------------------------------------- | --------------------------------------------------------------- | --------------- |
| `autoscaling.enabled`                  | Horizontal pod autoscaling enabled                              | `false`         |
| `autoscaling.minReplicas`              | Minimum pod count                                               | `1`                 |
| `autoscaling.maxReplicas`              | Maximum pod count                                               | `5`                 |
| `autoscaling.targetCPUUtilizationPercentage`    | CPU average utilization threshold                      | `80`                 |
| `autoscaling.targetMemoryUtilizationPercentage` | Memory average utilization threshol                    | `80`                 |
| `autoscaling.custom.enabled`           | Custom metric type monitoring                                   | `false`              |
| `autoscaling.custom.types`             | Custom metric type definitions                                  | `[]`              |
| `autoscaling.behavior`                 | Behavior policies for scaling up or down                        | `{}`                 |
|                                        |                                                                 |                                                                |

### ITX Advanced integration parameters 

| Parameter                              | Description                                                     | Default         |
| -------------------------------------- | --------------------------------------------------------------- | --------------- |
| `global.image.repository`              | ITX Advanced image registry and namespace                       | `"image-registry.openshift-image-registry.svc:5000/itxa"` |
| `global.image.name`                    | ITX Advanced image repository name                              | `"itxa-runtime"` |
| `global.image.tag`                     | ITX Advanced image tag                                          | `"10.0.2.0-x86_64-20250626"` |
| `global.image.digest`                  | ITX Advanced image digest                                       | `"sha256:4d30aef1000bd044c2e94bd11e4ee65de02050ef94f0330aced7f27f7fdae7de"` |
| `global.appSecret`                     | ITX Advanced secret                                             | `"itxa-oracle-secrets-new"` |
| `global.secureDBConnection.enabled`    | Activate secure DB connection                                   | `false` |
| `global.secureDBConnection.dbservercertsecretname` | Secure DB connection secret                         | `""` |
| `global.install.itxaRuntime.enabled`   | Enable ITX Advanced installation                                | `false` |
| `global.persistence.claims.name`       | Name of persistence volume claim                                | `"nfs-itxa-claim"` |
|                                        |                                                                 |                                                                |

### External integration parameters 

| Parameter                              | Description                                                     | Default         |
| -------------------------------------- | --------------------------------------------------------------- | --------------- |
| `external.data.volume.path`            | Path used to mount ConfigMap and secret files                   | `"/xdata"` |
| `external.data.volume.size`            | Size of the volume                                              | `"50Mi"` |
| `external.data.tls.subpath`            | Subdirectory path of TLS secret files                           | `"tls"` |
| `external.data.secret.subpath`         | Subdirectory path of generic secret files                       | `"sec"` |
| `external.tls`                         | Array of TLS secret names and keys to get mounted               | `[]` |
| `external.tls.name`                    | Name of the TLS secret                                          | `""` |
| `external.tls.data`                    | Data key of the TLS secret to mount as a file under tls.subpath | `""` |
| `external.secrets`                     | Array of generic secret names and keys to get mounted           | `[]` |
| `external.secrets.name`                | Name of the secret                                              | `""` |
| `external.secrets.data`                | Data key of the secret to mount as a file under secret.subpath  | `""` |
| `external.cos.objects`                 | Cloud Object Storage objects for system download                | `[]` |
| `external.cos.objects.name`            | Name of the zip object to download and unzip from COS           | `"maps.zip"` |
| `external.cos.objects.bucket`          | Bucket that contains the zip file                               | `"itx"` |
| `external.cos.objects.targetDir`       | Destination directory where maps are unzipped                   | `"/data/maps"` |
| `external.cos.objects.platform`        | Cloud platform ("s3", "gcp")                                    | `"s3"` |
| `external.cos.objects.gcp.cf`          | If "gcp" platform, name of the mounted credentials file         | `"cf.json"` |
| `external.cos.objects.s3.accessKey`    | If "s3" platform, name of the mounted access key                | `""` |
| `external.cos.objects.s3.secretKey`    | If "s3" platform, name of the mounted secret key                | `""` |
| `external.cos.objects.s3.region`       | If "s3" platform, name of the region                            | `"us-east-1"` |
| `external.cos.objects.s3.endpoint`     | If "s3" platform, URL of S3 compatible storage service          | `""` |

### Configuration parameters used in "config.yaml"

| Parameter                                | Description                                                   | Default                     |
| ---------------------------------------- | ------------------------------------------------------------- | --------------------------- |
| `config.runtime.launcher.initPendingHigh` | Max number of pending events before pausing listener threads | `200` |
| `config.runtime.launcher.initPendingLow` | Number of pending events before resuming listener threads     | `100` |
| `config.runtime.launcher.maxThreads`     | Max number of threads for map execution                       | `10` |
| `config.runtime.launcher.heartbeatFileInterval` | Interval in seconds for updating Launcher statistics in JSON file | `60` |
| `config.runtime.launcher.launcherLog`    | Log types of e-error, w-warning, s-startup, c-cfg summary     | `"esc"` |
| `config.runtime.launcher.log.info`       | Resource registry aliases and map execution logging           | `false` |
| `config.runtime.launcher.log.warning`    | Log Launcher warning messages                                 | `true` |
| `config.runtime.launcher.log.console`    | Log Launcher messages to Kubernetes console                   | `true` |
| `config.runtime.m4file.cooperativeMode`  | Multiple Launchers can trigger off the same input file        | `true` |
| `config.runtime.connectionsManager.log.info` | Connections Manager informational logging                 | `false` |
| `config.runtime.connectionsManager.pollWaitTimeMin` | Minimal polling interval in milliseconds           | `2000` |
| `config.runtime.connectionsManager.pollWaitTimeMax` | Maximum polling interval in milliseconds           | `5000` |
| `config.runtime.connectionsManager.idle` | Time in seconds before an idle connection is closed           | `60` |
| `config.runtime.connectionsManager.sLim` | Number of connections of a given type that can be kept idle   | `10` |
| `config.runtime.externalJarFiles`        | Array of external jar file names used in Java CLASSPATH       | `[]` |
| `config.runtime.externalJarDirectories`  | Array of directory names used in Java CLASSPATH               | `[]` |
| `config.runtime.jvmOptions`              | Array of JVM options used on Java startup                     | `[]` |
| `config.runtime.httpListener.mtomMode`   | Saves MTOM binary attachments to the MTOM directory           | `true` |
| `config.runtime.httpListener.mtomDir`    | Directory used to save all extracted MTOM attachments         | `/data/tmp` |
| `config.patch.directory`                 | Directory of patches to apply to runtime before startup       | `""` |
| `config.patch.manifest`                  | Manifest file that lists cksum of each fix on a separate line | `"/xdata/cfg/patchmanifest.txt"` |
|                                          |                                                               |       |

The "config.yaml" settings that are not listed above can also be overridden by providing the "camel" case equivalent. See the "config.yaml" template file for exact field names. 

## HTTP/S connectivity

A set of parameters are provided to enable externally inbound connections to be serviced by the [HTTP Listener](#http-listener-parameters). The external client connections are secured via the TLS protocol by using the `httpListener.ssl.enabled` boolean parameter and setting the `httpListener.ssl.certificate.http` value to the name of the certificate label in the default "dtx_keys.p12" [keystore file](#certificate-keystore). These secured connections can in turn be authorized via [basic authentication](#user-authorization).

### Certificate keystore
The keystore file, "dtx_keys.p12", contains TLS certificates that can be used to authenticate incoming HTTP/S connections. The keystore can be prepopulated with a server certificate and stored as a Kubernetes secret, which is then referenced at runtime by the HTTP Listener. 

The Kubernetes secret for both the keystore, "dtx_keys.p12", and its password stash, "dtx_keys.sth", can be created as follows:

```bash
kubectl create secret generic itx-ls-keystore --from-file=dtx_keys.p12=dtx_keys.p12 --from-file=dtx_keys.sth=dtx_keys.sth
```

Both secrets can be referenced at install time as follows:

```bash
helm install test . -f overrides.yaml
```

Here is the "overrides.yaml"  file that contains the overridden settings:
```
httpListener:
  ssl: 
    enabled: true  
  certificate:
    http: "mycert"
external:
  secrets:
    - name: "itx-ls-keystore"
      data: "dtx_keys.p12"
    - name: "itx-ls-keystore"
      data: "dtx_keys.sth"
```

When the key store and stash files, namely "dtx_keys.p12" and "dtx_keys.sth", are mounted as secrets, this enables custom certificates to be preconfigured by a Kubernetes administrator and automatically deployed with the ITX LS installation. Both the keystore and keystash files can now be directly referenced in the Helm chart with the settings, "config.runtime.sslServer.keyStore|keyStash". If not directly referenced, then both files are automatically copied from their secretly mounted location (e.g. /xdata/sec) to either the default "/opt/runtime/config" location or the directory specified within the "config.runtime.sslServer.keyStore|keystash" setting. In this way, The HTTP Listener is started in a secure way with a preconfigured set of certificates. The "mycert" label references the server certificate to be used during startup.

When the keystore is copied to a different location than the one mounted under the "/xdata/sec" folder, all the TLS certificates with a ".crt" extension under the "/xdata/tls" folder will get automatically imported into the keystore file. This enables new certificates to be readily imported into the default keystore. The [external tls settings](#external-integration-parameters) can be used to reference any secret that needs to be automatically imported as a TLS certificate into the key store. 

### User authorization

As part of the TLS connection, user IDs and passwords can be predefined to authorize connections. First, create a user secret to define all the user ID and passwords, as follows: 

```bash
kubectl create secret generic itx-ls-users --from-literal=produser=produserpswd --from-literal=admin=adminpswd
```

Here is the "users.yaml" file that contains the user authorization settings, which in turn reference the just created secret:
```
httpListener:
  users: 
    - name: "admin"
      secretFile: "itx-ls-users"
      admin: true
    - name: "produser"
      secretFile: "itx-ls-users"
      admin: false
      paths:
        - name: "/*"
```

Deployment can be run as follows:
```bash
helm install test . -f overrides.yaml -f users.yaml
```

In the example above, only the "produser" can invoke maps from externally inbound HTTP/S connections. All other connection attempts without the proper user id and password will be dropped as unauthorized.

## Storage

The ITX LS storage requirements can make use of both Cloud Object Storage (COS) and persistent volume claims (PVC). The COS enables the ITX LS deployment to auto deploy and configure multiple sets of systems. The deployments are decoupled from persistent storage and can readily scale in a cloud native way across all available worker nodes in the cluster.

Deployments can also leverage PVC storage to retain map and system definitions as well as generated output. During map execution, output results and audit files gets stored to the PVC. Since deployment, execution and logging results may require storage that persists after a pod restart or helm uninstall, the PVC needs to be [retained](#preparing-pvcs-and-pvs). Otherwise, all the deployed artifacts and generated output will get deleted after the ITX LS pod is stopped. 

### Cloud Object Storage
Cloud Object Storage (COS) is supported during an ITX LS installation. As long as S3-based or Google-based cloud storage is accessible, the ITX LS install will automatically download a user-specified "zip" file and then proceed to unzip it under the pre-defined "/data/maps" folder. In this way, the ITX LS deployment is automatically ready to execute system requests without manual intervention.   

Refer to the "external.cos" section of the "values.yaml" file for setup of this capability. Once activated, the deployment will automatically be initialized and ready to process system defined requests after the successful download and deployment of the zip file contents. A COS status report can be viewed by examining the Kubernetes log file, as the following command illustrates: `kubectl logs < your-pod-name > -c ibm-itx-ls-prod-cos-download`. 

### Persistent Storage
When Cloud Object Storage is not used, the ITX LS deployment requires persistent volume claims (PVCs) in the cluster to store maps and execution results. The following table lists the PVCs used in the ITX LS installation to provision and reference the necessary persistent volumes (PVs). The values shown in the `PVC` column represent suffixes of the names given to the PVCs when they are created automatically by the ITX LS installation. The fully generated PVC names will vary from one installation to another and will be based on the release name provided in the `helm install` command.

| PVC                       | Container Mount Point     | Primary Use                        |
| ------------------------- | ------------------------- | ---------------------------------- |
| `data` (see **Note**)     | `/data`                   | Launcher maps and system files |   
| `logs` (see **Note**)     | `/logs`                   | Launcher system logs |   

**Note:** Both PVCs are shared across all Launcher pods.

If ITX LS is installed using default chart parameters, the necessary PVCs are created. The PVs to which those PVCs bind may be dynamically provisioned with the `Delete` reclaim policy. This in turn results in the automatic deletion of those PVCs and PVs when ITX is subsequently uninstalled. 

To prevent the storage from being automatically deleted when ITX LS is uninstalled, you can choose to provision and configure the storage separately before installing ITX LS and then point to that storage in the `helm install` command. To accomplish that, you can perform the following steps:

* Prepare the required PVCs and PVs prior to installing ITX (see [Preparing PVCs and PVs](#preparing-pvcs-and-pvs) for details)
* Reference the prepared PVCs when installing ITX LS (see [Referencing existing PVCs](#referencing-existing-pvcs) for details)

### Preparing PVCs and PVs

When installing the ITX LS installation, create and bind the `data` and `logs` PVCs that will be used by Launcher pods for storing files.

To maximize the flexibility for scheduling ITX LS pods that share the `data` and `logs` PVCs, it is recommended, although not required, to use a storage provider that supports `ReadWriteMany` (`RWX`) access mode and use it for the `data` and `logs` storage. Kubernetes clusters often do not provide such support by default, and an external storage provider needs to be installed and configured in the cluster to provide the support.

Refer to the official Kubernetes documentation for detailed information on creating PVCs in the cluster. Cluster administrators are typically tasked with provisioning PVs using the available storage providers and making them available for claims by the application's PVCs.

The following set of steps is provided for illustration purposes and demonstrates how a PVC can be created and configured in preparation for the ITX LS installation. The steps are for the `data` PVC in ITX LS, but the same steps can be followed to prepare the `logs` PVC that is required by ITX LS. Refer to [this section](#storage-considerations) for information about the PVCs and PVs used in ITX LS.

Start by running the following command to create the `data` PVC:

```bash
cat <<EOF | kubectl apply -f - 
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: itx-data
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
kubectl get pvc itx-data
```

The output will display information about the `itx-data` PVC, including its name under the `NAME` column and the name of the PV to which it was bound under the `VOLUME` column.

The remaining steps shown here refer to the PV name via the `PVNAME` shell variable, so before running the remaining steps store the PV name in that shell variable by running this command:

```bash
PVNAME=`(kubectl get -o template pvc itx-data --template={{.spec.volumeName}})`
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

If you were to delete the `itx-data` PVC at this time, the PV would be automatically deleted along with its underlying storage contents.

Change the reclaim policy for the PV from `Delete` to `Retain` by running the command:

```bash
kubectl patch pv $PVNAME -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
```

Re-issue the `kubectl get pv $PVNAME` command and confirm that the `RECLAIM POLICY` for the PV was changed to `Retain`.

At this point you will have a PVC that you can reference in the new ITX LS installation.  For example, the command line option `--set persistence.data.existingClaim="itx-data"` can be used to ensure that the ITX LS uses the same PVC.  

As an extra check to make sure the PV will remain in place after deleting the bound PVC, you can now delete the `itx-data` PVC:

```bash
kubectl delete pvc itx-data
```

Re-issue the `kubectl get pv $PVNAME` command and notice that the PV is still present, that its `STATUS` column shows `Released`, and that its `CLAIM` column still indicates that the PV is claimed by the `itx-data` PVC.

Before you can claim this PV again, you need to remove the claim reference from it, which you can do by running the command: 

```bash
kubectl patch pv $PVNAME --type json -p '[{"op": "remove", "path": "/spec/claimRef"}]'
```

You can now create `itx-data` PVC again and bind it directly to the $PVNAME PV:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: itx-data
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
  volumeName: $PVNAME
EOF
```

Re-issue the command `kubectl get pvc itx-data` to ensure the PVC is created and is bound to the `$PVNAME` PV.

Notice that the `volumeName: $PVNAME` element was included in the `spec` section in the previous command to require binding the PVC to the specific PV (referenced by the `PVNAME` shell variable). If a PV was available all along with `Retain` reclaim policy set on it, such as for example if it was previously provisioned by the cluster administrator, you would be able to run the command like the one above to create a PVC and bind it to that PV without having to first go through the steps for dynamically provisioning a PV.

### Referencing existing PVCs

To reference existing PVCs when installing the ITX LS chart, override the chart parameters shown in this table:

| PVC         | Chart Parameter                    |
| ----------- | ---------------------------------- |
| `data`      | `persistence.data.existingClaim`   |
| `logs`      | `persistence.logs.existingClaim`   |

The following steps are an example of running the `helm install` command to install ITX LS and reference the existing PVCs. The steps assume that the `data` and `logs` PVCs were previously created and are bound to PVs. The PVC names can be different from the ones shown in this example, and if that is the case adjust the command accordingly.

Before running the command below replace the `[release-name]`, `[chart-dir]` and `[secret-name]` placeholders with the actual values, as follows:

`[release-name]` - the name you choose for the release, for example `test`\
`[chart-dir]` - path to the ITX product chart directory, or `.` if running the command directly from the chart directory\
`[secret-name]` - Kubernetes pull secret with the IBM container registry login credentials

The command is:

```bash
helm install [release-name] [chart-dir] \
--set image.pullSecret=[secret-name] \
--set persistence.data.existingClaim=itx-data \
--set persistence.data.existingClaim=itx-logs
```

After the ITX LS installation completes and maps start getting run, the map results will be saved in the storage represented by the PVs. The contents of the storage will be retained after uninstalling ITX LS, along with the PV and PVC resources that represent it. The same or different version of ITX LS can then be installed again and pointed to those existing PVCs as shown in the above command.

### Identifying dynamically provisioned PVs

If you have previously installed ITX LS using default chart parameters, the PVCs were automatically created by the install, and the PVs for those PVCs were dynamically provisioned in the cluster with the default `Delete` reclaim policy.

If you plan to uninstall ITX LS and at the same time preserve the artifacts stored in those PVs so that you can reuse them in a future ITX installation, then prior to uninstalling ITX you must change the reclaim policy of those PVs from `Delete` to `Retain`. 

The default, generic names given to the dynamically provisioned PVs in ITX LS will not by themselves indicate the role that they play in ITX and the ITX components that use them. The name of the PVCs bound to the PVs will on the other hand contain that information. Run the `kubectl get pv` command which will display the names of all the PVs. Look at the `NAME` and `CLAIM` columns. For each row, the `NAME` column will indicate the name of the `PV` and the `CLAIM` column will indicate the name of the PVC bound to that PV. The PVC names created by the ITX LS helm install will have `data` and `logs` suffixes. Refer to [this section](#storage-considerations) for more information on the PVs and PVCs used in ITX LS.

Once you have captured which PV is used for which PVC, you can update (patch) the PVs to change their reclaim policy to `Retain`, uninstall ITX and update the PVs one more time to remove their claim references. Then you can create new PVCs and bind them to the PVs, making sure to bind the right PVC with correct PV identified earlier. Refer to [Preparing PVCs and PVs](#preparing-pvcs-and-pvs) for more information and examples. Reference those PVCs when installing ITX LS the next time, as described in [Referencing existing PVCs](#referencing-existing-pvcs).

### Extra Content 

The `/data/extra` folder is used to host any JAR files, Java classes, or shared libraries that are required for running the maps but that are not included with the product and you will be providing separately. An example is JDBC and ODBC drivers to be utilized with JDBC and ODBC adapters. Since these components will be loading and executing in the ITX Launcher Server pods, it is critical that you ensure that they come from reputable sources that you trust, and that you validate them before enabling them for use with the ITX LS.

### Backup

While ITX LS operates on compiled maps (mmc files) and system definitions (msl files), the original source maps (mms files) and system definitions (msd files) must remain backed up within on-prem systems. Their backup is outside the scope of ITX LS installation and deployment.

If you need to back up any files in the persistent volumes that were produced by the maps or systems running under ITX LS, you must download those files individually.

### Encryption

ITX Launcher Server does not itself perform encryption and decryption of the data at rest. To ensure the data in your persistent volumes is encrypted at rest, when defining persistent volume claims for the ITX LS, you must specify a filesystem-based storage class that is available in your cluster which supports encryption. For some storage classes, the data may be encrypted automatically by their respective storage providers, but in some cases additional manual configuration may be necessary, such as definition and enablement of encryption keys. For more information, see documentation for the storage classes available in your environment.

In those cases where filesystem-based encryption is not available or only needed in select circumstances, the ITX **cipher** adapter may be used in maps, systems and configuration files to encrypt data that is stored to disk and decrypt the same data that is retrieved from disk. This capability is documented in the ITX Design Studio examples and online help. The data is encrypted with a highly secure symmetric AES-256 cipher. The key that is used for encryption and decryption can be stored as a secret in the cluster. By mounting the secret key via the `external.secrets` section of the values.yaml file, the data at rest on disk remains securely encrypted.

## Scaling

The ITX Launcher Server pods run independently of each other. The number of pods running at any time can be controlled through the **replicaCount** setting exposed by the product. When sufficient system resources are available and have been provisioned for the deployment, the deployment will be able to handle additional workload.

In addition to supporting multiple pods in a single deployment (ITX LS instance), multiple deployments can be installed within the same cluster. This enables each deployment of an ITX LS instance to be tailored to a specific business requirement. 

The ITX LS pods can be autoscaled based on CPU or Memory utilization thresholds getting reached on the worker nodes of the cluster. Autoscaling of ITX LS pods is disabled by default in the Helm Chart. When enabling the autoscaling option, the **replicaCount** setting will get overridden. The ITX LS deployment supports horizontal pod autoscaling but does not support vertical pod autoscaling at this time.

## Uninstalling

To uninstall ITX LS, run the following command, after replacing the `<target_namespace>` placeholder with the name of the namespace from which you wish to uninstall the ITX LS deployment.

```
helm uninstall ibm-itx-ls --namespace <target_namespace>
```

## Upgrade and Rollback considerations

ITX LS Helm chart has the major version listed in the first digit, such as `3` in `3.x.y`. To move between ITX LS installations with different minor chart versions, `helm upgrade` and `helm rollback` commands can be used.

Upgrading and rolling back ITX by default preserves the ITX LS PVCs and PVs and their contents. However, it is recommended to back up ITX files before performing upgrade or rollback operations. If direct access to the storage provisioned for ITX is available, you can choose to copy the files to an alternative location so that they can be restored later if necessary.

Use the following command to upgrade from an older minor version of the chart to a newer minor version within the same major release, and create a new revision for the ITX LS release:

```bash
helm upgrade [release-name] [chart-dir] --set ...
```

The `[release-name]` should be set to match the existing ITX LS release that is being upgraded. You can use `helm list` command to list all releases in the cluster.

The `[chart-dir]` should be set to match the path of the ITX chart directory, or `.` if running the command directly from the chart directory.

The remaining `--set` command arguments should be set to the same values that were used for installing the ITX LS revision that is being upgraded. At the minimum this includes the parameters for specifying the Kubernetes secret with credentials for the container registry. You can use `helm get values` command to obtain the values that were provided by the user for the current install that is being upgraded.

To roll back to a previous revision of ITX LS, issue the command:

```bash
helm rollback [release-name]
```

You can `helm upgrade` and `helm rollback` commands with the `--help` flag for more information about these two commands and all the flags they support, including the `--atomic` flag for the `helm upgrade` command which results in automatic rollback in case of a failed upgrade.

As a reference, this table lists the ITX LS product versions and their corresponding Helm chart versions:

| ITX product version    | Helm chart version |
| ---------------------- | ------------------ |
| `11.0.2`               | `3.1.*`            |
| `10.1.2`               | `2.0.*`            |

## Migration
The ITX LS version 11.x configuration is customized according to the settings in the "values.yaml" file. While many of these values are similar to previous versions, they are not equivalent because of the added container and launcher capabilities. When upgrading from a prior 10.x version, the "values.yaml" entries need to be manually migrated. The same applies for the Launcher configuration settings as previously provided by the "dtx.ini" file, which is currently deprecated and replaced by the "config.yaml" file.

In cases where the deprecated "dtx.ini" file settings still need to be used before transitioning to the "config.yaml" format, the ITX LS version 11.x will use the "dtx.ini" file found under the "/data/config" folder. If not found, the "config.yaml" file will be searched for in the same location. If neither are found, the default set of settings are used. The default settings can be customized on a per deployment basis by overriding the "values.yaml" file via the Helm chart command line option, "-f your_overrides.yaml". See the '[Configuration parameters](#configuration-parameters-used-in-configyaml)' section for further guidelines on updating the default "values.yaml" settings so that you get a customized "config.yaml" file for your specific deployment.

## Deployment Guidelines

### GDPR

Users of ITX LS are responsible for ensuring their own compliance with various laws and regulations, including the European Union General Data Protection Regulation (GDPR). Users are solely responsible for obtaining advice of competent legal counsel as to the identification and interpretation of any relevant laws and regulations that may affect the user's business and any actions the user may need to take to comply with such laws and regulations.

The products, services, and other capabilities described herein are not suitable for all user situations and may have restricted availability. HCL and IBM do not provide legal, accounting, or auditing advice or represent or warrant that its services or products will ensure that users are in compliance with any law or regulation.

For more information about GDPR, refer to:
- [EU GDPR Information Portal](https://ec.europa.eu/info/law/law-topic/data-protection_en)
- [IBM GDPR website](http://ibm.com/GDPR)

ITX Launcher Server enables an organization to integrate industry-based customer, supplier and business partner transactions across the enterprise. It helps automate complex transformation and validation of data between a range of different formats and standards. Securing and managing the personal data passed through the ITX Launcher Server for processing is a sole responsibility of the user. Some of the security guidelines that follow may help in securing the personal data:

- Harden the master and worker nodes in the cluster based on security benchmarks like CIS Benchmarks
- Harden the Red Hat Enterprise Linux OS based on security benchmarks like CIS Benchmarks
- Secure the communication with ITX LS using HTTPS protocol instead of HTTP
- Secure the credentials of external systems accessed by ITX LS using AES-256 encryption in Resource Registry
- Use secure options provided by the data source/target adapters where applicable to securely process the data
- Encrypt and decrypt the data, process data through ITX Launcher Server's Cipher and OpenPGP adapters
- Secure the transport of data from/to maps run by ITX Launcher Server with HTTPS, FTPS adapters
- Monitor the outputs generated by the ITX LS, remove input and output files when not required
- Look out for security bulletins from ITX and Red Hat support teams to resolve security vulnerabilities
- Apply the security patches when released and keep the cluster nodes up to date to avoid security threats
- Refer ITX Knowledge Center and Red Hat OpenShift documentation on the security features available in the products
- Scan map and input files for malware/virus before uploading to the data volume through application endpoint
- Scan driver files and user-defined exit modules for malware/virus before uploading through application endpoint

### CIS Benchmarks

CIS Benchmarks are best practices for the secure configuration of a target system. CIS Benchmarks are developed through a unique consensus-based process comprised of cybersecurity professionals and subject matter experts around the world. CIS benchmark guides are developed and accepted by government, business, industry, and academia.

CIS Benchmarks for Kubernetes and Red Hat OpenShift Container platform environments are available for download from the [CIS Benchmarks website](https://learn.cisecurity.org/benchmarks). These benchmark guides provide information on hardening the master and worker nodes in the OpenShift cluster. Guidance on hardening the Red Hat Enterprise Linux OS can be found in the [Red Hat documentation](https://docs.openshift.com/container-platform/4.18/security/container_security/security-hardening.html). 

ITX Launcher Server has been hardened to a level that satisfies the IBM certification requirements for Container Software. Users are responsible for hardening of the nodes in the cluster that meets their security policies and requirements. 

## Auditing

IBM License Service provides license consumption reporting and audit readiness for IBM containerized software. IBM License Service is useful to any customer that wants to view and understand the license consumption of IBM Certified Container Software running on a Red Hat OpenShift cluster. For information about deploying IBM License Service and tracking license usage of standalone IBM Certified Container software, check the [license tracking](https://www.ibm.com/docs/en/cpfs?topic=platforms-tracking-license-usage-stand-alone-containerized-software) page.

License audit snapshot is a record of license usage in your environment over a period of time. The audit snapshot is a compressed .zip package that includes a complete set of audit documents that certify your cumulative license usage. Audit snapshot is needed for compliance and audit purposes. For core license metrics, user is obliged to use License Service and periodically generate audit snapshots to fulfill container licensing requirements. For more information about core license metrics, see [Reporter metrics](https://www.ibm.com/docs/en/cloud-paks/cp-integration/2021.4?topic=service-reported-metrics).

You do not need to complete any manual actions to prepare the license audit snapshot; you only need to generate it. At this point, the license audit snapshot is required to be generated at least once a quarter, and stored for two years in a location from which it could be retrieved and delivered to auditors. Refer to [retrieving audit page](https://www.ibm.com/docs/en/cpfs?topic=pcfls-apis#auditSnapshot) for more information on capturing license audit snapshot for compliance and audit purposes.

`Note`: The requirements might change over time. You should always make sure to follow the latest requirements that are posted on Passport Advantage.

## Documentation

For general information about the IBM Sterling Transformation Extender product portfolio, check the [Overview]( https://www.ibm.com/products/transformation-extender) page.

For more technical details about IBM Sterling Transformation Extender in general, including the design of maps and flows with the ITX Design Studio and ITX Integration Flow Designer for use with ITX LS, refer to the ITX [Knowledge Center](https://www.ibm.com/docs/en/ste/11.0.2).

For additional information about the IBM Sterling Transformation Extender Launcher Container product, refer to this [support page](https://www.ibm.com/support/pages/node/7244607).

---
