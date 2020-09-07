{{- /*
Creates the environment for the UI server
*/ -}}
{{- define "ibm-ea-asm-normalizer.mirrormaker.environment" -}}
  {{- $integrations := .Values.global.integrations -}}
  {{- $zookeeperUrlTemplate := "%s-zookeeper" -}}
  {{- $eaKafkaHost := include "ibm-ea-asm-normalizer.mirrormaker.eaKafkaHost" . -}}
  {{- $eaKafkaUrl := printf "%s:%s" $eaKafkaHost $integrations.analyticsKafka.port -}}
  {{- $eaZookeeperHost := include "ibm-ea-asm-normalizer.geturl" (list . $integrations.analyticsKafka.zookeeperHostname $integrations.analyticsKafka.releaseName $zookeeperUrlTemplate) -}}
  {{- $eaZookeeperUrl := printf "%s:%s" $eaZookeeperHost $integrations.analyticsKafka.zookeeperPort -}}
  {{- $asmKafkaHost := include "ibm-ea-asm-normalizer.mirrormaker.asmKafkaHost" . -}}
  {{- $asmKafkaUrl := printf "%s:%s" $asmKafkaHost $integrations.asm.kafkaPort -}}

env:
  - name: LICENSE
    value: {{ .Values.global.license | quote }}
  - name: LOGGING_LEVEL
    value: "INFO"
  - name: KAFKA_GROUP_ID
    value: {{ printf "%s-ea-asm-normalizer-service-mmaker" .Release.Name | quote }}
  - name: KAFKA_IN_HOST
    value: {{ $asmKafkaHost | quote }}
  - name: KAFKA_IN_BOOTSTRAP_SERVERS
    value: {{ $asmKafkaUrl | quote }}
  - name: KAFKA_OUT_HOST
    value: {{ $eaKafkaHost | quote }}
  - name: KAFKA_OUT_BOOTSTRAP_SERVERS
    value: {{ $eaKafkaUrl | quote }}
  - name: KAFKA_OUT_ZOOKEEPER_URL
    value: {{ $eaZookeeperUrl | quote }}
  - name: KAFKA_TOPIC_NAME
    value: {{ $integrations.asm.kafkaExternalStatusTopic | quote }}
  - name: KAFKA_EVENTS_TOPIC_NAME
    value: {{ .Values.topics.incomingEvents.name | quote }}
    
  - name: KAFKA_NOI_ZOOKEEPER_HOST
    value: {{ $eaZookeeperHost | quote }} 
  - name: KAFKA_NOI_ZOOKEEPER_PORT
    value: {{ $integrations.analyticsKafka.zookeeperPort  | quote }} 
  - name: KAFKA_SUBTOPO_EVENTS_TOPIC_NAME
    value: {{ .Values.topics.subTopoEvents.name | quote }}
  - name: KAFKA_SUBTOPO_PATH_TOPIC_NAME
    value: {{ .Values.topics.subTopoPath.name | quote }}
  - name: KAFKA_SUBTOP_TOPO_TOPIC_NAME
    value: {{ .Values.topics.subTopoTopo.name | quote }}     
  - name: ASM_ON_PREMS_SECURE_REMOTE
    value: {{ .Values.global.integrations.asm.onPremSecureRemote.enabled | quote }}
  {{- if .Values.global.integrations.asm.onPremSecureRemote.enabled }}
  - name: KAFKA_CLIENT_USERNAME
    valueFrom:
     secretKeyRef:
      name: "external-asm-kafka-client"
      key: username
  - name: KAFKA_CLIENT_PASSWORD
    valueFrom:
     secretKeyRef:
      name: "external-asm-kafka-client"
      key: password
  - name: KAFKA_PROXY_CLIENT_USERNAME
    valueFrom:
     secretKeyRef:
      name: "external-asm-proxy-client"
      key: username
  - name: KAFKA_PROXY_CLIENT_PASSWORD
    valueFrom:
     secretKeyRef:
      name: "external-asm-proxy-client"
      key: password
  - name: ASM_KAFKA_IN_HOSTNAME
    value: {{ .Values.global.integrations.asm.onPremSecureRemote.remoteHost | quote }}
  - name: ASM_KAFKA_IN_PORT
    value: {{ .Values.global.integrations.asm.onPremSecureRemote.remotePort | quote }}
  - name: CA_CERTIFICATE
    value: /opt/cacerts/asm-ca.crt
  - name: CA_KEY
    value: /opt/cacerts/asm-ca.key
  {{- end }}

{{- end -}}


{{- define "ibm-ea-asm-normalizer.mirrormaker.eaKafkaHost" -}}
  {{- $integrations := .Values.global.integrations -}}

  {{- $kafkaUrlTemplate := "%s-kafka" -}}
  {{- include "ibm-ea-asm-normalizer.geturl" (list . $integrations.analyticsKafka.hostname $integrations.analyticsKafka.releaseName $kafkaUrlTemplate) -}}
{{- end -}}


{{- define "ibm-ea-asm-normalizer.mirrormaker.asmKafkaHost" -}}
  {{- $integrations := .Values.global.integrations -}}

  {{- $kafkaUrlTemplate := "%s-kafka" -}}
  {{- include "ibm-ea-asm-normalizer.geturl" (list . $integrations.asm.kafkaHostname $integrations.asm.releaseName $kafkaUrlTemplate) -}}
{{- end -}}
