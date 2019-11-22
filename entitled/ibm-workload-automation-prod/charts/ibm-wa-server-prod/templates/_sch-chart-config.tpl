{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)
_sch-chart-config.tpl is a config file for the chart to specify additional�
values and/or override values defined in the sch/_config.tpl file.
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}


{{- define "waserver.sch.chart.config.values" -}}
sch:
  chart:
    labelType: prefixed   
    appName: "waserver"
    metering:
      productName: IBM Workload Automation
      productID: 5725-G80_srv_prod
      productVersion: 9.5.0.00
    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
        key: beta.kubernetes.io/arch
        operator: In
        values:
          - amd64
      nodeAffinityPreferredDuringScheduling:
        amd64:
          weight: 3
          operator: In
          key: beta.kubernetes.io/arch        
{{- end -}}
