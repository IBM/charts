{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the nginx-ns deployment selector
*/}}
{{- define "nginx.ns.selector" -}}
{{ if .Values.global.icp4Data }}
{{- default "nginx-ingress" .Values.nameOverride | trunc 48 | trimSuffix "-" -}}
{{ else }}
{{- default "nginx-ingress" .Values.nameOverride | trunc 48 | trimSuffix "-" -}}
{{ end }}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{/*{{- define "name" -}}*/}}
{{/*{{ if .Values.global.icp4Data }}*/}}
{{/*{{- $name := default .Chart.Name .Values.nameOverride -}}*/}}
{{/*{{- printf "%s-%s" .Values.zenServiceInstanceId $name | trunc 48 | trimSuffix "-" -}}*/}}
{{/*{{ else }}*/}}
{{/*{{- default .Chart.Name .Values.nameOverride | trunc 48 | trimSuffix "-" -}}*/}}
{{/*{{ end }}*/}}
{{/*{{- end -}}*/}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{/*{{- define "fullname" -}}*/}}
{{/*{{- $name := default .Chart.Name .Values.nameOverride -}}*/}}
{{/*{{ if .Values.global.icp4Data }}*/}}
{{/*{{- printf "%s-%s" .Values.zenServiceInstanceId $name | trunc 48 | trimSuffix "-" -}}*/}}
{{/*{{ else }}*/}}
{{/*{{- printf "%s-%s" .Release.Name $name | trunc 48 | trimSuffix "-" -}}*/}}
{{/*{{ end }}*/}}
{{/*{{- end -}}*/}}
