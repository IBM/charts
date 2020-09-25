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

{{- define "eventanalytics.probe.smonitor.readiness" -}}
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

{{- define "eventanalytics.probe.smonitor.liveness" -}}
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

{{- define "eventanalytics.probe.tcpsocket.readiness" -}}
readinessProbe:
  tcpSocket:
    port: unsecure-port
  timeoutSeconds: 60
  initialDelaySeconds: 60
  periodSeconds: 60
  successThreshold: 1
  failureThreshold: 3
{{- end -}}

{{- define "eventanalytics.probe.tcpsocket.liveness" -}}
livenessProbe:
  tcpSocket:
    port: unsecure-port
  timeoutSeconds: 60
  initialDelaySeconds: 70
  periodSeconds: 60
  successThreshold: 1
  failureThreshold: 3
{{- end -}}

{{- define "eventanalytics.probe.smonitor.all" -}}
{{ include "eventanalytics.probe.smonitor.liveness" . }}
{{ include "eventanalytics.probe.smonitor.readiness" . }}
{{- end -}}

{{- define "eventanalytics.probe.tcpsocket.all" -}}
{{ include "eventanalytics.probe.tcpsocket.liveness" . }}
{{ include "eventanalytics.probe.tcpsocket.readiness" . }}
{{- end -}}
