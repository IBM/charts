{{/* HAProxy-specific labels */}}
{{ define "haproxy.labels" -}}
{{ include "global.labels" . }}
app.kubernetes.io/name: haproxy
app.kubernetes.io/component: loadbalancer
{{- end }}

{{/* labels to identify pods for upgrades etc. Must not change between releases */}}
{{ define "haproxy.selector.labels" -}}
{{ include "global.selector.labels" . }}
app.kubernetes.io/name: haproxy
app.kubernetes.io/component: loadbalancer
{{- end }}

{{ define "haproxy.replicas" -}}
{{- if .Values.global.cloudant.singleNode -}}
    1
{{- else -}}
    {{ .Values.global.replicas.glum }}
{{- end -}}
{{- end }}
