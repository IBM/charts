{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)

_sch-chart-config.tpl is a config file for the chart to specify additional 
values and/or override values defined in the sch/_config.tpl file.
 
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "sentiment.sch.chart.config.values" -}}
sch:
  chart:
    appName: "ibm-sentiment"
    labelType: prefixed
    components:
      sentiment:
        name: "sentiment-analysis-en"
      frontend:
        name: "frontend"
      modelserver:
        name: "model-server"
    metering:
      productName: "ibm-watson"
      productID: " "
      productVersion: "1.0"
{{- end -}}