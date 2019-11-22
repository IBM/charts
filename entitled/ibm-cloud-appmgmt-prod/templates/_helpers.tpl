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

{{- define "releasename" -}}
{{- printf "%s" .Release.Name  | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "serverNamespace" -}}
{{- printf "%s" .Release.Namespace  | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "icam.resourceMonitoringDisabled" -}}
{{- if (hasKey .Values "global") -}}
  {{- if (hasKey .Values.global "monitoring") -}}
    {{- if (hasKey .Values.global.monitoring "resources") -}}
      {{- if eq (toString .Values.global.monitoring.resources) "false" -}}
true
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "icam.isMCM" -}}
{{- $mcmProductNames := list "Event Management for IBM Multicloud Manager" "IBM Cloud App Management for Multicloud Manager" -}}
{{- if (hasKey .Values "ibm-cem") -}}
  {{- $cemValues := index .Values "ibm-cem" -}}
  {{- if (hasKey $cemValues "productName") -}}
    {{- if (has $cemValues.productName $mcmProductNames) -}}
true
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "icam.createCRD" -}}
{{- if eq (toString .Values.createCRD) "true" -}}
true
{{- end -}}
{{- end -}}
