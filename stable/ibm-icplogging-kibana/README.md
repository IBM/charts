# Kibana Helm Chart (Beta Version)

Installs Kibana, a web UI to query and visualize data in existing Elasticsearch clusters.

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install --name my-release stable/ibm-icplogging-kibana
```

The command deploys ibm-icplogging-kibana on the Kubernetes cluster with default values. The configuration section lists the parameters that can be configured during installation.

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

### Kibana

Parameter | Description | Default
----------|-------------|--------
`kibana.name`               | The internal name of the Kibana cluster      | `kibana`
`kibana.namespace`          | Namespace under which resources are created  | `kube-system`
`kibana.image.repository`   | Full repository and path to image            | `docker.elastic.co/kibana/kibana`
`kibana.image.tag`          | The version of Kibana to deploy              | `5.5.1`
`kibana.replicas`           | The initial pod cluster size                 | `1`
`kibana.internal`           | The port for Kubernetes-internal networking  | `5601`
`kibana.external`           | The port used by external users              | `32601`
`kibana.elasticsearch.url`  | URL of the ElasticSearch endpoint            | `http://elasticsearch:9200`
`kibana.managementNodeOnly` | Run Kibana on ICP management service nodes only | `false`

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
