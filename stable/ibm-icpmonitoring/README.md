# IBM Monitoring Service Helm Chart

## Introduction
This chart deploy Prometheus(https://prometheus.io), Grafana(https://grafana.com/) and related exporters to gather metrics from configured targets, evaluate alert rules, visuliaze the metrics in preinstalled dashboards.

## Chart Details
This chart includes
  - Deployments of prometheus, alertmanager, grafana, kube-state-metrics exporter, collectd exporter, elasticsearch exporter and corresponding services;
  - Daemonset of node exporter and corresponding service;
  - Ingress configurations for prometheus, alertmanager and grafana;
  - Persistent Volume Claims for prometheus, alertmanager and grafana;
  - Job to create prometheus datasource in grafana;
  - Job to generate the security certifications;
  - Configmaps for prometheus, alertmanager, grafana configurations;
  - Configmap for alert rules.

## Prerequisites

IBM Cloud Private 2.1.0.3 or higher for deployment mode "managed"

PV provisioner support in the underlying infrastructure

## Resources Required

see [Storage](#storage)

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install --name my-release stable/ibm-icpmonitoring
```

To uninstall/delete the my-release deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following tables lists the configurable parameters of the Prometheus chart and their default values.

Parameter | Description | Default
--------- | ----------- | -------
`mode` | deploy mode, options include managed|standard | standard
`tls.enabled` | Enabled security for the Chart | false
`imagePullPolicy` | pull policy for deployed images | IfNotPresent
`prometheus.image.repository` | Prometheus server container image name | ibmcom/prometheus
`prometheus.image.tag` | Prometheus server container image tag | v2.0.0
`prometheus.port` | Prometheus server service port | 80
`prometheus.scrapeInterval` | interval to scrape metrics | 1m
`prometheus.evaluationInterval` | evaluation interval for alert rules | 1m
`prometheus.retention` | Prometheus storage retention time | 24h
`prometheus.args` | arguments for prometheus container | {}
`prometheus.persistentVolume.enabled` | Create a volume to store data | false
`prometheus.persistentVolume.size` | Size of persistent volume claim | 10Gi
`prometheus.persistentVolume.storageClass` | storageClass for prometheus PV | -
`prometheus.resources.limits.cpu` | prometheus cpu limits | 500m
`prometheus.resources.limits.memory` | prometheus memory imits | 512Mi
`prometheus.resources.requests.cpu` | prometheus cpu requests | 100m
`prometheus.resources.requests.memory` | prometheus memory requests | 128Mi
`prometheus.alertRuleFiles` | Prometheus alert rules template | alertRules
`prometheus.configFiles` | Prometheus configurations template | prometheusConfig
`prometheus.rbacRoleCreation` | create rbac role&rolebinding if true | true
`prometheus.ingress.enabled` | create promethues ingress if true | false
`prometheus.ingress.annotations` | annotation for prometheus ingress | {}
`prometheus.service.type` | type for prometheus service | NodePort
`prometheus.etcdTarget.enabled` | add etcd scrape taget in prometheus config if true | false
`prometheus.etcdTarget.etcdAddress` | etcd server list | ["127.0.0.1"]
`prometheus.etcdTarget.etcdPort` | etcd server's port | 4001
`prometheus.etcdTarget.secret` | secret used to access etcd metrics endpoint | etcd-secret
`prometheus.etcdTarget.tlsConfig` | tls config for etcd scrape configuration | {}
`alertmanager.image.repository` | alertmanager container image name | ibmcom/alertmanager
`alertmanager.image.tag` | alertmanager container image tag | v0.13.0
`alertmanager.port` | alertmanager service port | 80
`alertmanager.persistentVolume.enabled` | Create a volume to store data | false
`alertmanager.persistentVolume.size` | Size of persistent volume claim | 1Gi
`alertmanager.persistentVolume.storageClass` | storageClass for alertmanager PV | -
`alertmanager.resources.limits.cpu` | alertmanager cpu limits | 200m
`alertmanager.resources.limits.memory` | alertmanager memory imits | 256Mi
`alertmanager.resources.requests.cpu` | alertmanager cpu requests | 10m
`alertmanager.resources.requests.memory` | alertmanager memory requests | 64Mi
`alertmanager.configFiles` | alertmanager configurations | alermanagerConfig
`alertmanager.ingress.enabled` | create alertmanager ingress if true | false
`alertmanager.ingress.annotations` | annotation for alertmanager ingress | {}
`alertmanager.service.type` | type for alertmanager service | NodePort
`kubeStateMetrics.enabled` | install kubernetes metrics exporter if true | false
`kubeStateMetrics.image.repository` | kube-state-metrics container image name | ibmcom/kube-state-metrics
`kubeStateMetrics.image.tag` | kube-state-metrics container image tag | v1.2.0
`kubeStateMetrics.port` | kube-state-metrics service port | 80
`nodeExporter.enabled` | install node exporter if true | false
`nodeExporter.image.repository` | node-exporter container image name | ibmcom/node-exporter
`nodeExporter.image.tag` | node-exporter container image tag | v0.15.2
`nodeExporter.port` | node-exporter service port | 9100
`grafana.image.repository` | Grafana Docker Image Name | ibmcom/grafana
`grafana.image.tag` | Grafana Docker Image Tag | 4.6.3
`grafana.port` | Grafana Container Exposed Port | 3000
`grafana.user` | Grafana user's name | admin
`grafana.password` | Grafana user's password | admin
`grafana.persistentVolume.enabled` | Create a volume to store data | false
`grafana.persistentVolume.size` | Size of persistent volume claim | 1Gi 
`grafana.persistentVolume.storageClass` | storageClass for persistent volume | - 
`grafana.resources.limits.cpu` | grafana cpu limits | 500m
`grafana.resources.limits.memory` | grafana memory imits | 512Mi
`grafana.resources.requests.cpu` | grafana cpu requests | 100m
`grafana.resources.requests.memory` | grafana memory requests | 128Mi
`grafana.configFiles` | grafana configurations | grafanaConfig
`grafana.ingress.enabled` | create grafana ingress if true | false
`grafana.ingress.annotations` | annotation for grafana ingress | {}
`grafana.service.type` | type for grafana service | NodePort
`grafana.elasticsearchDash.enabled` | add elasticsearch dashboard if true | false
`collectdExporter.enabled` | install collectd exporter if true | false
`collectdExporter.image.repository` | Collectd Exporter Image Name | ibmcom/collectd-exporter
`collectdExporter.image.tag` | Collectd Exporter Image Tag | 0.3.1 
`collectdExporter.service.serviceMetricsPort` | Metrics Service Exposed Port | 9103    
`collectdExporter.service.serviceCollectorPort` | Collector Service Exposed Port | 25826
`configmapReload.image.repository` | configmapReload Docker Image Name | ibmcom/configmap-reload
`configmapReload.image.tag` | configmapReload Docker Image Tag | v0.1
`router.image.repository` | router Docker Image Name | ibmcom/icp-router
`router.image.tag` | router Docker Image Tag | 2.2.0
`router.subjectAlt` | subject alternative dns or ip for the ssl key | 127.0.0.1
`elasticsearchExporter.enabled` | install elasticsearch exporter if true | false
`elasticsearchExporter.image.repository` | elasticsearchExporter Docker Image Name | ibmcom/lasticsearch_exporter
`elasticsearchExporter.image.tag` | elasticsearchExporter Docker Image Tag | 1.0.2
`elasticsearchExporter.esUri` | elasticsearch url | http://elasticsearch:9200
`elasticsearchExporter.port` | elasticsearchExporter exposed port | 9108
`curl.image.repository` | curl Docker Image Name | ibmcom/curl
`curl.image.tag` | curl Docker Image Tag | 3.6
`certGen.image.repository` | certGen Docker Image Name | ibmcom/icp-cert-gen
`certGen.image.tag` | certGen Docker Image Tag | 1.0.0

### Managed Mode

User can select which mode before install the chart, the options include managed and standard. For standard mode, the chart will be installed without any interception. For managed mode, it is the option for ICP monitoring service installation as management service. If set mode as "managed", it equals to use following values.yaml during installation.

```
tls:
  enabled: true
prometheus:
  ingress:
    enabled: true
  etcdTarget:
    enabled: true

alertmanager:
  ingress:
    enabled: true

kubeStateMetrics:
  enabled: true

nodeExporter:
  enabled: true

grafana:
  ingress:
    enabled: true
  elasticsearchDash: 
    enabled: true

collectdExporter:
  enabled: true

elasticsearchExporter:
  enabled: true
```

Besides this, there are some other deployment changes will be applied:
  - all the deployments/jobs will be added specific tolerations and NodeSelectorTerms so that they will be allocated to "management" nodes.
  - some ingress annotations, which are specific to ICP ingress controller, will be added to ingress configurations.

Prerequisites for managed mode deployment:
  - The chart need to be deployed into kube-system namespace and the release name should be set as "monitoring".

## Storage

A persistent volume is required if no dynamic provisioning has been set up. See product documentation on this [Setting up dynamic provisioning](https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0.2/manage_cluster/cluster_storage.html).  You can create a persistent volume via the IBM Cloud Private interface or through a yaml file. An example is below. See [official Kubernetes documentation](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) for more.

>```yaml
>kind: PersistentVolume
>apiVersion: v1
>metadata:
>  name: mon-data-1
>  labels:
>    component: prometheus
>spec:
>  storageClassName: monitoring-storage
>  capacity:
>    storage: 10Gi
>  accessModes:
>    - ReadWriteMany
>  local:
>    path: "/opt/ibm/cfc/monitoring/prometheus"
>  persistentVolumeReclaimPolicy: Recycle
>```

The above example is the PersistentVolume definition for prometheus.  The default storage requirements for the PersistentVolumes are the following:

- prometheus: 10Gi
- grafana: 1Gi
- alertmanager: 1Gi

These are dependent on the configuration of the helm chart.  If the storage requirements are altered the PersistentVolume definitions would need to be altered to match.  To make sure that existing data is preserved on upgrade the storage class must match the class defined in existing PV's.  In addition there needs to be an annotation section added to the metadata with the following text:

>```yaml
>  annotations:
>    "volume.alpha.kubernetes.io/node-affinity": '{
>      "requiredDuringSchedulingIgnoredDuringExecution": {
>        "nodeSelectorTerms": [
>          { "matchExpressions": [
>            { "key": "kubernetes.io/hostname",
>              "operator": "In",
>              "values": [  "{ip address of existing PV node for prometheus}" ]
>            }
>          ]}
>         ]}
>        }'
>```


## TLS support

During installation, if set "tls.enabled" as true, TLS will be enabled when accessing endpoints of prometheus, alert manager and grafana. When users try to install the chart, the certificates will be generated in pre-install hook and saved as kubenetes Secret resources:
- CA certificates: stored in Secret which named as {ReleaseName}-monitoring-ca-cert. If the chart is deployed to kube-system namespace, the cluster CA certificates cluster-ca-cert will be reused, else new CA certificates will be generated.
- Server certificates: stored in Secret which named as {ReleaseName}-monitoring-certs
- Client certificates: stored in Secret which named as {ReleaseName}-monitoring-client-certs

If set tls.enabled as true, prometheus/alert manager/grafana will block the incoming requests unless the requests contain the correct client certificates. In order to access the consoles successfully, need to enable the ingress and set the certificates correctly. e.g. in ICP environment, users can enable ingress for those services with following annotations:

```
    kubernetes.io/ingress.class: "ibm-icp-management"
    icp.management.ibm.com/secure-backends: "true"
    icp.management.ibm.com/secure-client-ca-secret: "{ReleaseName}-monitoring-client-certs"
    icp.management.ibm.com/rewrite-target: "/"
```

Notes: The communications between prometheus and exporters(node exporter, kube state metrics exporter, collectd exporter and elasticsearch exporter) still use plain http ones without tls.

## Limitations

Currently you can only deploy the chart to a namespace once.  If a second deployment is done it will fail.
