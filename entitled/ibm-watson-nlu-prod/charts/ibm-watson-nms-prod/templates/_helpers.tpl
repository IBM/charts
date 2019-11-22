{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "ibm-watson-nms-prod.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ibm-watson-nms-prod.fullname" -}}
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
{{- define "ibm-watson-nms-prod.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "icp-pull-secrets" -}}
{{- printf "%s" (default (printf "sa-%s" .Release.Namespace) .Values.global.imagePullSecretName) -}}
{{- end -}}

{{/* ######################################## TLS SECRET NAME ######################################## */}}
{{- define "nms.tlsSecretNameTemplate" -}}
{{- printf "%s-nms-tls-secrets" .Release.Name -}}
{{- end -}}
{{/* ######################################## TLS SECRET NAME ######################################## */}}

{{/* ######################################## MINIO ################################### */}}
{{- define "nms.minioAccessSecretNameTemplate" -}}
{{- printf "%s-nms-minio-access-secret" .Release.Name -}}
{{- end -}}

{{- /* MINIO ENDPOINT TEMPLATE
*/ -}}
{{- define "nms.minioEndpointTemplate" -}}
http{{ if .Values.global.s3.sslEnabled }}s{{ end }}://{{ .Release.Name }}-ibm-minio-svc.{{ .Release.Namespace }}.{{ .Values.global.clusterDomain }}:{{ .Values.global.s3.endpointPort }}
{{- end -}}
{{/* ######################################## MINIO ################################### */}}
