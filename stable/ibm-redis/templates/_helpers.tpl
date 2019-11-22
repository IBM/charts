{{/*
###############################################################################
# Licensed Materials - Property of IBM.
# Copyright IBM Corporation 2018, 2019.. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
# Contributors:
#  IBM Corporation - initial API and implementation
###############################################################################
*/}}
{{/* vim: set filetype=mustache: */}}

{{- define "redis.getImageRepo" -}}
{{- if .Values.global.image.repository -}}
{{- printf "%s" ( trimSuffix "/" .Values.global.image.repository ) }}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "redis.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
  Adds support for templated affinity
  i.e., .Values.affinity: "{ { include "umbrella-chart.affinity" . } }"
*/}}
{{- define "ibmRedis.affinityRedis" -}}
  {{- if .Values.affinityRedis -}}
    {{- if kindIs "string" .Values.affinityRedis -}}
      {{- tpl .Values.affinityRedis . -}}
    {{- else -}}
      {{- tpl ( .Values.affinityRedis | toYaml ) . -}}
    {{- end -}}
  {{- else if .Values.affinity -}}
    {{/* To be backward compatible, we are looking for .Values.affinity before defaulting to sch chart labels */}}
    {{- .Values.affinity -}}
  {{- else -}}
    {{- include "sch.affinity.nodeAffinity" (list . .sch.chart.nodeAffinity) }}
  {{- end -}}
{{- end -}}

{{/*
check if replicas == "environmentSizeDefault" and if so use value in _resouces.tpl
corresponding to environmentSize setting
*/}}
{{- define "ibmRedis.replicationFactor" -}}
  {{- if eq ( .Values.replicas | toString) "environmentSizeDefault" }}
    {{- include "ibmRedis.comp.size.data" (list . "both" "replicas") }}
  {{- else }}
    {{- .Values.replicas }}
  {{- end }}
{{- end }}

{{- define "ibmRedis.persistenceEnabled" }}
  {{- if ne (kindOf .Values.persistence.enabled) "invalid" }}
    {{- .Values.persistence.enabled }}
  {{- else }}
    {{- .Values.global.persistence.enabled }}
  {{- end }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "ibmRedis.serviceAccountName" -}}
  {{- include "sch.names.fullName" (list .) -}}
{{- end -}}
