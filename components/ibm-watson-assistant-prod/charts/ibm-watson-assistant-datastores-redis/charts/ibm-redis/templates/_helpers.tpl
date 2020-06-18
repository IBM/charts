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
{{- define "ibmRedis.affinity" -}}
  {{- $allParams := . }}
  {{- $root      := first . }}
  {{- $details   := first (rest . ) }}
  {{- $_         := set $root "affinityDetails" $details -}}
  

  {{- if and $root.Values.affinityRedis (eq $details.component $root.sch.chart.components.server ) -}}
    {{- if kindIs "string" $root.Values.affinityRedis -}}
      {{- tpl $root.Values.affinityRedis $root -}}
    {{- else -}}
      {{- tpl ( $root.Values.affinityRedis | toYaml ) $root -}}
    {{- end -}}

  {{- else if $root.Values.affinity -}}
    {{/* To be backward compatible, we are looking for .Values.affinity before defaulting to sch chart labels */}}
    {{- if kindIs "string" $root.Values.affinity -}}
      {{- tpl $root.Values.affinity $root -}}
    {{- else -}}
      {{- tpl ( $root.Values.affinity | toYaml ) $root -}}
    {{- end -}}
  {{- else -}}
    {{- include "sch.affinity.nodeAffinity" (list $root $root.sch.chart.nodeAffinity) }}
  {{- end -}}
{{- end -}}

{{- define "ibmRedis.antiAffinity" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- $component := index $params 1 -}}

  {{- if $root.Values.antiAffinity.policy -}}
    {{/* Accept a string or a template as the mode */}}
    {{- $antiAffinityPolicy := (tpl $root.Values.antiAffinity.policy $root) -}}
    {{- if eq $antiAffinityPolicy "hard" }}
podAntiAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    - topologyKey: {{ tpl $root.Values.antiAffinity.topologyKey $root }}
      labelSelector:
        matchLabels:
{{ include "sch.metadata.labels.standard" (list $root $component) | indent 10 }}
    {{- else if eq $antiAffinityPolicy "soft" }}
podAntiAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 1
      podAffinityTerm:
        topologyKey: {{ tpl $root.Values.antiAffinity.topologyKey $root }}
        labelSelector:
          matchLabels:
{{ include "sch.metadata.labels.standard" (list $root $component) | indent 12 }}
    {{- end }}
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

{{- define "ibmRedis.licenseValidate" -}}
  {{ $license := .Values.global.license }}
  {{- if $license -}}
    true
  {{- end -}}
{{- end -}}

{{/*
  Evaluates if a var is set to true or not.
  Support not only bool values true/false but also
    strings "true"/"false" and templates like "{{ .Values.global.etcd.tsl.enabled }}"
  Usage: {{ if "ibmRedis.boolConvertor" (list .Values.tls.enabled .) }}
*/}}
{{- define "ibmRedis.boolConvertor" -}}
{{- if typeIs "bool" (first .) -}}
  {{- if (first .) }}    VALUE_IS_BOOL_TRUE_THUS_GENERATING_NON_EMPTY_STRING {{- end -}}
{{- else if typeIs "string" (first .) -}}
  {{- if eq "true" ( tpl (first .) (last .) )  }}VAULT_IS_STRING_AND_RENDERS_TO_TRUE_THUS_GENERATING_NON_EMPTY_STRING{{- end -}}
{{- end -}}
{{- end -}}
