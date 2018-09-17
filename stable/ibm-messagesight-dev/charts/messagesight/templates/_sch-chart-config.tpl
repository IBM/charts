{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)
_sch-chart-config.tpl is a config file for the chart to specify additional 
values and/or override values defined in the sch/_config.tpl file.
 
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "server.sch.chart.config.values" -}}
sch:
  chart:
    appName: "messagesight"
    metering:
      productName: "IBM IoT MessageSight Server"
      productID: "5725-S17"
      productVersion: "2.0.0.2"
{{- end -}}
