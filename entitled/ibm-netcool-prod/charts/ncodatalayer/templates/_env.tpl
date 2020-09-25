{{/* vim: set filetype=mustache: */}}
{{/*
########################################################################
#
# Licensed Materials - Property of IBM
#
# (C) Copyright IBM Corp.
#
# 2019 All Rights Reserved
#
# US Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
########################################################################
*/}}

{{- define "common.application" -}}
- name: VCAP_APPLICATION
  value: '{}'
- name: NODE_ENV
  value: 'production'
- name: LC_ALL
  value: {{ .Values.ncodatalayer.env.locale | quote }}
{{- end -}}

{{- define "ncodatalayer.iducrelay" -}}
- name: PORT
  value: {{ .Values.ncodatalayer.port | quote }}
- name: SSL_PORT
  value: {{ .Values.ncodatalayer.portSsl | quote }}
- name: DATALAYER_INSTANCE_TYPE
  value: 'iducrelay'
- name: DBACCESS_TENANTID
  value: {{ .Values.global.common.eventanalytics.tenantId | quote }}
- name: NOIOMNIBUS_OS_APPNAME
  value: 'nodejs-cemdatalayer-ir'
- name: NOIOMNIBUS_IDUC_TYPE
  value: 'relay'
- name: NOIOMNIBUS_IDUC_ENABLED
  value: 'true'
- name: NOIOMNIBUS_IDUC_FLUSHRATE
  value: {{ .Values.ncodatalayer.flushrate | quote }}
- name: LOG_LEVEL
  value: {{ .Values.ncodatalayer.logLevel | quote }}
{{- if .Values.ncodatalayer.swagger.enabled }}
- name: ENABLE_SWAGGER_UI
  value: '1'
{{ end }}
{{- end -}}

{{- define "ncodatalayer.iducforward" -}}
- name: PORT
  value: {{ .Values.ncodatalayer.port | quote }}
- name: SSL_PORT
  value: {{ .Values.ncodatalayer.portSsl | quote }}
- name: DATALAYER_INSTANCE_TYPE
  value: 'iducrelay'
- name: DBACCESS_TENANTID
  value: {{ .Values.global.common.eventanalytics.tenantId | quote }}
- name: NOIOMNIBUS_OS_APPNAME
  value: 'nodejs-cemdatalayer-irf'
- name: NOIOMNIBUS_IDUC_TYPE
  value: 'forward'
- name: NOIOMNIBUS_IDUC_ENABLED
  value: 'true'
- name: NOIOMNIBUS_IDUC_FLUSHRATE
  value: {{ .Values.ncodatalayer.flushrate | quote }}
- name: NOIOMNIBUS_IDUC_TABLES
  value: '[{"name":"alerts.status"}]'
- name: KAFKA_CLIENTID
  value: 'nodejs-irf-cemdatalayer'
- name: LOG_LEVEL
  value: {{ .Values.ncodatalayer.logLevel | quote }}
{{- if .Values.ncodatalayer.swagger.enabled }}
- name: ENABLE_SWAGGER_UI
  value: '1'
{{ end }}
{{- end -}}

{{- define "ncodatalayer.standard" -}}
- name: PORT
  value: {{ .Values.ncodatalayer.port | quote }}
- name: SSL_PORT
  value: {{ .Values.ncodatalayer.portSsl | quote }}
- name: DATALAYER_INSTANCE_TYPE
  value: 'standard'
- name: DBACCESS_TENANTID
  value: {{ .Values.global.common.eventanalytics.tenantId | quote }}
- name: NOIOMNIBUS_OS_APPNAME
  value: 'nodejs-cemdatalayer-std'
- name: NOIOMNIBUS_IDUC_ENABLED
  value: 'false'
- name: LOG_LEVEL
  value: {{ .Values.ncodatalayer.logLevel | quote }}
{{- if .Values.ncodatalayer.swagger.enabled }}
- name: ENABLE_SWAGGER_UI
  value: '1'
{{ end }}
{{- end -}}

{{- define "common.omnibus" -}}
- name: NOIOMNIBUS_OS_CONTACT_POINTS
  value: {{ include "ncodatalayer.os.contactpoints" . }}
- name: NOIOMNIBUS_OS_USERNAME
  value: {{ include "ncodatalayer.os.username" . | quote }}
- name: NOIOMNIBUS_OS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "ncodatalayer.os.secret" . | quote }}
      key: OMNIBUS_ROOT_PASSWORD
      optional: false
- name:  NOIOMNIBUS_OS_FAILBACK_ENABLED
  value: {{ .Values.ncodatalayer.failback.enabled | quote }}
- name:  NOIOMNIBUS_OS_FAILBACK_TIMEOUT
  value: {{ .Values.ncodatalayer.failback.timeout | quote }}
- name: NOIOMNIBUS_OS_TRUSTSTORE_PATH
  value: "/app/ncodatalayer.jks"
- name: NOIOMNIBUS_OS_TRUSTSTORE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.global.authentication.objectserver.secretRelease | default .Release.Name }}{{ .Values.global.authentication.objectserver.certificateTemplate | default "-omni-certificate-secret" }}
      key: PASSWORD
      optional: false
{{- end -}}

{{- define "common.license" -}}
- name: LICENSE
  value: {{ .Values.global.license | quote }}
{{- end -}}

{{- define "common.kafka" -}}
- name: KAFKA_INIT_TOPICS
  value: '{{ .Values.global.kafka.topics.initialise }}'
- name: KAFKA_ENABLED
  value: '{{ .Values.global.kafka.enabled }}'
- name: KAFKA_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ include "ncodatalayer.kafka.secretName" . | quote }}
      key: username
- name: KAFKA_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "ncodatalayer.kafka.secretName" . | quote }}
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
      name: {{ include "ncodatalayer.kafka.adminSecretName" . | quote }}
      key: password
- name: KAFKA_ADMIN_URL
  value: {{ printf "http://%s:%s" (include "ncodatalayer.kafka.host" .) (include "ncodatalayer.kafka.adminPort" .) | quote }}
- name: KAFKA_BROKERS_SASL_BROKERS
  value: {{ printf "%s:%s" (include "ncodatalayer.kafka.host" .) (include "ncodatalayer.kafka.port" .) | quote }}
- name: KAFKA_TOPIC_PARTITIONS
  value: "6"
- name: KAFKA_TOPIC_REPLICAS
  {{- if eq .Values.global.environmentSize "size0" }}
  value: "2"
  {{- else }}
  value: "3"
  {{- end }}
- name: KAFKA_TOPIC_CONFIG
  value: "retention.ms=3600000"
- name: KAFKA_TOPICS
  value: '[]'
- name: MH_MODE
  value: none
- name: MH_BROKERS_SASL_BROKERS
  value: ''
- name: MH_USERNAME
  value: none
- name: MH_PASSWORD
  value: none
- name: MH_API_KEY
  value: none
- name: MH_ADMIN_URL
  value: 'https://dummyUrl'
- name: MH_REST_URL
  value: 'https://dummyUrl'
- name: MH_MQLIGHT_LOOKUP_URL
  value: 'https://dummyUrl/Lookup?serviceId=INSTANCE_ID'
{{- end -}}

{{- define "common.defaults" -}}
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
  value: 'https://cem-api-us-south.opsmgmt.bluemix.net/api/events/v1'
- name: COMMON_SERVICEMONITOR_EVENTSINK0_NAME
  value: none
- name: COMMON_SERVICEMONITOR_EVENTSINK0_PASSWORD
  value: none
- name: COMMON_SERVICEMONITOR_EVENTSINK1_ENABLED
  value: 'false'
- name: COMMON_SERVICEMONITOR_EVENTSINK1_URL
  value: 'https://cem-api-us-south.opsmgmt.bluemix.net/api/events/v1'
- name: COMMON_SERVICEMONITOR_EVENTSINK1_NAME
  value: none
- name: COMMON_SERVICEMONITOR_EVENTSINK1_PASSWORD
  value: none
- name: COMMON_SERVICEMONITOR_EVENTSINK2_ENABLED
  value: 'false'
- name: COMMON_SERVICEMONITOR_EVENTSINK2_URL
  value: 'https://cem-api-us-south.opsmgmt.bluemix.net/api/events/v1'
- name: COMMON_SERVICEMONITOR_EVENTSINK2_NAME
  value: none
- name: COMMON_SERVICEMONITOR_EVENTSINK2_PASSWORD
  value: none
- name: CIRCUITBREAKER_TRIP_LIMIT
  value: '1000000'
- name: CIRCUITBREAKER_RESET_TIME
  value: '1'
- name: SYSLOG_TARGETS
  value: '[]'
- name: CEMSERVICEBROKER_APIURL
  value: 'https://dummyUrl'
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
  value: '''self'''
- name: METRICREST_URL
  value: 'https://dummyUrl'
- name: METRICREST_DISABLE
  value: 'false'
- name: NOTIFICATIONPROCESSOR_URL
  value: 'https://dummyUrl'
- name: SCHEDULINGUI_URL
  value: 'https://dummyUrl'
- name: CHANNELSERVICES_URL
  value: 'https://dummyUrl'
- name: CHANNELSERVICES_USERNAME
  value: 'notdefined'
- name: CHANNELSERVICES_PASSWORD
  value: 'notdefined'
- name: UAG_URL
  value: 'https://dummyUrl'
- name: UAG_USERNAME
  value: 'notdefined'
- name: UAG_PASSWORD
  value: 'notdefined'
- name: UAG_CLIENT_ID
  value: 'notdefined'
- name: UAG_CLIENT_SECRET
  value: 'notdefined'
{{- end -}}
