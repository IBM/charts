{{- include "sch.config.init" (list . "ibm-ea-asm-normalizer.sch.chart.config.values") -}}

{{- /*
Creates the environment for the UI server
*/ -}}
{{- define "ibm-ea-asm-normalizer.normalizerstreams.environment" -}}
{{- $integrations := .Values.global.integrations -}}
{{- $kafkaUrlTemplate := "%s-kafka" -}}

{{- $eaKafkaHost := include "ibm-ea-asm-normalizer.geturl" (list . $integrations.analyticsKafka.hostname $integrations.analyticsKafka.releaseName $kafkaUrlTemplate) -}}
{{- $eaKafkaUrl := printf "%s:%s" $eaKafkaHost $integrations.analyticsKafka.port -}}
{{- $asmKafkaHost := include "ibm-ea-asm-normalizer.geturl" (list . $integrations.asm.kafkaHostname $integrations.asm.releaseName $kafkaUrlTemplate) -}}
{{- $asmKafkaUrl := printf "%s:%s" $eaKafkaHost $integrations.asm.kafkaPort -}}

{{- $zookeeperUrlTemplate := "%s-zookeeper" -}}
{{- $eaZookeeperHost := include "ibm-ea-asm-normalizer.geturl" (list . $integrations.analyticsKafka.zookeeperHostname $integrations.analyticsKafka.releaseName $zookeeperUrlTemplate) -}}
{{- $eaZookeeperUrl := printf "%s:%s" $eaZookeeperHost $integrations.analyticsKafka.zookeeperPort -}}

env:
  - name: LICENSE
    value: {{ .Values.global.license | quote }}
  - name: LOGGING_LEVEL
    value: "INFO"
  - name: KAFKA_STREAM_APPLICATION_ID
    value: {{ printf "%s-ea-asm-normalizer-service" .Release.Name | quote }}
  - name: KAFKA_HOST
    value: {{ $eaKafkaHost | quote }}
  - name: KAFKA_BOOTSTRAP_SERVERS
    value: {{ $eaKafkaUrl | quote }}
  - name: KAFKA_EVENTS_TOPIC_NAME
    value: {{ .Values.topics.incomingEvents.name | quote }}
  - name: KAFKA_EVENTS_REKEYED_TOPIC_NAME
    value: {{ .Values.topics.incomingEventsRekeyed.name | quote }}
  - name: KAFKA_ASM_STATUS_TOPIC_NAME
    value: {{ $integrations.asm.kafkaExternalStatusTopic | quote }}
  - name: KAFKA_ASM_STATUS_REKEYED_TOPIC_NAME
    value: {{ .Values.topics.asmStatusRekeyed.name | quote }}
  - name: KAFKA_EVENTS_OUTPUT_TOPIC_NAME
    value: {{ .Values.topics.outgoingEvents.name | quote }}
  - name: KAFKA_STREAMS_JOIN_WINDOW_SIZE
    value: {{ .Values.joinWindowSize | quote }}
  - name: KAFKA_STREAMS_MIN_ISR
    value: {{ include "ibm-ea-asm-normalizer.comp.size.data" (list . "normalizerstreams" "kafkaMinInSyncReplicas") | quote }}
  - name: KAFKA_STREAMS_REPLICATION_FACTOR
    value: {{ include "ibm-ea-asm-normalizer.comp.size.data" (list . "normalizerstreams" "kafkaReplicationFactor") | quote }}
  - name: ZOOKEEPER_URL
    value: {{ $eaZookeeperUrl | quote }}
{{- end -}}
