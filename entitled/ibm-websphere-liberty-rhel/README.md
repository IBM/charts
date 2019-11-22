# WebSphere Liberty Helm Chart for RHOS

## Introduction

WebSphere Liberty is a fast, dynamic, and easy-to-use Java EE application server. Ideal for developers, but also ready for production, Liberty is a combination of IBM technology and open source software, with fast startup times (<2 seconds), and a simple XML configuration. All in a package that's <70 MB to download. You can be developing applications in no time. With a flexible, modular runtime, you can download additional features from the Liberty Repository or strip it back to the essentials for deployment into production environments. Everything in Liberty is designed to help you get your job done how you want to do it.

## Resources Required

A persistent volume is required, if you plan on using the transaction service within Liberty. The `server.xml` Liberty configuration file must be configured to place the transaction log on this volume so that it persists, if the server fails and restarts.

## Accessing WebSphere Liberty

From a browser, use http://*external-ip*:*nodeport* to access the application.

## Chart Details

## Prerequisites

### Red Hat OpenShift `SecurityContextConstraints` Requirements

This chart requires a `SecurityContextConstraints` to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined `SecurityContextConstraints` name: [`ibm-restricted-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this `SecurityContextConstraints` resource you can proceed to install the chart.

#### Creating the required resources

This chart defines a custom `SecurityContextConstraints` which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom `SecurityContextConstraints` resource using the supplied instructions or scripts in the `pak_extensions/pre-install` directory.

* From the user interface, you can copy and paste the following snippets to enable the custom `SecurityContextConstraints`
  * Custom `SecurityContextConstraints` definition:

  ```yaml
  apiVersion: security.openshift.io/v1
  kind: SecurityContextConstraints
  metadata:
    annotations:
    name: ibm-websphere-liberty-rhel-scc
  allowHostDirVolumePlugin: false
  allowHostIPC: false
  allowHostNetwork: false
  allowHostPID: false
  allowHostPorts: false
  allowPrivilegedContainer: false
  allowedCapabilities: []
  allowedFlexVolumes: []
  defaultAddCapabilities: []
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

* From the command line, you can run the setup scripts included under `pak_extensions/pre-install`
  As a cluster admin the pre-install instructions are located at:
  * `pre-install/clusterAdministration/createSecurityClusterPrereqs.sh`

  As team admin the namespace scoped instructions are located at:
  * `pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh`

### Limitations

Please refer to the Release Notes.

### Installing the Chart

The Helm chart has the following values that can be overridden by using `--set name=value`. For example:

```bash
$ helm repo add ibm-charts https://raw.githubusercontent.com/IBM/charts/master/repo/stable/
$ helm install --tls --name my-release --set resources.constraints.enabled=true --set autoscaling.enabled=true --set autoscaling.minReplicas=2 ibm-charts/ibm-websphere-liberty-rhel --debug
```

### Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release --purge --tls
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

#### Cleanup any prerequisite resources that were created

Run cleanup scripts included in the `pak_extensions/post-delete` directory to clean up namespace and cluster scoped resources when appropriate.

### Configuration

| Qualifier | Parameter  | Definition | Allowed Value |
|---|---|---|---|
| `image`   | `pullPolicy` | Image Pull Policy | `Always`, `Never`, or `IfNotPresent`. Defaults to `Always` if `:latest` tag is specified, or `IfNotPresent` otherwise. See Kubernetes - [Updating Images](https://kubernetes.io/docs/concepts/containers/images/#updating-images)  |
|           | `repository` | Name of image, including repository prefix (if required). | See Docker - [Extended tag description](https://docs.docker.com/engine/reference/commandline/tag/#parent-command) |
|           | `tag`        | Docker image tag. | See Docker - [Tag](https://docs.docker.com/engine/reference/commandline/tag/) |
|           | `license`    |  The license state of the image being deployed. | `Empty` (default) for development. `accept` if you have previously accepted the production license. `base` `core` or `nd` to apply the license at deployment time (see below). |
|           | `readinessProbe`       | Configure when container is ready to start accepting traffic. Use this to override the default readiness probe configuration. See [Configure Liveness and Readiness Probes](#configure-liveness-and-readiness-probes) for more information. | YAML object of readiness probe |
|           | `livenessProbe`        | Configure when to restart container. Use this to override the default liveness probe configuration. See [Configure Liveness and Readiness Probes](#configure-liveness-and-readiness-probes) for more information. | YAML object of liveness probe |
|           | `extraEnvs`        | Extra environment variables for the image. | YAML array of environment variables |
|           | `lifecycle`        | Handlers for the PostStart and PreStop lifecycle events of container. | YAML object of lifecycle handlers |
|           | `serverOverridesConfigMapName`        | Name of the ConfigMap that contains server configuration overrides (within key 'server-overrides.xml') to configure your Liberty server at deployment. | Name of ConfigMap |
|           | `extraVolumeMounts`  | Additional `volumeMounts` for server pods | YAML array of `volumeMounts` definitions |
|           | `security`  | Configure the security attributes of the image | YAML object of security attributes |
| `resourceNameOverride` |     | This name will be appended to the release name to form the name of resources created by the chart. By default, this is set to the chart name. |  |
| `deployment`     | `annotations` | Additional annotations to be added to Deployment (or StatefulSet if persistence is enabled) | YAML object of annotations |
|                  | `labels`     | Additional labels to be added to Deployment (or StatefulSet if persistence is enabled)  | YAML object of labels |
| `pod`     | `annotations` | Additional annotations to be added to pods | YAML object of annotations |
|           | `labels`     | Additional labels to be added to pods  | YAML object of labels |
|           | `extraInitContainers` | Additional Init Containers which are run before the containers are started | YAML array of `initContainers` definitions |
|           | `extraContainers`     | Additional containers to be added to the server pods | YAML array of `containers` definitions |
|           | `extraVolumes`        | Additional volumes for server pods | YAML array of `volume` definitions |
|           | `security`  | Configure the security attributes of the pod | YAML object of security attributes |
| `service` | `enabled`    | Specifies whether the `HTTP` port service is enabled or not.  |  |
|           | `name`       | The service metadata name and DNS A record.  | |
|           | `port`       | The port that this container exposes.  |   |
|           | `targetPort` | Port that will be exposed externally by the pod. | |
|           | `type`       | Specify type of service. | Valid options are `ClusterIP` and `NodePort`. See [Publishing services - service types](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services---service-types). This parameter is ignored for headless services and instead, it is forced to `clusterIP` with a value of `None`. This chart makes a service headless when persistence is enabled, which is done by setting either `logs.persistTransactionLogs` or `logs.persistLogs` to `true`. See [Headless services](https://kubernetes.io/docs/concepts/services-networking/service/#headless-services). |
|           | `labels`         | Additional labels to be added to service.                       |  YAML object of labels  |
|           | `annotations`    | Additional annotations to be added to service.                  |  YAML object of annotations  |
|           | `extraPorts`     | List of additional ports that are exposed by this service.      |  YAML list service ports. See [Virtual IPs and service proxies](https://kubernetes.io/docs/concepts/services-networking/service/#virtual-ips-and-service-proxies).    |
|           | `extraSelectors` | List of additional label keys and values. Kubernetes routes service traffic to pods with label keys and values matching selector values.| See [Services](https://kubernetes.io/docs/concepts/services-networking/service/). |
| `iiopService`| `enabled` | Specifies whether the IIOP port service is enabled or not.  |   |
|           | `nonSecurePort`       | The IIOP port that this container exposes.  |   |
|           | `nonSecureTargetPort` | IIOP Port that will be exposed externally by the pod. | |
|           | `securePort`       | The secure IIOP port that this container exposes. Specifying this port is needed if SSL is enabled. |   |
|           | `secureTargetPort` | Secure IIOP Port that will be exposed externally by the pod. Specifying this port is needed if SSL is enabled. | |
|           | `type`       | Specify type of service. | Valid options are `ClusterIP` and `NodePort`. See [Publishing services - service types](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services---service-types). This parameter is ignored for headless services and instead, it is forced to `clusterIP` with a value of `None`. This chart makes a service headless when persistence is enabled, which is done by setting either `logs.persistTransactionLogs` or `logs.persistLogs` to `true`. See [Headless services](https://kubernetes.io/docs/concepts/services-networking/service/#headless-services).|
| `jmsService`| `enabled`  | Specifies whether the JMS port service is enabled or not.  |   |
|           | `port`      | The JMS port that this container exposes.  |   |
|           | `targetPort` | JMS Port that will be exposed externally by the pod. | |
|           | `type`       | Specify type of service. | Valid options are `ClusterIP` and `NodePort`. See [Publishing services - service types](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services---service-types). This parameter is ignored for headless services and instead, it is forced to `clusterIP` with a value of `None`. This chart makes a service headless when persistence is enabled, which is done by setting either `logs.persistTransactionLogs` or `logs.persistLogs` to `true`. See [Headless services](https://kubernetes.io/docs/concepts/services-networking/service/#headless-services). |
| `ssl`       | `enabled`                       | Specifies whether SSL is enabled. Set to true only if Liberty server is configured to use SSL in the Docker image. | `true` (default) or `false` |
|           | `useClusterSSLConfiguration`    | Set to true if you want to use the SSL ConfigMap and secrets generated by the createClusterSSLConfiguration option. Set to false if the Docker image already has SSL configured. | `false` (default) or `true` |
|           | `createClusterSSLConfiguration` | Specifies whether to automatically generate SSL ConfigMap and secrets. The generated ConfigMap is: liberty-config.  The generated secrets are: `mb-keystore`, `mb-keystore-password`, `mb-truststore`, and `mb-truststore-password`.  Only generate the SSL configuration one time. If you generate the configuration a second time, errors might occur. | `false` (default) or `true` |
| `ingress` | `enabled`        | Specifies whether to use ingress.        |  `false` (default) or `true`  |
|           | `rewriteTarget`  | Specifies the target URI where the traffic must be redirected. | See Kubernetes - Annotation `ingress.kubernetes.io/rewrite-target` - [Rewrite Target](https://github.com/kubernetes/ingress-nginx/tree/master/docs/examples/rewrite)  |
|           | `path`           | Specifies the path for the Ingress HTTP rule.    |  See Kubernetes - [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)  |
|           | `host`           | Specifies a fully qualified domain names of Ingress, as defined by RFC 3986. |  See [Ingress configuration](#ingress-configuration) for more into on this. |
|           | `secretName`     | Specifies the name of the Kubernetes secret that contains Ingress' TLS certificate and key.   |  See [Ingress configuration](#ingress-configuration) for more into on this. |
|           | `labels`         | Specifies custom labels.         |  YAML object of labels  |
|           | `annotations`    | Specifies custom annotations.    |  YAML object of annotations  |
| `persistence` | `name`                   | Descriptive name that will be used as a prefix for the generated persistence volume claim. A volume is only bound if either `tranlog.persistLogs` or `logs.persistLogs` is set to `true`. | |
|             | `useDynamicProvisioning` | If `true`, the persistent volume claim will use the storageClassName to bind the volume. If `storageClassName` is not set then it will use the default StorageClass setup by kube Administrator.  If `false`, the selector will be used for the binding process. | `true` (default) or `false` |
|             | `fsGroupGid`             | Defines file system group ID for volumes that support ownership management. This value is added to the container’s supplemental groups.  | `nil` |
|             | `storageClassName`       | Specifies a StorageClass pre-created by the Kubernetes sysadmin. When set to `""`, then the PVC is bound to the default `storageClass` setup by kube Administrator. | |
|             | `selector.label`         | When matching a PV, the label is used to find a match on the key. | See Kubernetes - [Labels and Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/). | |
|             | `selector.value`         | When matching a PV, the value is used to find a match on the values. | See Kubernetes - [Labels and Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/). | |
|             | `size`                   | Size of the volume to hold all the persisted data. | Size in Gi (default is `1Gi`) |
| `logs`        | `persistLogs`            | When `true`, the server logs will be persisted to the volume bound according to the persistence parameters. | `false` (default) or `true` |
|             | `persistTransactionLogs` | When `true`, the transaction logs will be persisted to the volume bound according to the persistence parameters. | `false` (default) or `true` |
|             | `consoleFormat`          | _[18.0.0.1+]_ Specifies container log output format | `json` (default) or `basic` |
|             | `consoleLogLevel`        | _[18.0.0.1+]_ Controls the granularity of messages that go to the container log | `info` (default), `audit`, `warning`, `error` or `off` |
|             | `consoleSource`          | _[18.0.0.1+]_ Specifies the sources that are written to the container log. Use a comma separated list for multiple sources. This property only applies when consoleFormat is set to `json`.  | Sources can be one or more of `message`, `trace`, `accessLog`, `ffdc`, `audit`. Default value is `message,trace,accessLog,ffdc`  |
| `microprofile` | `health.enabled` | Specifies whether to use the [MicroProfile Health](https://microprofile.io/project/eclipse/microprofile-health) endpoint (`/health`) for readiness and liveness probes of the container. Requires HTTP service to be enabled and Liberty server must be configured to use MicroProfile Health in the Docker image. | `false` (default) or `true` |
| `monitoring` | `enabled` | _[18.0.0.3+]_ Specifies whether to use Liberty features `monitor-1.0` and `mpMetrics-1.1` to monitor the server runtime environment and application metrics. Requires HTTP service to be enabled and Liberty server must be configured to enable monitoring in the Docker image. See [Monitoring](#monitoring) for more info. | `false` (default) or `true` |
| `replicaCount` |     |  Describes the number of desired replica pods running at the same time. | Default is `1`.  See [Replica Sets](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset) |
| `autoscaling` | `enabled`                        | Specifies whether a horizontal pod autoscaler (HPA) is deployed.  Note that enabling this field disables the `replicaCount` field. | `false` (default) or `true` |
|             | `minReplicas`                    | Lower limit for the number of pods that can be set by the autoscaler.   |  `Positive integer` (default to `1`)  |
|             | `maxReplicas`                    | Upper limit for the number of pods that can be set by the autoscaler.  Cannot be lower than `minReplicas`.   |  `Positive integer` (default to `10`)  |
|             | `targetCPUUtilizationPercentage` | Target average CPU utilization (represented as a percentage of requested CPU) over all the pods.  |  `Integer between `1` and `100` (default to `50`)  |
| `resources` | `constraints.enabled` | Specifies whether the resource constraints specified in this Helm chart are enabled.   | `false` (default) or `true`  |
|           | `limits.cpu`          | Describes the maximum amount of CPU allowed. | Default is `500m`. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu)  |
|           | `limits.memory`       | Describes the maximum amount of memory allowed. | Default is `512Mi`. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory) |
|           | `requests.cpu`        | Describes the minimum amount of CPU required. If not specified, the CPU amount will default to the limit (if specified) or implementation-defined value. | Default is 500m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu) |
|           | `requests.memory`     | Describes the minimum amount of memory required. If not specified, the memory amount will default to the limit (if specified) or the implementation-defined value. | Default is 512Mi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory) |
| `env`       | `jvmArgs`             | Specifies the `JVM_ARGS` environmental variable for the Liberty runtime. | |
| `sessioncache` | `hazelcast.enabled` | Enable session caching using Hazelcast | `false` |
| `sessioncache` | `hazelcast.embedded` | Hazelcast Topology. Embedded (true). Client/Server (false). | `false` |
|              | `hazelcast.image.repository` | Name of Hazelcast image, including repository prefix (if required).| `hazelcast/hazelcast-kubernetes` |
|              | `hazelcast.image.tag` | Docker image tag | `3.10.6` |
|              | `hazelcast.image.pullPolicy` | Image Pull Policy | `IfNotPresent` |
| `rbac`      | `install`             | Install RBAC. Set to `true` if using a namespace with RBAC. | `true` |
| `oidcClient`| `enabled`         | Set to `true` to enable security using OpenId Connect. |   `false` (default) or `true`  |
|                | `clientId`     | The client ID that has been obtained from the OpenId Connect Provider. |  a string  |
|                | `clientSecretName` | The Kubernetes secret containing the client secret that has been obtained from the OpenId Connect Provider. The key inside this secret must be named `clientSecret`. |  a string  |
|                | `discoveryURL` | The discovery URL of the OpenId Connect Provider. |  a URL  |

### Configuring Liberty

#### Liberty Docker image requirements

The Helm chart requires the Docker image to have certain directories linked. The `websphere-liberty` image from Docker Hub will already have the expected links. If you are not using this image, you must add the following to your Dockerfile:
```shell
ENV LOG_DIR /logs
ENV WLP_OUTPUT_DIR /opt/ibm/wlp/output
RUN mkdir /logs \
    && ln -s $WLP_OUTPUT_DIR/defaultServer /output \
    && ln -s /opt/ibm/wlp/usr/servers/defaultServer /config
```

Configuration values related to monitoring, health, JMS, IIOP, HTTP and SSL require the Liberty server to be configured appropriately at Docker image layer. See [WASDev/ci.docker](https://github.com/WASdev/ci.docker) for more information.

#### ConfigMap

The Helm release ConfigMap contains Liberty server configuration that is driven by the configuration choices of the chart deployer, using associated environmental variables. The Liberty container receives automatic updates to files from this ConfigMap.

You can also use the `image.serverOverridesConfigMapName` parameter to provide a ConfigMap to configure your Liberty server at deployment. The server configuration must be included within key `server-overrides.xml`. It will be mounted at `/config/configDropins/overrides/server-overrides.xml`.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-server-config
data:
  server-overrides.xml: |-
    <server>
      <!-- Customize the configuration. -->
    </server>
```

If you are including other server configuration files in the `configDropins/overrides` directory, note that the files are processed in alphabetical order.

#### Applying a production license

##### 18.0.0.3+

If your application container is using WebSphere Liberty 18.0.0.3 binary and newer version you no longer have to apply a production license - you only need to have entitlement to use WebSphere Liberty in production (either via ICP or other sales channels).

##### 18.0.0.2-

For WebSphere Liberty 18.0.0.2 binaries and older versions, please see instruction on [how to apply a license](https://github.com/WASdev/ci.docker#applying-a-license) to obtain production support.

#### Transaction logs

If the server fails and restarts, then to persist the transaction logs (preserve them through server restarts) you must set logs.persistTransactionLogs to true and configure persistence in the helm chart. You must also add the following to your server.xml in your docker image.

```xml
<transaction
    recoverOnStartup="true"
    waitForRecovery="true" />
```

For more information about the transaction element and its attributes, see [transaction - Transaction Manager](https://www.ibm.com/support/knowledgecenter/en/SSAW57_liberty/com.ibm.websphere.liberty.autogen.nd.doc/ae/rwlp_config_transaction.html) in the Liberty documentation.


#### Persisting logs

Create a persistent volume (PV) in a shared storage, NFS for example, with the following specification:
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: <persistent volume name>
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  storageClassName: <optional - must match PVC>
  nfs:
    server: <NFS Server IP>
    path: <NFS PATH>
```
Note: For NFS PATH you need to create your directory manually before deploying the persistent volume.

You can create a PV using the above template by executing:
```shell
kubectl create -f <yaml-file>
```
You can also create a PV from IBM Cloud Private dashboard by following these steps:

1.  From the dashboard panel, click Create resource.
2.  Copy and paste the PV template.
3.  Click Create.

_Note:_ For volumes that support ownership management, specify the group ID of the group owning the persistent volumes' file systems using the `persistence.fsGroupGid` parameter. Some storage management solutions automatically add persistent volumes' GID to the supplementary groups. If this is not setup properly, the Liberty server fails to write to the log files and the following error appears in the container logs: `TRAS0036E: The system could not create file /logs/messages.log because of the following exception: java.security.PrivilegedActionException: java.io.IOException: Permission denied`.

#### Analyzing Liberty messages

Logging in JSON format is enabled by default. Log events are forwarded to Elasticsearch automatically. In 18.0.0.3+, audit events can also be forwarded to Elasticsearch. Audit events may contain sensitive data. Make sure you have enabled security in the logging stack if you are deploying your chart into IBM Cloud Private.

Use Kibana to monitor and analyze the log events. Sample Kibana dashboards are provided in the `/ibm_cloud_pak/pak_extensions/dashboards` directory. Ensure Liberty log events exist in Elasticsearch before creating an index pattern and importing dashboards in Kibana.

For more information, see [Analyzing Liberty messages in IBM Cloud Private](https://www.ibm.com/support/knowledgecenter/en/SSEQTP_liberty/com.ibm.websphere.wlp.doc/ae/twlp_icp_json_logging.html) in the Knowledge Center.

#### SSL Configuration

SSL is enabled by default. When SSL is enabled, only secure ports are exposed. These ports are `9443` (HTTPS), `9402` (IIOPS), and `7286` (JMS). Only the ports you enable are exposed. When SSL is enabled, the application must be accessed accordingly, e.g. `https://`.

Note that due to requirements of the IIOP protocol, when you enable both IIOP and SSL, a secure and non-secure IIOP are configured, with the default port values of `9402` (secure) and `2809` (non-secure).

It is highly recommended to set `createClusterSSLConfiguration` and `useClusterSSLConfiguration` to true to establish trust between applications.

To turn off SSL:

1. Set `ssl.enabled` to `false`.
2. Depending on which ports you enable, change `port` and `targetPorts` to non-secure ports. By convention, the default port numbers for non-secure mode are `9080` (HTTPS), `2809` (IIOP), and `7276` (JMS).

#### Ingress configuration

If you are deploying your chart into IBM Cloud Private:

* `ingress.host` can be provided and set to a fully-qualified domain name that resolves to the IP address of your cluster’s proxy node. For example `example.com` resolved to the proxy node. When a domain name is not available, the service [`nip.io`](http://nip.io) can be used to provide a resolution based on an IP address. For example, `liberty.<IP>.nip.io` where `<IP>` would be replaced with the IP address of your cluster’s proxy node. The IP address of your cluster’s proxy node can be found by using the following command: `kubectl get nodes -l proxy=true`. Users can also leave this parameter as empty.

* `ingress.secretName` set to the name of the secret containing Ingress TLS certificate and key. If this is not provided, it dynamically creates a self-signed certificate/key, stores it in a Kubernetes secret and uses the secret in Ingress' TLS.

If the chart is deployed into IBM Cloud Kubernetes Service:

* `ingress.host` must be provided and set to the IBM-provided Ingress _subdomain_ or your custom domain. See [Select an app domain and TLS termination](https://console.bluemix.net/docs/containers/cs_ingress.html#public_inside_2) for more info on how to get this value in IBM Cloud Kubernetes Service.
* `ingress.secretName` must be provided. If you are using the IBM-provided Ingress domain, set this parameter to the name of the IBM-provided Ingress secret. However, if you are using a custom domain, set this parameter to the secret that you created earlier that holds your custom TLS certificate and key. See [IBM Cloud Kubernetes Service documentation](https://console.bluemix.net/docs/containers/cs_ingress.html#public_inside_2) for more info on how to get these value in an IBM Cloud Kubernetes Service cluster.

#### Configure Liveness and Readiness Probes

With the default configuration, readiness and liveness probes are determined by using an HTTP probe with path set to `/` or `/health` if MicroProfile Health is enabled. The container is considered healthy if connection can be established, otherwise it's considered a failure.

Optionally, you can override the default configurations for readiness and liveness probes by configuring `image.readinessProbe` and `image.livenessProbe` parameters, respectively. Complete definition of the probe must be provided if you choose to override.

The `initialDelaySeconds` defines how long to wait before performing the first probe. Default value for readiness probe is 2 seconds and for liveness probe is 20 seconds. You should set appropriate values for your container, if necessary, to ensure that the readiness and liveness probes don’t interfere with each other. Otherwise, the liveness probe might continuously restart the pod and the pod will never be marked as ready.

More information about configuring liveness and readiness probes can be found [here](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/)

#### Session Caching

The option to enable session caching in the ibm-websphere-liberty-rhel helm chart has been deprecated. The option to use Hazelcast as a Session Cache provider is moved to the image layer, see [WASDev/ci.docker](https://github.com/WASdev/ci.docker).

#### Monitoring

Monitoring is disabled by default. To use monitoring, the HTTP service must be enabled. Also, in the Liberty server configuration, features `mpMetrics-1.1` and `monitor-1.0` must be enabled and metrics endpoint `/metrics` must be configured without authentication. `mpMetrics-1.1` works with Java EE 7 features.

When SSL is enabled, an additional service (ClusterIP type) is created using port 9080 to provide metrics data to prometheus. This also means the applications and other endpoints can also be accessed within the cluster on port 9080. When SSL is not enabled, the user-specified port of the HTTP service is used. If the service is exposed outside of the cluster then the unauthenticated metrics endpoint `/metrics` will be exposed as well.

Metrics are collected by Prometheus automatically. Use Grafana to monitor and analyze the metrics.
#### OpenID Connect 
Liberty can function as an OpenID Connect Client, to secure applications using OpenID Connect. In this case, user authentication to access secured applications is performed remotely by an OpenID Connect Provider, and the result is returned to Liberty. First you must obtain a client ID, client secret, and discovery URL from the provider you intend to use. The process for obtaining these values is provider-specific. Please refer to documentation of the OpenID Connect Provider you intend to use.

Create a Kubernetes secret resource containing a key named `clientSecret` with client secret value you obtained from the OpenID Connect Provider. See [Creating your own Secrets](https://kubernetes.io/docs/concepts/configuration/secret/#creating-your-own-secrets) for more information. The name of the secret you created should be passed to `oidcClient.clientSecretName` parameter.

When your Docker image contains secured applications, you can specify your provider's client parameters, then user authentication will be performed using OpenID Connect. 

For additional information about configuring and using OpenID Connect, see  [Using OpenID Connect](https://www.ibm.com/support/knowledgecenter/SSEQTP_liberty/com.ibm.websphere.wlp.doc/ae/rwlp_using_oidc.html).

To use additional features beyond what are supported in this chart, your Docker image build can replace /opt/ibm/helpers/build/configuration_snippets/oidc-config.xml with a modified copy. 

#### Resource Reference

The helm chart creates the following Kubernetes resources that drive the configuration of the Liberty container. The configuration is used to ensure consistency of protocol, port and security configuration between the helm deployed Kubernetes objects and Liberty.

| Resource               |  Content                           | Container mount                          | Description |
| ---------------------- | ---------------------------------- | ---------------------------------------- | ----------- |
| `Secret`               | | | |
| mb-keystore            | jks binary                         | /etc/wlp/config/keystore                 | Namespace scope JKS keystore binary. |
| mb-keystore-password   | mb-keystore-password               | env MB_KEYSTORE_PASSWORD                 | Namespace scope JKS keystore password. |
| mb-truststore          | jks binary                         | /etc/wlp/config/truststore               | Namespace scope JKS truststore binary. |
| mb-truststore-password | mb-truststore-password             | env MB_TRUSTSTORE_PASSWORD               | Namespace scope JKS truststore password. |
| `ConfigMap` | | | |
| *fullname*  | include-configmap.xml              | /config/configDropins/overrides/         | Includes subsequent Liberty ConfigMap files. Container does not receive automatic updates to this file. |
|             | server.xml                         | /etc/wlp/configmap/                      | Available to modify running configuration. Container receives automatic updates to this file. |
|             | cluster-ssl.xml                    | /etc/wlp/configmap/                      | Configures `SSL` with cluster/namespace `mb` secrets. |


The helm chart augments the Liberty container with the following environmental variables.

| Environmental Variable | Description |
| ---------------------- | ---------------------------------- |
| `JVM_ARGS` | Sets `JVM_ARGS` used by Liberty JVM |
| `WLP_LOGGING_CONSOLE_FORMAT` | Determines json or standard log format. |
| `WLP_LOGGING_CONSOLE_LOGLEVEL` | Determines log level. |
| `WLP_LOGGING_CONSOLE_SOURCE` | Determines log sources to print to console output. |
| `IIOP_ENDPOINT_HOST` | Downward API status.podIP |
| `KUBERNETES_NAMESPACE` | Current namespace, used for auto-discovery. |
| `KEYSTORE_REQUIRED` | Determines whether keystore is generated. |
| `MB_KEYSTORE_PASSWORD` | Namespace scope JKS keystore password. |
| `MB_TRUSTSTORE_PASSWORD` | Namespace scope JKS truststore password. |
| `OIDC_CLIENT_ID`  | OpenID Connect client ID. |
| `OIDC_CLIENT_SECRET` | OpenID Connect client secret. |
| `OIDC_DISCOVERY_URL ` | OpenID Connect provider discovery URL. |


## More information
See the [WebSphere Liberty documentation](https://www.ibm.com/support/knowledgecenter/en/SSAW57_liberty/as_ditamaps/was900_welcome_liberty_ndmp.html) for configuration options for deploying the Liberty server.

