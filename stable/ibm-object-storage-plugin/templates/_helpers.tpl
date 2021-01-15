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
    {{- if contains "IBMC" (.Values.provider | quote | upper) }}
        {{- "kube-system" -}}
    {{- else -}}
        {{- .Release.Namespace -}}
    {{- end -}}
{{- end -}}

{{/*
CLI to use for connecting to cluster.
*/}}
{{- define "ibm-object-storage-plugin.clientcli" -}}
    {{- if contains "OPENSHIFT" (.Values.platform | quote | upper) }}
        {{- "oc" -}}
    {{- else -}}
        {{- "kubectl" -}}
    {{- end -}}
{{- end -}}

{{/*
license  parameter must be set to true
*/}}
{{- define "ibm-object-storage-plugin.licenseValidate" -}}
  {{- if .Values.license }}
    {{- true -}}
  {{- end -}}
{{- end -}}

{{/*
set REPO_SOURCE_URL and BUILD_URL for linking images
*/}}
{{- define "ibm-object-storage-plugin.repoSourceUrl" -}}
  {{- "https://github.ibm.com/alchemy-containers/armada-storage-s3fs-plugin/commit/b7b9932768dc26a844ec874b85a99b57955bc116" -}}
{{- end -}}

{{- define "ibm-object-storage-plugin.buildUrl" -}}
  {{- "https://travis.ibm.com/alchemy-containers/armada-storage-s3fs-plugin/builds/42287521" -}}
{{- end -}}
