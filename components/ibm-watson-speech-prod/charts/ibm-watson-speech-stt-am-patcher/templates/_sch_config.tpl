{{/* Configuration for SCH charts.  */}}
{{- define "sch.chart.chuck.stt.ampatcher.config.values" -}}
sch:
  chart:
    appName: "speech-to-text"
    components:
      runtime:
        name: "stt-runtime"
      amPatcher:
        name: "stt-am-patcher"
    metering:
      productName: "{{ .Values.global.stt.productName }}"
      productID: "ICP4D-addon-{{ .Values.global.stt.productId }}"
      productVersion: "{{ .Values.global.stt.productVersion }}"
    labelType: prefixed
{{- end -}}
