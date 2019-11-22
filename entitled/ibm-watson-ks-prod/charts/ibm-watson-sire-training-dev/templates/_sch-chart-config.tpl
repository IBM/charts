{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)
_sch-chart-config.tpl is a config file for the chart to specify additional
values and/or override values defined in the sch/_config.tpl file.
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "sireTraining.sch.chart.config.values" -}}
sch:
  chart:
    appName: "sire-training"
    labelType: "prefixed"
    components:
      jobq:
        deploymentName: "jobq"
      facade:
        deploymentName: "facade"
    metering:
{{ tpl ( .Values.global.umbrellaChartMetering | toYaml ) . | indent 6 }}
    specSecurityContext:
      hostNetwork: false
      hostPID: false
      hostIPC: false
      securityContext:
        runAsNonRoot: true
    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
        key: beta.kubernetes.io/arch
        operator: In
        values:
          - amd64
{{- end -}}
