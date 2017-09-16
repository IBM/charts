# IBM ICP Monitoring Service Helm Chart (Beta Version)

* Installs components for IBM ICP monitoring service

## TL;DR;

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
`alertmanager.image.tag`                        | alertmanager container image tag         | v0.5.1
`alertmanager.port`                             | alertmanager service port                | 80
`alertmanager.persistentVolume.enabled`         | Create a volume to store dat             | false
`alertmanager.persistentVolume.size`            | Size of persistent volume claim          | 1Gi
`alertmanager.persistentVolume.storageClass`    | storageClass for alertmanager PV         | -
`kubeStateMetrics.image.name`                   | kube-state-metrics container image name  | ibmcom/kube-state-metrics
`kubeStateMetrics.image.tag`                    | kube-state-metrics container image tag   | v1.0.0
`kubeStateMetrics.port`                         | kube-state-metrics service port          | 80
`nodeExporter.image.name`                       | node-exporter container image name       | ibmcom/node-exporter
`nodeExporter.image.tag`                        | node-exporter container image tag        | v0.14.0
`nodeExporter.port`                             | node-exporter service port               | 9100
`prometheus.image.name`                         | Prometheus server container image name   | ibmcom/prometheus
`prometheus.image.tag`                          | Prometheus server container image tag    | v1.7.1
`prometheus.port`                               | Prometheus server service port           | 80
`prometheus.persistentVolume.enabled`           | Create a volume to store data            | false
`prometheus.persistentVolume.size`              | Size of persistent volume claim          | 10Gi
`prometheus.persistentVolume.storageClass`      | storageClass for prometheus PV           | -
`grafana.image.name`                            | Grafana Docker Image Name                | ibmcom/grafana
`grafana.image.tag`                             | Grafana Docker Image Tag                 | 4.4.3
`grafana.port`                                  | Grafana Container Exposed Port           | 3000
`grafana.user`                                  | Grafana user's name                      | admin
`grafana.password`                              | Grafana user's password                  | admin
`grafana.persistentVolume.enabled`              | Create a volume to store data            | false
`grafana.persistentVolume.size`                 | Size of persistent volume claim          | 1Gi 
`grafana.persistentVolume.storageClass`         | storageClass for persistent volume       | - 
`collectdExporter.image.name`                   | Collectd Exporter Image Name             | ibmcom/collectd-exporter
`collectdExporter.image.tag`                    | Collectd Exporter Image Tag              | 0.3.1 
`collectdExporter.service.serviceMetricsPort`   | Metrics Service Exposed Port             | 9103    
`collectdExporter.service.serviceCollectorPort` | Collector Service Exposed Port           | 25826
