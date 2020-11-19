{{/* vim: set filetype=mustache: */}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "wml-canvas.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* Generate Cloud Pak annotations */}}
{{- define "spss-modeler.cloudpak_annotations" }}
cloudpakName: {{ .Values.global.annotations.cloudpakName }}
cloudpakId: {{ .Values.global.annotations.cloudpakId }}
cloudpakInstanceId: {{ .Values.global.cloudpakInstanceId }}
productMetric: {{ .Values.global.annotations.productMetric }}
productChargedContainers: {{ .Values.global.annotations.productChargedContainers }}
productID: {{ .Values.global.annotations.productID }}
productCloudpakRatio: {{ .Values.global.annotations.productCloudpakRatio }}
productName: {{ .Values.global.annotations.productName }}
productVersion: {{ .Values.global.annotations.productVersion | quote }}
hook.deactivate.cpd.ibm.com/command: "[]"
hook.activate.cpd.ibm.com/command: "[]"
{{- end }}

{{/* Pod Labels */}}
{{- define "spss-modeler.addOnPodLabels" }}
icpdsupport/addOnId: {{ .Values.global.addOnPodLabels.addOnId }}
icpdsupport/app: {{ .Values.global.addOnPodLabels.app }}
{{- end }}