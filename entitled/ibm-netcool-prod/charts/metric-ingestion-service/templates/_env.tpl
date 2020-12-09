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
{{- define "metric-ingestion-service.application" -}}

{{- $integrations := .Values.global.integrations -}}

{{- $kafkaRelease := include "metric-ingestion-service.getKafkaRelease" (list . $integrations.analyticsKafka.releaseName) -}}

{{- $sparkRelease := include "metric-ingestion-service.getSparkRelease" (list . $integrations.analyticsSpark.releaseName) -}}

{{- $userinfoTemplate := "{{ .releaseName }}-ibm-cem-cem-users.{{ .namespace }}.svc:6002/users/api/usermgmt/v1/userinfo" -}}

- name: LOGGING_LEVEL
  value: "INFO"
- name: PUBLICURL
  value: {{ include "metric-ingestion-service.ingress.baseurl" . | quote }}
{{- if eq .Values.global.environmentSize "size0" }}
- name: SPARK_EXEC_MEM
  value: "1G"
- name: SPARK_EXEC_CORES
  value: "1"
- name: SPARK_CORES_MAX
  value: "1"
{{- else }}
- name: SPARK_EXEC_MEM
  value: "1G"
- name: SPARK_EXEC_CORES
  value: "1"
- name: SPARK_CORES_MAX
  value: "2"
{{- end }}

{{- if  eq .Values.global.environmentSize  "size0" }}
- name: METRIC_INGEST_XMS
  value: '512M'
- name: METRIC_INGEST_XMX
  value: '1G'
{{- else if eq .Values.global.environmentSize "size1" }}
- name: METRIC_INGEST_XMS
  value: '1G'
- name: METRIC_INGEST_XMX
  value: '2G'
{{- else }}
- name: METRIC_INGEST_XMS
  value: '512M'
- name: METRIC_INGEST_XMX
  value: '1G'
{{ end }}

{{ include "metric-ingestion-service.getCemusersUrl" (list . "AUTH_CEMUSERS_USERINFO_ENDPOINT" $integrations.users.releaseName $integrations.users.namespace $integrations.users.config.userInfoTenant) }}
- name: AUTH_ENABLED
  value: {{ .Values.authentication.enabled | quote }}
- name: METRIC_INGESTION_HOST
  value: {{ .Release.Name }}-metric-ingestion-service-metricingestionservice
- name: METRIC_INGESTION_PORT
  value: {{ .Values.metricingestionservice.port | quote }}
- name: METRIC_INGESTION_ADMIN_PORT
  value: {{ .Values.metricingestionservice.portSsl | quote }}
# aggregation
- name: METRIC_INGESTION_LATENESS_THRESHOLD
  value: {{ .Values.metricingestionservice.latenessThreshold | quote }}
- name: METRIC_INGESTION_AGGREGATION_INTERVAL
  value: {{ .Values.metricingestionservice.aggregationInterval | quote }}
- name: METRIC_INGESTION_CHECKPOINT_LOCATION
  value: {{ .Values.metricingestionservice.checkpointLocation | quote }}
- name: METRIC_INGESTION_INACTIVE_SHUTDOWN_MS
  value: {{  (int .Values.metricingestionservice.inactiveShutdownMs) | default (int 1200000) | quote }}
- name: METRIC_INGESTION_START_JOBS_IMMEDIATELY
  value: {{ .Values.metricingestionservice.startJobsImmediately | quote }}
- name: METRIC_INGESTION_STOP_JOBS_WHEN_INACTIVE
  value: {{ .Values.metricingestionservice.stopJobsWhenInactive | quote }}
# kafka
- name: KAFKA_BROKERS_SASL_BROKERS
  value: '{{ $kafkaRelease }}-kafka:9092'
- name: KAFKA_SERVICE_HOST
  value: "{{ $kafkaRelease }}-kafka"
- name: KAFKA_SERVICE_PORT_KAFKAREST
  value: "8080"
- name: KAFKA_TOPIC_PARTITIONS
  value: "6"
- name: KAFKA_TOPIC_REPLICAS
{{- if eq .Values.global.environmentSize "size0" }}
  value: "3"
{{- else }}
  value: "3"
{{- end }}
- name: METRICS_TOPIC
  value: {{ .Values.topics.metrics.name | quote }}
- name: METRICS_TOPIC_RAW
  value: {{ .Values.topics.rawMetrics.name | quote }}
- name: METRICS_TOPIC_BASELINE
  value: {{ .Values.topics.outgoingBaselines.name | quote }}
- name: METRICS_TOPIC_ENABLED
  value: {{ .Values.topics.metrics.enabled | quote }}
# cassandra
- name: CASSANDRA_TTL_SECONDS
  value: {{  (int .Values.metricingestionservice.cassandraTTL) | default (int 2592000) | quote }}
- name: CASSANDRA_CONTACT_POINTS
  value: {{ .Release.Name }}-cassandra
- name: CASSANDRA_USERID
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-cassandra-auth-secret
      key: username
- name: CASSANDRA_PASSWD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-cassandra-auth-secret
      key: password
# spark
- name: SPARK_MASTER_HOST
  value: {{ $sparkRelease }}-spark-master
- name: SPARK_MASTER_CLUSTERMODE_PORT
  value: "7077"
{{- end -}}

{{- define "metric-ingestion-service.common.license" -}}
- name: LICENSE
  value: {{ .Values.global.license | quote }}
{{- end -}}
