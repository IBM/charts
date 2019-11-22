{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "eventstore.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "eventstore.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "eventstore.annotations" }}
productName: "IBM Db2 Event Store"
{{- if ( eq .Values.runtime "ICP4Data" ) }}
productID: "ICP4D-addon-5737-E53"
{{- else }}
productID: "5737-E53"
{{- end }}
productVersion: "2.0.0"
{{- end }}
