{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "ibm-watson-mma-prod.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ibm-watson-mma-prod.fullname" -}}
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
{{- define "ibm-watson-mma-prod.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "icp-pull-secrets" -}}
{{- printf "%s" (default (printf "sa-%s" .Release.Namespace) .Values.global.imagePullSecretName) -}}
{{- end -}}

{{/* ######################################## TLS SECRET NAME ######################################## */}}
{{- define "mma.tlsSecretNameTemplate" -}}
{{- printf "%s-mma-tls-secrets" .Release.Name -}}
{{- end -}}
{{/* ######################################## TLS SECRET NAME ######################################## */}}

{{/* ################################### POSTGRES AUTH SECRET NAME ################################### */}}
{{- define "mma.postgresAuthSecretNameTemplate" -}}
{{- printf "%s-mma-postgres-auth-secret" .Release.Name -}}
{{- end -}}
{{/* ################################### POSTGRES AUTH SECRET NAME ################################### */}}
