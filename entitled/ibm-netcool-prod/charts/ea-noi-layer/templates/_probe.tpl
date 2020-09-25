{{/* vim: set filetype=mustache: */}}
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

{{- define "ea-noi-layer.probe.smonitor.readiness" -}}
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

{{- define "ea-noi-layer.probe.smonitor.liveness" -}}
livenessProbe:
  httpGet:
    port: unsecure-port
{{ if .path }}
    path: {{ .path }}
{{ else }}
    path: /servicemonitor
{{ end }}
  timeoutSeconds: 60
  initialDelaySeconds: 70
  periodSeconds: 60
  successThreshold: 1
  failureThreshold: 3
{{- end -}}

{{- define "ea-noi-layer.probe.tcpsocket.readiness" -}}
readinessProbe:
  tcpSocket:
    port: unsecure-port
  timeoutSeconds: 60
  initialDelaySeconds: 60
  periodSeconds: 60
  successThreshold: 1
  failureThreshold: 3
{{- end -}}

{{- define "ea-noi-layer.probe.tcpsocket.liveness" -}}
livenessProbe:
  tcpSocket:
    port: unsecure-port
  timeoutSeconds: 60
  initialDelaySeconds: 70
  periodSeconds: 60
  successThreshold: 1
  failureThreshold: 3
{{- end -}}

{{- define "ea-noi-layer.probe.smonitor.all" -}}
{{ include "ea-noi-layer.probe.smonitor.liveness" . }}
{{ include "ea-noi-layer.probe.smonitor.readiness" . }}
{{- end -}}

{{- define "ea-noi-layer.probe.tcpsocket.all" -}}
{{ include "ea-noi-layer.probe.tcpsocket.liveness" . }}
{{ include "ea-noi-layer.probe.tcpsocket.readiness" . }}
{{- end -}}
