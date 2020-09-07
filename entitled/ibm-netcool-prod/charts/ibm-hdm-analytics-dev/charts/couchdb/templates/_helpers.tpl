{{/* vim: set filetype=mustache: */}}

{{- define "couchdb.getImageRepo" -}}
{{- if .Values.global.image.repository -}}
{{- printf "%s" ( trimSuffix "/" .Values.global.image.repository ) }}
{{- end -}}
{{- end -}}

{{- define "couchdb.getImage" -}}
{{- if or (eq (toString .Values.global.image.useTag) "true") (eq (toString .Values.image.digest) "") -}}
{{- printf "%s/%s:%s" (include "couchdb.getImageRepo" .) .Values.image.name .Values.image.tag -}}
{{- else -}}
{{- printf "%s/%s@%s" (include "couchdb.getImageRepo" .) .Values.image.name .Values.image.digest -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "couchdb.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "couchdb.releasename" -}}
{{- printf "%s" .Release.Name  | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Helper functions which can be used for used for .Values.arch in PPA Charts
Check if tag contains specific platform suffix and if not set based on kube platform
uncomment this section for PPA charts, can be removed in github.com charts
*/}}

{{/*
check if couchdb.clusterSize == "environmentSizeDefault" and if so use value in _resouces.tpl
corresponding to environmentSize setting
*/}}
{{- define "couchdb.replicationFactor" -}}
  {{- if eq ( .Values.clusterSize | toString) "environmentSizeDefault" }}
    {{- include "couchdb.comp.size.data" (list . "couchdb" "replicas") }}
  {{- else }}
    {{- .Values.clusterSize }}
  {{- end }}
{{- end }}

{{- define "couchdb.getServiceAccountName" -}}
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
