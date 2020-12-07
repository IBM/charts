{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "parquet-store.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "parquet-store.fullname" -}}
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
{{- define "parquet-store.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "parquet-store.labels" -}}
app.kubernetes.io/name: {{ include "parquet-store.name" . }}
helm.sh/chart: {{ include "parquet-store.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
release: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
project: insights
{{- end -}}

{{/*
Standard way of picking choosing the image to use
*/}}
{{- define "parquet-store.insightsImagePath" -}}
{{- if .Values.global.image.repository -}}
image: "{{ .Values.global.image.repository }}/{{ .Values.image.image }}:{{ .Values.image.tag }}"
{{- else -}}
{{- if .Values.image.use_repository_namespace -}}
image: "{{ .Values.image.repository }}/{{ .Release.Namespace }}/{{ .Values.image.image }}:{{ .Values.image.tag }}"
{{- else -}}
image: "{{ .Values.image.repository }}/{{ .Values.image.image }}:{{ .Values.image.tag }}"
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Renders a value that contains template.
Usage:
{{ include "parquet-store.tplValue" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "parquet-store.tplValue" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{/*
fsGroupGid
*/}}
{{- define "parquet-store.fsGroupGid" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- if $root.Values.global.fsGroupGid -}}
  fsGroup: {{ $root.Values.global.fsGroupGid }}
  {{- end -}}
{{- end -}}