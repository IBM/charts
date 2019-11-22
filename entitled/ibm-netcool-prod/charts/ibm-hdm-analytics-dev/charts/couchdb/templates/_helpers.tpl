{{/* vim: set filetype=mustache: */}}

{{- define "couchdb.getImageRepo" -}}
{{- if .Values.global.image.repository -}}
{{- printf "%s" ( trimSuffix "/" .Values.global.image.repository ) }}
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
