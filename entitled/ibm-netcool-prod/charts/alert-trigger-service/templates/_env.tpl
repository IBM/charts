{{/*
########################################################################
#
# Licensed Materials - Property of IBM
#
# 5725Q09
#
# (C) Copyright IBM Corp.
#
# 2018 All Rights Reserved
#
# US Government Users Restricted Rights - Use, duplication or disclosure 
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
########################################################################
*/}}
{{- define "alert-trigger-service.application" -}}

{{- $integrations := .Values.global.integrations -}}

{{- $kafkaRelease := include "alert-trigger-service.getKafkaRelease" (list . $integrations.analyticsKafka.releaseName) -}}

{{- $policyRegistryRelease := include "alert-trigger-service.getRegistryRelease" (list . $integrations.policyRegistry.releaseName) -}}

{{- if  eq .Values.global.environmentSize  "size0" }}
- name: SERVICE_XMS
  value: '512M'
- name: SERVICE_XMX
  value: '1G'
{{- else if eq .Values.global.environmentSize "size1" }}
- name: SERVICE_XMS
  value: '1G'
- name: SERVICE_XMX
  value: '2G'
{{- else }}
- name: SERVICE_XMS
  value: '512M'
- name: SERVICE_XMX
  value: '1G'
{{ end }}
- name: LOGGING_LEVEL
  value: "INFO"
- name: BATCHING_SIZE
  value: "200"
- name: BATCHING_TIME_SECS
  value: "1"
- name: EVENTS_TOPIC
  value: {{ .Values.topics.events.name | quote }}
- name: EA_EVENTS_TOPIC
  value: {{ .Values.topics.eaevents.name | quote }}
- name: ACTIONS_TOPIC
  value: {{ .Values.topics.actions.name | quote }}
- name: KAFKA_URL
  value: {{ $kafkaRelease }}-kafka:9092
- name: KAFKA_CONSUMER_THREADS
  value: '1'
- name: KAFKA_SERVICE_HOST
  value: "{{ $kafkaRelease }}-kafka"
- name: KAFKA_SERVICE_PORT_KAFKAREST
  value: "8080"
- name: REGISTRY_HOST
  value: {{ $policyRegistryRelease }}-{{ .Values.cneaChartName }}-policyregistryservice
- name: REGISTRY_PORT
  value: '5600'
- name: REGISTRY_URL
  value: "policies_consolidated"
- name: REGISTRY_CONTEXT_ROOT
  value: "api/policies/system/v2"
- name: REGISTRY_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ $policyRegistryRelease }}-systemauth-secret
      key: username
- name: REGISTRY_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ $policyRegistryRelease }}-systemauth-secret
      key: password
- name: REGISTRY_REFRESH_TIMEOUT
  value: '60'    
- name: KAFKA_BROKERS_SASL_BROKERS2
  value: '{{ $kafkaRelease }}-kafka:9092'
- name: KAFKA_TOPIC_PARTITIONS
  value: "6"
- name: KAFKA_TOPIC_REPLICAS
  {{- if eq .Values.global.environmentSize "size0" }}
  value: "1"
  {{- else }}
  value: "3"
  {{- end }}
{{- end -}}

{{- define "alert-trigger-service.common.license" -}}
- name: LICENSE
  value: {{ .Values.global.license | quote }}
{{- end -}}
