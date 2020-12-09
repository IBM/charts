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
{{- define "metric-api-service.application" -}}

{{- $integrations := .Values.global.integrations -}}

{{- if  eq .Values.global.environmentSize  "size0" }}
- name: METRIC_API_XMS
  value: '512M'
- name: METRIC_API_XMX
  value: '1G'
{{- else if eq .Values.global.environmentSize "size1" }}
- name: METRIC_API_XMS
  value: '1G'
- name: METRIC_API_XMX
  value: '2G'
{{- else }}
- name: METRIC_API_XMS
  value: '512M'
- name: METRIC_API_XMX
  value: '1G'
{{ end }}
- name: LOGGING_LEVEL
  value: "INFO"
- name: PUBLICURL
  value: {{ include "metric-api-service.ingress.baseurl" . | quote }}
{{ include "metric-api-service.getCemusersUrl" (list . "AUTH_CEMUSERS_USERINFO_ENDPOINT" $integrations.users.releaseName $integrations.users.namespace $integrations.users.config.userInfoTenant) }}
- name: METRICS_API_AUTH_ENABLED
  value: {{ .Values.authentication.enabled | quote }}
- name: METRIC_API_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-systemauth-secret
      key: username
- name: METRIC_API_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-systemauth-secret
      key: password
- name: CASSANDRA_TTL_SECONDS
  value: {{  (int .Values.metricapiservice.cassandraTTL) | default (int 2592000) | quote }}

- name: CASSANDRA_CONTACT_POINTS
  value: {{ .Release.Name }}-cassandra
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
{{- end -}}

{{- define "metric-api-service.common.license" -}}
- name: LICENSE
  value: {{ .Values.global.license | quote }}
{{- end -}}
