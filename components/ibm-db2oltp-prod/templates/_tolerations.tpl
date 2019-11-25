{{/* toleration - https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ */}}

{{- define "tolerations" }}
{{ if eq .Values.runtime "ICP4Data" -}}
tolerations:
- key: "icp4data"
  operator: "Equal"
  value: "database-{{ .Values.global.dbType }}"
  effect: "NoSchedule" 
{{- end }}
{{- end }}

{{- define "uc.tolerations" }}
{{- if .Values.dedicated }}
- key: "icp4data"
  operator: "Equal"
  value: "database-{{ .Values.global.dbType }}"
  effect: "NoSchedule"
{{- end }}
{{- end }}
