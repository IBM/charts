{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "couchdb.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "couchdbpo.name" -}}
po-couchdb
{{- end -}}

{{- define "couchdb.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name (include "couchdbpo.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{- define "couchdb.svcname" -}}
{{- if .Values.fullnameOverride -}}
{{- printf "%s-svc-%s" .Values.fullnameOverride .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-svc-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}


{{- define "couchdb.secret.name" -}}
{{- if .Values.global.secretGen.autoSecret -}}
{{- printf "%s-po-autosecret" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{ .Values.global.secretGen.existingSecret }}
{{- end -}}
{{- end -}}

{{- define "couchdb.cert.name" -}}
{{- if .Values.global.secretGen.autoCert -}}
{{- printf "%s-po-autocert" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{ .Values.global.secretGen.existingCert }}
{{- end -}}
{{- end -}}