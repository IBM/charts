{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "ibm-bai.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ibm-bai.imagePullSecret" }}
  {{- if and .Values.imageCredentials .Values.imageCredentials.registry }}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" .Values.imageCredentials.registry (printf "%s:%s" .Values.imageCredentials.username .Values.imageCredentials.password | b64enc) | b64enc }}
  {{- else }}
{{- printf "" }}
  {{- end }}
{{- end }}

{{/*
Elasticsearch cfg
*/}}
{{- define "elasticsearch.cfg" }}

elasticsearch-url: https://{{ .Release.Name }}-ibm-dba-ek-client:9200
    {{- if not (index .Values "ibm-dba-ek" "ekSecret") }}
elasticsearch-username: {{ index .Values "ibm-dba-ek" "kibana" "username" | quote }}
    {{- end }}

{{- end }}

{{/*
Elasticsearch password
*/}}
{{- define "elasticsearch.password" }}

elasticsearch-password: {{ index .Values "ibm-dba-ek" "kibana" "password" | b64enc | quote }}

{{- end }}

{{/*
bai node affinity settings. Only support amd64.
*/}}
{{- define "bai.nodeaffinity" -}}
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: beta.kubernetes.io/arch
          operator: In
          values:
          - amd64
{{ end }}

{{/*
Flink log4j configMap name
*/}}
{{- define "flink.configmap.name" -}}
{{ if .Values.flink.log4jConfigMap }}{{ .Values.flink.log4jConfigMap }}{{ else }}{{ .Release.Name }}-bai-flink-log4j{{ end -}}
{{ end }}

{{/*
Config values, which trigger a restart of jobManager when value change
*/}}
{{- define "jobManager.restart" -}}
checksum/config: {{ cat  .Values.kafka.serverCertificate .Values.elasticsearch.serverCertificate .Values.flink.initStorageDirectory .Values.flink.log4jConfigMap .Values.flink.hadoopConfigMap .Values.baiSecret | sha256sum }}
{{ end }}

{{/*
Config values, which trigger a restart of Flink taskManager when value change
*/}}
{{- define "taskManager.restart" -}}
checksum/config: {{ cat .Values.flink.taskManagerHeapMemory  .Values.kafka.serverCertificate .Values.elasticsearch.serverCertificate .Values.flink.rocksDbPropertiesConfigMap .Values.flink.log4jConfigMap .Values.flink.hadoopConfigMap .Values.baiSecret | sha256sum }}
{{ end }}

{{/*
Config values, which trigger a restart of admin when value change
*/}}
{{- define "admin.restart" -}}
checksum/config: {{ cat .Values.admin.username .Values.admin.password .Values.kafka.username .Values.kafka.password .Values.kafka.bootstrapServers .Values.kafka.securityProtocol  .Values.baiSecret | sha256sum }}
{{ end }}
