{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "ibm-apiconnect-ent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "ibm-apiconnect-ent.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ibm-apiconnect-ent.productName" -}}
"API Connect Enterprise"
{{- end -}}

{{- define "ibm-apiconnect-ent.productID" -}}
"5725-Z22"
{{- end -}}

{{- define "ibm-apiconnect-ent.productVersion" -}}
"2018.4.1.7"
{{- end -}}

{{- define "ibm-apiconnect-ent.productMetric" -}}
"PROCESSOR_VALUE_UNIT"
{{- end -}}

{{- define "ibm-apiconnect-ent.productChargedContainers" -}}
"All"
{{- end -}}

{{- define "ibm-apiconnect-ent.securityContext" -}}
allowPrivilegeEscalation: false
capabilities:
  drop:
  - ALL
privileged: false
readOnlyRootFilesystem: false
runAsNonRoot: true
runAsUser: 1001
{{- end -}}

{{- define "ibm-apiconnect-ent.podSecurityContext" -}}
fsGroup: 1001
runAsNonRoot: true
runAsUser: 1001
supplementalGroups:
  - 1001
{{- end -}}

{{- define "ibm-apiconnect-ent.resources" -}}
limits:
  cpu: 100m
  memory: 128Mi
requests:
  cpu: 100m
  memory: 128Mi
{{- end -}}