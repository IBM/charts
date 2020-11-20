{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "dv-caching.name" -}}
{{- default .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "dv-caching.fullname" -}}
{{- $name := default .Chart.Name -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create default Data Virtualization annotations
*/}}
{{- define "dv.annotations" }}
productName: "IBM Data Virtualization"
productID: "eb9998dcc5d24e3eb5b6fb488f750fe2"
productVersion: "1.5.0"
{{- end }}
