{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "jenkins.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "jenkins.fullname" -}}
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

{{- define "jenkins.kubernetes-version" -}}
  {{- range .Values.Master.InstallPlugins -}}
    {{ if hasPrefix "kubernetes:" . }}
      {{- $split := splitList ":" . }}
      {{- printf "%s" (index $split 1 ) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Generate private key for jenkins CLI
*/}}
{{- define "jenkins.gen-key" -}}
{{- if not .Values.Master.AdminSshKey -}}
{{- $key := genPrivateKey "rsa" -}}
jenkins-admin-private-key: {{ $key | b64enc | quote }}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "jenkins.chart" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
  Secret name for jenkins admin user and password
*/}}
{{- define "jenkins.getsecret" -}}
{{- if not .Values.Master.ExistingSecret -}}
{{ template "jenkins.fullname" . }}
{{- else -}}
{{- .Values.Master.ExistingSecret -}}
{{- end -}}
{{- end -}}
