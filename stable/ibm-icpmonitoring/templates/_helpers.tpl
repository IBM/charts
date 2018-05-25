{{/* vim: set filetype=mustache: */}}

{{/*
  Licensed Materials - Property of IBM
  5737-E67
  @ Copyright IBM Corporation 2016, 2018. All Rights Reserved.
  US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
*/}}

{{/*
Create a default fully qualified app name for monitoring.
*/}}
{{- define "monitoring.fullname" -}}
{{- $name := default "monitoring" .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name for prometheus.
*/}}
{{- define "prometheus.fullname" -}}
{{- $name := default "prometheus" .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name for grafana.
*/}}
{{- define "grafana.fullname" -}}
{{- $name := default "grafana" .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name for collectdexporter.
*/}}
{{- define "collectdexporter.fullname" -}}
{{- $name := default "exporter" .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
