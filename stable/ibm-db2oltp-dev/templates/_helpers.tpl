{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- $shortname := .Release.Name | trunc 10 -}}
{{- printf "%s-%s" $shortname $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default hadr store name
We truncate at 10 chars for the name as we reach a limit when PVCs for the statefulset are created
*/}}
{{- define "hadrstorname" -}}
{{- $name := default .Release.Name | trunc 10 | trimSuffix "-" -}}
{{- printf "%s-%s" $name .Values.hadrVolume.name -}}
{{- end -}}

{{/*
Create a default data store name
We truncate at 10 chars for the name as we reach a limit when PVCs for the statefulset are created
*/}}
{{- define "datastorname" -}}
{{- $name := default .Release.Name | trunc 10 | trimSuffix "-" -}}
{{- printf "%s-%s" $name .Values.dataVolume.name -}}
{{- end -}}


{{/*
Check if tag contains specific platform suffix and if not set based on kube platform
*/}}
{{- define "platform" -}}
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

{{/*
Return arch based on kube platform
*/}}
{{- define "arch" -}}
  {{- if (eq "linux/amd64" .Capabilities.KubeVersion.Platform) }}
    {{- printf "%s" "amd64" }}
  {{- end -}}
  {{- if (eq "linux/ppc64le" .Capabilities.KubeVersion.Platform) }}
    {{- printf "%s" "ppc64le" }}
  {{- end -}}
{{- end -}}

