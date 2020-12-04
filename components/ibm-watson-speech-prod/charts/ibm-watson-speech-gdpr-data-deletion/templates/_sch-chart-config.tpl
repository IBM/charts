{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)

_sch-chart-config.tpl is a config file for the chart to specify additional 
values and/or override values defined in the sch/_config.tpl file.
 
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "sch.chart.gdpr_data_deletion.config.values" -}}
sch:
  chart:
    appName: "speech-to-text"
    components:
      gdpr_data_deletion:
        name: "gdpr-data-deletion"
    metering:
      cloudpakName: {{ .Values.global.cloudpakName }}
      cloudpakId: {{ .Values.global.cloudpakId }}

      productName: {{ .Values.global.stt.productName }}
      productID: {{ .Values.global.stt.productId }}
      productVersion: {{ .Values.global.stt.productVersion }}
      productMetric: {{ .Values.global.stt.productMetric }}
      productCloudpakRatio: {{ .Values.global.productCloudpakRatio }}
      productChargedContainers: {{ .Values.global.productChargedContainers }}

    labelType: prefixed
{{- end -}}
