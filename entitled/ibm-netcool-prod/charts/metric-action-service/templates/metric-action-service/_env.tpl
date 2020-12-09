{{- include "sch.config.init" (list . "metric-action-service.sch.chart.config.values") -}}

{{- /*
Creates the environment for the UI server
*/ -}}
{{- define "metric-action-service.metricactionservice.environment" -}}


{{- $integrations := .Values.global.integrations -}}

{{- $kafkaRelease := include "metric-action-service.getKafkaRelease" (list . $integrations.analyticsKafka.releaseName) -}}


env:
{{- if  eq .Values.global.environmentSize  "size0" }}
  - name: JAVA_OPTS
    value: "-Xms512M -Xmx1G"
{{- else if eq .Values.global.environmentSize "size1" }}
  - name: JAVA_OPTS
    value: "-Xms1G -Xmx2G"
{{- else }}
  - name: JAVA_OPTS
    value: "-Xms512M -Xmx1G"
{{ end }}
  - name: LICENSE
    value: {{ .Values.global.license | quote }}
  - name: LOGGING_LEVEL
    value: "INFO"
  - name: KAFKA_STREAM_APPLICATION_ID
    value: {{ printf "%s-metric-action-service" $kafkaRelease | quote }}
  - name: KAFKA_HOST
    value: {{ $kafkaRelease }}-kafka
  - name: KAFKA_BOOTSTRAP_SERVERS
    value: {{ $kafkaRelease }}-kafka:9092
  - name: KAFKA_NOI_ACTIONS_TOPIC_NAME
    value: {{ .Values.topics.incomingActions.name | quote }}
  - name: KAFKA_NOI_BASELINES_TOPIC_NAME
    value: {{ .Values.topics.outgoingBaselines.name | quote }}
  - name: KAFKA_NOI_ANOMALIES_TOPIC_NAME
    value: {{ .Values.topics.outgoingAnomalies.name | quote }}
  - name: KAFKA_STREAMS_MIN_ISR
    value: {{ include "metric-action-service.comp.size.data" (list . "metricactionservice" "kafkaMinInSyncReplicas") | quote }}
  - name: KAFKA_STREAMS_REPLICATION_FACTOR
 {{- if eq .Values.global.environmentSize "size0" }}
    value: "1"
 {{- else }}
    value: "3"
 {{- end }}
{{- end -}}
