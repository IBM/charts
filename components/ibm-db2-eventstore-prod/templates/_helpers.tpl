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

{{/*
Create zenServiceInstanceId template for icpdsupport/serviceInstanceId label.
*/}}
{{- define "zenServiceInstanceId" -}}
  {{- if not .Values.zenServiceInstanceId }}
    {{- $name := default .Chart.Name .Values.nameOverride -}}
    {{- $shortname := .Release.Name | trunc 10 -}}
    {{- printf "%s-%s" $shortname $name | trunc 63 | trimSuffix "-" -}}
  {{- else }}
    {{- printf "%s" (int .Values.zenServiceInstanceId | toString) }}
  {{- end }}
{{- end -}}

{{/*
We assue this value will be passed by databases.
Create zenServiceInstanceUID template for icpdsupport/createBy label.
*/}}
{{- define "zenServiceInstanceUID" -}}
    {{- printf "%s" (int .Values.zenServiceInstanceUID | toString) }}
{{- end -}}

{{- define "eventstore.annotations" }}
cloudpakName: "IBM Cloud Pak for Data"
cloudpakId: "eb9998dcc5d24e3eb5b6fb488f750fe2"
cloudpakInstanceId: {{ .Values.zenCloudPakInstanceId | quote }}
productName: "IBM Db2 Event Store"
productVersion: {{ .Chart.Version }}
productMetric: "VIRTUAL_PROCESSOR_CORE"
productChargedContainers: "All"
{{- if ( eq .Values.runtime "ICP4Data" ) }}
productID: "eb9998dcc5d24e3eb5b6fb488f750fe2"
{{- else }}
productID: "5737-E53"
{{- end }}
{{- end }}

{{- define "eventstore.podLabels" }}
icpdsupport/addOnId: {{ .Values.serviceAccountName }}
icpdsupport/serviceInstanceId: "{{ template "zenServiceInstanceId" . }}"
icpdsupport/app: {{ .Values.serviceAccountName }}
icpdsupport/createBy: "{{ template "zenServiceInstanceUID" . }}"
{{- end }}
