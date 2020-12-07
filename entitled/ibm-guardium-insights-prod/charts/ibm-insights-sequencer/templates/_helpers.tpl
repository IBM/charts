{{/*
###############################################################################
# Licensed Materials - Property of IBM.
# Copyright IBM Corporation 2018. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
# Contributors:
#  IBM Corporation - initial API and implementation
###############################################################################
*/}}
{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "sequencer.name" -}}
{{- default "ibm-insights-sequencer" .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sequencer.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "ibm-insights-sequencer" .Values.nameOverride -}}
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
{{- define "sequencer.chart" -}}
{{- printf "%s-%s" "ibm-insights-sequencer" .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "sequencer.rolename" -}}
{{ template "sequencer.name" . }}-role
{{- end -}}

{{- define "sequencer.serviceaccountname" -}}
{{- if and (not .Values.rbac.create) (.Values.rbac.existingServiceAccount) -}}
{{- .Values.rbac.existingServiceAccount -}}
{{- else -}}
{{ template "sequencer.name" . }}-serviceaccount
{{- end -}}
{{- end -}}

{{- define "sequencer.rolebindingname" -}}
{{ template "sequencer.name" . }}-rolebinding
{{- end -}}

{{/*
  Common labels required by CASE bundling.
  Note: 'release' is a historical label
*/}}
{{- define "common.caseLabels" -}}
release: {{ .Release.Name }}
helm.sh/chart: {{ template "sequencer.chart" .}}
app.kubernetes.io/name: {{ template "sequencer.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
  Common information required by CASE bundling. These are set as env vars in
  images that dynamically create k8s artifacts.
  Note: 'release' is a historical label
*/}}
{{- define "common.envCaseLabels" -}}
- name: INSIGHTS_RELEASE
  value: {{ .Release.Name }}
- name: APP_K8S_IO_INSTANCE
  value: {{ .Release.Name }}
- name: APP_K8S_IO_MANAGEDBY
  value: {{ .Release.Service }}
- name: APP_K8S_IO_NAME
  value: {{ template "sequencer.name" . }}
- name: HELM_CHART
  value: {{ template "sequencer.chart" .}}
{{- end -}}

{{/*
  Utility env variables commonly used in containers
*/}}
{{- define "common.envUtilValues" -}}
- name: INSIGHTS_NAMESPACE
  valueFrom:
    fieldRef:
      apiVersion: v1
      fieldPath: metadata.namespace
{{- end -}}

{{/*
  IBM CloudPak setup admin credentials
*/}}
{{- define "common.envICPAdminCredentials" -}}
- name: ICP_ADMIN_USER
  valueFrom:
    secretKeyRef:
      name: insights-ics-authadmin
      key: _AUTH_ADMIN_USER
- name: ICP_ADMIN_PWD
  valueFrom:
    secretKeyRef:
      name: insights-ics-authadmin
      key: _AUTH_ADMIN_CREDENTIAL
{{- end -}}

{{/*
Inserts the root level (spec.template.spec) pod security context sections to pod definitions.
Usage: {{ include "common.podRootSecurityContextParams" . }}
*/}}
{{- define "common.podRootSecurityContextParams" -}}
hostNetwork: false
hostPID: false
hostIPC: false
{{- end -}}

{{/*
Inserts the container level (spec.template.spec.containers[0].securityContext) pod security context sections to pod definitions.
Usage: {{ include "common.podContainerSecurityContextParams" . }}
*/}}
{{- define "common.podContainerSecurityContextParams" -}}
allowPrivilegeEscalation: false
capabilities:
  drop:
  - ALL
privileged: false
readOnlyRootFilesystem: false
runAsNonRoot: true
runAsUser: 1001
{{- end -}}

{{/*
Renders a value that contains template.
Usage:
{{ include "sequencer.tplValue" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "sequencer.tplValue" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}