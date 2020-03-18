{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ibm-mobilefoundation.productName" -}}
"IBM MobileFirst Platform Foundation"
{{- end -}}

{{- define "ibm-mobilefoundation.productID" -}}
"9380ea99ddde4f5f953cf773ce8e57fc"
{{- end -}}

{{- define "ibm-mobilefoundation.productVersion" -}}
"8.0"
{{- end -}}


{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "k8name" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s_%s" .Release.Name $name | trunc 63 | trimSuffix "-" | replace "-" "_" | upper -}}
{{- end -}}

{{- define "mfp.ingress.fullname" -}}
{{- printf "%s-%s" .Release.Name "mfp-ingress" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mfp.server.fullname" -}}
{{- printf "%s-%s" .Release.Name "mfpserver" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mfp.push.fullname" -}}
{{- printf "%s-%s" .Release.Name "mfppush" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mfp.analytics.fullname" -}}
{{- printf "%s-%s" .Release.Name "mfpanalytics" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mfp.appcenter.fullname" -}}
{{- printf "%s-%s" .Release.Name "mfpappcenter" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mfp.dbinit.fullname" -}}
{{- printf "%s-%s" .Release.Name "mfpdbinit" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mfp.server-configmap.fullname" -}}
{{- printf "%s-%s" .Release.Name "mfpserver-configmap" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mfp.push-configmap.fullname" -}}
{{- printf "%s-%s" .Release.Name "mfppush-configmap" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mfp.analytics-configmap.fullname" -}}
{{- printf "%s-%s" .Release.Name "mfpanalytics-configmap" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mfp.appcenter-configmap.fullname" -}}
{{- printf "%s-%s" .Release.Name "mfpappcenter-configmap" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mfp.push-client-secret.fullname" -}}
{{- printf "%s-%s" .Release.Name "mfppushclientsecret" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mfp.server-admin-client-secret.fullname" -}}
{{- printf "%s-%s" .Release.Name "mfpserveradminclientsecret" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mfp.server-console-secret.fullname" -}}
{{- printf "%s-%s" .Release.Name "mfpserverconsolesecret" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mfp.analytics-console-secret.fullname" -}}
{{- printf "%s-%s" .Release.Name "mfpanalyticsconsolesecret" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mfp.appcenter-console-secret.fullname" -}}
{{- printf "%s-%s" .Release.Name "mfpappcenterconsolesecret" | trunc 63 | trimSuffix "-" -}}
{{- end -}}