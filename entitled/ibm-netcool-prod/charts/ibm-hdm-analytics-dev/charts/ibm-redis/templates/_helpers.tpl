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
    {{ default "default" ( default .Values.global.rbac.serviceAccountName .Values.serviceAccount.name ) }}
{{- end -}}
{{- end -}}

{{/*
Allow use of global.rbac.create
*/}}
{{- define "ibmRedis.rbac.create" }}
{{- if ne (kindOf .Values.rbac.create) "invalid" }}
  {{- .Values.rbac.create }}
{{- else }}
  {{- .Values.global.rbac.create }}
{{- end }}
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
check if replicas.servers == "environmentSizeDefault" and if so use value in _resouces.tpl
corresponding to environmentSize setting
*/}}
{{- define "ibmRedis.server.replicationFactor" -}}
  {{- if eq ( .Values.replicas.servers | toString) "environmentSizeDefault" }}
    {{- include "ibmRedis.comp.size.data" (list . "server" "replicas") }}
  {{- else }}
    {{- .Values.replicas.servers }}
  {{- end }}
{{- end }}

{{/*
check if replicas.servers == "environmentSizeDefault" and if so use value in _resouces.tpl
corresponding to environmentSize setting
*/}}
{{- define "ibmRedis.sentinel.replicationFactor" -}}
  {{- if eq ( .Values.replicas.sentinels | toString) "environmentSizeDefault" }}
    {{- include "ibmRedis.comp.size.data" (list . "sentinel" "replicas") }}
  {{- else }}
    {{- .Values.replicas.sentinels }}
  {{- end }}
{{- end }}

{{- define "ibmRedis.persistenceEnabled" }}
  {{- if ne (kindOf .Values.persistence.enabled) "invalid" }}
    {{- .Values.persistence.enabled }}
  {{- else }}
    {{- .Values.global.persistence.enabled }}
  {{- end }}
{{- end -}}
