{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "outlier2-aggregation.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "outlier2-aggregation.fullname" -}}
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
{{- define "outlier2-aggregation.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "outlier2-aggregation.labels" -}}
app.kubernetes.io/name: {{ include "outlier2-aggregation.name" . }}
helm.sh/chart: {{ include "outlier2-aggregation.chart" . }}
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
{{- define "outlier2-aggregation.insightsImagePath" -}}
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
{{ include "outlier2-aggregation.tplValue" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "outlier2-aggregation.tplValue" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{/*
fsGroupGid
*/}}
{{- define "outlier2-aggregation.fsGroupGid" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- if $root.Values.global.fsGroupGid -}}
  fsGroup: {{ $root.Values.global.fsGroupGid }}
  {{- end -}}
{{- end -}}