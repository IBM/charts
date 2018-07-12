# WebSphere Liberty Helm Chart
WebSphere Liberty is a fast, dynamic, and easy-to-use Java EE application server. Ideal for developers, but also ready for production, Liberty is a combination of IBM technology and open source software, with fast startup times (<2 seconds), and a simple XML configuration. All in a package that's <70 MB to download. You can be developing applications in no time. With a flexible, modular runtime, you can download additional features from the Liberty Repository or strip it back to the essentials for deployment into production environments. Everything in Liberty is designed to help you get your job done how you want to do it.

## Requirements

A persistent volume is required, if you plan on using the transaction service within Liberty. The `server.xml` Liberty configuration file must be configured to place the transaction log on this volume so that it persists, if the server fails and restarts.


## Accessing WebSphere Liberty

From a browser, use http://*external-ip*:*nodeport* to access the application.

## Configuration

### Parameters

The Helm chart has the following values that can be overridden by using `--set name=value`. For example:

*    `helm repo add ibm-charts https://raw.githubusercontent.com/IBM/charts/master/repo/stable/`
*    `helm install --name liberty2 --set resources.constraints.enabled=true --set autoscaling.enabled=true --set autoscaling.minReplicas=2 ibm-charts/ibm-websphere-liberty --debug`

#### Common Parameters

| Qualifier | Parameter  | Definition | Allowed Value |
|---|---|---|---|
| `image`   | `pullPolicy` | Image Pull Policy | `Always`, `Never`, or `IfNotPresent`. Defaults to `Always` if `:latest` tag is specified, or `IfNotPresent` otherwise. See Kubernetes - [Updating Images](https://kubernetes.io/docs/concepts/containers/images/#updating-images)  |
|           | `repository` | Name of image, including repository prefix (if required). | See Docker - [Extended tag description](https://docs.docker.com/engine/reference/commandline/tag/#parent-command) |
|           | `tag`        | Docker image tag. | See Docker - [Tag](https://docs.docker.com/engine/reference/commandline/tag/) |
|           | `license`    |  The license state of the image being deployed. | `Empty` (default) for development. `accept` if you have previously accepted the production license. `base` `core` or `nd` to apply the license at deployment time (see below). |
| `service` | `enabled`    | Specifies whether the `HTTP` port service is enabled or not.  |  |
|           | `name`       | The name of the `HTTP` port service.  | |
|           | `port`       | The port that this container exposes.  |   |
|           | `targetPort` | Port that will be exposed externally by the pod. | |
|           | `type`       | Specify type of service. | Valid options are `ClusterIP` and `NodePort`. See [Publishing services - service types](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services---service-types). This parameter is ignored for headless services and instead, it is forced to `clusterIP` with a value of `None`. This chart makes a service headless when persistence is enabled, which is done by setting either `logs.persistTransactionLogs` or `logs.persistLogs` to `true`. See [Headless services](https://kubernetes.io/docs/concepts/services-networking/service/#headless-services). |
| `iiopService`| `enabled` | Specifies whether the IIOP port service is enabled or not.  |   |
|           | `name`       | The name of the IIOP port service.  | |
|           | `nonSecurePort`       | The IIOP port that this container exposes.  |   |
|           | `nonSecureTargetPort` | IIOP Port that will be exposed externally by the pod. | |
|           | `securePort`       | The secure IIOP port that this container exposes. Specifying this port is needed if SSL is enabled. |   |
|           | `secureTargetPort` | Secure IIOP Port that will be exposed externally by the pod. Specifying this port is needed if SSL is enabled. | |
|           | `type`       | Specify type of service. | Valid options are `ClusterIP` and `NodePort`. See [Publishing services - service types](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services---service-types). This parameter is ignored for headless services and instead, it is forced to `clusterIP` with a value of `None`. This chart makes a service headless when persistence is enabled, which is done by setting either `logs.persistTransactionLogs` or `logs.persistLogs` to `true`. See [Headless services](https://kubernetes.io/docs/concepts/services-networking/service/#headless-services).|
| `jmsService`| `enabled`  | Specifies whether the JMS port service is enabled or not.  |   |
|           | `name`       | The name of the JMS port service.  | |
|           | `port`      | The JMS port that this container exposes.  |   |
|           | `targetPort` | JMS Port that will be exposed externally by the pod. | |
|           | `type`       | Specify type of service. | Valid options are `ClusterIP` and `NodePort`. See [Publishing services - service types](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services---service-types). This parameter is ignored for headless services and instead, it is forced to `clusterIP` with a value of `None`. This chart makes a service headless when persistence is enabled, which is done by setting either `logs.persistTransactionLogs` or `logs.persistLogs` to `true`. See [Headless services](https://kubernetes.io/docs/concepts/services-networking/service/#headless-services). |
| `ssl`       | `enabled`                       | Specifies whether SSL is enabled. Set to true if SSL will be enabled via the generated SSL configuration or if Liberty is configured to use SSL in the Docker image. | `true` (default) or `false` |
|           | `useClusterSSLConfiguration`    | Set to true if you want to use the SSL ConfigMap and secrets generated by the createClusterSSLConfiguration option. Set to false if the Docker image already has SSL configured. | `false` (default) or `true` |
|           | `createClusterSSLConfiguration` | Specifies whether to automatically generate SSL ConfigMap and secrets. The generated ConfigMap is: liberty-config.  The generated secrets are: `mb-keystore`, `mb-keystore-password`, `mb-truststore`, and `mb-truststore-password`.  Only generate the SSL configuration one time. If you generate the configuration a second time, errors might occur. | `false` (default) or `true` |
| `ingress`   | `enabled`        | Specifies whether to use ingress.        |  `false` (default) or `true`  |
|           | `rewriteTarget`  | Specifies the target URI where the traffic must be redirected. | See Kubernetes - Annotation `ingress.kubernetes.io/rewrite-target` - [Rewrite Target](https://github.com/kubernetes/ingress-nginx/tree/master/docs/examples/rewrite)  |
|           | `path`           | Specifies the path for the Ingress HTTP rule.    |  See Kubernetes - [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)  |
|           | `host`          | Specifies a fully qualified domain names of Ingress, as defined by RFC 3986. |  See [Ingress configuration](#ingress-configuration) for more into on this. |
|           | `secretName`    | Specifies the name of the Kubernetes secret that contains Ingress' TLS certificate and key.   |  See [Ingress configuration](#ingress-configuration) for more into on this. |
| `persistence` | `name`                   | Descriptive name that will be used as a prefix for the generated persistence volume claim. A volume is only bound if either `tranlog.persistLogs` or `logs.persistLogs` is set to `true`. | |
|             | `useDynamicProvisioning` | If `true`, the persistent volume claim will use the storageClassName to bind the volume. If `storageClassName` is not set then it will use the default StorageClass setup by kube Administrator.  If `false`, the selector will be used for the binding process. | `true` (default) or `false` |
|             | `storageClassName`       | Specifies a StorageClass pre-created by the Kubernetes sysadmin. When set to `""`, then the PVC is bound to the default `storageClass` setup by kube Administrator. | |
|             | `selector.label`         | When matching a PV, the label is used to find a match on the key. | See Kubernetes - [Labels and Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/). | |
|             | `selector.value`         | When matching a PV, the value is used to find a match on the values. | See Kubernetes - [Labels and Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/). | |
|             | `size`                   | Size of the volume to hold all the persisted data. | Size in Gi (default is `1Gi`) |
| `logs`        | `persistLogs`            | When `true`, the server logs will be persisted to the volume bound according to the persistence parameters. | `false` (default) or `true` |
|             | `persistTransactionLogs` | When `true`, the transaction logs will be persisted to the volume bound according to the persistence parameters. | `false` (default) or `true` |         
|             | `consoleFormat`          | _[18.0.0.1+]_ Specifies container log output format | `json` (default) or `basic` |
|             | `consoleLogLevel`        | _[18.0.0.1+]_ Controls the granularity of messages that go to the container log | `info` (default), `audit`, `warning`, `error` or `off` | 
|             | `consoleSource`          | _[18.0.0.1+]_ Specifies the sources that are written to the container log. Use a comma separated list for multiple sources. This property only applies when consoleFormat is set to `json`.  | `message`,`trace`,`accessLog`,`ffdc` (default) |
| `microprofile` | `health.enabled` | Specifies whether to use the [MicroProfile Health](https://microprofile.io/project/eclipse/microprofile-health) endpoint (`/health`) for readiness probe of the container. | `false` (default) or `true` |
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
| `arch`    | `amd64` | Architecture preference for amd64 worker node.   | `0 - Do not use`, `1 - Least preferred`, `2 - No preference` (default) or `3 - Most preferred`  |
|           | `ppc64le`          | Architecture preference for ppc64le worker node. | `0 - Do not use`, `1 - Least preferred`, `2 - No preference` (default) or `3 - Most preferred`  |
|           | `s390x`       | Architecture preference for s390x worker node. | `0 - Do not use`, `1 - Least preferred`, `2 - No preference` (default) or `3 - Most preferred` |
| `env`       | `jvmArgs`             | Specifies the `JVM_ARGS` environmental variable for the Liberty runtime. | |
| `sessioncache` | `hazelcast.enabled` | Enable session caching using Hazelcast | `false` |
|              | `hazelcast.image.repository` | Name of Hazelcast image, including repository prefix (if required).| `hazelcast/hazelcast-kubernetes` |
|              | `hazelcast.image.tag` | Docker image tag | `3.10` |
|              | `hazelcast.image.pullPolicy` | Image Pull Policy | `IfNotPresent` |
| `rbac`      | `install`             | Install RBAC. Set to `true` if using a namespace with RBAC. | `true` |

##### Configuring Liberty

###### Liberty Docker image requirements

The Helm chart requires the Docker image to have certain directories linked. The `websphere-liberty` image from Docker Hub will already have the expected links. If you are not using this image, you must add the following to your Dockerfile:
```shell
ENV LOG_DIR /logs
ENV WLP_OUTPUT_DIR /opt/ibm/wlp/output
RUN mkdir /logs \
    && ln -s $WLP_OUTPUT_DIR/defaultServer /output \
    && ln -s /opt/ibm/wlp/usr/servers/defaultServer /config
```

#### ConfigMap

The Helm release ConfigMap contains Liberty server configuration that is driven by the configuration choices of the chart deployer, using associated environmental variables. The Liberty container receives automatic updates to files from this ConfigMap.


##### Applying a license

To apply a license when building the Liberty Docker image
1. Copy the [base|core|nd] license jar to the directory the Dockerfile resides
2. Add the following to the Dockerfile
```shell
COPY wlp-nd-license.jar /tmp/wlp-nd-license.jar
RUN java -jar /tmp/wlp-nd-license.jar --acceptLicense /opt/ibm/wlp \
    && rm /tmp/wlp-nd-license.jar
```
3. Set the `image.license` value to `accept` to indicate the license has been accepted
  - `helm install --tls --set image.license="accept" ibm-charts/ibm-websphere-liberty`
    
Alternatively, to apply the license at deployment time

1. Create a Kubernetes secret in the namespace of the Liberty deployment
  - The secret name and jar file name must be of the the naming convention wlp-[base|core|nd]-license
  - `kubectl create secret generic wlp-nd-license --from-file=wlp-nd-license.jar`
2. Set the `image.license` value to one of [base|core|nd]
  - `helm install --tls --set image.license="nd" ibm-charts/ibm-websphere-liberty`


###### Transaction logs
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

#### Analyzing Liberty messages
Logging in JSON format is enabled by default.  Log events are forwarded to Elasticsearch automatically.  Use Kibana to monitor and analyze the log events.  Sample Kibana dashboards are provided at the Helm chart's [additionalFiles](https://github.com/IBM/charts/tree/master/stable/ibm-websphere-liberty/additionalFiles/) folder.

For more information, see [Analyzing Liberty messages in IBM Cloud Private](https://www.ibm.com/support/knowledgecenter/en/SSEQTP_liberty/com.ibm.websphere.wlp.doc/ae/twlp_icp_json_logging.html) in the Knowledge Center.


#### SSL Configuration
SSL is enabled by default. The chart automatically adds the `ssl-1.0` feature to your application server. When SSL is enabled, only secure ports are exposed. These ports are `9443` (HTTPS), `9402` (IIOPS), and `7286` (JMS). Only the ports you enable are exposed. When SSL is enabled, the application must be accessed accordingly, e.g. `https://`.

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

###### Session Caching
Session caching is disabled by default. To use session caching, the Liberty feature sessionCache-1.0 must be installed. Add the following to the websphere-liberty Dockerfile to install the sessionCache-1.0 feature, if it is not already present:
```
#For minified websphere-liberty Docker images, add this line to the websphere-liberty Dockerfile. Tolerate rc 22, feature is already installed.
RUN installUtility install --acceptLicense sessionCache-1.0 || if [ $? -ne 22 ]; then exit $?; fi
```
The session caching feature builds on top of an existing technology called JCache (JSR 107), which provides an API for distributed in-memory caching.  There are several providers of JCache implementations.  One example is Hazelcast In-Memory Data Grid. Enabling Hazelcast session caching automatically retrieves the Hazelcast client libraries from the hazelcast-kubernetes image, and configures the Hazelcast client and Liberty server feature sessionCache-1.0. The configuration is held in the ConfigMap associated with the helm release. By default, the Hazelcast client will auto-discover the Hazelcast server cluster within the same namespace.


###### Resource Reference

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
|             | http-endpoint.xml                  | /etc/wlp/configmap/                      | Configures `HTTP` endpoint port. |
|             | https-endpoint.xml                 | /etc/wlp/configmap/                      | Configures `HTTPS` endpoint port. |
|             | iiop-endpoint.xml                  | /etc/wlp/configmap/                      | Configures `IIOP` endpoint port. |
|             | iiop-ssl-endpoint.xml              | /etc/wlp/configmap/                      | Configures `IIOPS` endpoint port. |
|             | jms-ssl-endpoint.xml               | /etc/wlp/configmap/                      | Configures `JMSS` endpoint port. |
|             | jms-endpoint.xml                   | /etc/wlp/configmap/                      | Configures `JMS` endpoint port. |
|             | ssl.xml                            | /etc/wlp/configmap/                      | Configures `SSL`. |
|             | cluster-ssl.xml                    | /etc/wlp/configmap/                      | Configures `SSL` with cluster/namespace `mb` secrets. |
|             | liberty-sessioncache-hazelcast.xml | /etc/wlp/configmap/                      | Configures Liberty session cache & Hazelcast client libraries. |
|             | hazelcast-client.xml               | /opt/ibm/wlp/usr/shared/config/hazelcast | Configures Hazelcast client. |


The helm chart augments the Liberty container with the following environmental variables.

| Environmental Variable | Description |
| ---------------------- | ---------------------------------- |
| `JVM_ARGS` | Sets `JVM_ARGS` used by Liberty JVM |
| `WLP_LOGGING_CONSOLE_FORMAT` | Determines json or standard log format. |
| `WLP_LOGGING_CONSOLE_LOGLEVEL` | Determines log level. |
| `WLP_LOGGING_CONSOLE_SOURCE` | Determines log sources to print to console output. |
| `POD_IP` | Downward API status.podIP |
| `HTTPENDPOINT_HTTPSPORT` | Helm configured HTTPS port. |
| `HTTPENDPOINT_HTTPPORT` | Helm configured HTTP port. |
| `IIOPENDPOINT_IIOPSPORT` | Helm configured IIOPS port. |
| `IIOPENDPOINT_IIOPPORT` | Helm configured IIOP port. |
| `JMSENDPOINT_JMSSPORT` | Helm configured JMSS port. |
| `JMSENDPOINT_JMSPORT` | Helm configured JMS port. |
| `HAZELCAST_KUBERNETES_NAMESPACE` | Current namespace, used by Hazelcast for auto-discovery. |
| `KEYSTORE_REQUIRED` | Determines whether keystore is generated. |
| `MB_KEYSTORE_PASSWORD` | Namespace scope JKS keystore password. |
| `MB_TRUSTSTORE_PASSWORD` | Namespace scope JKS truststore password. |

###### Limitation

Helm upgrade from version `1.0.0` to any other chart version is not supported. If you need to upgrade from a version `1.0.0` chart, first delete your Helm release, and then re-install, using the intended chart version.

## More information
See the [Liberty documentation](https://www.ibm.com/support/knowledgecenter/en/SSAW57_liberty/as_ditamaps/was900_welcome_liberty_ndmp.html) for configuration options for deploying the Liberty server.

