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
  Adds support for templated affinity
  i.e., .Values.affinity: "{ { include "umbrella-chart.affinity" . } }"
*/}}
{{- define "ibmRedis.affinityRedis" -}}
  {{- if .Values.affinityRedis -}}
    {{- if kindIs "string" .Values.affinityRedis -}}
      {{- tpl .Values.affinityRedis . -}}
    {{- else -}}
      {{- $root := . -}}
      {{- range $key, $value := .Values.affinityRedis }}
{{ tpl $value $root }}
      {{- end }}
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

{{- define "redis.sentinel.podAntiAffinity" -}}
{{- if or (eq .Values.global.podAntiAffinity "Enable") (and (eq .Values.global.deploymentType "Production") (ne .Values.global.podAntiAffinity "Disable")) -}}
podAntiAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchExpressions:
    {{- $labels := include "sch.metadata.labels.standard" (list . .sch.chart.components.sentinel) | fromYaml }}
    {{- range $name, $value := $labels }}
      - key: {{ $name | quote }}
        operator: In
        values:
        - {{ $value | quote }}
    {{- end }}
    topologyKey: "kubernetes.io/hostname"
{{- end -}}
{{- end -}}

{{- define "redis.server.podAntiAffinity" -}}
{{- if or (eq .Values.global.podAntiAffinity "Enable") (and (eq .Values.global.deploymentType "Production") (ne .Values.global.podAntiAffinity "Disable")) -}}
podAntiAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchExpressions:
    {{- $labels := include "sch.metadata.labels.standard" (list . .sch.chart.components.server) | fromYaml }}
    {{- range $name, $value := $labels }}
      - key: {{ $name | quote }}
        operator: In
        values:
        - {{ $value | quote }}
    {{- end }}
      - key: redis-node
        operator: In
        values:
        - "true"
    topologyKey: "kubernetes.io/hostname"
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
