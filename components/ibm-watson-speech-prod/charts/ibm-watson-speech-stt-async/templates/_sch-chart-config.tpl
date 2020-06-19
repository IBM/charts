{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)

_sch-chart-config.tpl is a config file for the chart to specify additional 
values and/or override values defined in the sch/_config.tpl file.
 
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "sch.chart.stt_async.config.values" -}}
sch:
  chart:
    appName: "speech-to-text"
    components:
      stt_async:
        name: "stt-async"
    metering:
      productName: "{{ .Values.global.stt.productName }}"
      productID: "ICP4D-addon-{{ .Values.global.stt.productId }}"
      productVersion: "{{ .Values.global.stt.productVersion }}"
    labelType: prefixed
{{- end -}}
