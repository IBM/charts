{{/* IBM_SHIP_PROLOG_BEGIN_TAG                                              */}}
{{/* *****************************************************************      */}}
{{/*                                                                        */}}
{{/* Licensed Materials - Property of IBM                                   */}}
{{/*                                                                        */}}
{{/* (C) Copyright IBM Corp. 2018. All Rights Reserved.                     */}}
{{/*                                                                        */}}
{{/* US Government Users Restricted Rights - Use, duplication or            */}}
{{/* disclosure restricted by GSA ADP Schedule Contract with IBM Corp.      */}}
{{/*                                                                        */}}
{{/* *****************************************************************      */}}
{{/* IBM_SHIP_PROLOG_END_TAG                                                */}}


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
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default short app name.
We truncate at 40 chars because some Kubernetes name fields are limited to 63, and this gives us
room for 23 more characters for naming
*/}}
{{- define "shortname" -}}
{{- $name := default "powerai-vision" .Values.nameOverride -}}
{{- printf "%s-%s" $name .Release.Name | trunc 40 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the imagePullSecrets if any are needed (generally we don't need these).
*/}}
{{- define "imagesecrets" -}}
{{- if .Values.image.secretName }}
{{- if ne .Values.image.secretName "default"}}
imagePullSecrets:
  - name: {{ .Values.image.secretName }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Create the repoprefix if it was supplied.  If it doesn't have a trailing / then add one.
*/}}
{{- define "repoprefix" -}}
  {{- if .Values.image.repoPrefix -}}
    {{- if not (hasSuffix "/" .Values.image.repoPrefix) -}}
      {{- printf "%s/" .Values.image.repoPrefix -}}
    {{- else -}}
      {{- printf "%s" .Values.image.repoPrefix -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Create the repoprefix if it was supplied.  If it doesn't have a trailing / then add one.
This allows us to have a different repoPrefix for publicly available images such as
postgres vs our own custom ones.  Generally these are the same.  If the repoPrefixPublic
is not set, then we'll default to repoPrefix.  If the repoPrefixPublic is set to '-', then
we return nothing - that is...the '-' value means that there is no prefix.
*/}}
{{- define "repoprefixpublic" -}}
  {{- if .Values.image.repoPrefixPublic -}}
    {{- if eq .Values.image.repoPrefixPublic "-" -}}
    {{- else if not (hasSuffix "/" .Values.image.repoPrefixPublic) -}}
      {{- printf "%s/" .Values.image.repoPrefixPublic -}}
    {{- else -}}
      {{- printf "%s" .Values.image.repoPrefixPublic -}}
    {{- end -}}
  {{- else -}}
    {{ template "repoprefix" . }}
  {{- end -}}
{{- end -}}