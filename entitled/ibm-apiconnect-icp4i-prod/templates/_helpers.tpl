{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "ibm-apiconnect-cip.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "ibm-apiconnect-cip.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ibm-apiconnect-cip.productName" -}}
{{- if .Values.productionDeployment -}}
"IBM Cloud Pak for Integration - API Connect (Chargeable)"
{{- else -}}
"IBM Cloud Pak for Integration (non-production) - API Connect (Chargeable)"
{{- end -}}
{{- end -}}

{{- define "ibm-apiconnect-cip.productID" -}}
{{- if .Values.productionDeployment -}}
"APIConnect_5737_I89_ICP4I_chargeable"
{{- else -}}
"APIConnect_5737_I89_ICP4I_nonProd_chargeable"
{{- end -}}
{{- end -}}

{{- define "ibm-apiconnect-cip.productVersion" -}}
"2018.4.1.7"
{{- end -}}

{{- define "ibm-apiconnect-cip.productMetric" -}}
"PROCESSOR_VALUE_UNIT"
{{- end -}}

{{- define "ibm-apiconnect-cip.productChargedContainers" -}}
"All"
{{- end -}}

{{- define "ibm-apiconnect-cip.securityContext" -}}
allowPrivilegeEscalation: false
capabilities:
  drop:
  - ALL
privileged: false
readOnlyRootFilesystem: false
runAsNonRoot: true
runAsUser: 1001
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
  memory: 128Mi
requests:
  cpu: 100m
  memory: 128Mi
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "ibm-apiconnect-cip.serviceAccountName" -}}
{{- if .Values.operator.serviceAccount.create -}}
    {{ default (include "ibm-apiconnect-cip.fullname" .) .Values.operator.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.operator.serviceAccount.name }}
{{- end -}}
{{- end -}}