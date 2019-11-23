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
  {{- if not .Values.servicename }}
    {{- $name := default .Chart.Name .Values.nameOverride -}}
    {{- $shortname := .Release.Name | trunc 10 -}}
    {{- printf "%s-%s" $shortname $name | trunc 63 | trimSuffix "-" -}}
  {{- else }}
    {{- printf "%s" .Values.servicename }}
  {{- end }}
{{- end -}}

{{/*
Create a default hadr store name
We truncate at 10 chars for the name as we reach a limit when PVCs for the statefulset are created
*/}}
{{- define "hadrstorname" -}}
  {{- if not .Values.servicename }}
    {{- $name := default .Release.Name | trunc 10 | trimSuffix "-" -}}
    {{- printf "%s-%s" $name "ha-shared" -}}
  {{- else }}
    {{- printf "%s-%s" .Values.servicename "ha-shared" -}}
  {{- end }}
{{- end -}}


{{/*
Create a default data store name
We truncate at 10 chars for the name as we reach a limit when PVCs for the statefulset are created
*/}}
{{- define "datastorname" -}}
  {{- if not .Values.servicename }}
    {{- $name := default .Release.Name | trunc 10 | trimSuffix "-" -}}
    {{- printf "%s-%s" $name "data-stor" -}}
  {{- else }}
    {{- printf "%s-%s" .Values.servicename "data-stor" -}}
  {{- end }}
{{- end -}}

{{/*
Create a default data ha store name for the additional claim for hadr deployment
We truncate at 10 chars for the name as we reach a limit when PVCs for the statefulset are created
*/}}
{{- define "datahastorname" -}}
  {{- if not .Values.servicename }}
    {{- $name := default .Release.Name | trunc 10 | trimSuffix "-" -}}
    {{- printf "%s-%s" $name "ha-stor" -}}
  {{- else }}
    {{- printf "%s-%s" .Values.servicename "ha-stor" -}}
  {{- end }}
{{- end -}}

{{/*
Create a default shared store name
We truncate at 10 chars for the name as we reach a limit when PVCs for the statefulset are created
*/}}
{{- define "sharedstorname" -}}
  {{- if not .Values.servicename }}
    {{- $name := default .Release.Name | trunc 10 | trimSuffix "-" -}}
    {{- printf "%s-%s" $name "shared-stor" -}}
  {{- else }}
    {{- printf "%s-%s" .Values.servicename "shared-stor" -}}
  {{- end }}
{{- end -}}

{{/*
Create a default ldap store name
We truncate at 10 chars for the name as we reach a limit when PVCs for the statefulset are created
*/}}
{{- define "ldapstorname" -}}
  {{- if not .Values.hadr.enabled }}
    {{- printf "%s-%s" .Values.servicename "ldap-stor" -}}
  {{- else }}
    {{- printf "%s-%s-0" "ldap-stor" .Values.servicename -}}
  {{- end }}
{{- end -}}



