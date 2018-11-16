{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "grafana.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "grafana.fullname" -}}
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
{{- define "grafana.chart" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "grafana.nodeselector" -}}
  {{- if contains "icp" .Capabilities.KubeVersion.GitVersion -}}
  {{- if eq .Values.nodeRole "proxy" }}
  proxy: "true"
  {{- end -}}
  {{- if eq .Values.nodeRole "management" }}
  management: "true"
  {{- end -}}
  {{- end -}}
{{- end }}

{{- define "grafana.tolerations" -}}
{{- if contains "icp" .Capabilities.KubeVersion.GitVersion -}}
{{- if or (eq .Values.nodeRole "proxy") (eq .Values.nodeRole "management") }}
- key: "dedicated"
  operator: "Exists"
  effect: "NoSchedule"
- key: CriticalAddonsOnly
  operator: Exists
{{- end -}}
{{- end -}}
{{- end }}
