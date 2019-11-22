{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)

_sch-chart-config.tpl is a config file for the chart to specify additional 
values and/or override values defined in the sch/_config.tpl file.
 
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "sch.chart.config.values" -}}
sch:
  chart:
    appName: "ibm-reactive-platform-console"
    components: 
      alertmanager:
        compName: "alertmanager"
        service:
          name: "alertmanager-service"
        deployment:
          name: "alertmanager-deployment"
        persistentVolumeClaim:
          name: "alertmanager-pvc"
        configmap:
          name: "alertmanager-configmap"
        ports:
          httpPort: 10000
      esConsole:
        compName: "es-console"
        service:
          name: "es-console-service"
        exposeService:
          name: "es-console-expose"
        deployment:
          name: "es-console-deploy"
        configmap:
          name: "es-console-configmap"
        ports:
          httpPort: 10000
      esGrafana:
        compName: "es-grafana"
        service:
          name: "es-grafana-service"
        deployment:
          name: "es-grafana-deployment"
        persistentVolumeClaim:
          name: "es-grafana-pvc"
        configmapDatasource:
          name: "es-grafana-configmap-datasource"
        configmapPlugin:
          name: "es-grafana-configmap-plugin"
        ports:
          httpPort: 10000
      kubeStateMetrics:
        compName: "kube-state-metrics"
        service:
          name: "kube-state-metrics-service"
        deployment:
          name: "kube-state-metrics-deployment"
        serviceAccount:
          name: "kube-state-metrics-account"
        role:
          name: "kube-state-metrics-role"
        rolebinding:
          name: "kube-state-metrics-rolebinding"
        ports:
          httpPort: 10000
      nodeExporter:
        compName: "node-exporter"
        service:
          name: "node-exporter-service"
        daemonset:
          name: "node-exporter-daemonset"
        serviceAccount:
          name: "node-exporter-account"
        ports:
          httpPort: 10000
      prometheus:
        compName: "server"
        serviceAPI:
          name: "prometheus-service-api"
        service:
          name: "prometheus-service-prod"
        deployment:
          name: "prometheus-deployment"
        serviceAccount:
          name: "prometheus-account"
        configmapAPI:
          name: "prometheus-configmap-api"
        configmap:
          name: "prometheus-configmap-prod"
        persistentVolumeClaim:
          name: "prometheus-pvc"
        role:
          name: "prometheus-role"
        rolebinding:
          name: "prometheus-rolebinding"
    metering:
      productName: "IBM Reactive Platform Console"
      productID: "5737-F15"
      productVersion: "1.0.0"
{{- end -}}

