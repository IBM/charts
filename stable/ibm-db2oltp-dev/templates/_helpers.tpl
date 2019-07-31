{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- $shortname := .Release.Name | trunc 10 -}}
{{- printf "%s-%s" $shortname $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default hadr store name
We truncate at 10 chars for the name as we reach a limit when PVCs for the statefulset are created
*/}}
{{- define "hadrstorname" -}}
{{- $name := default .Release.Name | trunc 10 | trimSuffix "-" -}}
{{- printf "%s-%s" $name .Values.hadrVolume.name -}}
{{- end -}}

{{/*
Create a default data store name
We truncate at 10 chars for the name as we reach a limit when PVCs for the statefulset are created
*/}}
{{- define "datastorname" -}}
{{- $name := default .Release.Name | trunc 10 | trimSuffix "-" -}}
{{- printf "%s-%s" $name .Values.dataVolume.name -}}
{{- end -}}

