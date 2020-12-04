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
{{- define "edb.annotations" }}
productMetric: “VIRTUAL_PROCESSOR_CORE”
productChargedContainers: “All”
productVersion: “2.0”
{{- if ( eq .Values.epasInstance.spec.postgresType "AS" ) }}
productID:  “1658c31460304c6bba9d5bb8f2f94332”
productName: “IBM Data Management Platform for EDB Postgres Enterprise 2.0 for IBM Cloud Pak for Data”
cloudpakName: “IBM Data Management Platform for EDB Postgres Enterprise 2.0 for IBM Cloud Pak for Data”
cloudpakId: “1658c31460304c6bba9d5bb8f2f94332”
cloudpakInstanceId: "{{ .Values.zenCloudPakInstanceId }}"
{{- else }}
productID:  “ff0c396532e145a08f2df488f86a915c”
productName: “IBM Data Management Platform for EDB Postgres Standard 2.0 for IBM Cloud Pak for Data”
cloudpakName: “IBM Data Management Platform for EDB Postgres Standard 2.0 for IBM Cloud Pak for Data”
cloudpakId: “ff0c396532e145a08f2df488f86a915c”
cloudpakInstanceId: "{{ .Values.zenCloudPakInstanceId }}"
{{- end }}
{{- end }}

{{- define "edb.Podsecurity" }}
hostNetwork: false
hostPID: false
hostIPC: false
securityContext:
  runAsNonRoot: true
{{- end }}

{{- define "edb.Containersecurity" }}
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
icpdsupport/addOnId: "{{ .Values.dbType }}"
icpdsupport/serviceInstanceId: "{{ .Values.zenServiceInstanceId | int64 }}"
icpdsupport/app: database
icpdsupport/createdBy: "{{ .Values.zenServiceInstanceUID | int64 }}"
{{- end }}

