{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "kube-arangodb.name" -}}
{{- printf "%s" .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Expand the name of the release.
*/}}
{{- define "kube-arangodb.releaseName" -}}
{{- printf "%s" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Expand the name of the operator.
*/}}
{{- define "kube-arangodb.operatorName" -}}
{{- printf "arango-operator" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Combine name of the deployment.
*/}}
{{- define "kube-arangodb.fullName" -}}
{{- printf "%s-%s" .Chart.Name .Release.Name  | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the Operator RBAC role
*/}}
{{- define "kube-arangodb.rbac" -}}
{{- printf "%s-%s" (include "kube-arangodb.operatorName" .) "rbac" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
