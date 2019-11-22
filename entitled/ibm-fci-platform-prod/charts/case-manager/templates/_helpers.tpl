{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "case.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "case.fullname" -}}
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
{{- define "case.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Calculate the pvcName as a function to make consistency easy.
*/}}
{{- define "case.mqPvcname" -}}
{{-     if .Values.mqPvcName -}}
{{-        .Values.mqPvcName -}}
{{-     else -}}
{{-         template "case.fullname" . -}}-fci-messaging
{{-     end -}}
{{- end -}}

{{- define "case.libertyPvcname" -}}
{{-     if .Values.libertyPvcName -}}
{{-        .Values.libertyPvcName -}}
{{-     else -}}
{{-         template "case.fullname" . -}}-fci-solution
{{-     end -}}
{{- end -}}

{{/*
Get the release name for core services.
*/}}
{{- define "case.core-release-name" -}}
{{-     if .Values.global.coreReleaseName -}}
{{-        .Values.global.coreReleaseName -}}
{{-     else -}}
{{-         .Release.Name -}}
{{-     end -}}
{{- end -}}

{{/*
Get the LDAP config file
*/}}
{{- define "case.ldapConfigFile" -}}
{{- if eq .Values.global.IDENTITY_SERVER_TYPE "msad" -}}
server_ldap_actived.xml
{{- else if eq .Values.global.IDENTITY_SERVER_TYPE "sds" -}}
server_ldap_ids.xml
{{- else if eq .Values.global.IDENTITY_SERVER_TYPE "open" -}}
server_ldap_open.xml
{{- else -}}
server_basic_registry.xml
{{- end -}}
{{- end -}}
