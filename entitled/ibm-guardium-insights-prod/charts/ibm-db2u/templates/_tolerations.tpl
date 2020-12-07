{{/* toleration - https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ */}}

{{- define "tolerations" }}
{{ if eq .Values.runtime "ICP4Data" -}}
tolerations:
  {{- if eq .Values.global.nodeLabel.key "" }}
- key: "icp4data"
  {{- else }}
- key: {{ .Values.global.nodeLabel.key }}
  {{- end }}
  operator: "Equal"
  {{- if eq .Values.global.nodeLabel.value "" }}
  value: "database-{{ .Values.global.dbType }}"
  {{- else }}
  value: {{ .Values.global.nodeLabel.value }}
  {{- end }}
  effect: "NoSchedule" 
{{- end }}
{{- end }}

{{- define "uc.tolerations" }}
{{- if .Values.dedicated }}
  {{- if eq .Values.global.nodeLabel.key "" }}
- key: "icp4data"
  {{- else }}
- key: {{ .Values.global.nodeLabel.key }}
  {{- end }}
  operator: "Equal"
  {{- if eq .Values.global.nodeLabel.value "" }}
  value: "database-{{ .Values.global.dbType }}"
  {{- else }}
  value: {{ .Values.global.nodeLabel.value }}
  {{- end }}
  effect: "NoSchedule"
{{- end }}
{{- end }}
