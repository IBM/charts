{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)

_sch-chart-config.tpl is a config file for the chart to specify additional 
values and/or override values defined in the sch/_config.tpl file.
 
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "sch.chart.tts_customization.config.values" -}}
sch:
  chart:
    appName: "text-to-speech"
    components:
      tts_customization:
        name: "tts-customization"
    metering:
      productName: "{{ .Values.global.tts.productName }}"
      productID: "ICP4D-addon-{{ .Values.global.tts.productId }}"
      productVersion: "{{ .Values.global.tts.productVersion }}"
    labelType: prefixed
{{- end -}}
