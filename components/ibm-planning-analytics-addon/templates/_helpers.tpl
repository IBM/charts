{{- define "addon-sample.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "addon-sample.fullname" -}}
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

{{- define "addon-sample.configname" -}}
{{- if .Values.confignameOverride -}}
{{- .Values.confignameOverride | trunc 63 | trimSuffix "-" -}}
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
{{- define "addon-sample.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Expand the name of the chart.fdfd
*/}}
{{- define "svc-api.name" -}}
{{- default .Values.svcApi.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "svc-api.fullname" -}}
{{- default .Values.svcApi.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Create chart name and version as used by the chart label.fdfdf
*/}}
{{- define "svc-api.chart" -}}
{{- printf "%s-%s" .Values.svcApi.name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* vim: set filetype=mustache: */}}

{{/*
Create the default zen base chart annotations
*/}}




{{- define "zenhelper.nodeArchAffinity" }}
nodeAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    nodeSelectorTerms:
    - matchExpressions:
      - key: beta.kubernetes.io/arch
        operator: In
        values:
          - {{ .Values.global.architecture }}
{{- end }}

{{- define "zenhelper.user-home-pvc" }}
- name: user-home-mount
  persistentVolumeClaim:
  {{- if .Values.global.userHomePVC.persistence.existingClaimName }}
    claimName: {{ .Values.global.userHomePVC.persistence.existingClaimName }}
  {{- else }}
    claimName: "user-home-pvc"
  {{- end }}
{{- end }}