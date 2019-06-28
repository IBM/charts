{{/*
###############################################################################
# Licensed Materials - Property of IBM.
# Copyright IBM Corporation 2018. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
# Contributors:
#  IBM Corporation - initial API and implementation
###############################################################################
*/}}
{{/* vim: set filetype=mustache: */}}
{{- include "sch.config.init" (list . "ibmRedis.sch.chart.config.values") -}}

{{/*
Create a hostname of the default fully qualified app name.
We truncate at 24 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "ibmRedis.hostname" -}}
{{- (include "sch.names.fullName" (list .)) | upper | replace "-" "_" -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "ibmRedis.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{- include "sch.names.fullName" (list .) -}}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
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

{{- define "ibmRedis.persistenceEnabled" }}
  {{- if ne (kindOf .Values.persistence.enabled) "invalid" }}
    {{- .Values.persistence.enabled }}
  {{- else }}
    {{- .Values.global.persistence.enabled }}
  {{- end }}
{{- end -}}
