{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "ibm_storage_enabler_for_containers.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ibm_storage_enabler_for_containers.fullname" -}}
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
{{- define "ibm_storage_enabler_for_containers.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create product ID as used by the chart label.
*/}}
{{- define "ibm_storage_enabler_for_containers.productName" -}}
"IBM Storage Enabler for Containers"
{{- end -}}

{{/*
Create product name as used by the chart label.
*/}}
{{- define "ibm_storage_enabler_for_containers.productID" -}}
ibm-storage-enabler-for-containers
{{- end -}}

{{/*
Create the name for the scbe secret
*/}}
{{- define "ibm_storage_enabler_for_containers.scbeCredentials" -}}
    {{- if .Values.spectrumConnect.connectionInfo.existingSecret -}}
        {{- .Values.spectrumConnect.connectionInfo.existingSecret -}}
    {{- else -}}
        {{- template "ibm_storage_enabler_for_containers.fullname" . -}}-scbe
    {{- end -}}
{{- end -}}

{{/*
Create the name for the spectrum scale secret
*/}}
{{- define "ibm_storage_enabler_for_containers.spectrumscaleCredentials" -}}
    {{- if .Values.spectrumScale.connectionInfo.existingSecret -}}
        {{- .Values.spectrumScale.connectionInfo.existingSecret -}}
    {{- else -}}
        {{- template "ibm_storage_enabler_for_containers.fullname" . -}}-spectrumscale
    {{- end -}}
{{- end -}}

{{/*
Create the name for ubiquity-db secret
*/}}
{{- define "ibm_storage_enabler_for_containers.ubiquityDbCredentials" -}}
    {{- if .Values.ubiquityDb.dbCredentials.existingSecret -}}
        {{- .Values.ubiquityDb.dbCredentials.existingSecret -}}
    {{- else -}}
        {{- template "ibm_storage_enabler_for_containers.fullname" . -}}-ubiquitydb
    {{- end -}}
{{- end -}}

{{/*
Create the name of storageClass for ubiquity-db pvc
*/}}
{{- define "ibm_storage_enabler_for_containers.ubiquityDbStorageClass" -}}
    {{- if .Values.ubiquityDb.persistence.storageClass.existingStorageClass -}}
        {{- .Values.ubiquityDb.persistence.storageClass.existingStorageClass -}}
    {{- else -}}
        {{ .Values.ubiquityDb.persistence.storageClass.storageClassName }}
    {{- end -}}
{{- end -}}

{{- define "ibm_storage_enabler_for_containers.helmLabels" -}}
app.kubernetes.io/name: {{ template "ibm_storage_enabler_for_containers.name" . }}
helm.sh/chart: {{ template "ibm_storage_enabler_for_containers.chart" . }}
release: {{ .Release.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "ibm_storage_enabler_for_containers.podLabels" -}}
helm.sh/chart: {{ template "ibm_storage_enabler_for_containers.chart" . }}
release: {{ .Release.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "ibm_storage_enabler_for_containers.productAnnotations" -}}
productName: {{ template "ibm_storage_enabler_for_containers.productName" . }}
productID: {{ template "ibm_storage_enabler_for_containers.productID" . }}
productVersion: {{ .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
{{- end -}}

{{- define "ibm_storage_enabler_for_containers.securityContext" -}}
securityContext:
  privileged: false
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: false
  runAsNonRoot: false
  runAsUser: 0
  capabilities:
    drop:
    - ALL
    add:
    - CHOWN
    - FSETID
    - FOWNER
    - SETGID
    - SETUID
    - DAC_OVERRIDE
{{- end -}}