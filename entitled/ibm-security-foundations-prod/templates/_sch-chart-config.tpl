{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)
_sch-chart-config.tpl is a config file for the chart to specify additional 
values and/or override values defined in the sch/_config.tpl file.
 
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}

{{- define "ibm-security-foundations.sch.chart.config.values" -}}
sch:
  chart:
    appName: "ibm-security-foundations"
    labelsType: prefixed
    components:
      api:
        deploymentName: "ibm-security-foundations"
{{- end -}}
