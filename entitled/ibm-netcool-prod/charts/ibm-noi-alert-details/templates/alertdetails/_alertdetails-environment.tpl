{{- /*
Creates the environment for the service
*/ -}}

{{- define "ibm-noi-alert-details.alertdetails.environment" -}}
env:
  - name: LICENSE
    value: "{{ .Values.global.license }}"
  - name: PORT
    value: {{ .Values.common.restApi.port | quote }}
  - name: SSL_APP_PORT
    value: {{ .Values.common.restApi.portSsl | quote }}
  - name: PUBLICURL
    value: {{ include "ibm-noi-alert-details.ingress.baseurl" . | quote }}
  {{- if .Values.swagger }}
  - name: ENABLE_SWAGGER_UI
    value: "1"
  {{ end }}
  - name: NODE_ENV
    value: "production"
  - name: LOG_LEVEL
    value: {{ .Values.logLevel | quote }}
  - name: VCAP_APPLICATION
    value: "{}"
  - name: PAYLOAD_SIZE_LIMIT
    value: {{ (int .Values.payloadSizeLimit) | quote }}
  - name: DETAILS_TTL_DURATION
    value: {{ (int .Values.detailsTtl) | quote }}
{{ include "ibm-noi-alert-details.common.cassandra" . | indent 2 }}
{{ include "ibm-noi-alert-details.common.auth" . | indent 2 }}
{{ include "ibm-noi-alert-details.common.defaults" . | indent 2 }}
{{- end -}}

{{- define "ibm-noi-alert-details.common.cassandra" -}}
{{ $cassandra := .Values.global.integrations.cassandra }}
- name: CASSANDRA_AUTH_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ include "ibm-noi-alert-details.geturl" (list . $cassandra.authSecret $cassandra.releaseName $cassandra.authSecretTemplate) | quote }}
      key: username
- name: CASSANDRA_AUTH_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "ibm-noi-alert-details.geturl" (list . $cassandra.authSecret $cassandra.releaseName $cassandra.authSecretTemplate) | quote }}
      key: password
- name: CASSANDRA_SECURED
  value: 'false'
- name: CASSANDRA_CONTACT_POINTS
  value: {{ include "ibm-noi-alert-details.geturl" (list . $cassandra.url $cassandra.releaseName $cassandra.urlTemplate) | quote }}
- name: CASSANDRA_SSL_OPTION_VALS
  value: '{}'
- name: CASSANDRA_POLICIES
  value: '{"reconnection":{"baseDelay":1000,"maxDelay":60000,"startWithNoDelay":false}}'
- name: CASSANDRA_KEYSPACE
  value: {{ .Values.common.keyspaces.alertdetails.name | quote }}
- name: CASSANDRA_REPLICATION_FACTOR
  value: {{ .Values.common.keyspaces.alertdetails.replicationFactor | quote }}
{{- end -}}

{{- define "ibm-noi-alert-details.common.auth" -}}
{{ $systemAuth := .Values.global.integrations.systemAuth }}
- name: SYSTEMAUTH_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ include "ibm-noi-alert-details.geturl" (list . $systemAuth.authSecret $systemAuth.releaseName $systemAuth.authSecretTemplate) | quote }}
      key: username
- name: SYSTEMAUTH_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "ibm-noi-alert-details.geturl" (list . $systemAuth.authSecret $systemAuth.releaseName $systemAuth.authSecretTemplate) | quote }}
      key: password
- name: API_AUTHSCHEME_TYPE
  value: {{ .Values.common.authentication.scheme | quote }}
{{- end -}}

{{- define "ibm-noi-alert-details.common.defaults" -}}
{{ $cemUsers := .Values.global.integrations.cemUsers }}
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
  value: {{ include "ibm-noi-alert-details.geturl" (list . $cemUsers.url $cemUsers.releaseName $cemUsers.urlTemplate) | quote }}
- name: NOI_DASH_AUTH_SERVLET_URL
  value: 'https://dummyUrl'
{{- end -}}
