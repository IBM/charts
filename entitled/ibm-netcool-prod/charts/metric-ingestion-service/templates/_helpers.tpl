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
Helpers for calculating cluster.fqdns / URLs
*/ -}}
{{- define "metric-ingestion-service.cluster.fqdn" -}}
  {{- if .Values.global.cluster.fqdn -}}
    {{- .Values.global.cluster.fqdn -}}
  {{- else -}}
    {{- .Values.global.cluster.fqdn -}}
  {{- end -}}
{{- end -}}

{{- define "metric-ingestion-service.ingress.globalhost" -}}
  {{- $root := index . 0 -}}
  {{- $prefix := index . 1 -}}
  {{- $ingressGlobal := $root.Values.global.ingress }}
  {{- $ingressDomain := include "metric-ingestion-service.cluster.fqdn" $root -}}

  {{- if $ingressGlobal.prefixWithReleaseName -}}
    {{- printf "%s.%s.%s" $prefix $root.Release.Name $ingressDomain | trimPrefix "." -}}
  {{- else -}}
    {{- printf "%s.%s" $prefix $ingressDomain | trimPrefix "." -}}
  {{- end -}}
{{- end -}}

{{- define "metric-ingestion-service.ingress.host" -}}
  {{- $ingressComp := .Values.ingress }}

  {{- include "metric-ingestion-service.ingress.globalhost" (list . $ingressComp.prefix) -}}
{{- end -}}

{{- define "metric-ingestion-service.ingress.baseurl" -}}
  {{- $ingressGlobal := .Values.global.ingress }}
  {{- $ingressComp := .Values.ingress }}
  {{- $ingressHost := include "metric-ingestion-service.ingress.host" . -}}

  {{- printf "https://%s:%g%s" $ingressHost $ingressGlobal.port $ingressComp.path | trimPrefix "." -}}
{{- end -}}


{{- /*
Helpers for docker image locations
*/ -}}
{{- define "metric-ingestion-service.image.url" -}}
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

{{- define "metric-ingestion-service.container.security.context" -}}
securityContext:
  privileged: false
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: false
  runAsNonRoot: true
  capabilities:
    drop:
    - ALL
{{- end -}}

{{- define "metric-ingestion-service.spec.security.context" -}}
hostNetwork: false
hostPID: false
hostIPC: false
securityContext:
  runAsNonRoot: true
{{- end -}}

{{- define "metric-ingestion-service.getKafkaRelease" -}}
  {{- $root := index . 0 -}}
  {{- $userDefinedRelease := index . 1 -}}

  {{- if $userDefinedRelease -}}
    {{- $userDefinedRelease -}}
  {{ else }}
    {{- $root.Release.Name -}}
  {{- end -}}
{{- end -}}

{{- define "metric-ingestion-service.getCemusersUrl" -}}
  {{- $root := index . 0 -}}
  {{- $varName := index . 1 -}}
  {{- $releaseName := default $root.Release.Name (index . 2) -}}
  {{- $namespace := default $root.Release.Namespace (index . 3) -}}
  {{- $varTpl := index . 4 -}}
  {{- $_ := set $root "releaseName" $releaseName }}
  {{- $_ := set $root "namespace" $namespace }}
- name: {{ $varName | quote }}
  value: {{ tpl $varTpl $root | quote }}
{{- end -}}


{{- define "metric-ingestion-service.getSparkRelease" -}}
  {{- $root := index . 0 -}}
  {{- $userDefinedRelease := index . 1 -}}

  {{- if $userDefinedRelease -}}
    {{- $userDefinedRelease -}}
  {{ else }}
    {{- $root.Release.Name -}}
  {{- end -}}
{{- end -}}
