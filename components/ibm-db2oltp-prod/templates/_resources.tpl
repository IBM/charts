{{- define "jobs.resources" }}
resources:
  requests:
    cpu: "100m"
    memory: "50Mi"
  limits:
    cpu: "200m"
    memory: "100Mi"
{{- end }}

{{- define "jobs.resources.2X" }}
resources:
  requests:
    cpu: "100m"
    memory: "50Mi"
  limits:
    cpu: "200m"
    memory: "200Mi"
{{- end }}
