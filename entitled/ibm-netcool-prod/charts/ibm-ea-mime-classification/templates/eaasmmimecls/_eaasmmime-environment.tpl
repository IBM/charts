{{- /*
Creates the environment for the UI server
*/ -}}
{{- define "ibm-ea-mime-classification.eaasmmimecls.environment" -}}
{{- $integrations := .Values.global.integrations -}}
{{- $kafkaUrlTemplate := "%s-kafka" -}}

{{- $eaKafkaHost := include "ibm-ea-mime-classification.geturl" (list . $integrations.analyticsKafka.hostname $integrations.analyticsKafka.releaseName $kafkaUrlTemplate) -}}
{{- $eaKafkaUrl := printf "%s:%s" $eaKafkaHost $integrations.analyticsKafka.port -}}
{{- $asmKafkaHost := include "ibm-ea-mime-classification.geturl" (list . $integrations.asm.kafkaHostname $integrations.asm.releaseName $kafkaUrlTemplate) -}}
{{- $asmKafkaUrl := printf "%s:%s" $eaKafkaHost $integrations.asm.kafkaPort -}}
{{- $eaCassandraPort := printf "%s"  $integrations.analyticsCassandra.port -}}

env:
  - name: LICENSE
    value: {{ .Values.global.license | quote }}
  - name: LOGGING_LEVEL
    value: "INFO"
  - name: CASSANDRA_HOST
    value: {{  printf "%s-cassandra" .Release.Name | quote }}

  - name: CASSANDRA_PORT
    value: {{ $eaCassandraPort| quote }}

  - name: MIME_BASIC_AUTH_USERNAME
    valueFrom:
     secretKeyRef:
      name: {{ printf "%s-mime-api-secret" .Release.Name | quote }}
      key: api_username

  - name: MIME_BASIC_AUTH_PASSWORD
    valueFrom:
     secretKeyRef:
      name: {{ printf "%s-mime-api-secret" .Release.Name | quote }}
      key: api_password

  - name: CASSANDRA_CLIENT_USERNAME
    valueFrom:
     secretKeyRef:
      name: {{ printf "%s-cassandra-auth-secret" .Release.Name | quote }}
      key: username

  - name: CASSANDRA_CLIENT_PASSWORD
    valueFrom:
     secretKeyRef:
      name: {{  printf "%s-cassandra-auth-secret" .Release.Name | quote }}
      key: password

  - name: KAFKA_HOST
    value: {{ $eaKafkaHost | quote }}
  - name: KAFKA_BOOTSTRAP_SERVERS
    value: {{ $eaKafkaUrl | quote }}
  - name: KAFKA_NOI_ZOOKEEPER_HOST
    value: {{ printf "%s-zookeeper" .Release.Name | quote }}
  - name: KAFKA_NOI_ZOOKEEPER_PORT
    value: {{ $integrations.analyticsKafka.zookeeperPort  | quote }}
  - name: KAFKA_CLS_TRAINING_MODEL_TOPIC
    value: {{ $integrations.analyticsKafka.classification.topics.trainingmodel | quote }}
  - name: KAFKA_MIME_APP_STATUS
    value: {{ $integrations.analyticsKafka.classification.topics.appstatus | quote }}
  - name: KAFKA_CLS_MODEL_TOPIC_GROUP_ID
    value: {{ $integrations.analyticsKafka.classification.topics.groupid | quote }}
  - name: CLASSIFICATION_REST_API_PORT
    value: {{ $integrations.analyticsKafka.classification.restapi.port| quote }}
  - name: CLASSIFICATION_MODEL_TRAINING_TIME_OUT
    value: {{ $integrations.analyticsKafka.classification.model.timeout| quote }}
  - name: MIME_DEV_DEBUG_MODE
    value: {{ $integrations.analyticsKafka.classification.service.devdebug| quote }}
  - name: MIME_SWAGGER_SPECS_PROTOCOL_HTTPS
    value: {{ $integrations.analyticsKafka.classification.service.swaggerprotocol| quote }}    
{{- end -}}
