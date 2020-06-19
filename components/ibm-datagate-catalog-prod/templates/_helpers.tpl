{{- define "data-gate-catalog.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "data-gate-catalog.fullname" -}}
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


{{- define "data-gate-catalog.configname" -}}
{{- if .Values.confignameOverride -}}
{{- .Values.confignameOverride | trunc 63 | trimSuffix "-" -}}
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
{{- define "data-gate-catalog.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{- define "data-gate-catalog.metadataLabels" -}}
app: {{ template "data-gate-catalog.name" . }}
chart: {{ template "data-gate-catalog.chart" . }}
release: {{ .Release.Name }}
heritage: {{ .Release.Service }}
icpdata_addon: "true"
icpdata_addon_version: {{.Chart.AppVersion | quote }}
app.kubernetes.io/instance: "{{ .Release.Name }}"
app.kubernetes.io/managed-by: "helm"
app.kubernetes.io/name: {{ template "data-gate-catalog.fullname" . }}
helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
{{- end }}


{{- define "data-gate-catalog.nodeAffinity" -}}
requiredDuringSchedulingIgnoredDuringExecution:
  nodeSelectorTerms:
  - matchExpressions:
    - key: beta.kubernetes.io/arch
      operator: In
      values:
      - amd64
{{- end -}}
