{{/* Configuration for SCH charts.  */}}
{{- define "sch.chart.chuck.stt.config.values" -}}
sch:
  chart:
    appName: "speech-to-text"
    components:
      runtime:
        name: "stt-runtime"
      lmPatcher:
        name: "stt-lm-patcher"
      catalog:
        name: "stt-catalog"
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
