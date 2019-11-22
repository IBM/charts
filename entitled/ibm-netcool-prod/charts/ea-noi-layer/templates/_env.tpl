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
{{- define "eanoi.noieagateway.application" -}}
- name: NCO_AGGB_PORT_NUMBER
  value: "4100"
- name: NCO_AGGP_PORT_NUMBER
  value: "4100"
{{- if and .Values.objectserver.primary.hostname .Values.objectserver.primary.hostname }}
- name: NCO_AGGP_SERVICE_NAME
  value: {{ .Values.objectserver.primary.hostname }}
- name: NCO_AGGB_SERVICE_NAME
  value: {{ .Values.objectserver.backup.hostname }}
{{- else }}
- name: NCO_AGGP_SERVICE_NAME
  value: {{ .Release.Name }}-objserv-agg-primary
- name: NCO_AGGB_SERVICE_NAME
  value: {{ .Release.Name }}-objserv-agg-backup
{{- end }}
- name: LC_ALL
  value: {{ .Values.noieagateway.env.locale | quote }}
- name: OMNIHOME
  value: /home/netcool/IBM/core/omnibus
- name: OMNIBUS_ROOT_PWD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.global.authentication.objectserver.secretRelease | default .Release.Name }}{{ .Values.global.authentication.objectserver.secretTemplate | default "-omni-secret" }}
      key: OMNIBUS_ROOT_PASSWORD
      optional: false
- name: INGESTION_SERVICE_NAME
{{- if .Values.noieagateway.ingestionEndpoint.targetUrl }}
  value: {{ .Values.noieagateway.ingestionEndpoint.targetUrl }}:5600
{{- else }}
  value: {{ .Release.Name }}-ibm-hdm-analytics-dev-ingestionservice:5600
{{- end }}
- name: SUBSCRIPTION_APIKEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.global.authentication.backend.secretRelease | default .Release.Name }}-systemauth-secret
      key: password
- name: SUBSCRIPTION_KEYNAME
  valueFrom:
    secretKeyRef:
      name: {{ .Values.global.authentication.backend.secretRelease | default .Release.Name }}-systemauth-secret
      key: username
- name: LICENSE
  value: {{ .Values.global.license }}
{{- end -}}


{{- define "eanoi.noiactionservice.application" -}}
- name: LICENSE
  value: {{ .Values.global.license | quote }}
- name: LC_ALL
  value: {{ .Values.noiactionservice.env.locale | quote }}
- name: PORT
  value: {{ .Values.noiactionservice.port | quote }}
- name: SSL_APP_PORT
  value: {{ .Values.noiactionservice.portSsl | quote }}
- name: NODE_ENV
  value: "production"
- name: NODE_TLS_REJECT_UNAUTHORIZED
  value: "0"
- name: LOG_LEVEL
  value: {{ .Values.noiactionservice.logLevel | quote }}
- name: NOIOMNIBUS_OS_CONTACT_POINTS
  value:
{{- if and .Values.objectserver.primary.hostname .Values.objectserver.primary.hostname }}
{{- printf " '{\"primary\":{\"hostname\":\"%s\",\"port\":%d},\"backup\":{\"hostname\":\"%s\",\"port\":%d}}'" .Values.objectserver.primary.hostname (int .Values.objectserver.primary.port) .Values.objectserver.backup.hostname (int .Values.objectserver.backup.port) -}}
{{- else }}
{{- printf " '{\"primary\":{\"hostname\":\"%s-objserv-agg-primary\",\"port\":4100},\"backup\":{\"hostname\":\"%s-objserv-agg-backup\",\"port\":4100}}'" .Release.Name .Release.Name -}}
{{- end }}
- name: NOIOMNIBUS_OS_USERNAME
  value: {{ .Values.objectserver.username | quote }}
- name: NOIOMNIBUS_OS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.global.authentication.objectserver.secretRelease | default .Release.Name }}{{ .Values.global.authentication.objectserver.secretTemplate | default "-omni-secret" }}
      key: OMNIBUS_ROOT_PASSWORD
      optional: false
- name: NOIOMNIBUS_OS_COLUMNIDMAP
  value:
{{- print " '{" }}
{{- $local := dict "ofirst" true -}}
{{- range $key, $value := .Values.objectserver.columnidmap }}
   {{- if not $local.ofirst }}{{- printf "," }}{{- else }}{{- $_ := set $local "ofirst" false }}{{- end }}
   {{- if or (eq $key "correlation") (eq $key "seasonality") }}
     {{- printf "\"%s\":{" $key }}
     {{- $local := dict "ifirst" true -}}
     {{- range $ikey, $ivalue := $value }}
       {{- if not $local.ifirst }}{{- printf "," }}{{- else }}{{- $_ := set $local "ifirst" false }}{{- end }}
       {{- printf "\"%s\":\"%s\"" $ikey $ivalue }}
     {{- end }}
     {{- printf "}" }}
   {{- else }}
     {{- printf "\"%s\":\"%s\"" $key $value }}
   {{- end }}
{{- end }}
{{- print "}'\n" }}
- name:  NOIOMNIBUS_OS_FAILBACK_ENABLED
  value: {{ .Values.objectserver.failback.enabled | quote }}
- name:  NOIOMNIBUS_OS_FAILBACK_TIMEOUT
  value: {{ .Values.objectserver.failback.timeout | quote }}
{{ if .Values.noiactionservice.swagger.enabled }}
- name: ENABLE_SWAGGER_UI
  value: "1"
{{ end }}
{{ if .Values.noiactionservice.payloadSizeLimit }}
- name: PAYLOAD_SIZE_LIMIT
  value: {{ ( int .Values.noiactionservice.payloadSizeLimit ) | quote }}
{{ end }}
{{- end -}}

{{- define "eanoi.common.defaults" -}}
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
  value: 'https://dummyUrl'
{{- end -}}
