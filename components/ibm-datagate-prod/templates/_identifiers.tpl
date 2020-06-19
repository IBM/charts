{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "dg.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "dg.fullname" -}}
  {{- if not .Values.zenServiceInstanceId }}
    {{- $name := default .Chart.Name .Values.nameOverride -}}
    {{- $shortname := .Release.Name | trunc 10 -}}
    {{- printf "%s-%s" $shortname $name | trunc 63 | trimSuffix "-" -}}
  {{- else }}
    {{- $instanceId := .Values.zenServiceInstanceId | int64 -}}
    {{- printf "%s-%d" .Values.zenServiceInstanceType $instanceId }}
  {{- end }}
{{- end -}}

{{/*
Create a default data store name
We truncate at 10 chars for the name as we reach a limit when PVCs for the statefulset are created
*/}}
{{- define "dg.datastorname" -}}
  {{- if not .Values.zenServiceInstanceId }}
    {{- $name := default .Release.Name | trunc 10 | trimSuffix "-" -}}
    {{- printf "%s-%s" $name "data-stor" -}}
  {{- else }}
    {{- $instanceId := .Values.zenServiceInstanceId | int64 -}}
    {{- printf "%s-%d-%s" .Values.zenServiceInstanceType $instanceId "data-stor" -}}
  {{- end }}
{{- end -}}

{{/*
Create a default data ha store name for the additional claim for hadr deployment
We truncate at 10 chars for the name as we reach a limit when PVCs for the statefulset are created
*/}}
{{- define "dg.datahastorname" -}}
  {{- if not .Values.zenServiceInstanceId }}
    {{- $name := default .Release.Name | trunc 10 | trimSuffix "-" -}}
    {{- printf "%s-%s" $name "ha-stor" -}}
  {{- else }}
    {{- $instanceId := .Values.zenServiceInstanceId | int64 -}}
    {{- printf "%s-%d-%s" .Values.zenServiceInstanceType $instanceId "ha-stor" -}}
  {{- end }}
{{- end -}}

{{/*
Create a default shared store name
We truncate at 10 chars for the name as we reach a limit when PVCs for the statefulset are created
*/}}
{{- define "dg.sharedstorname" -}}
  {{- if not .Values.zenServiceInstanceId }}
    {{- $name := default .Release.Name | trunc 10 | trimSuffix "-" -}}
    {{- printf "%s-%s" $name "shared-stor" -}}
  {{- else }}
    {{- $instanceId := .Values.zenServiceInstanceId | int64 -}}
    {{- printf "%s-%d-%s" .Values.zenServiceInstanceType $instanceId "shared-stor" -}}
  {{- end }}
{{- end -}}

{{/*
Create a default ldap store name
We truncate at 10 chars for the name as we reach a limit when PVCs for the statefulset are created

{{- define "dg.ldapstorname" -}}
  {{- if not .Values.hadr.enabled }}
    {{- $instanceId := .Values.zenServiceInstanceId | int64 -}}
    {{- printf "%s-%d-%s" Values.zenServiceInstanceType $instanceId "ldap-stor" -}}
  {{- else }}
    {{- $instanceId := .Values.zenServiceInstanceId | int64 -}}
    {{- printf "%s-%d-%s-0" "ldap-stor" .Values.zenServiceInstanceType $instanceId -}}
  {{- end }}
{{- end -}}
*/}}
