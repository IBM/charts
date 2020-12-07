{{- define "jobs.resources" }}
resources:
  requests:
    cpu: "100m"
    memory: "50Mi"
  limits:
    cpu: "200m"
    memory: "100Mi"
{{- end }}

{{- define "jobs.resources.50" }}
resources:
  requests:
    cpu: "100m"
    memory: "50Mi"
  limits:
    cpu: "200m"
    memory: "150Mi"
{{- end }}


{{- define "jobs.resources.2X" }}
resources:
  requests:
    cpu: "100m"
    memory: "50Mi"
  limits:
    cpu: "200m"
    memory: "1500Mi"
{{- end }}

{{- define "jobs.resources.ppc64le.low" }}
resources:
  requests:
    cpu: "100m"
    memory: "200Mi"
  limits:
    cpu: "200m"
    memory: "250Mi"
{{- end }}


{{- define "jobs.resources.ppc64le" }}
resources:
  requests:
    cpu: "100m"
    memory: "250Mi"
  limits:
    cpu: "200m"
    memory: "500Mi"
{{- end }}
