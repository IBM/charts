{{- define "tolerations" }}
{{ if eq .Values.runtime "ICP4Data" -}}
tolerations:
- key: "icp4data"
  operator: "Equal"
  value: "database-edb"
  effect: "NoSchedule" 
{{- end }}
{{- end }}