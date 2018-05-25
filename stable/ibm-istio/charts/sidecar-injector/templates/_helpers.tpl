{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "sidecar-injector.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "sidecar-injector.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Service account name.
*/}}
{{- define "sidecar-injector.serviceAccountName" -}}
{{- if .Values.global.rbacEnabled -}}
{{- template "sidecar-injector.fullname" . -}}-service-account
{{- else }}
{{- .Values.serviceAccountName | trunc 63 | trimSuffix "-" -}}-service-account
{{- end -}}
{{- end -}}


{{/*
Service account name for signed certificate.
*/}}
{{- define "sidecar-injector.signedCertServiceAccountName" -}}
{{- if .Values.global.rbacEnabled -}}
{{- template "sidecar-injector.fullname" . -}}-signed-cert-service-account
{{- else }}
{{- .Values.serviceAccountName | trunc 63 | trimSuffix "-" -}}-service-account
{{- end -}}
{{- end -}}

{{/*
Service account name for patch ca bundle.
*/}}
{{- define "sidecar-injector.caBundleServiceAccountName" -}}
{{- if .Values.global.rbacEnabled -}}
{{- template "sidecar-injector.fullname" . -}}-ca-bundle-service-account
{{- else }}
{{- .Values.serviceAccountName | trunc 63 | trimSuffix "-" -}}-service-account
{{- end -}}
{{- end -}}
