{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "prometheus.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create unified labels for prometheus components
*/}}
{{- define "prometheus.common.matchLabels" -}}
release: {{ .Release.Name }}
{{- end -}}

{{- define "prometheus.common.metaLabels" -}}
chart: {{ .Chart.Name }}-{{ .Chart.Version }}
heritage: {{ .Release.Service }}
{{- end -}}

{{- define "prometheus.alertmanager.labels" -}}
{{ include "prometheus.alertmanager.matchLabels" . }}
{{ include "prometheus.common.metaLabels" . }}
{{- end -}}

{{- define "prometheus.alertmanager.matchLabels" -}}
app: {{ template "prometheus.name" . }}-am
{{ include "prometheus.common.matchLabels" . }}
{{- end -}}

{{- define "prometheus.kubeStateMetrics.labels" -}}
{{ include "prometheus.kubeStateMetrics.matchLabels" . }}
{{ include "prometheus.common.metaLabels" . }}
{{- end -}}

{{- define "prometheus.kubeStateMetrics.matchLabels" -}}
app: {{ template "prometheus.name" . }}-ks
{{ include "prometheus.common.matchLabels" . }}
{{- end -}}

{{- define "prometheus.nodeExporter.labels" -}}
{{ include "prometheus.nodeExporter.matchLabels" . }}
{{ include "prometheus.common.metaLabels" . }}
{{- end -}}

{{- define "prometheus.nodeExporter.matchLabels" -}}
app: {{ template "prometheus.name" . }}-ne
{{ include "prometheus.common.matchLabels" . }}
{{- end -}}


{{- define "prometheus.server.labels" -}}
{{ include "prometheus.server.matchLabels" . }}
{{ include "prometheus.common.metaLabels" . }}
{{- end -}}

{{- define "prometheus.server.matchLabels" -}}
app: {{ template "prometheus.name" . }}-server
{{ include "prometheus.common.matchLabels" . }}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "prometheus.fullname" -}}
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
Check if component should be disabled
*/}}
{{- define "prometheus.scaleDownIfDisabled" -}}
{{ if and .Values.global.enableMonitoring (not (or .Values.global.deployOnIBMCloud .Values.global.deployOnEKS) ) }}
replicas: 1
{{   else }}
replicas: 0
{{   end }}
{{- end -}}

{{/*
Create a fully qualified alertmanager name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}

{{- define "prometheus.alertmanager.fullname" -}}
{{- if .Values.alertmanager.fullnameOverride -}}
{{- .Values.alertmanager.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.alertmanager.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.alertmanager.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified kube-state-metrics name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "prometheus.kubeStateMetrics.fullname" -}}
{{- if .Values.kubeStateMetrics.fullnameOverride -}}
{{- .Values.kubeStateMetrics.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.kubeStateMetrics.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.kubeStateMetrics.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified node-exporter name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "prometheus.nodeExporter.fullname" -}}
{{- if .Values.nodeExporter.fullnameOverride -}}
{{- .Values.nodeExporter.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.nodeExporter.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.nodeExporter.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified Prometheus server name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "prometheus.server.fullname" -}}
{{- if .Values.server.fullnameOverride -}}
{{- .Values.server.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.server.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.server.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}


{{/*
Create the name of the service account to use for the alertmanager component
*/}}
{{- define "prometheus.serviceAccountName.alertmanager" -}}
{{- if .Values.serviceAccounts.alertmanager.create -}}
    {{ default (include "prometheus.alertmanager.fullname" .) .Values.serviceAccounts.alertmanager.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccounts.alertmanager.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for the kubeStateMetrics component
*/}}
{{- define "prometheus.serviceAccountName.kubeStateMetrics" -}}
{{- if .Values.serviceAccounts.kubeStateMetrics.create -}}
    {{ default (include "prometheus.kubeStateMetrics.fullname" .) .Values.serviceAccounts.kubeStateMetrics.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccounts.kubeStateMetrics.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for the nodeExporter component
*/}}
{{- define "prometheus.serviceAccountName.nodeExporter" -}}
{{- if .Values.serviceAccounts.nodeExporter.create -}}
    {{ default (include "prometheus.nodeExporter.fullname" .) .Values.serviceAccounts.nodeExporter.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccounts.nodeExporter.name }}
{{- end -}}
{{- end -}}


{{/*
Create the name of the service account to use for the server component
*/}}
{{- define "prometheus.serviceAccountName.server" -}}
{{- if .Values.serviceAccounts.server.create -}}
    {{ default (include "prometheus.server.fullname" .) .Values.serviceAccounts.server.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccounts.server.name }}
{{- end -}}
{{- end -}}
