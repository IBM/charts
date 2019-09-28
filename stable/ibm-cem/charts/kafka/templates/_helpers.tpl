{{/* vim: set filetype=mustache: */}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "kafka.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "kafka.releasename" -}}
{{- printf "%s" .Release.Name  | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "kafka.getImageRepo" -}}
{{- if .Values.global.image.repository -}}
{{- printf "%s" ( trimSuffix "/" .Values.global.image.repository ) }}
{{- end -}}
{{- end -}}


{{/*
Returns a space separated list of .Values.advertisedListeners
This is used to create a bash array, for looking up the desired advertised listener
hostname for a given instance of Kafka.
*/}}
{{- define "kafka.advertisedListenersAsBashArray" -}}
{{- range $lsnr := .Values.advertisedListeners -}}
{{ printf "%s " $lsnr -}}
{{ end }}
{{- end -}}

{{/*
Returns a comma separated list of advertised listeners
This is used to configure Kafka, depending on global.kafka.clientEncryption, global.kafka.allowInsecure and advertisedListeners
*/}}
{{- define "kafka.advertisedListeners" -}}
{{- if .Values.global.kafka.allowInsecure -}}
  {{- printf "PLAINTEXT://$HOSTNAME.%s-kafka.%s.svc.$CLUSTERDOMAIN:9092," .Release.Name .Release.Namespace -}}
  {{ if kindIs "slice" .Values.advertisedListeners }}
    {{- printf "PLAINTEXT_EXTERNAL://${EXTERNAL_KAFKA_HOSTNAME}:${EXTERNAL_KAFKA_PORT}," }}
  {{- end -}}
{{- end -}}
{{- if .Values.global.kafka.clientEncryption -}}
  {{- printf "SASL_SSL://$HOSTNAME.%s-kafka.%s.svc.$CLUSTERDOMAIN:9093," .Release.Name .Release.Namespace -}}
  {{- if kindIs "slice" .Values.advertisedListeners }}
    {{- printf "SASL_SSL_EXTERNAL://${EXTERNAL_KAFKA_HOSTNAME}:${EXTERNAL_KAFKA_SECURE_PORT}," }}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
decides on using global or local kafka.clustersize
*/}}
{{- define "kafka.rawReplicationFactor" }}
  {{- if .Values.global.kafka.clusterSize }}
    {{- .Values.global.kafka.clusterSize }}
  {{- else }}
    {{- .Values.clusterSize }}
  {{- end }}
{{- end -}}

{{/*
check if kafka.clusterSize == "environmentSizeDefault" and if so use value in _resouces.tpl
corresponding to environmentSize setting
*/}}
{{- define "kafka.replicationFactor" -}}
  {{- if eq ( (include "kafka.rawReplicationFactor" .) | toString) "environmentSizeDefault" }}
    {{- include "kafka.comp.size.data" (list . "kafka" "replicas") }}
  {{- else }}
    {{- include "kafka.rawReplicationFactor" . }}
  {{- end }}
{{- end }}

{{/*
Calculates the desired replication factor given the number of brokers.
Will work with either clusterSize or global.kafka.clusterSize (global value preferred)
*/}}
{{- define "kafka.topicReplicationFactor" -}}
{{- $numBrokers := int (include "kafka.replicationFactor" .) -}}
{{- if gt $numBrokers 3 -}}
  {{- printf "%d" 3 }}
{{- else -}}
  {{- printf "%d" $numBrokers }}
{{- end -}}
{{- end -}}

{{/*
Calculates the desired in sync replicas given the number of brokers.
Will work with either clusterSize or global.kafka.clusterSize (global value preferred)
*/}}
{{- define "kafka.minInSyncReplicas" -}}
{{- $numBrokers := int (include "kafka.replicationFactor" .) -}}
{{- if gt $numBrokers 2 -}}
  {{- printf "%d" 2 }}
{{- else -}}
  {{- printf "%d" 1 }}
{{- end -}}
{{- end -}}
