{{/* Configuration for SCH charts.  */}}
{{- define "sch.chart.chuck.tts.config.values" -}}
sch:
  chart:
    appName: "text-to-speech"
    components:
      ttsRuntime:
        name: "tts-runtime"
    metering:
      productName: "{{ .Values.global.tts.productName }}"
      productID: "ICP4D-addon-{{ .Values.global.tts.productId }}"
      productVersion: "{{ .Values.global.tts.productVersion }}"
    labelType: prefixed
{{- end -}}
