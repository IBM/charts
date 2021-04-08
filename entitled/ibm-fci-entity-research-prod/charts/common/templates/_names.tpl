{{/*
{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "common.name" -}}
{{-   default .Chart.Name (default .Values.global.subChartReleaseSuffix .Values.nameOverride) | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "common.fullname" -}}
{{-   if .Values.fullnameOverride -}}
{{-     .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{-   else -}}
{{-     $name := default .Chart.Name .Values.nameOverride -}}
{{-     if contains $name .Release.Name -}}
{{-       .Release.Name | trunc 63 | trimSuffix "-" -}}
{{-     else -}}
{{-       printf "%s-%s-%s" .Release.Name .Values.global.subChartReleaseSuffix $name | trunc 63 | trimSuffix "-" -}}
{{-     end -}}
{{-   end -}}
{{- end -}}

{{/*
Get the name for secrets.
*/}}
{{- define "common.secrets-name" -}}
{{-   printf "%s-%s-%s" .Release.Name .Values.global.subChartReleaseSuffix "secrets" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Get the release name for foundational services.
*/}}
{{- define "common.core-release-name" -}}
{{-     if .Values.global.coreReleaseName -}}
{{-        .Values.global.coreReleaseName -}}
{{-     else -}}
{{-         .Release.Name -}}
{{-     end -}}
{{- end -}}
