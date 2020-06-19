{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "chart.name" -}}
  {- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "chart.fullname" -}}
  {{- .Release.Name -}}
{{- end -}}

{{- define "chart.version" -}}
  {{- if .Values.addon.version -}}
    {{- .Values.addon.version -}}
  {{- else -}}
    {{- .Chart.Version -}}
  {{- end -}}
{{- end -}}

{{- define "voice-gateway.podAffinity" -}}
podAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
  - topologyKey: kubernetes.io/hostname
    labelSelector:
      matchLabels:
{{- end -}}