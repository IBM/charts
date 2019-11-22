{{/* Configuration for SCH charts.  */}}
{{- define "sch.chart.ttsvoices.config.values" -}}
sch:
  chart:
    appName: "text-to-speech"
    components:
      voices:
        name: "tts-voices"
    metering:
      productName: "{{ .Values.global.tts.productName }}"
      productID: "ICP4D-addon-{{ .Values.global.tts.productId }}"
      productVersion: "{{ .Values.global.tts.productVersion }}"
    labelType: prefixed
{{- end -}}
