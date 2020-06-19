{{/* toleration - https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ */}}

{{- define "dg.tolerations" }}
{{ if eq .Values.runtime "ICP4Data" -}}
tolerations:
- key: "icp4data"
  operator: "Equal"
  value: "database-db2oltp"
  effect: "NoSchedule"
{{- end }}
{{- end }}
