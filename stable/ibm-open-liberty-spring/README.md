# Spring with Open Liberty Helm Chart

## Introduction 

Spring provides a popular programming model for developing cloud-native Java applications, and when powered by Open Liberty the stack
becomes consistent with other enterprise Java workloads - performance, security and a single management plane. This Helm chart will help you deploy your shinny new Spring Boot application into Kubernetes with enterprise settings such as Ingress, Auto-scaling and Pod Security Policy!


## Resources Required

### System resources
- CPU Requested : 500m (500 millicpu)
- Memory Requested : 512Mi (~ 537 MB)

### Storage
A persistent volume is required, if you plan on using the transaction service within Liberty. The `server.xml` Liberty configuration file must be configured to place the transaction log on this volume so that it persists, if the server fails and restarts.

## Chart Details

  - Installs one `Deployment` or `StatefulSet` running Open Liberty image
  - Installs a `Service` and optionally an `Ingress` to route traffic to Open Liberty server
  - Optionally persistence can be configured to retain server logs and transaction logs

## Prerequisites

### Open Liberty Docker image requirements

Open Liberty Docker images based on Universal Base Images (UBI), with tags `springBoot1-ubi-min` and `springBoot2-ubi-min`, are publicly available from [Docker hub](https://hub.docker.com/r/openliberty/open-liberty). Our Docker images for Ubuntu are also publicly available from our [Docker Hub page](https://hub.docker.com/_/open-liberty), using the tags `springBoot1` and `springBoot2` depending on the version of Spring Boot your app depends on. Ensure your Kubernetes environment has set the image enforcement policy appropriately to allow access to those repositories. See [Enforcing container image security](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.2.0/manage_images/image_security.html) for more information.

Within the `Using springBoot images` section, you’ll also learn how to achieve an optimized application image where the layer containing Spring libraries has been pushed between Open Liberty’s layer and your application’s layer – allowing for a much faster continuous development and build flow.

We have also pre-packaged the popular [Spring Pet Clinic](http://projects.spring.io/spring-petclinic/) application as a sample that is ready to be used! You can check out [how we built it](https://github.com/OpenLiberty/ci.docker/tree/master/community/samples/spring-petclinic) or run it right away via `docker run -d --name springApp -p 8080:9080 openliberty/samples:springPetClinic`. Ensure your Kubernetes environment has set the image enforcement policy appropriately to allow access to the sample application.

The Helm chart requires the Docker image to have certain directories linked. The `open-liberty` image from Docker Hub will already have the expected links. If you are not using that image, either directly or as parent image, then you must add the following to your Dockerfile:

```shell
ENV PATH /opt/ol/wlp/bin:/opt/ol/docker/:$PATH
ENV LOG_DIR /logs 
ENV WLP_OUTPUT_DIR /opt/ol/wlp/output

RUN mkdir -p /logs \
    && mkdir -p $WLP_OUTPUT_DIR/defaultServer \
    && ln -s $WLP_OUTPUT_DIR/defaultServer /output \
    && ln -s /opt/ol/wlp/usr/servers/defaultServer /config \
    && ln -s /logs $WLP_OUTPUT_DIR/defaultServer/logs
```

Configuration values related to HTTP, SSL, session caching and monitoring require the Liberty server to be configured appropriately at Docker image layer. See [OpenLiberty/ci.docker](https://github.com/OpenLiberty/ci.docker) for more information.

### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you:

* Predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp)
* Custom PodSecurityPolicy definition:

```yaml
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  name: ibm-open-liberty-spring-psp
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

* Custom ClusterRole for the custom PodSecurityPolicy:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ibm-open-liberty-spring-clusterrole
rules:
- apiGroups:
  - extensions
  resourceNames:
  - ibm-open-liberty-spring-psp
  resources:
  - podsecuritypolicies
  verbs:
  - use
```

#### Configuration scripts can be used to create the required resources

Download the following scripts located at [/ibm_cloud_pak/pak_extensions/pre-install](https://github.com/IBM/charts/tree/master/stable/ibm-open-liberty-spring/ibm_cloud_pak/pak_extensions/pre-install) directory.

* The pre-install instructions are located at `clusterAdministration/createSecurityClusterPrereqs.sh` for cluster admins to create the PodSecurityPolicy and ClusterRole for all releases of this chart.

* The namespace scoped instructions are located at `namespaceAdministration/createSecurityNamespacePrereqs.sh` for team admin/operator to create the RoleBinding for the namespace. This script takes one argument; the name of a pre-existing namespace where the chart will be installed.
  * Example usage: `./createSecurityNamespacePrereqs.sh myNamespace`

#### Configuration scripts can be used to clean up resources created

Download the following scripts located at [/ibm_cloud_pak/pak_extensions/post-delete](https://github.com/IBM/charts/tree/master/stable/ibm-open-liberty-spring/ibm_cloud_pak/pak_extensions/post-delete) directory.

* The post-delete instructions are located at `clusterAdministration/deleteSecurityClusterPrereqs.sh` for cluster admins to delete the PodSecurityPolicy and ClusterRole for all releases of this chart.

* The namespace scoped instructions are located at `namespaceAdministration/deleteSecurityNamespacePrereqs.sh` for team admin/operator to delete the RoleBinding for the namespace. This script takes one argument; the name of the namespace where the chart was installed.
  * Example usage: `./deleteSecurityNamespacePrereqs.sh myNamespace`

### Red Hat OpenShift SecurityContextConstraints Requirements

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
    name: ibm-open-liberty-spring-scc
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

See [RELEASENOTES.md](https://github.com/IBM/charts/tree/master/stable/ibm-open-liberty-spring/RELEASENOTES.md)

### Installing the Chart

The Helm chart can also be installed using the Helm command-line interface (CLI). The default parameter values specified in values.yaml can be overridden by using `--set name=value`. 

For example, to deploy the sample Spring Pet Clinic application run the following commands:

*    `helm repo add ibm-charts https://raw.githubusercontent.com/IBM/charts/master/repo/stable/`
*    `helm install --name my-release --set image.repository=openliberty/samples --set image.tag=springPetClinic ibm-charts/ibm-open-liberty-spring --tls`

To get the application URL, run the commands provided in the `NOTES` section from the output of running above commands.

Resource constraints can be enabled using `resources.constraints.enabled` parameter. Required resource can be configured using `resources.requests.cpu` and `resources.requests.memory` parameters. Resource limits can be configured using `resources.limits.cpu` and `resources.limits.memory` parameters. Review the default values specified by the chart and adjust according to your needs. It is recommended not to use `Xmx` or `Xms`. Use `–XX:MaxRAMPercentage` and `–XX:InitialRAMPercentage` for any fine tuning, such as if there are other processes set to run in the same container.

### Verifying the Chart

See the instruction after the helm installation completes for chart verification. The instruction can also be displayed by viewing the installed helm release under Menu -> Workloads -> Helm Releases or by running the command: `helm status my-release --tls`


### Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
helm delete my-release --purge --tls
```

This command removes all the Kubernetes components associated with the chart, except any persistent volume claims (PVCs) which is created when `logs.persistLogs` or `logs.persistTransactionLogs` is set to `true`. This is the default behavior of Kubernetes, and ensures that valuable data is not deleted. In order to delete the server data, you can delete the PVC using the following command:

```bash
kubectl delete pvc my-pvc
```

Note: You can use `kubectl get pvc` to see the list of available PVCs.

### Configuration 

| Qualifier | Parameter  | Definition | Allowed Value |
|---|---|---|---|
| `image`   | `pullPolicy` | Image Pull Policy | `Always`, `Never`, or `IfNotPresent`. Defaults to `Always` if `:latest` tag is specified, or `IfNotPresent` otherwise. See Kubernetes - [Updating Images](https://kubernetes.io/docs/concepts/containers/images/#updating-images)  |
|           | `repository` | Name of image, including repository prefix (if required). | See Docker - [Extended tag description](https://docs.docker.com/engine/reference/commandline/tag/#parent-command) |
|           | `tag`        | Docker image tag. | See Docker - [Tag](https://docs.docker.com/engine/reference/commandline/tag/) |
|           | `pullSecret`        | Image pull secret, if using a Docker registry that requires credentials. | See Kubernetes - [ImagePullSecrets](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#add-imagepullsecrets-to-a-service-account) |
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
| `ssl`       | `enabled`                       | Specifies whether SSL is enabled. Set to true only if Liberty server is configured to use SSL in the Docker image. | `true` (default) or `false` |
|           | `useClusterSSLConfiguration`    | Set to true if you want to use the SSL ConfigMap and secrets generated by the createClusterSSLConfiguration option. Set to false if the Docker image already has SSL configured. | `false` (default) or `true` |
|           | `createClusterSSLConfiguration` | Specifies whether to automatically generate SSL ConfigMap and secrets. The generated ConfigMap is: liberty-config.  The generated secrets are: `mb-keystore`, `mb-keystore-password`, `mb-truststore`, and `mb-truststore-password`.  Only generate the SSL configuration one time. If you generate the configuration a second time, errors might occur. | `false` (default) or `true` |
| `ingress` | `enabled`        | Specifies whether to use ingress.        |  `false` (default) or `true`  |
|           | `rewriteTarget`  | Specifies the target URI where the traffic must be redirected. | See [Ingress Configuration](https://github.com/OpenLiberty/ci.docker/docs) for more info on this. |
|           | `path`           | Specifies the path for the Ingress HTTP rule.    |  See [Ingress Configuration](https://github.com/OpenLiberty/ci.docker/docs) for more info on this. |
|           | `host`           | Specifies a fully qualified domain names of Ingress, as defined by RFC 3986. |  See [Ingress Configuration](https://github.com/OpenLiberty/ci.docker/docs) for more info on this. |
|           | `secretName`     | Specifies the name of the Kubernetes secret that contains Ingress' TLS certificate and key.   |  See [Ingress Configuration](https://github.com/OpenLiberty/ci.docker/docs) for more info on this. |
|           | `labels`         | Specifies custom labels.         |  YAML object of labels. See [Ingress Configuration](https://github.com/OpenLiberty/ci.docker/docs) for more info on this.  |
|           | `annotations`    | Specifies custom annotations.    |  YAML object of annotations. See [Ingress Configuration](https://github.com/OpenLiberty/ci.docker/docs) for more info on this.  |
| `persistence` | `name`                   | Descriptive name that will be used as a prefix for the generated persistence volume claim. A volume is only bound if either `logs.persistTransactionLog` or `logs.persistLogs` is set to `true`. | |
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
| `monitoring` | `enabled` | _[18.0.0.3+]_ Specifies whether to scrape metrics. If the metrics endpoint is not `/metrics` (default), define it with annotation `prometheus.io/path` in `service.annotations` parameter. See [Monitoring](#Monitoring) for more info. | `false` (default) or `true` |
| `replicaCount` |     |  Describes the number of desired replica pods running at the same time. | Default is `1`.  See [Replica Sets](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset) |
| `autoscaling` | `enabled`                        | Specifies whether a horizontal pod autoscaler (HPA) is deployed.  Note that enabling this field disables the `replicaCount` field. | `false` (default) or `true` |
|             | `minReplicas`                    | Lower limit for the number of pods that can be set by the autoscaler.   |  `Positive integer` (default to `1`)  |
|             | `maxReplicas`                    | Upper limit for the number of pods that can be set by the autoscaler.  Cannot be lower than `minReplicas`.   |  `Positive integer` (default to `10`)  |
|             | `targetCPUUtilizationPercentage` | Target average CPU utilization (represented as a percentage of requested CPU) over all the pods.  |  `Integer between `1` and `100` (default to `50`)  |
| `resources` | `constraints.enabled` | Specifies whether the resource constraints specified in this Helm chart are enabled.   | `false` (default) or `true`  |
|           | `limits.cpu`          | Describes the maximum amount of CPU allowed. | Default is `4000m`. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu)  |
|           | `limits.memory`       | Describes the maximum amount of memory allowed. | Default is `2Gi`. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory) |
|           | `requests.cpu`        | Describes the minimum amount of CPU required. If not specified, the CPU amount will default to the limit (if specified) or implementation-defined value. | Default is 500m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu) |
|           | `requests.memory`     | Describes the minimum amount of memory required. If not specified, the memory amount will default to the limit (if specified) or the implementation-defined value. | Default is 512Mi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory) |
| `arch`    | `amd64` | Architecture preference for amd64 worker node.   | `0 - Do not use`, `1 - Least preferred`, `2 - No preference` (default) or `3 - Most preferred`  |
|           | `ppc64le`          | Architecture preference for ppc64le worker node. | `0 - Do not use`, `1 - Least preferred`, `2 - No preference` (default) or `3 - Most preferred`  |
|           | `s390x`       | Architecture preference for s390x worker node. | `0 - Do not use`, `1 - Least preferred`, `2 - No preference` (default) or `3 - Most preferred` |
| `env`       | `jvmArgs`             | Specifies the `JVM_ARGS` environmental variable for the Liberty runtime. | |
| `rbac`      | `install`             | Install RBAC. Set to `true` if using a namespace with RBAC. | `true` |
| `app`      | `autoCreate`             | Adds `prism.app.auto-create` annotation for integration with Application Navigator. | `true` |
|            | `version`             | Adds `prism.app.auto-create.version` annotation. | `1.0.0` |
### Configuring Open Liberty

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

#### Transaction logs

If the server fails and restarts, then to persist the transaction logs (preserve them through server restarts) you must set logs.persistTransactionLogs to true and configure persistence in the helm chart. You must also add the following to your server.xml in your docker image.

```xml
<transaction 
    recoverOnStartup="true" 
    waitForRecovery="true" />
```

For more information about the transaction element and its attributes, see [transaction - Transaction Manager](https://openliberty.io/config/rwlp_config_transaction.html) in the Liberty documentation.

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

Note: For volumes that support ownership management, specify the group ID of the group owning the persistent volumes' file systems using the `persistence.fsGroupGid` parameter. Some storage management solutions automatically add persistent volumes' GID to the supplementary groups. If this is not setup properly, the Liberty server fails to write to the log files and the following error appears in the container logs: `TRAS0036E: The system could not create file /logs/messages.log because of the following exception: java.security.PrivilegedActionException: java.io.IOException: Permission denied`.

#### Analyzing Liberty messages

Logging in JSON format is enabled by default. Log events are forwarded to Elasticsearch automatically. Use Kibana to monitor and analyze the log events. Sample Kibana dashboards are provided at the Helm chart's [dashboards](https://github.com/IBM/charts/tree/master/stable/ibm-open-liberty-spring/ibm_cloud_pak/pak_extensions/dashboards/) folder. Ensure Liberty log events exist in Elasticsearch before creating an index pattern and importing dashboards in Kibana.

#### SSL Configuration

SSL is enabled by default. When SSL is enabled, only secure port `9443` (HTTPS) is exposed. Only the ports you enable are exposed. When SSL is enabled, the application must be accessed accordingly, e.g. `https://`.

It is highly recommended to set `createClusterSSLConfiguration` and `useClusterSSLConfiguration` to true to establish trust between applications.

To turn off SSL:

1. Set `ssl.enabled` to `false`.
2. Change `service.port` and `service.targetPort` to non-secure port. By convention, the default port number for non-secure mode is `9080` (HTTPS).

#### Ingress Configuration

For information on how to setup Ingress, See [Ingress Configuration](https://github.com/OpenLiberty/ci.docker/docs).

#### Configure Liveness and Readiness Probes

With the default configuration, readiness and liveness probes are determined by using an HTTP probe with path set to `/`. The container is considered healthy if connection can be established, otherwise it's considered a failure.

Optionally, you can override the default configurations for readiness and liveness probes by configuring `image.readinessProbe` and `image.livenessProbe` parameters, respectively. Complete definition of the probe must be provided if you choose to override.

The `initialDelaySeconds` defines how long to wait before performing the first probe. Default value for readiness probe is 2 seconds and for liveness probe is 20 seconds. You should set appropriate values for your container, if necessary, to ensure that the readiness and liveness probes don’t interfere with each other. Otherwise, the liveness probe might continuously restart the pod and the pod will never be marked as ready.

More information about configuring liveness and readiness probes can be found [here](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/)

#### Session Caching

The option to use Hazelcast as a Session Cache provider is available in the image layer, see [OpenLiberty/ci.docker](https://github.com/OpenLiberty/ci.docker).

#### Monitoring

Monitoring is disabled by default. To use monitoring, the HTTP service must be enabled and Liberty server must be configured to enable monitoring and Metrics endpoint must be configured without authentication in the Docker image. Refer to [Metrics with Spring](https://cloud.ibm.com/docs/java?topic=java-spring-metrics) for more information.

When SSL is enabled, an additional service (ClusterIP type) is created using port 9080 to provide metrics data to Prometheus. This also means the applications and other endpoints can also be accessed within the cluster on port 9080. When SSL is not enabled, the user-specified port of the HTTP service is used. If the service is exposed outside of the cluster then the unauthenticated metrics endpoint will be exposed as well.

Metrics are collected by Prometheus automatically. Use Grafana to monitor and analyze the metrics.

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
| `KUBERNETES_NAMESPACE` | Current namespace, used for auto-discovery. |
| `KEYSTORE_REQUIRED` | Determines whether keystore is generated. |
| `MB_KEYSTORE_PASSWORD` | Namespace scope JKS keystore password. |
| `MB_TRUSTSTORE_PASSWORD` | Namespace scope JKS truststore password. |

## Documentation

Refer to the [Using springBoot images](https://hub.docker.com/_/open-liberty) section in Docker Hub for information about support of Spring Boot applications.

See [Open Liberty website](https://openliberty.io/) for configuration options for deploying the Open Liberty server.

## Service information

This Helm chart installs the open source product Open Liberty. Refer to the [Open Liberty website](https://openliberty.io/) to get service for Open Liberty.
