{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "minio.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "minio.fullname" -}}
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
{{- define "minio.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for networkpolicy.
*/}}
{{- define "minio.networkPolicy.apiVersion" -}}
{{- if semverCompare ">=1.4-0, <1.7-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "extensions/v1beta1" -}}
{{- else if semverCompare "^1.7-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "networking.k8s.io/v1" -}}
{{- end -}}
{{- end -}}

{{/*
  Define a secret name to be used to gather accessKey and secretKey
*/}}
{{- define "minio.accessSecretName" -}}
{{- if .Values.minioAccessSercret -}}
  {{- printf "%s" .Values.minioAccessSercret -}}
{{- else if .Values.minioAccessSecretTemplateName -}}
  {{- include .Values.minioAccessSecretTemplateName . -}}
{{- else -}}
{{ required "Specify non empty minioAccessSercret (or minioAccessSecretTemplateName) value. This value specifies (generates) the name of the secret with access and secret keys." "" }}
{{- end -}}
{{- end -}}