# ELK Helm Chart

* Installs Filebeat, Elasticsearch, Logstash and Kibana, providing log streaming, storage and search management services.

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install --name my-release stable/ibm-icplogging
```

The command deploys ibm-icplogging on the Kubernetes cluster with default values. The configuration section lists the parameters that can be configured during installation.

## Uninstalling the Chart

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

### Logstash

Parameter | Description | Default
----------|-------------|--------
`logstash.name`             | The internal name of the Logstash cluster    | `logstash`
`logstash.image.repository` | Full repository and path to image            | `docker.elastic.co/logstash/logstash`
`logstash.image.tag`        | The version of Logstash to deploy            | `5.5.1`
`logstash.replicas`         | The initial pod cluster size                 | `1`
`logstash.heapSize`         | The maximum allowable memory for Logstash    | `256m`
`logstash.port`             | The port on which Logstash listens for beats | `5000`

### Kibana

Parameter | Description | Default
----------|-------------|--------
`kibana.name`               | The internal name of the Kibana cluster      | `kibana`
`kibana.image.repository`   | Full repository and path to image            | `docker.elastic.co/kibana/kibana`
`kibana.image.tag`          | The version of Kibana to deploy              | `5.5.1`
`kibana.replicas`           | The initial pod cluster size                 | `1`
`kibana.internal`           | The port for Kubernetes-internal networking  | `5601`
`kibana.external`           | The port used by external users              | `31601`

### Elasticsearch

Parameter | Description | Default
----------|-------------|--------
`elasticsearch.name`                | A name to uniquely identify this Elasticsearch deployment          | `elasticsearch`
`elasticsearch.image.repository`    | Full repository and path to image                                  | `docker.elastic.co/elasticsearch/elasticsearch`
`elasticsearch.image.tag`           | The version of Elasticsearch to deploy                             | `5.5.1`
`elasticsearch.initImage.repository` | Full repository and path to the container used during initialization | `ibmcom/icp-initcontainer`
`elasticsearch.initImage.tag`        | The version of init-container image to use                           | `1.0.0`
`elasticsearch.internalPort`        | The port on which the full Elasticsearch cluster will communicate  | `9300`
`elasticsearch.client.name`         | The internal name of the client node cluster                       | `client`
`elasticsearch.client.replicas`     | The number of initial pods in the client cluster                   | `1`
`elasticsearch.client.serviceType`  | The way in which the client service should be published. [See official documentation.](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services---service-types) | `ClusterIP`
`elasticsearch.client.heapSize`     | The maximum memory to allocate to each Elasticsearch client        | `256m`
`elasticsearch.client.restPort`     | The port to which the client node will bind the REST APIs          | `9200`
`elasticsearch.client.antiAffinity` | Whether Kubernetes "may" (`soft`) or "must not" (`hard`) [deploy client pods onto the same node](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) | `soft`
`elasticsearch.master.name`         | The internal name of the master node cluster                       | `master`
`elasticsearch.master.replicas`     | The number of initial pods in the master cluster                   | `1`
`elasticsearch.master.heapSize`     | The maximum memory to allocate to each Elasticsearch master        | `256m`
`elasticsearch.master.antiAffinity` | Whether Kubernetes "may" (`soft`) or "must not" (`hard`) [deploy master pods onto the same node](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) | `soft`
`elasticsearch.data.name`         | The internal name of the data node cluster                       | `data`
`elasticsearch.data.replicas`     | The number of initial pods in the data cluster                   | `2`
`elasticsearch.data.heapSize`     | The maximum memory to allocate to each Elasticsearch data        | `512m`
`elasticsearch.data.antiAffinity` | Whether Kubernetes "may" (`soft`) or "must not" (`hard`) [deploy data pods onto the same node](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) | `hard`
`elasticsearch.data.storage.size`         | The minimum [size of the persistent volume](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/scheduling/resources.md#resource-quantities)    | `10Gi`
`elasticsearch.data.storage.accessModes`  | [See official documentation](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes) | `ReadWriteOnce`
`elasticsearch.data.storage.subPath`      | An optional path within the persistent volume that the Elasticsearch data should be stored | ""
`elasticsearch.data.storage.storageClass` | [See official documentation](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#storageclasses) | `manual`

### XPack

XPack is a [separately-licensed feature](https://www.elastic.co/products/x-pack) of Elastic products. Please see official documentation for more information. Without a license the features are only enabled for a trial basis, and by default the XPack features are disabled in this chart.

_Note: All features&mdash;including security or authentication services&mdash;in XPack are not related to any services offered by IBM Cloud Private._

Parameter | Description | Default
----------|-------------|--------
`xpack.monitoring` | [Link to official documentation](https://www.elastic.co/guide/en/kibana/5.5/xpack-monitoring.html)     | `false`
`xpack.security`   | [Link to official documentation](https://www.elastic.co/guide/en/kibana/5.5/security-settings-kb.html) | `false`
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
