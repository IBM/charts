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


{{- include "sch.config.init" (list . "ibm-hdm-analytics-dev.sch.chart.config.values") -}}

{{- /*
Helpers for docker image locations
*/ -}}
{{- define "alert-trigger-service.image.url" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- $imageParams := last $params -}}
  {{- $trimedRepo := ($root.Values.global.image.repository | trimAll "/") -}}

  {{- if $imageParams.repository -}}
    {{- printf "%s/%s/%s" $trimedRepo $imageParams.repository $imageParams.name | trimAll "/" -}}
  {{- else -}}
    {{- printf "%s/%s" $trimedRepo $imageParams.name | trimAll "/" -}}
  {{- end -}}
  {{- if or (eq (toString $root.Values.global.image.useTag) "true") (eq (toString $imageParams.digest) "") -}}
    {{- printf ":%s" $imageParams.tag -}}
  {{- else -}}
    {{- printf "@%s" $imageParams.digest -}}
  {{- end -}}
{{- end -}}

{{- define "alert-trigger-service.container.security.context" -}}
securityContext:
  privileged: false
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: false
  runAsNonRoot: true
  capabilities:
    drop:
    - ALL
{{- end -}}

{{- define "alert-trigger-service.spec.security.context" -}}
hostNetwork: false
hostPID: false
hostIPC: false
securityContext:
  runAsNonRoot: true
{{- end -}}


{{- /*
Default URLs based on release name
*/ -}}
{{- define "alert-trigger-service.getRegistryRelease" -}}
  {{- $root := index . 0 -}}
  {{- $userDefinedRelease := index . 1 -}}

  {{- if $userDefinedRelease -}}
    {{- $userDefinedRelease -}}
  {{ else }}
    {{- $root.Release.Name -}}
  {{- end -}}
{{- end -}}

{{- define "alert-trigger-service.getKafkaRelease" -}}
  {{- $root := index . 0 -}}
  {{- $userDefinedRelease := index . 1 -}}

  {{- if $userDefinedRelease -}}
    {{- $userDefinedRelease -}}
  {{ else }}
    {{- $root.Release.Name -}}
  {{- end -}}
{{- end -}}
