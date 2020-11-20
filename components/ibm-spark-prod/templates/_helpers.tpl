{{/* vim: set filetype=mustache: */}}

{{/*
Create the default zen base chart annotations
*/}}
{{- define "zenhelper.annotations" }}
productName: "Analytics Engine powered by Apache Spark"
productID: "eb9998dcc5d24e3eb5b6fb488f750fe2"
productVersion: "3.5.0"
productCloudpakRatio: "1:1"
productMetric: "VIRTUAL_PROCESSOR_CORE"
productChargedContainers: All
cloudpakId: "eb9998dcc5d24e3eb5b6fb488f750fe2"
cloudpakName: "IBM Cloud Pak for Data"
cloudpakInstanceId: "{{ .Values.global.cloudpakInstanceId }}"
hook.deactivate.cpd.ibm.com/command: "[]"
hook.activate.cpd.ibm.com/command: "[]"
{{- end }}

{{/*
Create the default helm chart labels
*/}}
{{- define "helm.labels" }}
chart: "{{ .Chart.Name }}"
heritage: {{ .Release.Service }}
release: {{ .Release.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: helm
app.kubernetes.io/name: {{ .Release.Name }}
helm.sh/chart: "{{ .Chart.Name }}"
{{- end }}

{{/*
Create the default cpd chart labels
*/}}
{{- define "cloudpak.labels" }}
icpdsupport/addOnId: "{{ .Values.global.addOnId }}"
icpdsupport/app: "api"
{{- end }}