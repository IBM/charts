{{/* Configuration for SCH charts.  */}}
{{- define "sch.chart.ttsvoices.config.values" -}}
sch:
  chart:
    appName: "text-to-speech"
    components:
      voices:
        name: "tts-voices"
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
