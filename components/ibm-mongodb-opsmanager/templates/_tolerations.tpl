{{- define "tolerations" }}
{{ if eq .Values.runtime "ICP4Data" -}}
tolerations:
- key: "icp4data"
  operator: "Equal"
  value: "database-mongodb"
  effect: "NoSchedule" 
{{- end }}
{{- end }}