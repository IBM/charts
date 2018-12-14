{{/*********************************************************** {COPYRIGHT-TOP} ****
* Licensed Materials - Property of IBM
*
* "Restricted Materials of IBM"
*
*  5737-H89, 5737-H64
*
* © Copyright IBM Corp. 2015, 2018  All Rights Reserved.
*
* US Government Users Restricted Rights - Use, duplication, or
* disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
********************************************************* {COPYRIGHT-END} ****/}}

{{- define "rbarbs.env" }}
- name: LICENSE
  value: {{ .Values.license | default "not accepted" }}
- name: RBA_DATABASE_ENCRYPTION_KEYNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "releasename" . }}-cem-model-secret'
      key: keyname
- name: RBA_DATABASE_ENCRYPTION_KEYVALUE
  valueFrom:
    secretKeyRef:
      name: '{{ template "releasename" . }}-cem-model-secret'
      key: keyvalue
- name: RBA_DATABASE_ENCRYPTION_HKEYNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "releasename" . }}-cem-model-secret'
      key: hkeyname
- name: RBA_DATABASE_ENCRYPTION_HKEYVALUE
  valueFrom:
    secretKeyRef:
      name: '{{ template "releasename" . }}-cem-model-secret'
      key: hkeyvalue
- name: RBA_RBS_CEMFEEDBACK_URL
  value: {{ include "cem.services.incidentprocessor" . }}/api/incidents/v1
- name: RBA_RBS_CEMUIPROXYPREFIX
  value: '/{{ .Values.global.ingress.prefix }}cemui/proxy/rba'
- name: RBA_RBS_MAIL_NOTIFICATION_CEMTYPE
  value: '{{ .Values.email.type }}'
{{ if eq .Values.email.type "smtp" }}
- name: RBA_RBS_MAIL_NOTIFICATION_HOST
  value: '{{ .Values.email.smtphost }}'
- name: RBA_RBS_MAIL_NOTIFICATION_PORT
  value: '{{ .Values.email.smtpport }}'
- name: RBA_RBS_MAIL_NOTIFICATION_REQUIRE_TLS
  value: 'true'
- name: RBA_RBS_MAIL_NOTIFICATION_USER
  valueFrom:
    secretKeyRef:
      name: '{{ template "releasename" . }}-cem-email-cred-secret'
      key: smtpuser
- name: RBA_RBS_MAIL_NOTIFICATION_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "releasename" . }}-cem-email-cred-secret'
      key: smtppassword
- name: RBA_RBS_MAIL_NOTIFICATION_FROM
  value: '{{ .Values.email.mail }}'
{{ end }}
- name: RBA_RBS_KAFKA_BROKERS
  value: '{{ include "cem.services.kafkabrokers" . }}'
- name: RBA_RBS_KAFKA_USERNAME
  value: '{{ .Values.kafka.client.username }}'
- name: RBA_RBS_KAFKA_PASSWORD
  value: '{{ .Values.kafka.client.password }}'
- name: RBA_RBS_KAFKA_SSL_ENABLED
  value: '{{ .Values.kafka.ssl.enabled }}'
- name: RBA_RBS_KAFKA_CONSUMER_TOPIC
  value: 'incidents'
- name: RBA_RBS_KAFKA_CONSUMER_GROUPID
  value: 'rba'
- name: RBA_RBS_KAFKA_CONSUMER_CLIENTID
  value: 'RBA'
- name: VCAP_APP_HOST
  value: {{ template "releasename" . }}-rba-rbs.{{ .Release.Namespace }}.svc
- name: RBA_DEPLOYMODE
  value:  'icp-cem'
- name: RBA_RUNBOOKSERVICE_EXTERNAL_HOST
  value: {{ include "cem.service.host" (list . "cem.services.rba") }}
- name: RBA_RUNBOOKSERVICE_EXTERNAL_PROTOCOL
  value: {{ include "cem.service.protocol" (list . "cem.services.rba") }}
- name: RBA_RUNBOOKSERVICE_INTERNAL_PROTOCOL
  value: http
- name: RBA_DATABASE_CLUSTER_ENABLED
  value: 'true'
- name: RBA_DATABASE_CLUSTER_PROTOCOL
  value: {{ include "cem.service.protocol" (list . "cem.services.couchdb") }}
- name: RBA_DATABASE_CLUSTER_HOST
  value: {{ include "cem.service.host" (list . "cem.services.couchdb") }}
- name: RBA_DATABASE_CLUSTER_PORT
  value: {{ include "cem.service.port" (list . "cem.services.couchdb") | quote }}
- name: RBA_DATABASE_CLUSTER_USER
  valueFrom:
    secretKeyRef:
      name: {{ template "releasename" . }}-{{ .Values.couchdb.secretName }}
      key: username
- name: RBA_DATABASE_CLUSTER_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ template "releasename" . }}-{{ .Values.couchdb.secretName }}
      key: password
- name: RBA_DATABASE_CLUSTER_DBNAMEPREFIX
  value: 'icp'
- name: RBA_RBS_USERGROUPSERVICE_PROTOCOL
  value: {{ include "cem.service.protocol" (list . "cem.services.cemusers") }}
- name: RBA_RBS_USERGROUPSERVICE_HOST
  value: {{ include "cem.service.host" (list . "cem.services.cemusers") }}
- name: RBA_RBS_USERGROUPSERVICE_PORT
  value: {{ include "cem.service.port" (list . "cem.services.cemusers") | quote }}
- name: RBA_RBS_USERGROUPSERVICE_USER
  valueFrom:
    secretKeyRef:
      name: {{ template "releasename" . }}-cem-cemusers-cred-secret
      key: username
- name: RBA_RBS_USERGROUPSERVICE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ template "releasename" . }}-cem-cemusers-cred-secret
      key: password
- name: RBA_DEVOPS_USER
  valueFrom:
    secretKeyRef:
      name: {{ template "releasename" . }}-rba-devops-secret
      key: username
- name: RBA_DEVOPS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ template "releasename" . }}-rba-devops-secret
      key: password
- name: RBA_JWT_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ template "releasename" . }}-rba-jwt-secret
      key: secret
- name: RBA_AUTOMATIONSERVICE_EXTERNAL_HOST
  value: {{ include "cem.service.host" (list . "cem.services.rbaas") }}
- name: RBA_AUTOMATIONSERVICE_EXTERNAL_PROTOCOL
  value: {{ include "cem.service.protocol" (list . "cem.services.rbaas") }}
- name: RBA_AUTOMATIONSERVICE_EXTERNAL_PORT
  value: {{ include "cem.service.port" (list . "cem.services.rbaas") | quote }}
- name: RBA_RBS_LOG_WRITETOFILE_ENABLED
  value: 'false'
- name: INGRESS_PREFIX
  value: '{{ .Values.global.ingress.prefix }}'
- name: INGRESS_DOMAIN
  value: '{{ .Values.global.ingress.domain }}'
{{- end }}

{{- define "rbaas.env" }}
- name: LICENSE
  value: {{ .Values.license | default "not accepted" }}
- name: RBA_AUTOMATIONSERVICE_EXTERNAL_HOST
  value: {{ include "cem.service.host" (list . "cem.services.rbaas") }}
- name: RBA_DATABASE_ENCRYPTION_KEYNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "releasename" . }}-cem-model-secret'
      key: keyname
- name: RBA_DATABASE_ENCRYPTION_KEYVALUE
  valueFrom:
    secretKeyRef:
      name: '{{ template "releasename" . }}-cem-model-secret'
      key: keyvalue
- name: RBA_DEVOPS_USER
  valueFrom:
    secretKeyRef:
      name: {{ template "releasename" . }}-rba-devops-secret
      key: username
- name: RBA_DEVOPS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ template "releasename" . }}-rba-devops-secret
      key: password
- name: RBA_AS_ENABLE_API_DOCS
  value: 'true'
- name: RBA_DEPLOYMODE
  value:  'icp-cem'
- name: RBA_JWT_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ template "releasename" . }}-rba-jwt-secret
      key: secret
- name: RBA_AUTOMATIONSERVICE_EXTERNAL_PROTOCOL
  value:  {{ include "cem.service.protocol" (list . "cem.services.rbaas") }}
- name: RBA_AUTOMATIONSERVICE_INTERNAL_PROTOCOL
  value:  http
- name: RBA_DATABASE_CLUSTER_ENABLED
  value: 'true'
- name: RBA_DATABASE_CLUSTER_PROTOCOL
  value: {{ include "cem.service.protocol" (list . "cem.services.couchdb") }}
- name: RBA_DATABASE_CLUSTER_HOST
  value: {{ include "cem.service.host" (list . "cem.services.couchdb") }}
- name: RBA_DATABASE_CLUSTER_PORT
  value: {{ include "cem.service.port" (list . "cem.services.couchdb") | quote }}
- name: RBA_DATABASE_CLUSTER_DBNAMEPREFIX
  value: icp
- name: RBA_DATABASE_CLUSTER_USER
  valueFrom:
    secretKeyRef:
      name: {{ template "releasename" . }}-{{ .Values.couchdb.secretName }}
      key: username
- name: RBA_DATABASE_CLUSTER_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ template "releasename" . }}-{{ .Values.couchdb.secretName }}
      key: password
- name: RBA_AS_LOG_TOFILE
  value: 'false'
- name: RBA_AS_LOG_PATH
  value: ''
- name: INGRESS_PREFIX
  value: '{{ .Values.global.ingress.prefix }}'
- name: INGRESS_DOMAIN
  value: '{{ .Values.global.ingress.domain }}'
- name: INGRESS_PORT
  value: '{{ .Values.global.ingress.port }}'
{{- end }}

