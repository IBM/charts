{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)
_sch-chart-config.tpl is a config file for the chart to specify additional
values and/or override values defined in the sch/_config.tpl file.

*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "ibm-ucdr-prod.sch.chart.config.values" -}}
sch:
  chart:
    appName: {{ .Chart.Name }}
    labelType: "prefixed"
    nodeaffinity:
      nodeAffinityRequiredDuringScheduling:
        operator: In
        values:
        - amd64
        - ppc64le
        - s390x
      nodeAffinityPreferredDuringScheduling:
        amd64:
          weight: 3
          operator: In
          key: beta.kubernetes.io/arch
{{- end -}}
