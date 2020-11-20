{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "common.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "common.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | replace "." "" | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | replace "." "" | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}


{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "common.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}


{{- define "image.repoTag" -}}

{{- $params := . }}
{{- $top := first $params }}
{{- $compName := (include "sch.utils.getItem" (list $params 1 "")) }}
{{- $registry := "" }}
{{- if $top.Values.global.docker_registry_prefix }}
{{- $registry = printf "%s/"  $top.Values.global.docker_registry_prefix }}
{{- else }}
{{- $registry = "" }}
{{- end -}}

{{- $arch := "" }}
{{- if $top.Values.global.currentModuleArch }}
{{- $arch = printf "-%s" $top.Values.global.currentModuleArch -}}
{{- else }}
{{- if $top.Values.image.arch }}
{{- $arch = printf "-%s" $top.Values.image.arch -}}
{{- else }}
{{- $arch = "" -}}
{{- end -}}
{{- end -}}

{{- printf "%s%s:%s%s" $registry (index $top.Values  $compName).image.repository (index $top.Values  $compName).image.tag  $arch -}}
{{- end -}}

{{- define "common.matchLabels" -}}
 {{- $params := . }}
 {{- $top := first $params }}
 {{- $compName := (include "sch.utils.getItem" (list $params 1 "")) }}

{{- if $top.Values.customLabelValues.app }}
app: {{ $top.Values.customLabelValues.app }}
{{- else }}
app: {{ include "sch.names.appName" (list $top)  | quote }}
{{- end }}
component: {{ $compName | quote }}
chart: "{{ $top.Chart.Name }}"
heritage: {{ $top.Values.helm2Legacy | ternary "Tiller" ($top.Release.Service | quote) }}
release: {{ $top.Release.Name | quote }}
{{- end -}}


{{- define "common.annotations" -}}
{{- if .Values.customAnnotations }}
{{ .Values.customAnnotations  }}
{{- end }}
productName: "IBM Db2 Data Management Console Addon"
{{- if .Values.global.productID }}
productID: "{{ .Values.global.productID }}"
{{- else }}
{{- if .Values.productID }}
productID: "{{ .Values.productID }}"
{{- end }}
{{- end }}
{{- if .Values.global.productVersion }}
productVersion: "{{ .Values.global.productVersion }}"
{{- else }}
{{- if .Values.productVersion }}
productVersion: "{{ .Values.productVersion }}"
{{- end }}
{{- end }}
productMetric: "VIRTUAL_PROCESSOR_CORE"
productChargedContainers: "All"
productCloudpakRatio: "1:1" 
hook.activate.cpd.ibm.com/command: "[]"
hook.deactivate.cpd.ibm.com/command: "[]"
hook.quiesce.cpd.ibm.com/command: "[]"
hook.unquiesce.cpd.ibm.com/command: "[]"
{{- if .Values.global.cloudpakName }}
cloudpakName: "{{ .Values.global.cloudpakName }}"
{{- end }}
{{- if .Values.global.cloudpakId }}
cloudpakId: "{{ .Values.global.cloudpakId }}"
{{- end }}
{{- if .Values.global.cloudpakVersion }}
cloudpakVersion: "{{ .Values.global.cloudpakVersion }}"
{{- end }}
{{- if .Values.global.cloudpakInstanceId }}
cloudpakInstanceId: "{{ .Values.global.cloudpakInstanceId }}"
{{- end }}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "common.labels" -}}
 {{- $params := . }}
 {{- $top := first $params }}
 {{- $compName := (include "sch.utils.getItem" (list $params 1 "")) }}
{{- if $top.Values.customLabels  }}
{{ $top.Values.customLabels }}
{{- end }}
{{- if $top.Values.customLabelValues.app }}
app: {{ $top.Values.customLabelValues.app }}
{{- else }}
app: {{ include "sch.names.appName" (list $top)  | quote }}
{{- end }}
chart: {{ $top.Chart.Name | quote }}
heritage: {{ $top.Values.helm2Legacy | ternary "Tiller" ($top.Release.Service | quote) }}
release: {{ $top.Release.Name | quote }}
app.kubernetes.io/managed-by: helm
sidecar.istio.io/inject: "true"
helm.sh/chart: {{ $top.Chart.Name | quote }}
namespace: {{ $top.Release.Namespace }}
{{- if $top.Values.customLabelValues.appKubeIo.name }}
app.kubernetes.io/name: {{ $top.Values.customLabelValues.appKubeIo.name }}
{{- else }}
app.kubernetes.io/name: {{ include "sch.names.appName" (list $top)  | quote }}
{{- end }}
{{- if $top.Values.customLabelValues.serviceInstanceID }}
{{- $customServiceInstanceID := $top.Values.customLabelValues.serviceInstanceID | int64 }}
ServiceInstanceID: "{{ $customServiceInstanceID }}"
icpdsupport/serviceInstanceId: "{{ $customServiceInstanceID }}"
icpd-addon/status: "{{ $customServiceInstanceID }}"
{{- else }}
{{- if $top.Values.zenServiceInstanceId }}
{{- $zenServiceInstanceID := $top.Values.zenServiceInstanceId | int64 }}
ServiceInstanceID: "{{ $zenServiceInstanceID }}"
icpdsupport/serviceInstanceId: "{{ $zenServiceInstanceID }}"
icpd-addon/status: "{{ $zenServiceInstanceID }}"
{{- end }}
{{- end }}
{{- if $top.Values.customLabelValues.appKubeIo.instance }}
app.kubernetes.io/instance: {{ $top.Values.customLabelValues.appKubeIo.instance }}
{{- else }}
app.kubernetes.io/instance: {{ $top.Release.Name | quote }}
{{- end }}
icpdsupport/app: {{ $compName | quote }}
icpdsupport/podSelector: {{ $compName | quote }}
icpdsupport/addOnId: "dmc"
{{- if $compName }}
component: {{ $compName | quote }}
  {{- end }}
  {{- if (gt (len $params) 2) }}
    {{- $moreLabels := (index $params 2) }}
    {{- range $k, $v := $moreLabels }}
{{ $k }}: {{ $v | quote }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
SecurityContext
*/}}
{{- define "common.podSecurityContext" -}}
hostNetwork: false
hostPID: false
hostIPC: false
securityContext:
  runAsNonRoot: true
  runAsUser: 1000321000
{{- end -}}

{{/*
SecurityContext
*/}}
{{- define "common.containerSecurityContext" -}}
privileged: false
readOnlyRootFilesystem: false
allowPrivilegeEscalation: true
runAsNonRoot: true
capabilities:
  drop:
  - ALL
{{- end }}
