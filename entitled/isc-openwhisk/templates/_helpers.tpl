#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ibm-isc-openwhisk.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "openwhisk.fullname" -}}
{{- $name := default .Chart.Name -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* boilerplate labels */}}
{{- define "openwhisk.label_boilerplate" -}}
helm.sh/chart: {{ template "ibm-isc-openwhisk.chart" . }}
release: {{ .Release.Name }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
app.kubernetes.io/name: {{ .Release.Service }}
{{- end -}}

{{/* hostname for apigateway */}}
{{- define "openwhisk.apigw_host" -}}
{{ .Release.Name }}-apigateway.{{ .Release.Namespace }}.svc.{{ .Values.k8s.domain }}
{{- end -}}

{{/* hostname for controller */}}
{{- define "openwhisk.controller_host" -}}
{{ .Release.Name }}-controller.{{ .Release.Namespace }}.svc.{{ .Values.k8s.domain }}
{{- end -}}

{{/* hostname for database */}}
{{- define "openwhisk.db_host" -}}
{{- if .Values.db.external -}}
{{ .Values.db.host }}
{{- else -}}
{{ .Release.Name }}-couchdb.{{ .Release.Namespace }}.svc.{{ .Values.k8s.domain }}
{{- end -}}
{{- end -}}

{{/* hostname for redis */}}
{{- define "openwhisk.redis_host" -}}
{{ .Release.Name }}-redis.{{ .Release.Namespace }}.svc.{{ .Values.k8s.domain }}
{{- end -}}

{{/* client connection string for zookeeper cluster (server1:port,server2:port, ... serverN:port)*/}}
{{- define "openwhisk.zookeeper_connect" -}}
{{- $zkname := printf "%s-zookeeper" .Release.Name }}
{{- $zkport := .Values.zookeeper.port }}
{{- $kubeDomain := .Values.k8s.domain }}
{{- range $i, $e := until (int .Values.zookeeper.replicaCount) -}}{{ if ne $i 0 }},{{ end }}{{ $zkname }}-{{ . }}.{{ $zkname }}.{{ $.Release.Namespace }}.svc.{{ $kubeDomain }}:{{ $zkport }}{{ end }}
{{- end -}}

{{/* host name for server.0 in zookeeper cluster */}}
{{- define "openwhisk.zookeeper_zero_host" -}}
{{- $zkname := printf "%s-zookeeper" .Release.Name }}
{{ $zkname }}-0.{{ $zkname }}.{{ $.Release.Namespace }}.svc.{{ .Values.k8s.domain }}
{{- end -}}

{{/* client connection string for kafka cluster (server1:port,server2:port, ... serverN:port)*/}}
{{- define "openwhisk.kafka_connect" -}}
{{- $kname := printf "%s-kafka" .Release.Name }}
{{- $kport := .Values.kafka.port }}
{{- $kubeDomain := .Values.k8s.domain }}
{{- range $i, $e := until (int .Values.kafka.replicaCount) -}}{{ if ne $i 0 }},{{ end }}{{ $kname }}-{{ . }}.{{ $kname }}.{{ $.Release.Namespace }}.svc.{{ $kubeDomain }}:{{ $kport }}{{ end }}
{{- end -}}

{{/* host name for server.0 in kafka cluster */}}
{{- define "openwhisk.kafka_zero_host" -}}
{{- $kname := printf "%s-kafka" .Release.Name }}
{{ $kname }}-0.{{ $kname }}.{{ $.Release.Namespace }}.svc.{{ .Values.k8s.domain }}
{{- end -}}

{{/* Runtimes manifest */}}
{{- define "openwhisk.runtimes_manifest" -}}
{{ .Files.Get .Values.whisk.runtimes | quote }}
{{- end -}}

{{/* Whisk Config */}}
{{- define "openwhisk.whiskconfig" -}}
{{ .Files.Get .Values.metrics.whiskconfigFile | b64enc }}
{{- end -}}

{{/* Environment variables required for accessing CouchDB from a pod */}}
{{- define "openwhisk.dbEnvVars" -}}
- name: "CONFIG_whisk_couchdb_username"
  valueFrom:
    secretKeyRef:
      name: {{ .Values.db.secret }} 
      key: adminUsername
- name: "CONFIG_whisk_couchdb_password"
  valueFrom:
    secretKeyRef:
      name:  {{ .Values.db.secret }} 
      key: adminPassword
- name: "CONFIG_whisk_couchdb_port"
  valueFrom:
    configMapKeyRef:
      name: {{ .Release.Name }}-db.config
      key: db_port
- name: "CONFIG_whisk_couchdb_protocol"
  valueFrom:
    configMapKeyRef:
      name: {{ .Release.Name }}-db.config
      key: db_protocol
- name: "CONFIG_whisk_couchdb_host"
  value: {{ include "openwhisk.db_host" . | quote }}
- name: "CONFIG_whisk_couchdb_provider"
  valueFrom:
    configMapKeyRef:
      name: {{ .Release.Name }}-db.config
      key: db_provider
- name: "CONFIG_whisk_couchdb_databases_WhiskActivation"
  valueFrom:
    configMapKeyRef:
      name: {{ .Release.Name }}-db.config
      key: db_whisk_activations
- name: "CONFIG_whisk_couchdb_databases_WhiskEntity"
  valueFrom:
    configMapKeyRef:
      name: {{ .Release.Name }}-db.config
      key: db_whisk_actions
- name: "CONFIG_whisk_couchdb_databases_WhiskAuth"
  valueFrom:
    configMapKeyRef:
      name: {{ .Release.Name }}-db.config
      key: db_whisk_auths
{{- end -}}

{{/* Environment variables for specifying action limits */}}
{{- define "openwhisk.limitsEnvVars" -}}
- name: "LIMITS_ACTIONS_INVOKES_PERMINUTE"
  value: {{ .Values.whisk.limits.actionsInvokesPerminute | quote }}
- name: "LIMITS_ACTIONS_INVOKES_CONCURRENT"
  value: {{ .Values.whisk.limits.actionsInvokesConcurrent | quote }}
- name: "LIMITS_TRIGGERS_FIRES_PERMINUTE"
  value: {{ .Values.whisk.limits.triggersFiresPerminute | quote }}
- name: "LIMITS_ACTIONS_SEQUENCE_MAXLENGTH"
  value: {{ .Values.whisk.limits.actionsSequenceMaxlength | quote }}
- name: "CONFIG_whisk_timeLimit_min"
  value: {{ .Values.whisk.limits.actions.time.min | quote }}
- name: "CONFIG_whisk_timeLimit_max"
  value: {{ .Values.whisk.limits.actions.time.max | quote }}
- name: "CONFIG_whisk_timeLimit_std"
  value: {{ .Values.whisk.limits.actions.time.std | quote }}
- name: "CONFIG_whisk_memory_min"
  value: {{ .Values.whisk.limits.actions.memory.min | quote }}
- name: "CONFIG_whisk_memory_max"
  value: {{ .Values.whisk.limits.actions.memory.max | quote }}
- name: "CONFIG_whisk_memory_std"
  value: {{ .Values.whisk.limits.actions.memory.std | quote }}
- name: "CONFIG_whisk_concurrencyLimit_min"
  value: {{ .Values.whisk.limits.actions.concurrency.min | quote }}
- name: "CONFIG_whisk_concurrencyLimit_max"
  value: {{ .Values.whisk.limits.actions.concurrency.max | quote }}
- name: "CONFIG_whisk_concurrencyLimit_std"
  value: {{ .Values.whisk.limits.actions.concurrency.std | quote }}
- name: "CONFIG_whisk_logLimit_min"
  value: {{ .Values.whisk.limits.actions.log.min | quote }}
- name: "CONFIG_whisk_logLimit_max"
  value: {{ .Values.whisk.limits.actions.log.max | quote }}
- name: "CONFIG_whisk_logLimit_std"
  value: {{ .Values.whisk.limits.actions.log.std | quote }}
- name: "CONFIG_whisk_activation_payload_max"
  value: {{ .Values.whisk.limits.activation.payload.max | quote }}
{{- end -}}

{{/* Environment variables for configuring kafka topics */}}
{{- define "openwhisk.kafkaConfigEnvVars" -}}
- name: "CONFIG_whisk_kafka_replicationFactor"
  value: {{ .Values.whisk.kafka.replicationFactor | quote }}
- name: "CONFIG_whisk_kafka_topics_cacheInvalidation_retentionBytes"
  value: {{ .Values.whisk.kafka.topics.cacheInvalidation.retentionBytes | quote }}
- name: "CONFIG_whisk_kafka_topics_cacheInvalidation_retentionMs"
  value: {{ .Values.whisk.kafka.topics.cacheInvalidation.retentionMs | quote }}
- name: "CONFIG_whisk_kafka_topics_cacheInvalidation_segmentBytes"
  value: {{ .Values.whisk.kafka.topics.cacheInvalidation.segmentBytes | quote }}
- name: "CONFIG_whisk_kafka_topics_completed_retentionBytes"
  value: {{ .Values.whisk.kafka.topics.completed.retentionBytes | quote }}
- name: "CONFIG_whisk_kafka_topics_completed_retentionMs"
  value: {{ .Values.whisk.kafka.topics.completed.retentionMs | quote }}
- name: "CONFIG_whisk_kafka_topics_completed_segmentBytes"
  value: {{ .Values.whisk.kafka.topics.completed.segmentBytes | quote }}
- name: "CONFIG_whisk_kafka_topics_events_retentionBytes"
  value: {{ .Values.whisk.kafka.topics.events.retentionBytes | quote }}
- name: "CONFIG_whisk_kafka_topics_events_retentionMs"
  value: {{ .Values.whisk.kafka.topics.events.retentionMs | quote }}
- name: "CONFIG_whisk_kafka_topics_events_segmentBytes"
  value: {{ .Values.whisk.kafka.topics.events.segmentBytes | quote }}
- name: "CONFIG_whisk_kafka_topics_health_retentionBytes"
  value: {{ .Values.whisk.kafka.topics.health.retentionBytes | quote }}
- name: "CONFIG_whisk_kafka_topics_health_retentionMs"
  value: {{ .Values.whisk.kafka.topics.health.retentionMs | quote }}
- name: "CONFIG_whisk_kafka_topics_health_segmentBytes"
  value: {{ .Values.whisk.kafka.topics.health.segmentBytes | quote }}
- name: "CONFIG_whisk_kafka_topics_invoker_retentionBytes"
  value: {{ .Values.whisk.kafka.topics.invoker.retentionBytes | quote }}
- name: "CONFIG_whisk_kafka_topics_invoker_retentionMs"
  value: {{ .Values.whisk.kafka.topics.invoker.retentionMs | quote }}
- name: "CONFIG_whisk_kafka_topics_invoker_segmentBytes"
  value: {{ .Values.whisk.kafka.topics.invoker.segmentBytes | quote }}
{{- end -}}

{{/* tlssecretname for ingress */}}
{{- define "openwhisk.tls_secret_name" -}}
{{ .Values.whisk.ingress.tls.secretname | default "ow-ingress-tls-secret" | quote }}
{{- end -}}

{{/* Create imagePullSecrets for private docker-registry*/}}
{{- define "openwhisk.dockerRegistrySecret" -}}
{{- if ne .Values.docker.registry.name "" }}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" .Values.docker.registry.name (printf "%s:%s" .Values.docker.registry.username .Values.docker.registry.password | b64enc) | b64enc }}
{{- end }}
{{- end -}}

{{/* ImagePullSecrets in pods and job*/}}
{{- define "openwhisk.docker.imagePullSecrets" -}}
{{- if ne .Values.docker.registry.name "" }}
imagePullSecrets:
- name: {{ .Values.global.image.pullSecret }}
{{- end }}
{{- end -}}

{{/* Environment variables required for Lean OW configuration */}}
{{- define "openwhisk.lean.provider" -}}
{{- if .Values.controller.lean -}}
- name: "CONFIG_whisk_spi_MessagingProvider"
  value: "org.apache.openwhisk.connector.lean.LeanMessagingProvider"
- name: "CONFIG_whisk_spi_LoadBalancerProvider"
  value: "org.apache.openwhisk.core.loadBalancer.LeanBalancer"
{{- end -}}
{{- end -}}

{{/* Environment variables required for invoker API HOST configuration */}}
{{- define "openwhisk.invoker.apihost" -}}
- name: "WHISK_API_HOST_PROTO"
  valueFrom:
    configMapKeyRef:
      name: {{ .Release.Name }}-whisk.config
      key: whisk_api_host_proto
- name: "WHISK_API_HOST_PORT"
  valueFrom:
    configMapKeyRef:
      name: {{ .Release.Name }}-whisk.config
      key: whisk_api_host_port
- name: "WHISK_API_HOST_NAME"
  valueFrom:
    configMapKeyRef:
      name: {{ .Release.Name }}-whisk.config
      key: whisk_api_host_name
- name: "CONFIG_whisk_docker_containerFactory_useRunc"
  value: {{ .Values.invoker.containerFactory.useRunc | quote }}
- name: "CONFIG_whisk_containerPool_userMemory"
  value: {{ .Values.whisk.containerPool.userMemory | quote }}
{{- end -}}

{{/* Environment variables required for invoker volumes configuration */}}
{{- define "openwhisk.invoker.volumes" -}}
{{- if eq .Values.invoker.containerFactory.impl "docker" }}
      volumes:
{{ include "openwhisk.docker_volumes" . | indent 6 }}
      - name: scripts-dir
        configMap:
          name: {{ .Release.Name }}-invoker-scripts
{{- end }}
{{- end }}

{{/* Environment variables required for invoker volumes configuration */}}
{{- define "openwhisk.invoker.volume_mounts" -}}
{{- if (eq .Values.invoker.containerFactory.impl "docker") }}
        volumeMounts:
{{ include "openwhisk.docker_volume_mounts" . | indent 8 }}
{{- if .Values.invoker.containerFactory.networkConfig.dns.inheritInvokerConfig }}
        - name: scripts-dir
          mountPath: "/invoker-scripts/configureDNS.sh"
          subPath: "configureDNS.sh"
{{- end }}
{{- end }}
{{- end }}

{{/* invoker additional options */}}
{{- define "openwhisk.invoker.add_opts" -}}
{{- if eq .Values.invoker.containerFactory.impl "docker" -}}
-Dwhisk.spi.ContainerFactoryProvider=org.apache.openwhisk.core.containerpool.docker.DockerContainerFactoryProvider
{{- else -}}
-Dkubernetes.master=https://$KUBERNETES_SERVICE_HOST -Dwhisk.spi.ContainerFactoryProvider=org.apache.openwhisk.core.containerpool.kubernetes.KubernetesContainerFactoryProvider
{{- end -}}
{{- end -}}


{{- define "openwhisk.serviceAccountName" -}}
{{- printf "ibm-isc-application" -}} 
{{- end -}}

