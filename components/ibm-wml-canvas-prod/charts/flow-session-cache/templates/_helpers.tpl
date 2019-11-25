{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "flow-session-cache.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "flow-session-cache.secrets" -}}
{{- printf "%s-%s-%d" .Release.Name .Chart.Name .Release.Revision | trunc 63 | trimSuffix "-" -}}
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

{{/* Where do we get the flow session cache secrets from... */}}
{{- define "cache-db.password-secret" -}}
{{- printf "%s-cache-db-postgres-password" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "flow-session-cache.fullname" -}}
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
{{- define "flow-session-cache.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "flow-session-cache.jobname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 50 | trimSuffix "-" -}}
{{- end -}}

{{- define "flow-session-cache.hookRole" -}}
{{- printf "%s-%s-hook" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "flow-session-cache.hookServiceAccount" -}}
{{- printf "%s-%s-hook" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "flow-session-cache.mainRole" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "flow-session-cache.mainServiceAccount" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Create session pod name prefix.
*/}}
{{- define "flow-session-cache.session-pod-name-prefix" -}}
{{- printf "%s-%s" .Release.Name .Values.sessionPodName | trunc 63 | trimSuffix "-" -}}
{{- end -}}
