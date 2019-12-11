{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "ambassador.name" -}}
{{- printf "%s" $.Values.ambassador.name | default "ambassador" -}} 
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ambassador.fullname" -}}
{{- printf "%s" $.Values.ambassador.name | default "ambassador" -}} 
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ambassador.chart" -}}
{{- printf "%s" .Chart.Name -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "ambassador.serviceAccountName" -}}
{{- printf "%s" $.Values.ambassador.name | default "ambassador" -}} 
{{- end -}}

{{/*
Sanitise and define registries
*/}}
{{- define "foundations.repository" -}}
{{- if eq "entitled" .Values.global.repositoryType -}}
{{- if contains "/" .Values.global.repository -}}
{{ .Values.global.repository | trimSuffix "/" }}/foundations
{{- else -}}
{{ .Values.global.repository }}
{{- end -}}
{{- else -}}
{{ .Values.global.repository }}
{{- end -}}
{{- end -}}

{{- define "solutions.repository" -}}
{{- if eq "entitled" .Values.global.repositoryType -}}
{{- if contains "/" .Values.global.repository -}}
{{ .Values.global.repository | trimSuffix "/" }}/solutions
{{- else -}}
{{ .Values.global.repository }}
{{- end -}}
{{- else -}}
{{ .Values.global.repository }}
{{- end -}}
{{- end -}}
