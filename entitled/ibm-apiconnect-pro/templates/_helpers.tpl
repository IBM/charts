{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "ibm-apiconnect-pro.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "ibm-apiconnect-pro.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ibm-apiconnect-pro.productName" -}}
"API Connect Professional"
{{- end -}}

{{- define "ibm-apiconnect-pro.productID" -}}
"5725-Z22"
{{- end -}}

{{- define "ibm-apiconnect-pro.productVersion" -}}
"2018.4.1.7"
{{- end -}}

{{- define "ibm-apiconnect-pro.productMetric" -}}
"PROCESSOR_VALUE_UNIT"
{{- end -}}

{{- define "ibm-apiconnect-pro.productChargedContainers" -}}
"All"
{{- end -}}

{{- define "ibm-apiconnect-pro.securityContext" -}}
allowPrivilegeEscalation: false
capabilities:
  drop:
  - ALL
privileged: false
readOnlyRootFilesystem: false
runAsNonRoot: true
runAsUser: 1001
{{- end -}}

{{- define "ibm-apiconnect-pro.podSecurityContext" -}}
fsGroup: 1001
runAsNonRoot: true
runAsUser: 1001
supplementalGroups:
  - 1001
{{- end -}}

{{- define "ibm-apiconnect-pro.resources" -}}
limits:
  cpu: 100m
  memory: 128Mi
requests:
  cpu: 100m
  memory: 128Mi
{{- end -}}