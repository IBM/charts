{{/*
########################################################################
#
# Licensed Materials - Property of IBM
#
# 5725Q09
#
# (C) Copyright IBM Corp.
#
# 2018 All Rights Reserved
#
# US Government Users Restricted Rights - Use, duplication or disclosure 
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
########################################################################
*/}}

{{- define "metric-trigger-service.probe.smonitor.readiness" -}}
readinessProbe:
  httpGet:
    port: unsecure-port
{{ if .path }}
    path: {{ .path }}
{{ else }}
    path: /servicemonitor
{{ end }}
  timeoutSeconds: 60
  initialDelaySeconds: 30
  periodSeconds: 60
  successThreshold: 1
  failureThreshold: 3
{{- end -}}

{{- define "metric-trigger-service.probe.smonitor.liveness" -}}
livenessProbe:
  httpGet:
    port: unsecure-port
{{ if .path }}
    path: {{ .path }}
{{ else }}
    path: /servicemonitor
{{ end }}
  timeoutSeconds: 60
  initialDelaySeconds: 60
  periodSeconds: 60
  successThreshold: 1
  failureThreshold: 3
{{- end -}}

{{- define "metric-trigger-service.probe.smonitor.all" -}}
{{ include "metric-trigger-service.probe.smonitor.liveness" . }}
{{ include "metric-trigger-service.probe.smonitor.readiness" . }}
{{- end -}}
