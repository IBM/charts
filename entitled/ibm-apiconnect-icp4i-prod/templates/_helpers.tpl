{{/* vim: set filetype=mustache: */}}

{{/*
Name helpers: Most are truncated at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}

{{- define "ibm-apiconnect-cip.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ibm-apiconnect-cip.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ibm-apiconnect-cip.operator.fullname" -}}
{{- printf "%s-apiconnect-operator" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ibm-apiconnect-cip.register-oidc.fullname" -}}
{{- printf "%s-register-oidc" .Release.Name | trunc 60 | trimSuffix "-" -}}
{{- end -}}

{{- define "ibm-apiconnect-cip.delete-cluster.fullname" -}}
{{- printf "%s-delete-cluster" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ibm-apiconnect-cip.extra-vals.fullname" -}}
{{- printf "%s-extra-values" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ibm-apiconnect-cip.init-files.fullname" -}}
{{- printf "%s-init-files" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ibm-apiconnect-cip.tuning-profile.fullname" -}}
{{- printf "%s-high-max-map-count" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ibm-apiconnect-cip.serviceAccountName" -}}
{{- if .Values.operator.serviceAccount.create -}}
    {{ default (include "ibm-apiconnect-cip.fullname" .) .Values.operator.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.operator.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Helpers for common labels and annotations across top-level and embedded charts.
*/}}

{{- define "ibm-apiconnect-cip.labels" -}}
app: {{ template "ibm-apiconnect-cip.name" . }}
chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
release: {{ .Release.Name }}
heritage: {{ .Release.Service }}
{{- end -}}

{{- define "ibm-apiconnect-cip.commonAnnotations" -}}
{{- if .Values.productionDeployment -}}
productName: "IBM API Connect Enterprise"
productID: "2c717d4ecc924aa5ac345015b55492eb"
productCloudpakRatio: "1:1"
{{- else }}
productName:  "IBM API Connect Enterprise non Production"
productID: "f831eb5a8f4a4e7b9b3f2ebc37ed302e"
productCloudpakRatio: "2:1"
{{- end }}
productVersion: {{ .Chart.AppVersion }}
productMetric: "VIRTUAL_PROCESSOR_CORE"
{{- end -}}

{{- define "ibm-apiconnect-cip.cloudPakAnnotations" -}}
icp4i.ibm.com/product: apiconnect
icp4i.ibm.com/release: {{ .Release.Name }}
cloudpakName: "IBM Cloud Pak for Integration"
cloudpakId: "c8b82d189e7545f0892db9ef2731b90d"
cloudpakVersion: "2020.1.1"
{{- end -}}

{{- define "ibm-apiconnect-cip.subsysAnnotations" -}}
{{ include "ibm-apiconnect-cip.commonAnnotations" . }}
productChargedContainers: "All"
{{ include "ibm-apiconnect-cip.cloudPakAnnotations" . }}
{{- end -}}


{{- define "ibm-apiconnect-cip.annotations" -}}
{{ include "ibm-apiconnect-cip.commonAnnotations" . }}
productChargedContainers: ""
{{ include "ibm-apiconnect-cip.cloudPakAnnotations" . }}
{{- end -}}

{{/*
Helpers for common container fields in top-level chart.
*/}}

{{- define "ibm-apiconnect-cip.containerSpec" -}}
{{- if .Values.operator.registry }}
image: {{ regexReplaceAll "/$" .Values.operator.registry "" }}/{{ .Values.operator.image }}:{{ .Values.operator.tag }}
{{- else }}
image: {{ regexReplaceAll "/$" .Values.global.registry "" }}/{{ .Values.operator.image }}:{{ .Values.operator.tag }}
{{- end }}
imagePullPolicy: {{ .Values.operator.pullPolicy }}
resources:
{{ include "ibm-apiconnect-cip.resources" . | indent 2 }}
securityContext:
{{ include "ibm-apiconnect-cip.securityContext" . | indent 2 }}
{{- end -}}

{{/*
Helpers for security-related fields in top-level and embedded charts.
*/}}

{{- define "ibm-apiconnect-cip.commonSecurityContext" -}}
allowPrivilegeEscalation: false
capabilities:
  drop:
  - ALL
privileged: false
readOnlyRootFilesystem: false
{{- end -}}

{{- define "ibm-apiconnect-cip.securityContext" -}}
{{ include "ibm-apiconnect-cip.commonSecurityContext" . }}
runAsNonRoot: true
runAsUser: 1001
{{- end -}}

{{- define "ibm-apiconnect-cip.hostSettings" -}}
hostNetwork: false
hostPID: false
hostIPC: false
{{- end -}}

{{- define "ibm-apiconnect-cip.podSecurityContext" -}}
fsGroup: 1001
runAsNonRoot: true
runAsUser: 1001
supplementalGroups:
  - 1001
{{- end -}}

{{- define "ibm-apiconnect-cip.resources" -}}
limits:
  cpu: 100m
  memory: 512Mi
requests:
  cpu: 100m
  memory: 256Mi
{{- end -}}