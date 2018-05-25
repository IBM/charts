<!--
 Licensed Materials - Property of IBM
 5737-E67
 @ Copyright IBM Corporation 2016, 2018. All Rights Reserved.
 US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
-->
## Introduction

Contains a fully integrated Elasticsearch solution to securely collect logs in a Kubernetes environment.

## Chart Details

This chart deploys:
  - Elasticsearch client and master pods
  - Elasticsearch data node StatefulSet, requiring a persistent volume
  - Logstash pod(s)
  - Filebeat daemonset
  - Optional Kibana pod
  - Optional automated TLS configuration

In management mode it also deploys:
  - Elasticsearch ingress
  - Kibana ingress
  - Kibana proxy to verify user authentication only

## Resources Required

* Elasticsearch resource needs are entirely based on your environment. Please read the [capacity planning guide](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_2.1.0/manage_metrics/capacity_planning.html) for helpful information to plan the necessary resources.
* See [Storage](#storage)


## Prerequisites

* Kubernetes 1.9 or higher
* Tiller 2.7.2 or higher
* PV provisioner support in the underlying infrastructure


## Installing and Removing the Chart

### Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install --name my-release stable/ibm-icplogging
```

The command deploys ibm-icplogging on the Kubernetes cluster with default values. The configuration section lists the parameters that can be configured during installation.

### Uninstalling the Chart

To uninstall/delete the my-release deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.


## Configuration

### General

Parameter | Description | Default
----------|-------------|--------
`image.pullPolicy` | The policy used by Kubernetes for images | IfNotPresent

### Filebeat

Parameter | Description | Default
----------|-------------|--------
`filebeat.name`             | The internal name of the Filebeat pod        | `filebeat-ds`
`filebeat.image.repository` | Full repository and path to image            | `docker.elastic.co/beats/filebeat`
`filebeat.image.tag`        | The version of Filebeat to deploy            | `5.5.1`
`filebeat.scope.nodes`      | One or more label key/value pairs that refine [node selection](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector) for Filebeat pods| `empty (nil)`
`filebeat.scope.namespaces` | List of log namespaces to monitor upon. Logs from all namespaces will be collected if value is set to empty | `empty (nil)`

### Logstash

Parameter | Description | Default
----------|-------------|--------
`logstash.name`                | The internal name of the Logstash cluster    | `logstash`
`logstash.image.repository`    | Full repository and path to image            | `docker.elastic.co/logstash/logstash`
`logstash.image.tag`           | The version of Logstash to deploy            | `5.5.1`
`logstash.replicas`            | The initial pod cluster size                 | `1`
`logstash.heapSize`            | The JVM heap size to allocate to Logstash    | `512m`
`logstash.memoryLimit`         | The maximum allowable memory for Logstash. This includes both JVM heap and file system cache    | `1024Mi`
`logstash.port`                | The port on which Logstash listens for beats | `5000`
`logstash.probe.enabled`       | Enables the [liveness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/) for Logstash. Logstash instance is considered not alive when: <ul><li>logstash endpoint is not available for  `logstash.probe.periodSeconds` * `logstash.probe.maxUnavailablePeriod`, or</li><li> processed event count is smaller than `logstash.probe.minEventsPerPeriod` within `logstash.probe.periodSeconds`</li></ul> | `false`
`logstash.probe.periodSeconds` | Seconds probe will wait before calling Logstash endpoint for status again | `60`
`logstash.probe.minEventsPerPeriod`   | Logstash instance is considered healthy if number of log events processed is greater than `logstash.probe.minEventsPerPeriod` within `logstash.probe.periodSeconds` | `1`
`logstash.probe.maxUnavailablePeriod` | Logstash instance is considered unhealthy after API endpoint is unavailable for `logstash.probe.periodSeconds` * `logstash.probe.maxUnavailablePeriod` seconds | `5`
`logstash.probe.image.repository`     | Full repository and path to image | `ibmcom/logstash-liveness-probe`
`logstash.probe.image.tag`            | Image version                     | `0.1.5`

### Kibana

Parameter | Description | Default
----------|-------------|--------
`kibana.name`               | The internal name of the Kibana cluster      | `kibana`
`kibana.image.repository`   | Full repository and path to image            | `docker.elastic.co/kibana/kibana`
`kibana.image.tag`          | The version of Kibana to deploy              | `5.5.1`
`kibana.replicas`           | The initial pod cluster size                 | `1`
`kibana.internal`           | The port for Kubernetes-internal networking  | `5601`
`kibana.external`           | The port used by external users              | `31601`
`kibana.maxOldSpaceSize`    | Maximum old space size (in MB) of the V8 Javascript engine| `1024`
`kibana.memoryLimit`        | The maximum allowable memory for Kibana      | `1280Mi`

### Elasticsearch&mdash;General settings

Parameter | Description | Default
----------|-------------|--------
`elasticsearch.name`                   | A name to uniquely identify this Elasticsearch deployment          | `elasticsearch`
`elasticsearch.image.repository`       | Full repository and path to Elasticsearch image                    | `docker.elastic.co/elasticsearch/elasticsearch`
`elasticsearch.image.tag`              | The version of Elasticsearch to deploy                             | `5.5.1`
`elasticsearch.initImage.repository`   | Full repository and path to the image used during bringup          | `ibmcom/icp-initcontainer`
`elasticsearch.initImage.tag`          | The version of init-container image to use                         | `1.0.0`
`elasticsearch.pluginImage.repository` | Full repository and path to the TLS-enabling Elastic plugin image  | `ibmcom/elasticsearch-plugin-searchguard`
`elasticsearch.pluginImage.tag`        | The version of TLS-enabling plugin to use                          | `1.0.0`
`elasticsearch.pluginInitImage.repository`  | Full repository and path to the image that will initialize the TLS plugin | `ibmcom/searchguard-init`
`elasticsearch.pluginInitImage.tag`         | The version of TLS plugin initialization image to use              | `1.0.0`
`elasticsearch.pkiInitImage.repository`| Full repository and path to the image for public key infrastructure (PKI) initialization | `ibmcom/pki-init`
`elasticsearch.pkiInitImage.tag`       | Version of the image for public key infrastructure (PKI) initialization                  | `1.1.0`
`elasticsearch.internalPort`           | The port on which the full Elasticsearch cluster will communicate  | `9300`

### Elasticsearch&mdash;Client node

Parameter | Description | Default
----------|-------------|--------
`elasticsearch.client.name`         | The internal name of the client node cluster                       | `client`
`elasticsearch.client.replicas`     | The number of initial pods in the client cluster                   | `1`
`elasticsearch.client.serviceType`  | The way in which the client service should be published. [See official documentation.](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services---service-types) | `ClusterIP`
`elasticsearch.client.heapSize`     | The JVM heap size to allocate to each Elasticsearch client pod     | `1024m`
`elasticsearch.client.memoryLimit`  | The maximum memory (including JVM heap and file system cache) to allocate to each Elasticsearch client pod | `1536Mi`
`elasticsearch.client.restPort`     | The port to which the client node will bind the REST APIs          | `9200`
`elasticsearch.client.antiAffinity` | Whether Kubernetes "may" (`soft`) or "must not" (`hard`) [deploy client pods onto the same node](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) | `soft`

### Elasticsearch&mdash;Master node

Parameter | Description | Default
----------|-------------|--------
`elasticsearch.master.name`         | The internal name of the master node cluster                       | `master`
`elasticsearch.master.replicas`     | The number of initial pods in the master cluster                   | `1`
`elasticsearch.master.heapSize`     | The JVM heap size to allocate to each Elasticsearch master pod     | `1024`
`elasticsearch.master.memoryLimit`  | The maximum memory (including JVM heap and file system cache) to allocate to each Elasticsearch master pod | `1536Mi`
`elasticsearch.master.antiAffinity` | Whether Kubernetes "may" (`soft`) or "must not" (`hard`) [deploy master pods onto the same node](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) | `soft`

### Elasticsearch&mdash;Data node

Parameter | Description | Default
----------|-------------|--------
`elasticsearch.data.name`                 | The internal name of the data node cluster                       | `data`
`elasticsearch.data.replicas`             | The number of initial pods in the data cluster                   | `2`
`elasticsearch.data.heapSize`             | The JVM heap size to allocate to each Elasticsearch data pod     | `1024m`
`elasticsearch.data.memoryLimit`          | The maximum memory (including JVM heap and file system cache) to allocate to each Elasticsearch data pod | `2048Mi`
`elasticsearch.data.antiAffinity`         | Whether Kubernetes "may" (`soft`) or "must not" (`hard`) [deploy data pods onto the same node](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) | `hard`
`elasticsearch.data.storage.size`         | The minimum [size of the persistent volume](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/scheduling/resources.md#resource-quantities)    | `10Gi`
`elasticsearch.data.storage.accessModes`  | [See official documentation](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes)   | `ReadWriteOnce`
`elasticsearch.data.storage.storageClass` | [See official documentation](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#storageclasses) | `""`
`elasticsearch.data.storage.persistent`   | Set to `false` for non-production or trial-only deployment                                                   | `true`
`elasticsearch.data.storage.useDynamicProvisioning` | Set to `true` to use GlusterFS or other dynamic storage provisioner                                | `false`

### Security

Parameter | Description | Default
----------|-------------|--------
`security.enabled`                | If set to `true`, configures HTTPS/TLS and mutual certificate-based authentication for all components of the logging service, including: <ul><li>between Elasticsearch and all client components</li><li>within Elasticsearch cluster</li><li>between Logstash and Filebeat</li></ul> | `false`
`security.provider`               | Elastic stack plugin to provide TLS. Acceptable values are `searchguard-tls` or `xpack`: <ul><li>`xpack` requires an Elastic license; see [official documentation](https://www.elastic.co/guide/en/kibana/5.5/security-settings-kb.html)</li><li> `searchguard-tls` leverages the community-edition features of SearchGuard; see [official documentation](https://github.com/floragunncom/search-guard-ssl)</li></ul> | `searchguard-tls`
`security.ca.keystore.password`   | Keystore password for the Certificate Authority (CA)                              | `changeme`
`security.ca.truststore.password` | Truststore password for the CA                                                    | `changeme`
`security.ca.origin`              | Specifies which CA to to use for generating certs. There are two accepted values: <ul><li> `external`: use existing CA stored in a Kubernetes secret under the same namespace as the Helm release</li><li> `internal`: generate and use new self-signed CA as part of the Helm release</li></ul>  | `internal`
`security.ca.secretName`          | Name of Kubernetes secret that stores the external CA. The secret needs to be under the same namespace as the Helm release  | `cluster-ca-cert`
`security.ca.certFieldName`       | Field name (key) within the specified Kubernetes secret that stores CA cert. If signing cert is used, the complete trust chain (root CA and signing CA) needs to be included in this file | `tls.crt`
`security.ca.keyFieldName`        | Field name (key) within the specified Kubernetes secret that stores CA private key | `tls.key`
`security.app.keystore.password`  | Keystore password for logging service components (such as Elasticsearch, Kibana)  | `changeme`

### XPack

XPack is a [separately-licensed feature](https://www.elastic.co/products/x-pack) of Elastic products. Please see official documentation for more information. Without a license the features are only enabled for a trial basis, and by default the XPack features are disabled in this chart.

_Note: All X-Pack features&mdash;including security and authentication services&mdash;are standalone. There is no integration with other authentication services._

Parameter | Description | Default
----------|-------------|--------
`xpack.monitoring` | [Link to official documentation](https://www.elastic.co/guide/en/kibana/5.5/xpack-monitoring.html)     | `false`
`xpack.graph`      | [Link to official documentation](https://www.elastic.co/guide/en/kibana/5.5/xpack-graph.html)          | `false`
`xpack.reporting`  | [Link to official documentation](https://www.elastic.co/guide/en/kibana/5.5/xpack-reporting.html)      | `false`
`xpack.ml`         | [Link to official documentation](https://www.elastic.co/guide/en/kibana/5.5/xpack-ml.html)             | `false`
`xpack.watcher`    | [Link to official documentation](https://www.elastic.co/guide/en/x-pack/5.5/how-watcher-works.html)    | `false`

### Curator

The curator is a tool to clean out old log indices from Elasticsearch. More information is available through [Elastic's official documentation](https://www.elastic.co/guide/en/elasticsearch/client/curator/5.2/index.html).

Parameter | Description | Default
----------|-------------|--------
`curator.name`              | A name to uniquely identify this curator deployment     | `curator`
`curator.image.repository`  | Full repository and path to image                       | `ibmcom/indices-cleaner`
`curator.image.tag`         | The version of curator image to deploy                  | `0.2`
`curator.schedule`          | A [Linux cron schedule](https://en.wikipedia.org/wiki/Cron#CRON_expression), identifying when the curator process should be launched. The default schedule runs at midnight. | `59 23 * * *`
`curator.log.unit`          | The [age unit type](https://www.elastic.co/guide/en/elasticsearch/client/curator/5.2/filtertype_age.html) to retain application logs | `days`
`curator.log.count`         | The number of `curator.log.unit`s to retain application logs | `1`
`curator.monitoring.unit`   | The [age unit type](https://www.elastic.co/guide/en/elasticsearch/client/curator/5.2/filtertype_age.html) to retain monitoring logs | `days`
`curator.monitoring.count`  | The number of `curator.monitoring.unit`s to retain monitoring logs | `1`
`curator.watcher.unit`      | The [age unit type](https://www.elastic.co/guide/en/elasticsearch/client/curator/5.2/filtertype_age.html) to retain watcher logs | `days`
`curator.watcher.count`     | The number of `curator.watcher.unit`s to retain watcher logs | `1`

## Storage

A persistent volume is required if no dynamic provisioning has been set up. See product documentation on this [Setting up dynamic provisioning](https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0.2/manage_cluster/cluster_storage.html). An example is below. See [official Kubernetes documentation](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) for more.

>```yaml
>kind: PersistentVolume
>apiVersion: v1
>metadata:
>  name: es-data-1
>  labels:
>    type: local
>spec:
>  storageClassName: logging-storage-datanode
>  capacity:
>    storage: 150Gi
>  accessModes:
>    - ReadWriteOnce
>  hostPath:
>    path: "/nfsdata/logging/1"
>  persistentVolumeReclaimPolicy: Recycle
>```

## Limitations

* When security is enabled then Logstash, Elasticsearch and Kibana must install onto `amd64`-based nodes. Filebeat can deploy to all platforms.
* All X-Pack features&mdash;including security and authentication services&mdash;are standalone. There is no integration with other authentication services.

Please refer to the knowledge center for more information about the features and limitations.

## Troubleshooting

### Security Policies

**Symptom:** After deploying the helm chart, none of the pods are in ready state. After running the command `kubectl describe pod <pod_name>` the "Events" section contains text such as `unable to validate against any pod security policy`, `Privileged containers are not allowed`, or `Invalid value: "IPC_LOCK": capability may not be added`.

**Cause:** The error indicates that the Kubernetes service account is not permitted to deploy into the target namespace any pods requiring the `IPC_LOCK` privilege.

**Explanation:** Some deployment types in Kubernetes are queued and fulfilled asynchronously. When Kubernetes executes the queued deployment, however, it does so in the context of its internal _service account_ instead of using the security context of the user that invoked the deployment originally. (See [Kubernetes issue 55973](https://github.com/kubernetes/kubernetes/issues/55973) for the public discussion.)

**Resolution:** Depending on your environment, one of the following may resolve the problem.

1. If you do not have permission to change privileges yourself, ask an administrator to add the `IPC_LOCK` privilege for the target namespace to the _service account's_ `PodSecurityPolicy`.
2. If you are able to modify security policies, the steps below describe one way to enable the deployment. Your environment may require more fine-grained policy changes.
   1. Run `kubectl edit clusterrolebindings privileged-psp-users`. This will open the contents of the file in a `vi` editor.
   2. Append your namespace to the list. For example, if your namespace is named `test`, then it might look like the following:
      ```
      - apiGroup: rbac.authorization.k8s.io
        kind: Group
        name: system:serviceaccounts:test
      ```
   3. Save the change and close the editor. Kubernetes will automatically apply the updated configuration.

### Invalid DNS

**Symptom:** The Kibana status page reports `Elasticsearch plugin status is red`, and when you run `kubectl describe deploy <deployment_name>` you see an error message that contains `spec.hostname: Invalid value`.

**Cause:** The user specified an invalid value for one or more of the `name` keys (e.g. `kibana.name`) in the Helm chart.

**Explanation:** The deployment name for a Kubernetes pod also resolves as its hostname within the network. As such, the deployment name must conform to DNS rules, described by Kubernetes this way: `a DNS-1123 label must consist of lower case alphanumeric characters or '-', and must start and end with an alphanumeric character (e.g. 'my-name', or '123-abc', regex used for validation is 'a-z0-9?')`.

**Resolution:** Delete the deployment, and reinstall with name values that conform to the rules as required by Kubernetes.
