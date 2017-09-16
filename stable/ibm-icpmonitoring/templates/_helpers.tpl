{{/* vim: set filetype=mustache: */}}

{{/*
Create a default fully qualified app name for prometheus.
*/}}
{{- define "prometheus.fullname" -}}
{{- $name := default "prometheus" .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name for grafana.
*/}}
{{- define "grafana.fullname" -}}
{{- $name := default "grafana" .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name for collectdexporter.
*/}}
{{- define "collectdexporter.fullname" -}}
{{- $name := default "exporter" .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
