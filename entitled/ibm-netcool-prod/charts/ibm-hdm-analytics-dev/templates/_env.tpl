{{/* vim: set filetype=mustache: */}}
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

{{- define "eventanalytics.iproto" }}
{{- if .Values.global.internalTLS.enabled -}}
https
{{- else -}}
http
{{- end }}
{{- end }}

{{- define "eventanalytics.eaingestionservice.application" -}}
- name: API_AUTHSCHEME_TYPE
  value: "statickey"
- name: API_AUTHSCHEME_STATICKEY_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-systemauth-secret
      key: username
- name: API_AUTHSCHEME_STATICKEY_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-systemauth-secret
      key: password
- name: API_AUTHSCHEME_STATICKEY_TENANTID
  value: {{ .Values.global.common.eventanalytics.tenantId | quote }}
- name: PORT
  value: {{ .Values.common.restApi.port | quote }}
- name: SSL_APP_PORT
  value: {{ .Values.common.restApi.portSsl | quote }}
- name: NODE_ENV
  value: "production"
- name: NODE_TLS_REJECT_UNAUTHORIZED
  value: "0"
- name: LOG_LEVEL
  value: {{ .Values.ingestionservice.logLevel | quote }}
- name: EVENTS_TOPIC
  value: {{ .Values.common.topics.events.name | quote }}
- name: PRODUCER_ID
  value: {{ .Release.Name }}/ingestionservice
{{- if .Values.ingestionservice.swagger.enabled }}
- name: ENABLE_SWAGGER_UI
  value: "1"
{{ end }}
{{- if .Values.ingestionservice.payloadSizeLimit }}
- name: PAYLOAD_SIZE_LIMIT
  value: {{ (int .Values.ingestionservice.payloadSizeLimit) | quote }}
{{ end }}
{{- end -}}

{{- define "eventanalytics.eaarchivingservice.application" -}}
- name: PORT
  value: {{ .Values.common.restApi.port | quote }}
- name: SSL_APP_PORT
  value: {{ .Values.common.restApi.portSsl | quote }}
- name: NODE_ENV
  value: "production"
- name: NODE_TLS_REJECT_UNAUTHORIZED
  value: "0"
- name: LOG_LEVEL
  value: {{ .Values.archivingservice.logLevel | quote }}
- name: EVENTS_TOPIC
  value: {{ .Values.common.topics.events.name | quote }}
- name: CONSUMER_ID
  value: {{ .Release.Name }}/archivingservice
- name: EVENTS_TTL_SECONDS
  value: {{  (int .Values.archivingservice.eventTTL) | default (int 7776000) | quote }}
{{- end -}}

{{- define "eventanalytics.inferenceservice.application" -}}
- name: INFERENCE_XMS
  value: '1G'
- name: INFERENCE_XMX
  value: '2G'
- name: LOGGING_LEVEL
  value: "INFO"
- name: BATCHING_SIZE
  value: "200"
- name: BATCHING_TIME_SECS
  value: "1"
- name: EVENTS_TOPIC
  value: {{ .Values.common.topics.events.name | quote }}
- name: EVENTS_TOPIC_ENABLED
  value: {{ .Values.common.topics.events.enabled | quote }}
- name: ACTIONS_TOPIC
  value: {{ .Values.common.topics.eventactions.name | quote }}
- name: ACTIONS_TOPIC_ENABLED
  value: {{ .Values.common.topics.eventactions.enabled | quote }}
- name: METRICS_TOPIC
  value: {{ .Values.common.topics.metrics.name | quote }}
- name: METRICS_TOPIC_ENABLED
  value: {{ .Values.common.topics.metrics.enabled | quote }}
- name: BASELINE_TOPIC
  value: {{ .Values.common.topics.baseline.name | quote }}
- name: BASELINE_TOPIC_ENABLED
  value: {{ .Values.common.topics.baseline.enabled | quote }}
- name: BASELINE_PERSISTENCE_TOPIC
  value: {{ .Values.common.topics.baselinePersistence.name | quote }}
- name: BASELINE_PERSISTENCE_TOPIC_ENABLED
  value: {{ .Values.common.topics.baselinePersistence.enabled | quote }}
- name: ASM_MESSAGE_TOPIC
  value: {{ .Values.common.topics.asmMessages.name | quote }}
- name: ASM_MESSAGE_TOPIC_ENABLED
  value: {{ .Values.common.topics.asmMessages.enabled | quote }}
- name: KAFKA_URL
  value: {{ .Release.Name }}-kafka:9092
- name: KAFKA_CONSUMER_THREADS
  value: '1'
- name: KAFKA_SERVICE_HOST
  value: "{{ .Release.Name }}-kafka"
- name: KAFKA_SERVICE_PORT_KAFKAREST
  value: "8080"
- name: REGISTRY_PORT
  value: {{ .Values.common.restApi.port | quote }}
- name: REGISTRY_URL
  value: "policies/event"
- name: REGISTRY_CONTEXT_ROOT
  value: "api/policies/system/v1"
- name: REGISTRY_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-systemauth-secret
      key: username
- name: REGISTRY_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-systemauth-secret
      key: password
- name: EXEC_OPTS_ANALYTICS
  value: "-Xdebug -Xrunjdwp:server=y,transport=dt_socket,address=4013,suspend=n -Xgcthreads2 -verbose:gc -Xverbosegclog:/statusip/logs/ANALYTICS_APP_gc_%Y%m%d.%H%M%S.%pid.log"
- name: EXPECTED_EVENT_ID
  value: {{ .Values.inference.expectedEventId | quote }}
{{- end -}}

{{- define "eventanalytics.trainerservice.application" -}}
- name: TRAINING_XMS
  value: '1G'
- name: TRAINING_XMX
  value: '2G'
- name: TRAINER_PORT
  value: {{ .Values.trainer.port | quote }}
- name: TRAINING_CONSOLE_THRESHOLD
  value: 'INFO'
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
- name: RE_POLICY_DEPLOYED_STATUS
  value: {{ .Values.common.temporalGroupingDeployFirst | quote }}
- name: SE_POLICY_DEPLOYED_STATUS
  value: {{ .Values.common.seasonalityDeployFirst | quote }}
- name: SPARK_MASTER_HOST
  value: {{ .Release.Name }}-spark-master
- name: SPARK_MASTER_CLUSTERMODE_PORT
  value: "6066"
- name: REGISTRY_PORT
  value: {{ .Values.common.restApi.port | quote }}
- name: REGISTRY_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-systemauth-secret
      key: username
- name: REGISTRY_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-systemauth-secret
      key: password
- name: METRIC_SERVICE_HOST
  value: {{ .Release.Name }}-metric
- name: METRIC_SERVICE_PORT
  value: '9080'
- name: BASELINE_CONFIG_SERVICE_HOST
  value: {{ .Release.Name }}-baselineconfiguration
- name: BASELINE_CONFIG_SERVICE_PORT
  value: '80'
{{- if  eq .Values.global.environmentSize  "size0" }}
- name: RE_EXECUTOR_MEMORY
  value: "2048M"
- name: RE_DRIVER_MEMORY
  value: "512M"
- name: RE_DRIVER_OPTS
  value: "-Xdisableexplicitgc -Xgcthreads1 -Xms256M"
- name: RE_EXEC_OPTS
  value: "-Xdisableexplicitgc -Xgcthreads1 -Xms1024M -XX:MaxDirectMemorySize=512M"
- name: SEAS_EXECUTOR_MEMORY
  value: "1024M"
- name: SEAS_DRIVER_MEMORY
  value: "512M"
- name: SEAS_DRIVER_CORES
  value: "1"
- name: SEAS_DRIVER_OPTS
  value: "-Xdisableexplicitgc -Xgcthreads1 -Xms256M"
- name: SEAS_EXEC_OPTS
  value: "-Xdisableexplicitgc -Xgcthreads1 -Xms1024M -XX:MaxDirectMemorySize=512M"
{{- else if eq .Values.global.environmentSize "size1" }}
- name: RE_EXECUTOR_MEMORY
  value: "6144M"
- name: RE_DRIVER_MEMORY
  value: "1024M"
- name: RE_DRIVER_OPTS
  value: "-Xdisableexplicitgc -Xgcthreads4 -Xms512M"
- name: RE_EXEC_OPTS
  value: "-Xdisableexplicitgc -Xgcthreads4 -Xms4096M -XX:MaxDirectMemorySize=512M"
- name: SEAS_EXECUTOR_MEMORY
  value: "4096M"
- name: SEAS_DRIVER_MEMORY
  value: "1024M"
- name: SEAS_DRIVER_CORES
  value: "1"
- name: SEAS_DRIVER_OPTS
  value: "-Xdisableexplicitgc -Xgcthreads4 -Xms512M"
- name: SEAS_EXEC_OPTS
  value: "-Xdisableexplicitgc -Xgcthreads4 -Xms2048M -XX:MaxDirectMemorySize=512M"
{{- else }}
- name: RE_EXECUTOR_MEMORY
  value: "1024M"
- name: RE_DRIVER_MEMORY
  value: "512M"
- name: RE_DRIVER_OPTS
  value: "-Xdisableexplicitgc -Xgcthreads1 -Xms256M"
- name: RE_EXEC_OPTS
  value: "-Xdisableexplicitgc -Xgcthreads1 -Xms1024M -XX:MaxDirectMemorySize=512M"
- name: SEAS_EXECUTOR_MEMORY
  value: "1024M"
- name: SEAS_DRIVER_MEMORY
  value: "512M"
- name: SEAS_DRIVER_CORES
  value: "1"
- name: SEAS_DRIVER_OPTS
  value: "-Xdisableexplicitgc -Xgcthreads1 -Xms256M"
- name: SEAS_EXEC_OPTS
  value: "-Xdisableexplicitgc -Xgcthreads1 -Xms1024M -XX:MaxDirectMemorySize=512M"
{{ end }}
{{- end -}}

{{- define "eventanalytics.eapolicyregistryservice.application" -}}
- name: PORT
  value: {{ .Values.common.restApi.port | quote }}
- name: SSL_APP_PORT
  value: {{ .Values.common.restApi.portSsl | quote }}
- name: NODE_ENV
  value: "production"
- name: NODE_TLS_REJECT_UNAUTHORIZED
  value: "0"
- name: LOG_LEVEL
  value: {{ .Values.policyregistryservice.logLevel | quote }}
- name: SYSTEMAUTH_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-systemauth-secret
      key: username
- name: SYSTEMAUTH_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-systemauth-secret
      key: password
{{- if .Values.policyregistryservice.swagger.enabled }}
- name: ENABLE_SWAGGER_UI
  value: "1"
{{ end }}
{{- if .Values.policyregistryservice.payloadSizeLimit }}
- name: PAYLOAD_SIZE_LIMIT
  value: {{ (int .Values.policyregistryservice.payloadSizeLimit) | quote }}
{{ end }}
{{- end -}}

{{- define "eventanalytics.eaeventsqueryservice.application" -}}
- name: PORT
  value: {{ .Values.common.restApi.port | quote }}
- name: SSL_APP_PORT
  value: {{ .Values.common.restApi.portSsl | quote }}
- name: NODE_ENV
  value: "production"
- name: NODE_TLS_REJECT_UNAUTHORIZED
  value: "0"
- name: LOG_LEVEL
  value: {{ .Values.eventsqueryservice.logLevel | quote }}
{{- if .Values.eventsqueryservice.swagger.enabled }}
- name: ENABLE_SWAGGER_UI
  value: "1"
{{ end }}
{{- if .Values.eventsqueryservice.payloadSizeLimit }}
- name: PAYLOAD_SIZE_LIMIT
  value: {{ (int .Values.eventsqueryservice.payloadSizeLimit) | quote }}
{{ end }}
{{- end -}}

{{- define "eventanalytics.easervicemonitorservice.application" -}}
- name: PORT
  value: {{ .Values.common.restApi.port | quote }}
- name: SSL_APP_PORT
  value: {{ .Values.common.restApi.portSsl | quote }}
- name: NODE_ENV
  value: "production"
- name: NODE_TLS_REJECT_UNAUTHORIZED
  value: "0"
- name: LOG_LEVEL
  value: {{ .Values.servicemonitorservice.logLevel | quote }}
- name: EA_SERVICE_MONITOR_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-systemauth-secret
      key: username
- name: EA_SERVICE_MONITOR_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-systemauth-secret
      key: password
- name: EA_SERVICE_MONITOR_ENDPOINTS
  value:
{{- print " '{" }}
{{- $local := dict "ofirst" true -}}
{{- $port := .Values.common.restApi.port -}}
{{- $tport := .Values.trainer.port -}}
{{- $iport := .Values.inference.port -}}
{{- $root := . -}}
{{- range $value := .Values.servicemonitorservice.services }}
  {{- if not $local.ofirst }}{{- printf "," }}{{- else }}{{- $_ := set $local "ofirst" false }}{{- end }}
  {{- $deploymentName := include "sch.names.fullCompName" (list $root $value) -}}
  {{ if eq $value "trainer" }}
    {{- printf "\"%s\": \"http://%s:%d/1.0/training/servicemonitor\"" $value $deploymentName (int $tport) }}
  {{ else if eq $value "inferenceservice" }}
    {{- printf "\"%s\": \"http://%s:%d/servicemonitor\"" $value $deploymentName (int $iport) }}
  {{ else }}
    {{- printf "\"%s\": \"http://%s:%d/servicemonitor\"" $value $deploymentName (int $port) }}
  {{ end }}
{{- end }}
{{- print "}'\n" }}
{{- if .Values.servicemonitorservice.swagger.enabled }}
- name: ENABLE_SWAGGER_UI
  value: "1"
{{ end }}
{{- end -}}

{{- define "eventanalytics.common.license" -}}
- name: LICENSE
  value: {{ .Values.global.license | quote }}
{{- end -}}

{{- define "eventanalytics.common.dropwizard" -}}
- name: LOG_FOLDER
  value: "/statusip/logs"
{{- end -}}

{{- define "eventanalytics.common.authentication" -}}
- name: API_AUTHSCHEME_TYPE
  value: {{ .Values.common.authentication.scheme | quote }}
  {{- if eq .Values.common.authentication.scheme "noiusers" }}
- name: API_AUTHSCHEME_NOIUSERS_TENANTID
  value: {{ .Values.global.common.eventanalytics.tenantId | quote }}
  {{- end }}
  {{- if eq .Values.common.authentication.scheme "statickey" }}
- name: API_AUTHSCHEME_NOIUSERS_TENANTID
  value: {{ .Values.global.common.eventanalytics.tenantId | quote }}
- name: API_AUTHSCHEME_STATICKEY_USERNAME
  valueFrom:
    secretKeyRef:
      name: '{{ .Release.Name }}-statickey-secret'
      key: username
- name: API_AUTHSCHEME_STATICKEY_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ .Release.Name }}-statickey-secret'
      key: password
  {{- end }}
{{- end -}}

{{- define "eventanalytics.common.cassandra" }}
- name: CASSANDRA_AUTH_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-cassandra-auth-secret
      key: username
- name: CASSANDRA_AUTH_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-cassandra-auth-secret
      key: password
- name: CASSANDRA_SECURED
  value: 'false'
- name: CASSANDRA_CONTACT_POINTS
  value: {{ .Release.Name }}-cassandra
- name: CASSANDRA_SSL_OPTION_VALS
  value: '{}'
- name: CASSANDRA_POLICIES
  value: '{"reconnection":{"baseDelay":1000,"maxDelay":60000,"startWithNoDelay":false}}'
{{- end -}}

{{- define "eventanalytics.common.cassandra.events" -}}
- name: CASSANDRA_KEYSPACE
  value: {{ .Values.common.keyspaces.events.name | quote }}
- name: CASSANDRA_REPLICATION_FACTOR
  value: {{ .Values.common.keyspaces.events.replicationFactor | quote }}
{{- end -}}

{{- define "eventanalytics.common.cassandra.policies" -}}
- name: CASSANDRA_KEYSPACE
  value: {{ .Values.common.keyspaces.policies.name | quote }}
- name: CASSANDRA_REPLICATION_FACTOR
  value: {{ .Values.common.keyspaces.policies.replicationFactor | quote }}
{{- end -}}

{{- define "eventanalytics.common.kafka" -}}
- name: KAFKA_INIT_TOPICS
  value: '{{ .Values.kafka.topics.initialise }}'
- name: KAFKA_ENABLED
  value: '{{ .Values.kafka.enabled }}'
- name: KAFKA_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ tpl .Values.global.kafka.clientUserSecret . }}
      key: username
- name: KAFKA_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ tpl .Values.global.kafka.clientUserSecret . }}
      key: password
- name: KAFKA_SECURED
  value: '{{ not .Values.global.kafka.allowInsecure }}'
- name: KAFKA_SSL_CA_LOCATION
  value: /etc/keystore/ca-cert
- name: KAFKA_SSL_CERT_LOCATION
  value: /etc/keystore/client.pem
- name: KAFKA_SSL_KEY_LOCATION
  value: /etc/keystore/client.key
- name: KAFKA_SSL_KEY_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ tpl .Values.kafka.adminUserSecret . }}
      key: password
- name: KAFKA_ADMIN_URL
  value: 'http://{{ .Release.Name }}-kafka:8080'
- name: KAFKA_BROKERS_SASL_BROKERS2
  value: '{{ .Release.Name }}-kafka:9092'
- name: KAFKA_TOPIC_PARTITIONS
  value: "6"
- name: KAFKA_TOPIC_REPLICAS
  {{- if eq .Values.global.environmentSize "size0" }}
  value: "1"
  {{- else }}
  value: "3"
  {{- end }}
- name: KAFKA_TOPIC_CONFIG
  value: "retention.ms=3600000"
- name: KAFKA_TOPICS
  value: '[]'
- name: MH_MQLIGHT_LOOKUP_URL
  value: 'https://mqlight-lookup-prod01.messagehub.services.us-south.bluemix.net/Lookup?serviceId=INSTANCE_ID'
- name: MH_BROKERS_SASL_BROKERS
  value: 'kafka04-prod01.messagehub.services.us-south.bluemix.net:9093,kafka01-prod01.messagehub.services.us-south.bluemix.net:9093,kafka03-prod01.messagehub.services.us-south.bluemix.net:9093,kafka02-prod01.messagehub.services.us-south.bluemix.net:9093,kafka05-prod01.messagehub.services.us-south.bluemix.net:9093'
- name: MH_USERNAME
  value: none
- name: MH_PASSWORD
  value: none
- name: MH_API_KEY
  value: none
- name: MH_ADMIN_URL
  value: 'https://kafka-admin-prod01.messagehub.services.us-south.bluemix.net:443'
- name: MH_REST_URL
  value: 'https://kafka-rest-prod01.messagehub.services.us-south.bluemix.net:443'
{{- end -}}

{{- define "eventanalytics.common.defaults" -}}
- name: ENV_ICP
  value: 'true'
- name: LOGMET_LOG_HOST
  value: logs.opvis.bluemix.net
- name: LOGMET_LOG_PORT
  value: '9091'
- name: LOGMET_LOG_TOKEN
  value: ''
- name: LOGMET_LOG_SPACE
  value: 00000000-0000-0000-0000-000000000000
- name: LOGMET_LOG_ENABLE
  value: 'false'
- name: LOGMET_METRICS_ENABLE
  value: 'false'
- name: LOGMET_METRICS_HOST
  value: metrics.ng.bluemix.net
- name: LOGMET_METRICS_PORT
  value: '9095'
- name: LOGMET_METRICS_TOKEN
  value: ''
- name: LOGMET_METRICS_SPACE
  value: 00000000-0000-0000-0000-000000000000
- name: LOGMET_METRICS_PREFIX
  value: ''
- name: LOGMET_METRICS_ENABLE_NODEOBSERVER
  value: 'true'
- name: COMMON_SERVICEMONITOR_RETRY_INTERVAL
  value: '60'
- name: COMMON_SERVICEMONITOR_EVENTSINK0_ENABLED
  value: 'false'
- name: COMMON_SERVICEMONITOR_EVENTSINK0_URL
  value: 'https://dummyUrl'
- name: COMMON_SERVICEMONITOR_EVENTSINK0_NAME
  value: APIKEYNAME
- name: COMMON_SERVICEMONITOR_EVENTSINK0_PASSWORD
  value: PASSWORD
- name: COMMON_SERVICEMONITOR_EVENTSINK1_ENABLED
  value: 'false'
- name: COMMON_SERVICEMONITOR_EVENTSINK1_URL
  value: 'https://dummyUrl'
- name: COMMON_SERVICEMONITOR_EVENTSINK1_NAME
  value: APIKEYNAME
- name: COMMON_SERVICEMONITOR_EVENTSINK1_PASSWORD
  value: PASSWORD
- name: COMMON_SERVICEMONITOR_EVENTSINK2_ENABLED
  value: 'false'
- name: COMMON_SERVICEMONITOR_EVENTSINK2_URL
  value: 'https://dummyUrl'
- name: COMMON_SERVICEMONITOR_EVENTSINK2_NAME
  value: APIKEYNAME
- name: COMMON_SERVICEMONITOR_EVENTSINK2_PASSWORD
  value: PASSWORD
- name: CIRCUITBREAKER_TRIP_LIMIT
  value: '1000000'
- name: CIRCUITBREAKER_RESET_TIME
  value: '1'
- name: SYSLOG_TARGETS
  value: '[]'
- name: BROKERS_URL
  value: 'https://dummyUrl'
- name: UISERVER_URL
  value: 'https://dummyUrl'
- name: EVENTPREPROCESSOR_URL
  value: 'https://dummyUrl'
- name: INCIDENTPROCESSOR_URL
  value: 'https://dummyUrl'
- name: NORMALIZER_URL
  value: 'https://dummyUrl'
- name: INTEGRATIONCONTROLLER_URL
  value: 'https://dummyUrl'
- name: ALERTNOTIFICATION_URL
  value: 'https://dummyUrl'
- name: RBA_URL
  value: 'https://dummyUrl'
- name: APMUI_URL
  value: 'https://dummyUrl'
- name: CEMAPI_URL
  value: 'https://dummyUrl'
- name: FRAMEANCESTORS_URL
  value: 'https://dummyUrl'
- name: METRICREST_URL
  value: 'https://dummyUrl'
- name: NOTIFICATIONPROCESSOR_URL
  value: 'https://dummyUrl'
- name: SCHEDULINGUI_URL
  value: 'https://dummyUrl'
- name: UAG_URL
  value: {{ if .Values.global.isIcamDeployment }}
    {{ include "eventanalytics.iproto" .}}://{{ .Release.Name }}-ibm-cem-cem-users.{{ .Release.Namespace }}.svc:6002/
  {{- else -}}
    {{ .Values.common.services.uagUrl }}
  {{- end}}
- name: NOI_DASH_AUTH_SERVLET_URL
  value: {{ if .Values.common.services.noiDashAuthUrl -}}
    {{ .Values.common.services.noiDashAuthUrl | quote }}
  {{- else -}}
    https://{{ .Release.Name }}-webgui:16311
  {{- end }}
{{- end -}}

{{- define "eventanalytics.common.redis" -}}
- name: REDIS_SENTINEL_HOST
  value: '{{ .Release.Name }}-ibm-redis-sentinel-svc.{{ .Release.Namespace }}.svc'
- name: REDIS_SENTINEL_PORT
  value: '26379'
- name: REDIS_SENTINEL_NAME
  value: 'mymaster'
- name: REDIS_CONNECT_SENTINELS
  value: 'false'
- name: REDIS_DST_HOST
  value: '{{ .Release.Name }}-ibm-redis-master-svc.{{ .Release.Namespace }}.svc'
- name: REDIS_DESTINATIONS
  value: '[]'
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ default (nospace (cat .Release.Name "-ibm-redis-authsecret")) (tpl .Values.ibmRedis.auth.authSecretName .) }}
      key: password
- name: REDIS_DST_PORT
  value: '6379'
- name: REDIS_LOCAL_PORT
  value: '6780'
- name: REDIS_SSH_KEY
  value: ''
- name: REDIS_SSH_HOSTS
  value: '[]'
{{- end -}}

{{- define "eventanalytics.common.couchdb" -}}
- name: COUCHDB_HOST
  value: '{{ .Release.Name }}-couchdb'
- name: COUCHDB_PORT
  value: {{ .Values.couchdb.port | quote }}
- name: COUCHDB_USERNAME
  valueFrom:
    secretKeyRef:
      name: '{{ .Release.Name }}-{{ .Values.couchdb.secretName }}'
      key: username
- name: COUCHDB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ .Release.Name }}-{{ .Values.couchdb.secretName }}'
      key: password
{{- end -}}

{{- define "eventanalytics.aggregationdedupservice.application" -}}
- name: DEDUPLICATOR_QUIET_PERIOD
  value: {{ .Values.aggregationcollaterservice.quietPeriod | quote }}
- name: PORT
  value: {{ .Values.common.restApi.port | quote }}
- name: SSL_APP_PORT
  value: {{ .Values.common.restApi.portSsl | quote }}
- name: NODE_ENV
  value: "production"
- name: NODE_TLS_REJECT_UNAUTHORIZED
  value: "0"
- name: LOG_LEVEL
  value: {{ .Values.aggregationdedupservice.logLevel | quote }}
- name: KAFKA_TOPIC_NAME
  value: {{ .Values.common.topics.eventactions.name | quote }}
- name: CONSUMER_ID
  value: {{ .Release.Name }}/aggregationdedupservice
- name: KAFKA_CREATE_TOPIC
  value: "false"
{{- end -}}

{{- define "eventanalytics.aggregationcollaterservice.application" -}}
- name: NODE_ENV
  value: "production"
- name: NODE_TLS_REJECT_UNAUTHORIZED
  value: "0"
- name: LOG_LEVEL
  value: {{ .Values.aggregationcollaterservice.logLevel | quote }}
- name: PRODUCER_ID
  value: {{ .Release.Name }}/aggregationcollaterservice
- name: COLLATER_POLLINGINTERVAL
  value: {{ .Values.aggregationcollaterservice.pollingInterval | quote }}
- name: COLLATER_INITIALWINDOWINTERVAL
  value: {{ .Values.aggregationcollaterservice.initialWindowInterval | quote }}
- name: COLLATER_LATENESSTHRESHOLD
  value: {{ .Values.aggregationcollaterservice.latenessThreshold | quote }}
- name: COLLATER_QUIET_PERIOD
  value: {{ .Values.aggregationcollaterservice.quietPeriod | quote }}
- name: COLLATER_MAX_CONNECTED_ITEMS
  value: {{ .Values.aggregationcollaterservice.maxConnectedItems | quote }}
- name: COLLATER_SAVEBACKUP
  value: {{ .Values.aggregationcollaterservice.savebackup | quote }}
- name: KAFKA_TOPIC
  value: {{ .Values.common.topics.collatedactions.name | quote }}
- name: KAFKA_TOPIC_ENABLED
  value: {{ .Values.common.topics.collatedactions.enabled | quote }}
{{- end -}}

{{- define "eventanalytics.aggregationnormalizerservice.application" -}}
- name: PORT
  value: {{ .Values.common.restApi.port | quote }}
- name: SSL_APP_PORT
  value: {{ .Values.common.restApi.portSsl | quote }}
- name: NODE_ENV
  value: "production"
- name: NODE_TLS_REJECT_UNAUTHORIZED
  value: "0"
- name: LOG_LEVEL
  value: {{ .Values.aggregationnormalizerservice.logLevel | quote }}
- name: CONSUMER_ID
  value: {{ .Release.Name }}/aggregationnormalizerservice
- name: KAFKA_CREATE_TOPIC
  value: "true"
- name: KAFKA_TOPIC_NAME
  value: {{ .Values.common.topics.collatedactions.name | quote }}
- name: EVT_MGMT_TARGET_URL
{{- if .Values.aggregationnormalizerservice.evtMgmtEndpoint.targetUrl }}
  value: {{ .Values.aggregationnormalizerservice.evtMgmtEndpoint.targetUrl | quote }}
{{- else }}
  value: "{{ .Release.Name }}-ea-noi-layer-eanoiactionservice:5600/api/actions/v1/actions"
{{- end }}
- name: EVT_MGMT_ENDPOINT_USERNAME
  value: {{ .Values.aggregationnormalizerservice.evtMgmtEndpoint.username | quote }}
- name: EVT_MGMT_ENDPOINT_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.global.authentication.objectserver.secretRelease | default .Release.Name }}{{ .Values.global.authentication.objectserver.secretTemplate | default "-omni-secret" }}
      key: OMNIBUS_ROOT_PASSWORD
      optional: false
{{- end -}}
