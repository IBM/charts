{{- define "asm.containerSecurityContext" -}}
privileged: false
readOnlyRootFilesystem: false
allowPrivilegeEscalation: false
runAsNonRoot: true
runAsUser: 1000
capabilities:
  drop:
  - ALL
{{- end -}}

{{- define "asm.getImageRepo" -}}
{{- if .Values.global.image.repository -}}
{{- printf "%s" ( trimSuffix "/" .Values.global.image.repository ) }}
{{- end -}}
{{- end -}}


{{/*
Calculates the replication factor for Cassandra, based on environment size or
the number of Cassandra nodes, up to a maximum of three.
*/}}
{{- define "asm.cassandraReplicationFactor" -}}
  {{- if eq ( .Values.global.cassandraNodeReplicas | toString) "environmentSizeDefault" }}
    {{- if eq .Values.global.environmentSize "size0" }}
      {{- printf "%d" 1 }}
    {{- else -}}
      {{- printf "%d" 3 }}
    {{- end -}}
  {{- else -}}
    {{- $numBrokers := .Values.global.cassandraNodeReplicas -}}
    {{- if gt $numBrokers 3.0 -}}
      {{- printf "%d" 3 }}
    {{- else -}}
      {{- printf "%d" (int $numBrokers) }}
    {{- end -}}
  {{- end -}}
{{- end -}}


{{/*
Calculates the replication factor for Kafka, based on environment size or
the number of Kafka brokers, up to a maximum of three.
*/}}
{{- define "asm.kafkaReplicationFactor" -}}
  {{- if eq ( .Values.global.kafka.clusterSize | toString) "environmentSizeDefault" }}
    {{- if eq .Values.global.environmentSize "size0" }}
      {{- printf "%d" 1 }}
    {{- else -}}
      {{- printf "%d" 3 }}
    {{- end -}}
  {{- else -}}
    {{- $numBrokers := .Values.global.kafka.clusterSize -}}
    {{- if gt $numBrokers 3.0 -}}
      {{- printf "%d" 3 }}
    {{- else -}}
      {{- printf "%d" (int $numBrokers) }}
    {{- end -}}
  {{- end -}}
{{- end -}}


{{/*
Sets the resources required for helm test pods and initContainers
*/}}
{{- define "asm.minimalPodResources" -}}
requests:
  memory: "64Mi"
  cpu: "100m"
limits:
  memory: "64Mi"
  cpu: "100m"
{{- end -}}
