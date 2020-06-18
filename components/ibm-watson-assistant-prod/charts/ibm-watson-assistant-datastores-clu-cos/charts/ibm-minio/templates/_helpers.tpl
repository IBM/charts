{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}

{{- define "ibm-minio.licenseValidate" -}}
  {{ $license := .Values.global.license }}
  {{- if $license -}}
    true
  {{- end -}}
{{- end -}}

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


{{/* Computes  service account name to be used by the chart. */}}
{{- define "ibm-minio.serviceAccountName" -}}
  {{- if tpl (.Values.serviceAccount.name | toString ) . -}}
    {{- tpl  (.Values.serviceAccount.name | toString ) . | trunc 63 -}}
  {{- else -}}
    {{- include "sch.names.fullName" (list .) -}}
  {{- end -}}
{{- end -}}

{{/*
  Determine names of the masterKeySecret for sse.
*/}}
{{- define "ibm-minio.sse.masterKeySecret" -}}
  {{- if tpl (.Values.sse.masterKeySecret | toString ) . -}}
    {{-  tpl (.Values.sse.masterKeySecret | toString ) . -}}
  {{- else -}}
    {{- include "sch.names.fullCompName" (list . .sch.chart.components.sseSecret) -}}
  {{- end -}}
{{- end -}}

{{/*
Return the appropriate minio replicas based on the deployment type.
For why 'kindIs' func was used see: https://github.com/Masterminds/sprig/issues/53
*/}}
{{- define "minio.configReplicas" -}}
  {{- if (ne "0" (tpl (.Values.replicas | toString ) . ) ) -}}
    {{- tpl ( .Values.replicas | toString ) . -}}
  {{- else if .Values.global.deploymentType -}}
    {{- if eq .Values.global.deploymentType "Production" -}}
      {{- .Values.replicasForProd -}}
    {{- else -}}
      {{- .Values.replicasForDev -}}
    {{- end -}}
  {{- end -}}
{{- end -}}



{{/*
  Adds support for templated affinity
  i.e., .Values.affinity: "{ { include "umbrella-chart.affinity" . } }"
*/}}
{{- define "ibm-minio.affinity" -}}
  {{- $allParams := . }}
  {{- $root    := first . }}
  {{- $details := first (rest . ) }}
  {{- $_       := set $root "affinityDetails" $details -}}
  
  {{- if and $root.Values.affinityMinio (eq $details.component $root.sch.chart.components.minioServer) -}}
    {{- if kindIs "string" $root.Values.affinityMinio -}}
      {{- tpl $root.Values.affinityMinio $root -}}
    {{- else -}}
      {{- range $key, $value := $root.Values.affinityMinio }}
{{ tpl $value $root }}
      {{- end }}
    {{- end -}}
  {{- else if $root.Values.affinity -}}
    {{/* To be backward compatible, we are looking for .Values.affinity before defaulting to sch chart labels */}}
    {{- if kindIs "string" $root.Values.affinity -}}
      {{- tpl $root.Values.affinity $root -}}
    {{- else -}}
      {{- tpl ( $root.Values.affinity | toYaml ) $root -}}
    {{- end -}}
  {{- else -}}
    {{- include "sch.affinity.nodeAffinity" (list $root $root.sch.chart.nodeAffinity) }}
  {{- end -}}
{{- end -}}

{{- define "ibm-minio.antiAffinity" -}}
  {{- if .Values.antiAffinity.policy -}}
    {{/* Accept a string or a template as the mode */}}
    {{- $antiAffinityPolicy := (tpl .Values.antiAffinity.policy .) -}}
    {{- if eq $antiAffinityPolicy "hard" }}
podAntiAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
  - topologyKey: {{ tpl (.Values.antiAffinity.topologyKey | toString ) . }}
    labelSelector:
      matchLabels:
{{ include "sch.metadata.labels.standard" (list . "server") | indent 8 }}
    {{- else if eq $antiAffinityPolicy "soft" }}
podAntiAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 1
    podAffinityTerm:
      topologyKey: {{ tpl .Values.antiAffinity.topologyKey . }}
      labelSelector:
        matchLabels:
{{ include "sch.metadata.labels.standard" (list . "server") | indent 10 }}
    {{- end }}
  {{- end -}}
{{- end -}}
