{{/*
  Licensed Materials - Property of IBM
  5737-E67
  @ Copyright IBM Corporation 2016, 2018. All Rights Reserved.
  US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
*/}}

{{/* Grafana Configuration Files */}}
{{- define "grafanaConfig" }}
grafana.ini: |-
    [paths]
    data = /var/lib/grafana
    logs = /var/log/grafana
    plugins = /var/lib/grafana/plugins

    [server]
    {{- if or (eq .Values.mode "managed") .Values.tls.enabled }}
    root_url = %(protocol)s://%(domain)s:%(http_port)s/grafana
    {{- end }}

    [users]
    default_theme = light

    [log]
    mode = console
{{- end }}
