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
