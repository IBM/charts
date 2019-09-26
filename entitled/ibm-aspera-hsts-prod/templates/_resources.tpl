{{ define "hsts.resources.static.tiny" -}}
resources:
  requests:
    memory: 50Mi
    cpu: '.01'
  limits:
    memory: 100Mi
    cpu: '.1'
{{- end }}

{{ define "hsts.resources.static.small" -}}
resources:
  requests:
    memory: 100Mi
    cpu: '.1'
  limits:
    memory: 200Mi
    cpu: '.1'
{{- end }}
