{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "ibm-object-storage-plugin.name" -}}
{{- default .Chart.Name .Values.nameOverride | replace "ibm" "ibmcloud" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "ibm-object-storage-plugin.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride | replace "ibm" "ibmcloud" -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Expand driver component name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "ibm-object-storage-plugin.drivername" -}}
{{- default .Chart.Name .Values.nameOverride | replace "ibm" "ibmcloud" | replace "plugin" "driver" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Namespace to use for chart deployment.
*/}}
{{- define "ibm-object-storage-plugin.namespace" -}}
    {{- if contains "CLASSIC" (.Values.provider | quote | upper) }}
        {{- "kube-system" -}}
    {{- else -}}
        {{- .Release.Namespace -}}
    {{- end -}}
{{- end -}}
