<!--
 Licensed Materials - Property of IBM
 5737-E67
 @ Copyright IBM Corporation 2016, 2018. All Rights Reserved.
 US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
-->
## Introduction

Installs Kibana, a web UI to query and visualize data in existing Elasticsearch clusters.

THIS CHART IS NOW DEPRECATED. On March 8th, 2019 the Helm chart for IBM Cloud Private ibm-icplogging-kibana will no longer be supported and will be removed from IBM's public helm repository on github.com. This will result in the chart no longer being displayed in the catalog. This will not impact existing deployments of the helm chart.

## Chart Details

This chart includes:
  - Kibana 5.5.1

## Prerequisites

* Kubernetes 1.9 or higher
* Tiller 2.7.2 or higher
* Elasticsearch 5.5.1 stack deployed by `ibm-icplogging`

## Resources Required

None

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
`image.pullPolicy` | The policy used by Kubernetes for images | `IfNotPresent`

### Kibana

Parameter | Description | Default
----------|-------------|--------
`kibana.name`                     | The internal name of the Kibana cluster                    | `kibana`
`kibana.image.repository`         | Full repository and path to Kibana image                   | `ibmcom/kibana`
`kibana.image.tag`                | The version of Kibana to deploy                            | `5.5.1`
`kibana.routerImage.repository`   | Full repository and path to proxy image                    | `ibmcom/icp-router`
`kibana.routerImage.tag`          | The version of proxy image to deploy                       | `2.2.0`
`kibana.replicas`                 | The initial pod cluster size                               | `1`
`kibana.internal`                 | The port for Kubernetes-internal access                    | `5601`
`kibana.external`                 | The port used by external users (or ingress)               | `32601`
`kibana.maxOldSpaceSize`          | Maximum old space size (in MB) of the V8 Javascript engine | `32601`
`kibana.memoryLimit`              | The maximum allowable memory for Kibana                    | `32601`
`kibana.managedMode`              | Whether to deploy Kibana as a management service           | `false`

### Elasticsearch

Parameter | Description | Default
----------|-------------|--------
`elasticsearch.service.name`          | The name of the Elasticsearch service for the target cluster        | `elasticsearch`
`elasticsearch.service.port`          | The port on which the Elasticsearch service listens                 | `9200`
`elasticsearch.security.enabled`      | Whether TLS security is enabled in the target Elasticsearch cluster | `false`
`elasticsearch.security.secretRoot`   | The common root string for the target Elasticsearch cluster secrets; it will expand to `[secretRoot]-certs` and `[secretRoot]-elasticsearch-pki-secret` to extract credentials to communicate with the target cluster | `logging-elk`

### X-Pack

X-Pack is a [separately-licensed feature](https://www.elastic.co/products/x-pack) of Elastic products. Please see official documentation for more information. Without a license the features are only enabled for a trial basis, and by default the X-Pack features are disabled in this chart.

_Note: All X-Pack features&mdash;including security and authentication services&mdash;are standalone. There is no integration with other authentication services._

Parameter | Description | Default
----------|-------------|--------
`xpack.monitoring` | [Link to official documentation](https://www.elastic.co/guide/en/kibana/5.5/xpack-monitoring.html)     | `false`
`xpack.graph`      | [Link to official documentation](https://www.elastic.co/guide/en/kibana/5.5/xpack-graph.html)          | `false`
`xpack.reporting`  | [Link to official documentation](https://www.elastic.co/guide/en/kibana/5.5/xpack-reporting.html)      | `false`
`xpack.ml`         | [Link to official documentation](https://www.elastic.co/guide/en/kibana/5.5/xpack-ml.html)             | `false`

## Limitations

This will only install the Kibana UI.
