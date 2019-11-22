{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)

_sch-chart-config.tpl is a config file for the chart to specify additional 
values and/or override values defined in the sch/_config.tpl file.
 
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}

{{- define "alm.sch.chart.config.values" -}}
sch:
  chart:
    appName: {{ .Chart.Name }}
    components:
      vaultInitName: "vault-init"
      secretScrubber: secret-cleaner
      secretFactory: secret-generator
{{- end -}}

{{- define "ibm-alm-prod.data" -}}
  metering:
    productName: "Agile Lifecycle Manager"
    productID: "7df8f234cb164286911813e8ec8232b8"
    productVersion: "2.0.0"
{{- end -}}

{{- define "parent.data" -}}
{{ $chartList := (splitList "/charts/" .Template.Name) }}
{{ $rootChartName := (index (splitList "/" (index $chartList 0)) 0) }}
{{ $rootDataTemplate := printf "%s.%s" $rootChartName "data"}}
{{ include $rootDataTemplate . }}
{{- end -}}

{{- define "root.data" -}}
{{- $chartList := (splitList "/charts/" .Template.Name) -}}
{{- $rootChartName := (index (splitList "/" (index $chartList 0)) 0) -}}
{{- $rootDataTemplate := printf "%s.%s" $rootChartName "data" -}}
{{- include $rootDataTemplate . -}}
{{- end -}}
