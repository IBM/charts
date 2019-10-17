{{- define "ibm-eventstreams.features" }}
  replicator:
    {{- if eq .sch.chart.edition "dev" }}
    enabled: false
    {{- /* Replicator is in all other charts aside from dev */ -}}
    {{- else }}
    enabled: true
    {{- end }}
{{- end }}
