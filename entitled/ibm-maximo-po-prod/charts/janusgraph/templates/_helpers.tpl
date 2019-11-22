{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "janusgraph.name" -}}
po-janusgraph
{{- end -}}

{{/*
Expand the configs for outer app.
*/}}
{{- define "janusgraph.sslenabled" -}}false{{- end -}}
{{- define "janusgraph.port" -}}8182{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "janusgraph.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "janusgraph.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "janusgraph.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "janusgraphpo.cert.name" -}}
{{- if .Values.global.secretGen.autoCert -}}
{{- printf "%s-po-autocert" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{ .Values.global.secretGen.existingCert }}
{{- end -}}
{{- end -}}
