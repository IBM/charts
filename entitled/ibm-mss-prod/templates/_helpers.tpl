{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "mss.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mss.fullname" -}}
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
{{- define "mss.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mss.ContainerUID" -}}
15585
{{- end -}}

{{ define "ibm-mss-prod.serviceaccount" }}
{{ if .Values.global.serviceAccountName }}
serviceAccountName: {{ .Values.global.serviceAccountName }}
{{- else }}
serviceAccountName: {{ .Release.Name }}-mss
{{- end }}
{{- end }}

{{ define "ibm-mss-prod.tolerations" }}
{{ if .Values.global.tolerationKey }}
tolerations:
  - key: {{ .Values.global.tolerationKey | quote }}
{{- if .Values.global.tolerationValue }}
    operator: "Equal"
    value: {{ .Values.global.tolerationValue | quote }}
{{- else }}
    operator: "Exists"
{{- end }}
    effect: {{ .Values.global.tolerationEffect | quote }}
{{- end }}
{{- end -}}

{{ define "ibm-mss-prod.releaseAnnotations" }}
productName: "IBM Watson Machine Learning Accelerator"
productVersion: "2.1.0"
productID: "ICP4D-addon-5737-F22"
{{- end -}}
