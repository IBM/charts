{{/* vim: set filetype=mustache: */}}

{{/* ######################################## PULL SECRET TEMPLATE ######################################## */}}
{{- define "flink.imagePullSecretTemplate" -}}
{{- if ne .Values.global.image.pullSecret "" }}
imagePullSecrets:
- name: {{ .Values.global.image.pullSecret | quote }}
{{- end -}}
{{- end -}}
{{/* ######################################## PULL SECRET TEMPLATE ######################################## */}}

{{/* ######################################## SERVICE ACCOUNT NAME ############################## */}}
{{- define "flink.masterServiceAccountName" -}}
{{ .Release.Name }}-{{ .Values.global.product.schName }}
{{- end -}}
{{- define "flink.serviceAccountName" -}}
{{- default (include "flink.masterServiceAccountName" .) (default .Values.global.existingServiceAccount .Values.existingServiceAccount) -}}
{{- end -}}
{{/* ######################################## SERVICE ACCOUNT NAME ############################## */}}

{{/* ######################################## IMAGE NAME TEMPLATE ######################################## */}}
{{- define "flink.imageName" -}}
{{ if .Values.global.dockerRegistryPrefix }}{{ trimSuffix "/" .Values.global.dockerRegistryPrefix }}/{{ end }}{{ .Values.image.repository }}:{{ .Values.image.tag }}
{{- end -}}
{{/* ######################################## IMAGE NAME TEMPLATE ######################################## */}}

{{/* ######################################## FLINK CONFIG TEMPLATE ######################################## */}}
{{- define "flink.flinkConfigSecretName" -}}
{{ .Release.Name }}-flink-config-secret
{{- end -}}
{{/* ######################################## FLINK CONFIG TEMPLATE ######################################## */}}

{{/* ######################################## IMAGE AFFINITY ################################## */}}
{{- define "flink.nodeAffinity" -}}
{{- if .Values.global.affinity -}}
{{ toYaml .Values.global.affinity }}
{{- else -}}
{{ include "sch.affinity.nodeAffinity" (list . .sch.chart.nodeAffinity) }}
{{- end -}}
{{- end -}}
{{/* ######################################## IMAGE AFFINITY ################################## */}}

{{/* ######################################## IMAGE PULL POLICY TEMPLATE ######################################## */}}
{{- define "flink.imagePullPolicy" -}}
{{ if .Values.global.image.pullPolicy }}{{ .Values.global.image.pullPolicy }}{{ else }}{{ .Values.image.pullPolicy }}{{ end }}
{{- end -}}
{{/* ######################################## IMAGEPULL POLICYTEMPLATE ######################################## */}}

{{/* ######################################## FLINK ENDPOINT TEMPLATE ########################### */}}
{{- define "flink.jobmanagerAddressTemplate" -}}
{{ .Release.Name }}-flink-jobmanager-service
{{- end -}}
{{/* ######################################## FLINK ENDPOINT TEMPLATE ########################### */}}

{{/* ######################################## POD ANTI-AFFINITY ################################## */}}
{{- define "flink.podAntiAffinity" -}}
  {{- $params := . }}
  {{- $root := first $params }}
  {{- $compName := (include "sch.utils.getItem" (list $params 1 "")) -}}
podAntiAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchExpressions:
      - key: app
        operator: In
        values:
        - {{$compName}}
    topologyKey: "kubernetes.io/hostname"
{{- end -}}
{{/* ######################################## POD ANTI-AFFINITY ################################## */}}

{{/* ######################################## VOLUME INJECTION TEMPLATE ########################### */}}
{{ define "flink.templateInjector" }}
{{- $params := . -}}
{{- $root := first $params -}}
{{- $templateList := (index $params 1) -}}
{{range $templateList }}
{{include . $root }}
{{end}}
{{end}}
{{/* ######################################## VOLUME INJECTION TEMPLATE ########################### */}}
