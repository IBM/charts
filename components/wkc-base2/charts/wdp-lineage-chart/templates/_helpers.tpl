{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "wdp-lineage-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name or vice versa it(release name) will be used as a full name.
*/}}
{{- define "wdp-lineage-chart.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- if contains .Release.Name $name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "wdp-lineage-chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create autheticator
*/}}
{{- define "wdp-lineage-chart.autheticator" -}}
{{- if eq .Values.global.deploymentTarget "icp4data" -}}
{{- "ICP4D" -}}
{{- else -}}
{{- .Values.environment.LS_AUTHENTICATOR -}}
{{- end -}}
{{- end -}}

{{/*
Create token generator
*/}}
{{- define "wdp-lineage-chart.tokenGenerator" -}}
{{- if eq .Values.global.deploymentTarget "icp4data" -}}
{{- "ICP4D" -}}
{{- else -}}
{{- .Values.environment.LS_TOKEN_GENERATOR -}}
{{- end -}}
{{- end -}}
