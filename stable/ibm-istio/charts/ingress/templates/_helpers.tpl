{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "ingress.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "ingress.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Service account name.
*/}}
{{- define "ingress.serviceAccountName" -}}
{{- if .Values.global.rbacEnabled -}}
{{- template "ingress.fullname" . -}}-service-account
{{- else }}
{{- .Values.serviceAccountName | trunc 63 | trimSuffix "-" -}}-service-account
{{- end -}}
{{- end -}}
