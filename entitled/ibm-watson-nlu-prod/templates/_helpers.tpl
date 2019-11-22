{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "ibm-watson-nlu-prod.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ibm-watson-nlu-prod.fullname" -}}
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
{{- define "ibm-watson-nlu-prod.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "icp-pull-secrets" -}}
{{- printf "%s" (default (printf "sa-%s" .Release.Namespace) .Values.global.imagePullSecretName) -}}
{{- end -}}

{{- /* ################################### ETCD ################################### */ -}}
{{- /* ETCD SECRET NAME TEMPLATE
We assume that the etcd secret already exists and is specific to a release, i.e.
there is a single shared etcd instance per release that is provided by a parent chart.
We allow a parent chart to provide a different template though and pass it
in via .Values.global.etcd.accessSecret.nameTpl. In our deployment, we use whatever
template is provided in .Values.global.etcd.accessSecret.nameTpl.
*/ -}}
{{- define "nlu.etcdAccessSecretNameTemplate" -}}
{{- .Release.Name -}}-etcd-access
{{- end -}}

{{- /* ETCD SECRET NAME TEMPLATE
We assume that the etcd secret already exists and is specific to a release, i.e.
there is a single shared etcd instance per release that is provided by a parent chart.
We allow a parent chart to provide a different template though and pass it
in via .Values.global.etcd.secret.tlsSecret.nameTpl. In our deployment, we use whatever
template is provided in .Values.global.etcd.tlsSecret.nameTpl.
*/ -}}
{{- define "nlu.etcdTlsSecretNameTemplate" -}}
{{- .Release.Name -}}-etcd-tls
{{- end -}}

{{- /* ETCD ENDPOINT TEMPLATE
*/ -}}
{{- define "nlu.etcdEndpointTemplate" -}}
http{{ if .Values.global.etcd.sslEnabled }}s{{ end }}://{{ .Release.Name }}-ibm-etcd.{{ .Release.Namespace }}:{{ .Values.global.etcd.endpointPort }}
{{- end -}}
{{- /* ################################### ETCD ################################### */ -}}

{{/* ######################################## MINIO ################################### */}}
{{- define "nlu.minioAccessSecretNameTemplate" -}}
{{- printf "%s-nlu-minio-access-secret" .Release.Name -}}
{{- end -}}

{{- /* MINIO ENDPOINT TEMPLATE
*/ -}}
{{- define "nlu.minioEndpointTemplate" -}}
http{{ if .Values.global.s3.sslEnabled }}s{{ end }}://{{ .Release.Name }}-ibm-minio-svc.{{ .Release.Namespace }}.{{ .Values.global.clusterDomain }}:{{ .Values.global.s3.endpointPort }}
{{- end -}}
{{/* ######################################## MINIO ################################### */}}

{{/* ################################### POSTGRES AUTH SECRET NAME ################################### */}}
{{- define "nlu.postgresAuthSecretNameTemplate" -}}
{{- printf "%s-nlu-postgres-auth-secret" .Release.Name -}}
{{- end -}}
{{/* ################################### POSTGRES AUTH SECRET NAME ################################### */}}


{{/* ######################################## TLS SECRET NAME ######################################## */}}
{{- define "nlu.tlsSecretNameTemplate" -}}
{{- printf "%s-nlu-tls" .Release.Name -}}
{{- end -}}
{{/* ######################################## TLS SECRET NAME ######################################## */}}

{{- define "nlu.roleName" -}}
{{ include "sch.names.fullName" (list . ) }}
{{- end -}}

{{- define "nlu.serviceAccountName" -}}
{{- default (include "sch.names.fullName" (list . )) (default .Values.global.existingServiceAccount .Values.existingServiceAccount) -}}
{{- end -}}

{{- define "nlu.roleBindingName" -}}
{{ include "sch.names.fullName" (list . ) }}
{{- end -}}

{{/* ######################################## ICP4D addon backend  ######################################## */}}
{{- define "icp4d-addon.backendService.name" -}}
{{- printf "%s-%s" .Release.Name "ibm-watson-nlu-prod-nluserver" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "icp4d-addon.modelsServerService.name" -}}
{{- printf "%s-%s" .Release.Name "ibm-watson-nms-prod-models-server" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{/* ######################################## ICP4D addon backend ######################################## */}}

{{/* ######################################## NLU Image Settings ######################################## */}}
{{- /* PULL SECRET TEMPLATE */ -}}
{{- define "nlu.components.imagePullSecretTemplate" -}}
imagePullSecrets:
{{ printf "- name: sa-%s" .Release.Namespace }}
{{- if ne .Values.global.imagePullSecretName "" }}
{{ printf "- name: %s" .Values.global.imagePullSecretName -}}
{{- end -}}
{{- if ne .Values.global.image.pullSecret "" }}
{{- if ne .Values.global.image.pullSecret .Values.global.imagePullSecretName }}
{{ printf "- name: %s" .Values.global.image.pullSecret -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{/* ######################################## NLU Image Settings ######################################## */}}
