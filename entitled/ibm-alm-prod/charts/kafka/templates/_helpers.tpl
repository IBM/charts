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
This is used to configure Kafka, depending on ssl.enabled, ssl.allowInsecure and advertisedListeners
*/}}
{{- define "kafka.advertisedListeners" -}}
{{- if .Values.ssl.allowInsecure -}}
  {{- printf "PLAINTEXT://$POD_IP:9092," -}}
  {{ if kindIs "slice" .Values.advertisedListeners }}
    {{- printf "PLAINTEXT_EXTERNAL://${EXTERNAL_KAFKA_HOSTNAME}:${EXTERNAL_KAFKA_PORT}," }}
  {{- end -}}
{{- end -}}
{{- if .Values.ssl.enabled -}}
  {{- printf "SASL_SSL://$POD_IP:9093," -}}
  {{- if kindIs "slice" .Values.advertisedListeners }}
    {{- printf "SASL_SSL_EXTERNAL://${EXTERNAL_KAFKA_HOSTNAME}:${EXTERNAL_KAFKA_SECURE_PORT}," }}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Calculates the desired replication factor given the number of brokers.
Will work with either clusterSize or global.kafka.clusterSize (global value preferred)
*/}}
{{- define "kafka.topicReplicationFactor" -}}
{{- $numBrokers := default (default 1 .Values.clusterSize) .Values.global.kafka.clusterSize -}}
{{- if gt $numBrokers 3.0 -}}
  {{- printf "%d" 3 }}
{{- else -}}
  {{- printf "%d" (int $numBrokers) }}
{{- end -}}
{{- end -}}

{{/*
Calculates the desired in sync replicas given the number of brokers.
Will work with either clusterSize or global.kafka.clusterSize (global value preferred)
*/}}
{{- define "kafka.minInSyncReplicas" -}}
{{- $numBrokers := default (default 1 .Values.clusterSize) .Values.global.kafka.clusterSize -}}
{{- if gt $numBrokers 2.0 -}}
  {{- printf "%d" 2 }}
{{- else -}}
  {{- printf "%d" 1 }}
{{- end -}}
{{- end -}}
