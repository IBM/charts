{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)

_sch-chart-config.tpl is a config file for the chart to specify additional 
values and/or override values defined in the sch/_config.tpl file.
 
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "probe.kafka.sch.chart.config.values" -}}
sch:
  chart:
    labelType: prefixed
    appName: "probe-mb-kfk"
    components: 
      probe:
        name: "mb"
        transport:
          type: "kafka"
        configmap:
          name: "config"
        rules:
          name: "rules"
      rbac:
        roleName: role
        roleBindingName: rolebinding
        serviceAccountName: sa
    metering:
      productName: "IBM Tivoli Netcool/OMNIbus Message Bus Kafka Probe"
      productID: "B2AFDB343F444764A833AC78C08B1BD3"
      productVersion: "8.0.29"
    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
        operator: In
        values:
        - {{ .Values.messagebus.arch }}
      nodeAffinityPreferredDuringScheduling:
        amd64:
          weight: 3
          operator: In
          key: beta.kubernetes.io/arch
{{- end -}}
