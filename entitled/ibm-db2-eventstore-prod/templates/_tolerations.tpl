{{/* toleration - https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ */}}

{{- define "eventstore.tolerations" }}
{{ if eq .Values.runtime "ICP4Data" -}}
tolerations:
- key: "icp4data"
  operator: "Equal"
  value: {{ .Values.servicename }}
  effect: "NoSchedule" 
{{- end }}
{{- end }}
