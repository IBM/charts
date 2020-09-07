{{/* vim: set filetype=mustache: */}}
{{/*
########################################################################
#
# Licensed Materials - Property of IBM
#
# (C) Copyright IBM Corp.
#
# 2019 All Rights Reserved
#
# US Government Users Restricted Rights - Use, duplication or disclosure 
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
########################################################################
*/}}

{{- define "ncodatalayer.probe.liveness" -}}
livenessProbe:
  httpGet:
    port: {{ .Values.ncodatalayer.liveness.port }}
    path: {{ .Values.ncodatalayer.liveness.path }}
  initialDelaySeconds: {{ .Values.ncodatalayer.liveness.initialDelaySeconds }}
  periodSeconds: {{ .Values.ncodatalayer.liveness.periodSeconds }}
  timeoutSeconds: {{ .Values.ncodatalayer.liveness.timeoutSeconds }}
  failureThreshold: {{ .Values.ncodatalayer.liveness.failureThreshold }}
{{- end -}}

{{- define "ncodatalayer.probe.readiness" -}}
readinessProbe:
  httpGet:
    port: {{ .Values.ncodatalayer.readiness.port }}
    path: {{ .Values.ncodatalayer.readiness.path }}
  initialDelaySeconds: {{ .Values.ncodatalayer.readiness.initialDelaySeconds }}
  periodSeconds: {{ .Values.ncodatalayer.readiness.periodSeconds }}
  timeoutSeconds: {{ .Values.ncodatalayer.readiness.timeoutSeconds }}
  failureThreshold: {{ .Values.ncodatalayer.readiness.failureThreshold }}
{{- end -}}
