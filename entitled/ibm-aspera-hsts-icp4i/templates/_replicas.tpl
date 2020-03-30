# aej
{{ define "hsts.replicas.aej" -}}
  {{- if .Values.aej.replicas }}
    {{- .Values.aej.replicas -}}
  {{ else }}
    {{- .Values.global.replicas -}}
  {{ end }}
{{- end }}

# asperanode
{{ define "hsts.replicas.asperanode" -}}
  {{- if .Values.asperanode.replicas }}
    {{- .Values.asperanode.replicas -}}
  {{ else }}
    {{- .Values.global.replicas -}}
  {{ end }}
{{- end }}

# tcp-proxy
{{ define "hsts.replicas.tcpProxy" -}}
  {{- if .Values.tcpProxy.replicas }}
    {{- .Values.tcpProxy.replicas -}}
  {{ else }}
    {{- .Values.global.replicas -}}
  {{ end }}
{{- end }}

# ascp-loadbalancer
{{ define "hsts.replicas.ascpLoadbalancer" -}}
  {{- if .Values.ascpLoadbalancer.replicas }}
    {{- .Values.ascpLoadbalancer.replicas -}}
  {{ else }}
    {{- .Values.global.replicas -}}
  {{ end }}
{{- end }}

# ascp-swarm
{{ define "hsts.replicas.ascpSwarm" -}}
  {{- if .Values.ascpSwarm.replicas }}
    {{- .Values.ascpSwarm.replicas -}}
  {{ else }}
    {{- .Values.global.replicas -}}
  {{ end }}
{{- end }}

# http-proxy
{{ define "hsts.replicas.httpProxy" -}}
  {{- if .Values.httpProxy.replicas }}
    {{- .Values.httpProxy.replicas -}}
  {{ else }}
    {{- .Values.global.replicas -}}
  {{ end }}
{{- end }}

# noded-loadbalancer
{{ define "hsts.replicas.nodedLoadbalancer" -}}
  {{- if .Values.nodedLoadbalancer.replicas }}
    {{- .Values.nodedLoadbalancer.replicas -}}
  {{ else }}
    {{- .Values.global.replicas -}}
  {{ end }}
{{- end }}

# noded-swarm
{{ define "hsts.replicas.nodedSwarm" -}}
  {{- if .Values.nodedSwarm.replicas }}
    {{- .Values.nodedSwarm.replicas -}}
  {{ else }}
    {{- .Values.global.replicas -}}
  {{ end }}
{{- end }}

# lifecycle
{{ define "hsts.replicas.lifecycle" -}}
  {{- if .Values.lifecycle.replicas }}
    {{- .Values.lifecycle.replicas -}}
  {{ else }}
    {{- .Values.global.replicas -}}
  {{ end }}
{{- end }}

# stats
{{ define "hsts.replicas.stats" -}}
  {{- if .Values.stats.replicas }}
    {{- .Values.stats.replicas -}}
  {{ else }}
    {{- .Values.global.replicas -}}
  {{ end }}
{{- end }}

# prometheus-endpoint
{{ define "hsts.replicas.prometheusEndpoint" -}}
  {{- if .Values.prometheusEndpoint.replicas }}
    {{- .Values.prometheusEndpoint.replicas -}}
  {{ else }}
    {{- .Values.global.replicas -}}
  {{ end }}
{{- end }}