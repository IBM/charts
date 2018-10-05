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
    appName: "chirper"
    components: 
      chirp:
        compName: "chirp"
        service:
          name: "chirp-svc"
        deployment:
          name: "chirp-deploy"
        ports:
          httpPort: 10000
          akkaRemotePort: 10001
          akkaHttpPort: 10002
      front:
        compName: "frontend"
        service:
          name: "frontend-svc"
        deployment:
          name: "frontend-deploy"
        ports:
          httpPort: 10000
          akkaRemotePort: 10001
          akkaHttpPort: 10002
      friend:
        compName: "friend"
        service:
          name: "friend-svc"
        deployment:
          name: "friend-deploy"
        ports:
          httpPort: 10000
          akkaRemotePort: 10001
          akkaHttpPort: 10002
      activity:
        compName: "activity-stream"
        service:
          name: "activity-stream-svc"
        deployment:
          name: "activity-stream-deploy"
        ports:
          httpPort: 10000
          akkaRemotePort: 10001
          akkaHttpPort: 10002
      ingress:
        name: "ingress"
      rbac:
        name: "RBAC"
      rolebinding:
        name: "RoleBinding"
      configmap:
        name: "secret-config"
      secret:
        name: "secret-generator"
    metering:
      productName: "Reactive Platform Lagom Sample"
      productID: "IBM-Reactive-Platform-Lagom-Sample_001_opensource_00000"
      productVersion: "1.0.0"
{{- end -}}

