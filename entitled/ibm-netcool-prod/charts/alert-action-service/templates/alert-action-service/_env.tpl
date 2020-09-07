{{- include "sch.config.init" (list . "alert-action-service.sch.chart.config.values") -}}

{{- /*
Creates the environment for the UI server
*/ -}}
{{- define "alert-action-service.alertactionservice.environment" -}}


{{- $integrations := .Values.global.integrations -}}

{{- $kafkaRelease := include "alert-action-service.getKafkaRelease" (list . $integrations.analyticsKafka.releaseName) -}}

{{- $alertDetailsRelease := include "alert-action-service.getAlertDetailsRelease" (list . $integrations.alertDetails.releaseName) -}}


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
    value: {{ printf "%s-alert-action-service" $kafkaRelease | quote }}
  - name: KAFKA_HOST
    value: {{ $kafkaRelease }}-kafka
  - name: KAFKA_BOOTSTRAP_SERVERS
    value: {{ $kafkaRelease }}-kafka:9092
  - name: KAFKA_NOI_ACTIONS_TOPIC_NAME
    value: {{ .Values.topics.incomingActions.name | quote }}
  - name: KAFKA_NOI_REQUESTS_TOPIC_NAME
    value: {{ .Values.topics.outgoingRequests.name | quote }}
  - name: KAFKA_EA_ACTIONS_TOPIC_NAME
    value: {{ .Values.topics.outgoingEaActions.name | quote }}
  - name: KAFKA_STREAMS_MIN_ISR
    value: {{ include "alert-action-service.comp.size.data" (list . "alertactionservice" "kafkaMinInSyncReplicas") | quote }}
  - name: ALERT_DETAILS_HOSTNAME
    value: {{ $alertDetailsRelease }}-ibm-noi-alert-details-service
  - name: ALERT_DETAILS_PORT
    value: "5600"
  - name: ALERT_DETAILS_CONTEXT_ROOT
    value: "api/alert_details/v1/system"    
  - name: ALERT_DETAILS_USERNAME
    valueFrom:
      secretKeyRef:
        name: {{ $alertDetailsRelease }}-systemauth-secret
        key: username
  - name: ALERT_DETAILS_PASSWORD
    valueFrom:
      secretKeyRef:
        name: {{ $alertDetailsRelease }}-systemauth-secret
        key: password
  - name: KAFKA_STREAMS_REPLICATION_FACTOR
 {{- if eq .Values.global.environmentSize "size0" }}
    value: "1"
 {{- else }}
    value: "3"
 {{- end }}
{{- end -}}
