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
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create annotation
*/}}
{{- define "mongo.annotations" }}
productName: "IBM Data management Platform for MongoDB Enterprise Advanced 2.0 Cloud Pak"
{{- if ( eq .Values.runtime "ICP4Data" ) }}
productID: "ICP4D-addon-5737-H42"
{{- else }}
productID: "5737-H42"
{{- end }}
productVersion: "1.0.1"
{{- end }}
