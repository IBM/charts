{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "istio-remote.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "istio-remote.fullname" -}}
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
{{- define "istio-remote.chart" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "nodeselector" }}
  {{- if .Values.global.management }}
  management: 'true'
  {{- end -}}
  {{- if and .Values.global.extraNodeSelector.key .Values.global.extraNodeSelector.value }}
  {{ .Values.global.extraNodeSelector.key }}: {{ .Values.global.extraNodeSelector.value }}
  {{- end -}}
{{- end }}

{{- define "tolerations" }}
{{- if .Values.global.dedicated }}
- key: "dedicated"
  operator: "Exists"
  effect: "NoSchedule"
{{- end -}}
{{- if .Values.global.criticalAddonsOnly }}
- key: "CriticalAddonsOnly"
  operator: "Exists"
{{- end -}}
{{- end }}
