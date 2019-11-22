{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)
_sch-chart-config.tpl is a config file for the chart to specify additional
values and/or override values defined in the sch/_config.tpl file.
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}

{{- define "asm.sch.chart.config.values" -}}
sch:
  chart:
    appName: {{ .Chart.Name }}
    components:
      secretScrubber: secret-cleaner
      secretFactory: secret-generator
{{- end -}}

{{- define "ibm-netcool-asm-prod.data" -}}
  metering:
    productName: "IBM Netcool Operations Insight Agile Service Manager"
    productID: "c09ebc102d9d41afbf657c45a7b175df"
    productVersion: "1.1.6"
{{- end -}}

{{- define "parent.data" -}}
{{ $chartList := (splitList "/charts/" .Template.Name) }}
{{ $rootChartName := (index (splitList "/" (index $chartList 0)) 0) }}
{{ $rootDataTemplate := printf "%s.%s" $rootChartName "data"}}
{{ include $rootDataTemplate . }}
{{- end -}}
