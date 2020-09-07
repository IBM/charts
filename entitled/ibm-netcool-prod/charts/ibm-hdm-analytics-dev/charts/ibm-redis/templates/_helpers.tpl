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

{{- define "redis.images.redis" -}}
{{- if or (eq (toString .Values.global.image.useTag) "true") (eq (toString .Values.image.digest) "") -}}
{{- printf "%s/%s:%s" (include "redis.getImageRepo" .) .Values.image.name .Values.image.tag -}}
{{- else -}}
{{- printf "%s/%s@%s" (include "redis.getImageRepo" .) .Values.image.name .Values.image.digest -}}
{{- end -}}
{{- end -}}

{{- define "redis.images.creds" -}}
{{- if or (eq (toString .Values.global.image.useTag) "true") (eq (toString .Values.creds.image.digest) "") -}}
{{- printf "%s/%s:%s" (include "redis.getImageRepo" .) .Values.creds.image.name .Values.creds.image.tag -}}
{{- else -}}
{{- printf "%s/%s@%s" (include "redis.getImageRepo" .) .Values.creds.image.name .Values.creds.image.digest -}}
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
{{- define "ibmRedis.getServiceAccountName" -}}
{{- if ne (toString .Values.serviceAccountName) "" -}}
  {{- tpl .Values.serviceAccountName . }}
{{- else if ne (toString .Values.global.rbac.serviceAccountName) "" -}}
  {{- tpl .Values.global.rbac.serviceAccountName . }}
{{- else if eq (toString .Values.global.rbac.create) "false" -}}
  {{- printf "%s" "default" | quote }}
{{- else -}}
  {{ include "sch.names.fullCompName" (list . "serviceaccount") }}
{{- end -}}
{{- end -}}

{{- define "ibmRedis.authSecretName" }}
{{- tpl (.Values.global.redis.authSecretName | default .Values.auth.authSecretName) . }}
{{- end }}

{{- define "ibmRedis.upgradeFromV1" }}
{{- toString (or .Values.upgradeFromV1 .Values.global.redis.upgradeFromV1) }}
{{- end }}
