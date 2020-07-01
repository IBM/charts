{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "uc.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "uc.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ucapi.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-api" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ucui.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-ui" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ucinfluxdb.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-influxdb" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ucgoapi.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-ucgoapi" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "uccollector.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-collector" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "repoDB.fullname" -}}
{{- printf "%s-%s" .Release.Name "repository" | trunc 63 -}}
{{- end -}}

{{/*
Create a zos agent qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "db2zAgent.fullname" -}}
{{- printf "%s-%s" .Release.Name "db2zAgent" | trunc 63 -}}
{{- end -}}

{{/*
Create a sentinel list string
*/}}
{{- define "redis.sentinel.list" -}}
{{- $replicas := int .Values.redis.replicas -}}
{{- $root := . -}}
{{- $list := "" -}}
{{- range $i := until $replicas -}}
{{- $list = printf "%s%s-%s-%d:%d;" $list $.Release.Name "redis-announce" $i 26379 -}}
{{- end -}}
{{- print $list | trimSuffix ";" -}}
{{- end -}}


{{/*
Create uc comp service port
*/}}
{{- define "uc.service.port" -}}
{{- if eq .Values.enableMesh true }}
{{- print .Values.service.httpPort -}}
{{- else }}
{{- print .Values.service.httpsPort -}}
{{- end -}}
{{- end -}}

{{/*
Create scheduler service port
*/}}
{{- define "scheduler.service.port" -}}
{{- if eq .Values.enableMesh true }}
{{- print .Values.scheduler.service.httpPort -}}
{{- else }}
{{- print .Values.scheduler.service.httpsPort -}}
{{- end -}}
{{- end -}}

{{/*
Create registry service port
*/}}
{{- define "registry.service.port" -}}
{{- if eq .Values.enableMesh true }}
{{- print .Values.registry.service.httpPort -}}
{{- else }}
{{- print .Values.registry.service.httpsPort -}}
{{- end -}}
{{- end -}}
