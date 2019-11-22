{{/*
#+------------------------------------------------------------------------+
#| Licensed Materials - Property of IBM
#| IBM Cognos Products: Cognos Dashboard Embedded
#| (C) Copyright IBM Corp. 2019
#|
#| US Government Users Restricted Rights - Use, duplication or disclosure
#| restricted by GSA ADP Schedule Contract with IBM Corp.
#+------------------------------------------------------------------------+
*/}}
{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "ibmCde.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "ibmCde.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" "cognos" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{ define "ibmCde.proxy.fullname" }}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" "cognos" "daas-proxy" | trunc 63 | replace "-" "" -}}
{{ end }}

{{ define "ibmCde.server.fullname" }}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" "cognos" "daas-server" | trunc 63 | replace "-" "" -}}
{{ end }}

{{ define "ibmCde.redis.fullname" }}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" "cognos" "daas-redis" | trunc 63 | replace "-" "" -}}
{{ end }}


{{/*
Boilerplate labels that we apply to all resources.
*/}}
{{- define "ibmCde.release_labels" }}
app.kubernetes.io/name: {{ template "ibmCde.name" . }}
helm.sh/chart: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
release: {{ .Release.Name }}
{{- end }}

{{/*
Helper functions which can be used for .Values.arch in PPA Charts
Check if tag contains specific platform suffix and if not set based on kube platform
uncomment this section for PPA charts, can be removed in github.com charts
*/}}

{{- define "ibmCde.platform" -}}
{{- if not .Values.arch }}
  {{- if (eq "linux/amd64" .Capabilities.KubeVersion.Platform) }}
    {{- printf "-%s" "x86_64" }}
  {{- end -}}
  {{- if (eq "linux/ppc64le" .Capabilities.KubeVersion.Platform) }}
    {{- printf "-%s" "ppc64le" }}
  {{- end -}}
{{- else -}}
  {{- if eq .Values.arch "amd64" }}
    {{- printf "-%s" "x86_64" }}
  {{- else -}}
    {{- printf "-%s" .Values.arch }}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "ibmCde.arch" -}}
  {{- if (eq "linux/amd64" .Capabilities.KubeVersion.Platform) }}
    {{- printf "%s" "amd64" }}
  {{- end -}}
  {{- if (eq "linux/ppc64le" .Capabilities.KubeVersion.Platform) }}
    {{- printf "%s" "ppc64le" }}
  {{- end -}}
{{- end -}}

{{/*
Helper template to define pod annotations for metering
*/}}
{{- define "ibmCde.metering.annotations" -}}
  {{- if .Values.global.icp4dAddon }}
productID: ICP4D-addon-{{ .Values.global.metering.productID }}
productName: {{ .Values.global.metering.productName }}
productVersion: {{ .Values.global.metering.productVersion }}
  {{- else }}
productID: {{ .Values.global.metering.productID }}
productName: {{ .Values.global.metering.productName }}
productVersion: {{ .Values.global.metering.productVersion }}
  {{ end }}
{{- end -}}

{{- define "ibmCde.serviceability.annotations" -}}
  {{- if .Values.global.serviceability }}
serviceability.io/collection_type: {{ .Values.global.serviceability.collectiontype }}
{{/* serviceability.io/app_name: {{ .Values.global.serviceability.appName }} */}}
  {{- end -}}
{{- end -}}
