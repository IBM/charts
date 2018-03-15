# IBM ICP Monitoring Service Helm Chart

* Installs components for IBM ICP monitoring service

## Quick Start

```console
$ helm install stable/ibm-icpmonitoring
```

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install --name my-release stable/ibm-icpmonitoring
```

## Uninstalling the Chart

To uninstall/delete the my-release deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following tables lists the configurable parameters of the Prometheus chart and their default values.

Parameter                                       | Description                              | Default
----------------------------------------------- | ---------------------------------------- | -------
`alertmanager.image.name`                       | alertmanager container image name        | ibmcom/alertmanager
`alertmanager.image.tag`                        | alertmanager container image tag         | v0.13.0
`alertmanager.port`                             | alertmanager service port                | 80
`alertmanager.persistentVolume.enabled`         | Create a volume to store data            | false
`alertmanager.persistentVolume.size`            | Size of persistent volume claim          | 1Gi
`alertmanager.persistentVolume.storageClass`    | storageClass for alertmanager PV         | -
`alertmanager.resources.limits.cpu`             | alertmanager cpu limits                  | 200m
`alertmanager.resources.limits.memory`          | alertmanager memory imits                | 256Mi
`alertmanager.resources.requests.cpu`           | alertmanager cpu requests                | 10m
`alertmanager.resources.requests.memory`        | alertmanager memory requests             | 64Mi
`alertmanager.configFiles`                      | alertmanager configurations              | alermanagerConfig
`kubeStateMetrics.image.name`                   | kube-state-metrics container image name  | ibmcom/kube-state-metrics
`kubeStateMetrics.image.tag`                    | kube-state-metrics container image tag   | v1.2.0
`kubeStateMetrics.port`                         | kube-state-metrics service port          | 80
`nodeExporter.image.name`                       | node-exporter container image name       | ibmcom/node-exporter
`nodeExporter.image.tag`                        | node-exporter container image tag        | v0.15.2
`nodeExporter.port`                             | node-exporter service port               | 9100
`prometheus.image.name`                         | Prometheus server container image name   | ibmcom/prometheus
`prometheus.image.tag`                          | Prometheus server container image tag    | v2.0.0
`prometheus.port`                               | Prometheus server service port           | 80
`prometheus.args.retention`                     | Prometheus storage retention time        | 24h
`prometheus.args.memoryChunks`                  | Prometheus memory chunks setting         | 500000
`prometheus.persistentVolume.enabled`           | Create a volume to store data            | false
`prometheus.persistentVolume.size`              | Size of persistent volume claim          | 10Gi
`prometheus.persistentVolume.storageClass`      | storageClass for prometheus PV           | -
`prometheus.resources.limits.cpu`               | prometheus cpu limits                    | 500m
`prometheus.resources.limits.memory`            | prometheus memory imits                  | 512Mi
`prometheus.resources.requests.cpu`             | prometheus cpu requests                  | 100m
`prometheus.resources.requests.memory`          | prometheus memory requests               | 128Mi
`prometheus.alertRuleFiles`                     | Prometheus alert rules template          | alertRules
`prometheus.configFiles`                        | Prometheus configurations template       | prometheusConfig
`grafana.image.name`                            | Grafana Docker Image Name                | ibmcom/grafana
`grafana.image.tag`                             | Grafana Docker Image Tag                 | 4.6.3
`grafana.port`                                  | Grafana Container Exposed Port           | 3000
`grafana.user`                                  | Grafana user's name                      | admin
`grafana.password`                              | Grafana user's password                  | admin
`grafana.persistentVolume.enabled`              | Create a volume to store data            | false
`grafana.persistentVolume.size`                 | Size of persistent volume claim          | 1Gi 
`grafana.persistentVolume.storageClass`         | storageClass for persistent volume       | - 
`grafana.resources.limits.cpu`                  | grafana cpu limits                       | 500m
`grafana.resources.limits.memory`               | grafana memory imits                     | 512Mi
`grafana.resources.requests.cpu`                | grafana cpu requests                     | 100m
`grafana.resources.requests.memory`             | grafana memory requests                  | 128Mi
`grafana.configFiles`                           | grafana configurations                   | grafanaConfig
`collectdExporter.image.name`                   | Collectd Exporter Image Name             | ibmcom/collectd-exporter
`collectdExporter.image.tag`                    | Collectd Exporter Image Tag              | 0.3.1 
`collectdExporter.service.serviceMetricsPort`   | Metrics Service Exposed Port             | 9103    
`collectdExporter.service.serviceCollectorPort` | Collector Service Exposed Port           | 25826
`configmapReload.image.name`                    | configmapReload Docker Image Name        | ibmcom/configmap-reload
`configmapReload.image.tag`                     | configmapReload Docker Image Tag         | v0.1
