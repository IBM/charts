{{- /*
Creates the environment for the UI server
*/ -}}
{{- define "ibm-ea-asm-mime.eaasmmime.environment" -}}
{{- $integrations := .Values.global.integrations -}}
{{- $kafkaUrlTemplate := "%s-kafka" -}}

{{- $eaKafkaHost := include "ibm-ea-asm-mime.geturl" (list . $integrations.analyticsKafka.hostname $integrations.analyticsKafka.releaseName $kafkaUrlTemplate) -}}
{{- $eaKafkaUrl := printf "%s:%s" $eaKafkaHost $integrations.analyticsKafka.port -}}
{{- $asmKafkaHost := include "ibm-ea-asm-mime.geturl" (list . $integrations.asm.kafkaHostname $integrations.asm.releaseName $kafkaUrlTemplate) -}}
{{- $asmKafkaUrl := printf "%s:%s" $eaKafkaHost $integrations.asm.kafkaPort -}}
{{- $eaCassandraPort := printf "%s"  $integrations.analyticsCassandra.port -}}
{{- $asmSecretTemplate := "%s-asm-credentials" -}}
{{- $asmuiapiUrlTemplate := "https://%s-topology" -}}
{{- $asmuiapiPort := "8080" -}}
{{- $userinfoTemplate := "{{ .releaseName }}-ibm-cem-cem-users.{{ .namespace }}.svc:6002/users/api/usermgmt/v1/userinfo" -}}

env:
  - name: LICENSE
    value: {{ .Values.global.license | quote }}
  - name: LOGGING_LEVEL
    value: "INFO"
  - name: MIME_DEBUG_LEVEL
    value: "INFO"
  - name: EVENT_CLASS_HOST
    value: {{ printf "%s-ibm-ea-mime-classification-eaasmmimecls" .Release.Name| quote }}
  - name: KAFKA_STREAM_APPLICATION_ID
    value: {{ printf "%s-ea-asm-mime" .Release.Name | quote }}
  - name: KAFKA_HOST
    value: {{ $eaKafkaHost | quote }}
  - name: KAFKA_SERVICE_HOST
    value: {{ .Release.Name }}-kafka
  - name: KAFKA_SERVICE_PORT_KAFKAREST
    value: "8080"
  - name: KAFKA_TOPIC_REPLICAS
    value: {{ include "ibm-ea-asm-mime.comp.size.data" (list . "eaasmmime" "kafkaReplicationFactor") | quote }}
  - name: KAFKA_BOOTSTRAP_SERVERS
    value: {{ $eaKafkaUrl | quote }}
  - name: KAFKA_BROKERS_SASL_BROKERS
    value: {{ $eaKafkaUrl | quote }}
  - name: KAFKA_EVENTS_TOPIC_NAME
    value: {{ .Values.topics.incomingEvents.name | quote }}
  - name: KAFKA_EVENTS_OUTPUT_TOPIC_NAME
    value: {{ .Values.topics.outgoingEvents.name | quote }}
  - name: KAFKA_NOI_ZOOKEEPER_HOST
    value: {{ printf "%s-zookeeper" .Release.Name | quote }}
  - name: KAFKA_NOI_ZOOKEEPER_PORT
    value: {{ $integrations.analyticsKafka.zookeeperPort  | quote }}
  - name: KAFKA_SUBTOPO_EVENTS_TOPIC_NAME
    value: {{ .Values.topics.subTopoEvents.name | quote }}
  - name: KAFKA_SUBTOPO_PATH_TOPIC_NAME
    value: {{ .Values.topics.subTopoPath.name | quote }}
  - name: KAFKA_SUBTOP_TOPO_TOPIC_NAME
    value: {{ .Values.topics.subTopoTopo.name | quote }}
  - name: KAFKA_STREAMS_JOIN_WINDOW_SIZE
    value: {{ .Values.joinWindowSize | quote }}
  - name: ASM_HOST
    value: {{ $integrations.asm.asmHostName | quote }}
  - name: ASM_PORT
    value: {{ $integrations.asm.asmPortName | quote }}
  - name: ASM_ON_PREM
    value: {{ $integrations.asm.onPremSecureRemote.enabled | quote}}
  - name: ASM_CA_CERTIFICATE
    value: /opt/cacerts/asm-ca.crt
  - name: ASM_ON_PREM_SECURITY_PROTOCOL
    value: TLSv1.2
  - name: ASM_API_URL
  {{ if and $integrations.asm.enabled $integrations.asm.onPremSecureRemote.enabled }}
    value: {{ ( printf "%s"  $integrations.asm.onPremSecureRemote.remoteHost ) | quote }}
  {{ else }}
    value: {{ printf "%s-topology" $integrations.asm.releaseName | quote }}
  {{ end }}
  - name: ASM_API_PORT
  {{ if and $integrations.asm.enabled $integrations.asm.onPremSecureRemote.enabled }}
    value: {{ ( printf "%s"  $integrations.asm.onPremSecureRemote.uiApiPort ) | quote }}
  {{ else }}
    value: {{ ( printf "%s"  $asmuiapiPort ) | quote }}
  {{ end }}

{{ if or $integrations.asm.useDefaultAsmCredentialsSecret $integrations.asm.asmCredentialsSecret }}
  - name: ASM_API_USERNAME
    valueFrom:
      secretKeyRef:
      {{ if and $integrations.asm.enabled $integrations.asm.onPremSecureRemote.enabled }}
        name: "external-asm-proxy-client"
      {{ else }}
        name: {{ include "ibm-ea-asm-mime.geturl" (list . $integrations.asm.asmCredentialsSecret $integrations.asm.releaseName $asmSecretTemplate) | quote }}
      {{ end }}
        key: username
        optional: false
  - name: ASM_API_PASSWORD
    valueFrom:
      secretKeyRef:
      {{ if and $integrations.asm.enabled $integrations.asm.onPremSecureRemote.enabled }}
        name: "external-asm-proxy-client"
      {{ else }}
        name: {{ include "ibm-ea-asm-mime.geturl" (list . $integrations.asm.asmCredentialsSecret $integrations.asm.releaseName $asmSecretTemplate) | quote }}
      {{ end }}
        key: password
        optional: false
{{ end }}

  - name: CASSANDRA_HOST
    value: {{ printf "%s-cassandra" .Release.Name | quote }}
  - name: CASSANDRA_PORT
    value: {{ $eaCassandraPort | quote }}
  - name: CASSANDRA_CLIENT_USERNAME
    valueFrom:
     secretKeyRef:
      name: {{ printf "%s-cassandra-auth-secret" .Release.Name | quote }}
      key: username
  - name: CASSANDRA_CLIENT_PASSWORD
    valueFrom:
     secretKeyRef:
      name: {{ printf "%s-cassandra-auth-secret" .Release.Name | quote }}
      key: password

{{ include "ibm-ea-asm-mime.getCemusersUrl" (list . "AUTH_CEMUSERS_USERINFO_ENDPOINT" $integrations.users.releaseName $integrations.users.namespace $integrations.users.config.userInfoTenant) | indent 2 }}
  - name: MIME_AUTH_ENABLED
    value: {{ $.Values.authentication.enabled | quote }}
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

  - name: MIME_GROUPS_CHECK_INITIAL_DELAY_SECONDS
    value: {{ .Values.probableCause.groupsApiInitialCacheCheckDelaySeconds | quote }}
  - name: MIME_GROUPS_INVALIDATE_CACHE_OLDER_THAN_SECONDS
    value: {{ .Values.probableCause.groupsApiDeleteCacheOlderThanSeconds | quote }}
  - name: MIME_GROUPS_CHECK_PERIOD_SECONDS
    value: {{ .Values.probableCause.groupsApiInvalidCacheCheckPeriodSeconds | quote }}
{{- end -}}
