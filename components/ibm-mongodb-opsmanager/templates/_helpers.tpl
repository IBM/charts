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
Create annotation
*/}}
{{- define "mongo.annotations" }}
productVersion: "2.0.2"
cloudpakName: "IBM Data Management Platform for MongoDB Enterprise Advanced for IBM Cloud Pak for Data"
cloudpakId: "628fa31a63e849e391eb9e5184be8fa5"
cloudpakInstanceId: "{{ .Values.zenCloudPakInstanceId }}"
productCloudpakRatio: "1:1"
productID: "628fa31a63e849e391eb9e5184be8fa5"
productName: "IBM Data Management Platform for MongoDB Enterprise Advanced"
productMetric: "VIRTUAL_SERVER"
productChargedContainers: "All"
cloudpakVersion: "3.0.1"
{{- end }}

{{- define "mongo.Podsecurity" }}
hostNetwork: false
hostPID: false
hostIPC: false
securityContext:
  runAsNonRoot: true
{{- end }}

{{- define "mongo.Containersecurity" }}
securityContext:
  privileged: false
  allowPrivilegeEscalation: false
  runAsNonRoot: true
  capabilities:
    drop:
    - ALL
{{- end }}


{{- define "metadata_info" }}
app.kubernetes.io/name: {{ include "fullname" . }}
helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
release: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

