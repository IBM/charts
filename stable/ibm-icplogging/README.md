# Elasticsearch Helm Chart

* Installs Elasticsearch, providing log storage and search management services.

## TL;DR;

```console
$ helm install charts/elasticsearch
```

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install --name my-release charts/elasticsearch
```

## Uninstalling the Chart

To uninstall/delete the my-release deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.


## Configuration

| Parameter               | Description                                       | Default                                           |
|-------------------------|---------------------------------------------------|---------------------------------------------------|
| `image.repository`      | Full repository and path to image                 | docker.elastic.co/elasticsearch/elasticsearch     |
| `image.tag`             | The version of Elasticsearch to deploy            | 5.5.1                                             |
| `image.pullPolicy`      | The Kubernetes policy for pulling the ES image    | Always                                            |
| `cluster.name`          | The internal name of the Elasticsearch cluster    | elasticsearch                                     |
| `cluster.port`          | The cluster/transport network port                | 9300                                              |
| `client.name`           | The name for the client deployment                | client                                            |
| `client.replicas`       | The number of client pods in the cluster          | 2                                                 |
| `client.heapSize`       | Size of heap to allocate to the client JVM        | 256m                                              |
| `client.restPort`       | The Elasticsearch REST endpoint port              | 9200                                              |
| `client.antiAffinity`   | The anti-affinity policy for client pods          | soft                                              |
| `master.name`           | The name for the master deployment                | master                                            |
| `master.replicas`       | The number of master pods in the cluster          | 1                                                 |
| `master.heapSize`       | Size of heap to allocate to the master JVM        | 256m                                              |
| `master.antiAffinity`   | The anti-affinity policy for master pods          | soft                                              |
| `data.name`             | The name for the data node deployment             | data                                              |
| `data.replicas`         | The number of pods in the client cluster          | 2                                                 |
| `data.heapSize`         | Size of heap to allocate to the client JVM        | 1024m                                             |
| `data.storage`          | The Elasticsearch REST endpoint port              | 10Gi                                              |
| `data.antiAffinity`     | The anti-affinity policy for data pods            | soft                                              |
| `xpack.security`        | Whether to enable XPack security                  | false                                             |
