{{/* Configuration for SCH charts.  */}}
{{- define "sch.chart.sttmodels.config.values" -}}
sch:
  chart:
    appName: "speech-to-text"
    components:
      models:
        name: "stt-models"
    metering:
      productName: "{{ .Values.global.stt.productName }}"
      productID: "ICP4D-addon-{{ .Values.global.stt.productId }}"
      productVersion: "{{ .Values.global.stt.productVersion }}"
    labelType: prefixed
{{- end -}}
