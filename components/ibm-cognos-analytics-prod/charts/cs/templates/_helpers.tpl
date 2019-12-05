{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{/*{{- define "name" -}}*/}}
{{/*{{ if .Values.global.icp4Data }}*/}}
{{/*{{- $name := default .Chart.Name .Values.nameOverride -}}*/}}
{{/*{{- printf "%s-%s" .Values.zenServiceInstanceId $name | trunc 48 | trimSuffix "-" -}}*/}}
{{/*{{ else }}*/}}
{{/*{{- default .Chart.Name .Values.nameOverride | trunc 48 | trimSuffix "-" -}}*/}}
{{/*{{ end }}*/}}
{{/*{{- end -}}*/}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{/*{{- define "fullname" -}}*/}}
{{/*{{- $name := default .Chart.Name .Values.nameOverride -}}*/}}
{{/*{{ if .Values.global.icp4Data }}*/}}
{{/*{{- printf "%s-%s" .Values.zenServiceInstanceId $name | trunc 48 | trimSuffix "-" -}}*/}}
{{/*{{ else }}*/}}
{{/*{{- printf "%s-%s" .Release.Name $name | trunc 48 | trimSuffix "-" -}}*/}}
{{/*{{ end }}*/}}
{{/*{{- end -}}*/}}


{{/*
Get the cluster role for this Cluster version
*/}}
{{- define "cs-cluster-role" -}}
{{ if .Values.global.icp4Data }}
  {{- printf "%s" .Values.cs.roleBinding.name -}}
{{ else }}
  {{- if semverCompare ">=1.12-0" .Capabilities.KubeVersion.GitVersion }}
    {{- printf "%s" .Values.cs.roleBinding3.name -}}
  {{- else }}
    {{- printf "%s" .Values.cs.roleBinding.name -}}
  {{- end }}
{{ end }}
{{- end -}}
