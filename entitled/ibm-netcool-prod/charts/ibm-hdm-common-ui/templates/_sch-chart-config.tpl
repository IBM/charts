{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)
_sch-chart-config.tpl is a config file for the chart to specify additional
values and/or override values defined in the sch/_config.tpl file.
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "ibm-hdm-common-ui.sch.chart.config.values" -}}
sch:
  chart:
    appName: "ibm-hdm-common-ui"
    nginx:
      ingress:
        ingress.kubernetes.io/rewrite-target: /
        ingress.kubernetes.io/add-base-url: "true"
        kubernetes.io/ingress.class: nginx
    components:
      uiserver:
        name: "ui-server"
        servicePort: "8080"
    labelType: "prefixed"
    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
        key: beta.kubernetes.io/arch
        operator: In
        values:
          - amd64
{{- end -}}

{{- /*
##############################
## METERING
##############################
*/ -}}
{{- define "ibm-hdm-common-ui.data" -}}
metering:
  productName: "HDM Common UI"
  productID: "HDMCommonUI"
  productVersion: "0.0.0.1"
{{- end -}}

{{- /*
##############################
## common helper to get the root data based on parsing the template name
##############################
*/ -}}
{{- define "root.data" -}}
{{- $chartList := (splitList "/charts/" .Template.Name) -}}
{{- $rootChartName := (index (splitList "/" (index $chartList 0)) 0) -}}
{{- $rootDataTemplate := printf "%s.%s" $rootChartName "data" -}}
{{- include $rootDataTemplate . -}}
{{- end -}}
