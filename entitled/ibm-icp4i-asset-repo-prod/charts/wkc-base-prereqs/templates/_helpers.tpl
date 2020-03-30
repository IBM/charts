{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "wkc-base-prereqs.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "wkc-base-prereqs.fullname" -}}
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
{{- define "wkc-base-prereqs.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Create rabbitmqUrl with pw for secret
*/}}
{{- define "wkc-base-prereqs.rabbitmqUrl" -}}
{{- if .Values.rabbitmq -}}
{{- $rmqpw := required "wdp-rabbitmq.rabbitmqPassword must be specified" (index .Values "wdp-rabbitmq" "rabbitmqPassword") -}}
{{- printf .Values.env.rabbitmqUrl (index .Values "wdp-rabbitmq" "rabbitmqUsername") $rmqpw | b64enc | quote -}}
{{- end -}}
{{- end -}}
