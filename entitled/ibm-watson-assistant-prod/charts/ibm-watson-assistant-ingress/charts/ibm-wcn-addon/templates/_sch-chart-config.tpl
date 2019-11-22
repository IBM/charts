{{- define "wcn-addon.sch.chart.config.values" -}}
sch:
  chart:
    appName: "{{ .Values.global.appName }}-{{ .Values.addon.serviceId }}"
    components:
      metrics:
        name: "metrics"
      addon:
        name: "addon"
    metering:
      productName: {{ .Values.addon.displayName }}
      productID: {{ printf "%s-%s-%s-%s-%s" "ICP4D" "addon" "IBMWatsonAddon" .Release.Name .Values.addon.serviceId | trunc 63 }}
      productVersion: {{ include "wcn-addon.version" . }}
    labelType: new
    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
        operator: In
        values:
        - amd64
      nodeAffinityPreferredDuringScheduling:
        amd64:
          weight: 3
          operator: In
          key: beta.kubernetes.io/arch
{{- end -}}
