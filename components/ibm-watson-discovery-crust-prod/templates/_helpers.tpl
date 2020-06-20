{{/* vim: set filetype=mustache: */}}

{{- define "minio.secret" -}}
  {{- $appName := .Values.global.appName -}}
  {{- printf "%s-%s-minio-secret" .Release.Name $appName | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "discovery.admin.tlsSecret" -}}
  {{- $appName := .Values.global.appName -}}
  {{- $adminName := (index .Values.global.components "ibm-watson-discovery-admin-prod").releaseName -}}
  {{- printf "%s-%s-tls" $adminName $appName | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "discovery.admin.privilegedServiceAccount" -}}
  {{- .Values.global.privilegedServiceAccount.name -}}
{{- end -}}
