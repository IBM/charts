{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "baas.name" -}}
{{- if .Values.nameOverride -}}
{{- default .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "baas.version" -}}
{{- default .Chart.Version .Values.versionOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "baas.appversion" -}}
{{- default .Chart.AppVersion .Values.versionOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "baas.productName" -}}
{{- printf "%s" "IBM Spectrum Protect Plus" -}}
{{- end -}}

{{- define "baas.productVersion" -}}
{{- printf "%s" .Chart.AppVersion -}}
{{- end -}}

{{- define "baas.productID" -}}
{{- printf "%s" "aaa070ab7a3a4af398f6b01a0e5f8e03" -}}
{{- end -}}

{{- define "baas.productMetric" -}}
{{- printf "%s" "GIGABYTE" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "baas.fullname" -}}
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
{{- define "baas.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
license  parameter must be set to true
*/}}
{{- define "{{ .Chart.Name }}.licenseValidate" -}}
  {{ $license := .Values.license }}
  {{- if $license  -}}
    true
  {{- end -}}
{{- end -}}