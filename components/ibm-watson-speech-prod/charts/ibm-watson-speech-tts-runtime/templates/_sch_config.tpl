{{/* Configuration for SCH charts.  */}}
{{- define "sch.chart.chuck.tts.config.values" -}}
sch:
  chart:
    appName: "text-to-speech"
    components:
      ttsRuntime:
        name: "tts-runtime"
      catalog:
        name: "tts-catalog"
    metering:
      cloudpakName: {{ .Values.global.cloudpakName }}
      cloudpakId: {{ .Values.global.cloudpakId }}

      productName: {{ .Values.global.tts.productName }}
      productID: {{ .Values.global.tts.productId }}
      productVersion: {{ .Values.global.tts.productVersion }}
      productMetric: {{ .Values.global.tts.productMetric }}
      productCloudpakRatio: {{ .Values.global.productCloudpakRatio }}
      productChargedContainers: {{ .Values.global.productChargedContainers }}

    labelType: prefixed
{{- end -}}
