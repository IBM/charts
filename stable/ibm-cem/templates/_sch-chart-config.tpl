{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)
_sch-chart-config.tpl is a config file for the chart to specify additional
values and/or override values defined in the sch/_config.tpl file.
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}

{{- define "cem.sch.chart.config.values" -}}
sch:
  chart:
    appName: {{ .Chart.Name }}
{{- end -}}

{{- define "ibm-cem.data" -}}
  metering:
    productName: "IBM Cloud Event Management – Private Deployment"
    productID: "5900-A1M"
    productVersion: "{{ .Chart.AppVersion }}"
{{- end -}}

{{- define "root.data" -}}
{{- $chartList := (splitList "/charts/" .Template.Name) -}}
{{- $rootChartName := (index (splitList "/" (index $chartList 0)) 0) -}}
{{- $rootDataTemplate := printf "%s.%s" $rootChartName "data" -}}
{{- include $rootDataTemplate . -}}
{{- end -}}
