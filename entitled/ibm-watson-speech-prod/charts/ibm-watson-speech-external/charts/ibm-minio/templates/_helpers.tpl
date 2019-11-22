{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}


{{/*
   A helper template to support templated boolean values.
   Takes a value (and converts it into Boolean equivalent string value).
     If the value is of type Boolean, then false value renders to empty string, otherwise renders to non-empty string.
     If the value is of type String, then takes (and renders the string) and if the value is true (case sensitive) or renders to (true) then renders to non-empty string, otherwise renders to empty string.
     
  Usage: For keys like `tls.enabled` "true/false" add possiblity to have also non-boolean value "{{ .Values.global.minio.tls.enables }}"
  
  Usage in templates:
    Instead of direct value test `{{ if .Values.tls.enabled }}` one has to use {{ if include "ibm-minio.boolConvertor" (list .Values.tls.enabled . ) }}
*/}}
{{- define "ibm-minio.boolConvertor" -}}
  {{- if typeIs "bool" (first .) -}}
    {{- if (first .) }}                            Type is Boolean  VALUE is TRUE           ==>  Generating a non-empty string{{- end -}}
  {{- else if typeIs "string" (first .) -}}
    {{- if eq "true" ( tpl (first .) (last .) )  }}Type is String   VALUE renders to "true" ==>  Generating a non-empty string{{- end -}}
  {{- end -}}
{{- end -}}


{{- define "minio.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "minio.fullname" -}}
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
{{- define "minio.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Determine service account name for deployment or statefulset.
*/}}
{{- define "minio.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "minio.fullname" .) .Values.serviceAccount.name | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate minio replicas based on the deployment type.
For why 'kindIs' func was used see: https://github.com/Masterminds/sprig/issues/53
*/}}
{{- define "minio.configReplicas" -}}
  {{- if (ne .Values.replicas 0.0) -}}
    {{- .Values.replicas -}}
  {{- else if .Values.global.deploymentType -}}
    {{- if eq .Values.global.deploymentType "Production" -}}
      {{- .Values.replicasForProd -}}
    {{- else -}}
      {{- .Values.replicasForDev -}}
    {{- end -}}
  {{- end -}}
{{- end -}}