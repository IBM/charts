{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "informix-ibm.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "informix-ibm.fullname" -}}
{{- if .Values.global.fullnameOverride -}}
{{- .Values.global.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- if .Values.servicename -}}
{{- .Values.servicename | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "informix-ibm.dbserveralias" -}}
{{ .Release.Name  | replace "-" "_" }}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "informix-ibm.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "informix-ibm.labels" -}}
release: "{{ .Release.Name }}"
app.kubernetes.io/name: {{ include "informix-ibm.name" . }}
helm.sh/chart: {{ include "informix-ibm.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/* these functions are used to built the registry/repository path */}}

{{- define "informix-ibm.eng-repo-image" -}}
{{- if ( eq .Values.runtime "ICP4Data" ) }}
{{- .Values.images.eng.image.repository }}:{{ .Values.images.eng.image.tag -}}
{{- else -}}
{{- .Values.images.eng.image.registry }}/{{ .Values.images.eng.image.repository }}:{{ .Values.images.eng.image.tag -}}
{{- end -}}
{{- end -}}

{{/* api is only used if ICP4Data is defined no need the extra if */}}
{{- define "informix-ibm.api-repo-image" -}}
{{- .Values.images.api.image.repository }}:{{ .Values.images.api.image.tag -}}
{{- end -}}
