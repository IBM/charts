{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "modeler-flow-api.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "modeler-flow-api.secrets" -}}
{{- printf "%s-%s-%d-secrets" .Release.Name .Chart.Name .Release.Revision | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "full-image-url" -}}
{{- if and .Values.global.docker.useNameSpace .Values.global.dockerRegistryPrefix -}}
{{- printf "%s/%s/%s/%s:%s" .Values.global.dockerRegistryPrefix .Values.image.repository .Values.image.namespace .Values.image.name .Values.image.tag -}}
{{- else if .Values.global.docker.useNameSpace -}}
{{- printf "%s/%s/%s:%s" .Values.image.repository .Values.image.namespace .Values.image.name .Values.image.tag -}}
{{- else if .Values.global.dockerRegistryPrefix -}}
{{- printf "%s/%s:%s" .Values.global.dockerRegistryPrefix .Values.image.repository .Values.image.tag -}}
{{- else -}}
{{- printf "%s:%s" .Values.image.repository .Values.image.tag -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "modeler-flow-api.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "modeler-flow-api.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
