{{- define "cloudeventmanagement.brokers.env" -}}
- name: OSBCREDENTIALS_USERNAME
  value: not-applicable
- name: OSBCREDENTIALS_PASSWORD
  value: not-applicable
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
- name: OTCBROKERCREDENTIALS_ALERTNOTIFICATION
  value: SECRET
- name: OTCBROKERCREDENTIALS_EVENTMANAGEMENT
  value: SECRET
- name: OTCBROKERCREDENTIALS_RUNBOOKAUTOMATION
  value: ''
- name: TIAM_URL
  value: 'https://devops-api.DOMAIN.ng.bluemix.net/v1/identity/service/'
- name: CEMSERVICEBROKER_APIREFERENCEURL
  value: '919'
- name: PRODUCT_NAME
  value: '{{ .Values.productName }}'
- name: CEMSERVICEBROKER_DOCUMENTATIONURL
  value: 'https://console.bluemix.net/docs/services/EventManagement/index.html'
- name: CEMSERVICEBROKER_CEMOTCDOCUMENTATIONURL
  value: 'https://cloud.ibm.com/docs/services/ContinuousDelivery?topic=ContinuousDelivery-integrations#cloudeventmanagement'
- name: CEMSERVICEBROKER_ANSOTCDOCUMENTATIONURL
  value: 'https://cloud.ibm.com/docs/services/ContinuousDelivery?topic=ContinuousDelivery-integrations#alertnotification'
- name: CEMSERVICEBROKER_APIURL
  value: 'https://ENV-api.DOMAIN.mybluemix.net'
- name: CEMSERVICEBROKER_EXPERIMENTALPLANID
  value: d07dfeff-c94b-450a-93c3-f562c653c839
- name: CEMSERVICEBROKER_BETAPLANID
  value: af0a953b-f647-4b0b-b099-8dcc61a910ed
- name: CEMSERVICEBROKER_STANDARDPLANID
  value: 5591084c-086a-48b9-817b-fb51532cecf3
- name: CEMSERVICEBROKER_MONITORINGPLANID
  value: fd9349be-e7e3-4ff7-90ff-45f75465f444
- name: CEMSERVICEBROKER_MONITORINGADVPLANID
  value: 99b23e24-a751-4217-bb64-edc00b87e672
- name: CEMSERVICEBROKER_MONITORINGMCMPLANID
  value: 29a1b47b-176e-41e0-ae7e-202f489d6f01
- name: CEMSERVICEBROKER_EVENTMANAGEMENTPLANID
  value: 3e0c0fc1-bce1-4d81-9885-ae3f0d218d28
- name: CEMSERVICEBROKER_EVENTMANAGEMENTMCMBASEPLANID
  value: 7a2a80eb-90c6-4846-8cd4-c10d83bc2f73
- name: CEMSERVICEBROKER_LOCATIONNAME
  value: ICP
- name: CEMSERVICEBROKER_MEDIA
  value: '[{"caption":"catalog_cem_image_incidentviewer","type":"image","url":"https://localhost/static/incident_viewer.png"},{"caption":"catalog_cem_image_adminpage","type":"image","url":"https://localhost/static/admin_page.png"},{"caption":"catalog_cem_image_incidentqueue","type":"image","url":"https://localhost/static/incident_queue.png"},{"caption":"catalog_cem_image_timeline","type":"image","url":"https://localhost/static/timeline.png"},{"caption":"catalog_cem_image_runbook","type":"image","url":"https://localhost/static/runbook.png"}]'
- name: CEMSERVICEBROKER_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-brokers-cred-secret'
      key: password
- name: CEMSERVICEBROKER_REGIONURL
  value: 'https://mccp.REGION.bluemix.net/v2/region'
- name: CEMSERVICEBROKER_SERVICEID
  value: 16a036f0-f1fc-11e6-a38d-394caee7d66d
- name: CEMSERVICEBROKER_SERVICENAME
  value: ibm-cloud-evtmgmt
- name: CEMSERVICEBROKER_AMSERVICEID
  value: 941a5588-b6a2-41f2-be9c-e7c87839cea7
- name: CEMSERVICEBROKER_AMSERVICENAME
  value: ibm-cloud-appmgmt
- name: CEMSERVICEBROKER_SUFFIX
  value: '{{.Values.cemservicebroker.suffix}}'
- name: CEMSERVICEBROKER_TERMSURL
  value: 'https://www.ibm.com/software/sla/sladb.nsf/sla/bm-6620-02'
- name: CEMSERVICEBROKER_USERNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-brokers-cred-secret'
      key: username
- name: CEMSERVICEBROKER_MASTERURL
  value: 'https://cem-bm-broker.mybluemix.net'
- name: SSMENDPOINT_FQDN
  value: not-applicable
- name: SSMENDPOINT_FQDN2
  value: not-applicable
- name: SSMENDPOINT_PARTS
  value: '[{"id":"D00T4ZX","type":"base","events":1000,"messages":200,"runbooks":200},{"id":"D00CMZX","type":"base","events":20000,"messages":1000,"runbooks":1000},{"id":"D00T3ZX","type":"base","events":300000,"messages":10000,"runbooks":10000},{"id":"D00T5ZX","type":"base","unlimited":true},{"id":"D00CQZX","type":"addon","events":20000,"messages":1000,"runbooks":1000,"allowOverage":true}]'
- name: SSMENDPOINT_OTCDBNAME
  value: otc_omaas_broker
- name: COUCHDB_URL
  value: '{{ include "cem.services.couchdb" . }}'
- name: COUCHDB_USERNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-{{ .Values.couchdb.secretName }}'
      key: username
- name: COUCHDB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-{{ .Values.couchdb.secretName }}'
      key: password
- name: COUCHDB_MAXRETRIES
  value: '15'
- name: COUCHDB_DBNAME
  value: collabopsuser
- name: UAG_URL
  value: '{{ include "cem.services.cemusers" . }}'
- name: UAG_USERNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: username
- name: UAG_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: password
- name: UAG_CLIENT_ID
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: clientid
- name: UAG_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: clientsecret
- name: BROKERS_URL
  value: '{{ include "cem.services.brokers" . }}'
- name: UISERVER_URL
  value: '{{ include "cem.services.uiserver" . }}'
- name: EVENTPREPROCESSOR_URL
  value: '{{ include "cem.services.eventpreprocessor" . }}'
- name: INCIDENTPROCESSOR_URL
  value: '{{ include "cem.services.incidentprocessor" . }}'
- name: NORMALIZER_URL
  value: '{{ include "cem.services.normalizer" . }}'
- name: INTEGRATIONCONTROLLER_URL
  value: '{{ include "cem.services.integrationcontroller" . }}'
- name: ALERTNOTIFICATION_URL
  value: '{{ include "cem.services.alertnotification" . }}'
- name: RBA_URL
  value: '{{ include "cem.services.rba" . }}'
- name: APMUI_URL
  value: '{{ include "cem.services.apm" . }}'
- name: CEMAPI_URL
  value: '{{ include "cem.services.cemapi" . }}'
- name: FRAMEANCESTORS_URL
  value: '''self'''
- name: METRICREST_URL
  value: '{{ include "cem.services.metricrest" . }}'
- name: NOTIFICATIONPROCESSOR_URL
  value: '{{ include "cem.services.notificationprocessor" . }}'
- name: SCHEDULINGUI_URL
  value: '{{ include "cem.services.schedulingui" . }}'
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
- name: KAFKA_ENABLED
  value: 'true'
- name: KAFKA_BROKERS_SASL_BROKERS
  value: '{{ include "cem.services.kafkabrokers" . }}'
- name: KAFKA_USERNAME
  value: '{{ .Values.kafka.client.username }}'
- name: KAFKA_PASSWORD
  value: '{{ .Values.kafka.client.password }}'
- name: KAFKA_SECURED
  value: '{{ .Values.kafka.ssl.enabled }}'
- name: KAFKA_SSL_CA_LOCATION
  value: /etc/keystore/ca-cert
- name: KAFKA_SSL_CERT_LOCATION
  value: /etc/keystore/client.pem
- name: KAFKA_SSL_KEY_LOCATION
  value: /etc/keystore/client.key
- name: KAFKA_SSL_KEY_PASSWORD
  value: '{{ .Values.kafka.ssl.password }}'
- name: KAFKA_ADMIN_URL
  value: '{{ include "cem.services.kafkaadmin" . }}'
- name: KAFKA_TOPICS
  value: '[{"name":"cem-notifications","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"},{"name":"cem-serviceinstances","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=-1"},{"name":"incidents","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"},{"name":"incidentResourceDashboard","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"},{"name":"incidentStateDashboard","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"},{"name":"incidentTrendDashboard","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"},{"name":"timeline","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"},{"name":"cem-usage","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"}]'
- name: MAINTENANCE_KAFKA_CQUEUE_SIZE_KB
  value: '100000'
- name: MCM_POLL_INTERVAL
  value: '86400'
- name: MCM_POLL_DELAY
  value: '90'
- name: MODEL_KEYNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-model-secret'
      key: keyname
- name: MODEL_KEYVALUE
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-model-secret'
      key: keyvalue
- name: MODEL_HKEYNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-model-secret'
      key: hkeyname
- name: MODEL_HKEYVALUE
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-model-secret'
      key: hkeyvalue
- name: S3RBAOBJECTSTORAGE_APIKEY
  value: none
- name: S3RBAOBJECTSTORAGE_ENDPOINTS
  value: 'https://control.cloud-object-storage.cloud.ibm.com/v2/endpoints'
- name: S3RBAOBJECTSTORAGE_BUCKET
  value: none
- name: S3RBAOBJECTSTORAGE_LOCATION
  value: us
- name: RBA_PDOC_OBJECTSTORAGE_AUTHURL
  value: 'https://identity.open.softlayer.com'
- name: RBA_PDOC_OBJECTSTORAGE_REGION
  value: dallas
- name: RBA_PDOC_OBJECTSTORAGE_USERID
  value: ''
- name: RBA_PDOC_OBJECTSTORAGE_PASSWORD
  value: ''
- name: RBA_PDOC_OBJECTSTORAGE_PROJECTID
  value: ''
- name: AUTH_SESSION_SECRET
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-event-analytics-ui-session-secret'
      key: session
- name: AUTH_SESSION_TTL
  value: '7200'
- name: REDIS_SSH_USERNAME
  value: none
- name: REDIS_SERVER_SECURED
  value: '{{ include "cem.services.redissecured" . }}'
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-ibm-redis-cred-secret'
      key: password
- name: REDIS_SSH_HOSTS
  value: '[]'
- name: REDIS_DST_HOST
  value: '{{ include "cem.services.redishost" . }}'
- name: REDIS_DST_PORT
  value: '6379'
- name: REDIS_DESTINATIONS
  value: '[{"host":"{{ include "cem.services.redishost" . }}","port":6379}]'
- name: REDIS_LOCAL_HOST
  value: 127.0.0.1
- name: REDIS_LOCAL_PORT
  value: '6780'
- name: REDIS_INDEX
  value: '0'
- name: REDIS_KEEP_ALIVE
  value: 'true'
- name: REDIS_SSH_KEY
  value: ''
- name: SSH_READY_TIMEOUT
  value: '30000'
- name: REDIS_SENTINEL_HOST
  value: '{{ include "cem.services.redissentinelsvc" . }}'
- name: REDIS_SENTINEL_PORT
  value: '26379'
- name: REDIS_SENTINEL_NAME
  value: mymaster
- name: REDIS_CONNECT_SENTINELS
  value: 'false'
- name: SERVICEMONITOR_MONITORS
  value: '{"cemusers":"{{ include "cem.services.cemusers" . }}","channelservices":"{{ include "cem.services.channelservices" . }}","eventpreprocessor":"{{ include "cem.services.eventpreprocessor" . }}","incidentprocessor":"{{ include "cem.services.incidentprocessor" . }}","normalizer":"{{ include "cem.services.normalizer" . }}","notificationprocessor":"{{ include "cem.services.notificationprocessor" . }}","integrationcontroller":"{{ include "cem.services.integrationcontroller" . }}","schedulingui":"{{ include "cem.services.schedulingui" . }}","uiserver":"{{ include "cem.services.uiserver" . }}"}'
- name: SYSLOG_TARGETS
  value: '[]'
- name: ICP_ADMIN_USER
  value: '{{.Values.icpbroker.adminusername}}'
{{- end -}}

{{- define "cloudeventmanagement.cemusers.env" -}}
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
- name: UAG_CONFLICT_SCAN_GAP
  value: '60'
- name: UAG_URL
  value: '{{ include "cem.services.cemusers" . }}'
- name: UAG_USERNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: username
- name: UAG_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: password
- name: UAG_CLIENT_ID
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: clientid
- name: UAG_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: clientsecret
- name: CHANNELSERVICES_URL
  value: '{{ include "cem.services.channelservices" . }}/api/send/v1'
- name: CHANNELSERVICES_USERNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-channelservices-cred-secret'
      key: username
- name: CHANNELSERVICES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-channelservices-cred-secret'
      key: password
- name: CIRCUITBREAKER_TRIP_LIMIT
  value: '1000000'
- name: CIRCUITBREAKER_RESET_TIME
  value: '1'
- name: COUCHDB_URL
  value: '{{ include "cem.services.couchdb" . }}'
- name: COUCHDB_USERNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-{{ .Values.couchdb.secretName }}'
      key: username
- name: COUCHDB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-{{ .Values.couchdb.secretName }}'
      key: password
- name: COUCHDB_MAXRETRIES
  value: '15'
- name: COUCHDB_DBNAME
  value: collabopsuser
- name: BACKUPDB_URL
  value: 'https://ACCOUNT.cloudant.com'
- name: BACKUPDB_USERNAME
  value: none
- name: BACKUPDB_PASSWORD
  value: none
- name: BACKUPDB_OPTIONS
  value: '{}'
- name: BACKUPDB_DISABLED
  value: 'true'
- name: BROKERS_URL
  value: '{{ include "cem.services.brokers" . }}'
- name: UISERVER_URL
  value: '{{ include "cem.services.uiserver" . }}'
- name: EVENTPREPROCESSOR_URL
  value: '{{ include "cem.services.eventpreprocessor" . }}'
- name: INCIDENTPROCESSOR_URL
  value: '{{ include "cem.services.incidentprocessor" . }}'
- name: NORMALIZER_URL
  value: '{{ include "cem.services.normalizer" . }}'
- name: INTEGRATIONCONTROLLER_URL
  value: '{{ include "cem.services.integrationcontroller" . }}'
- name: ALERTNOTIFICATION_URL
  value: '{{ include "cem.services.alertnotification" . }}'
- name: RBA_URL
  value: '{{ include "cem.services.rba" . }}'
- name: APMUI_URL
  value: '{{ include "cem.services.apm" . }}'
- name: CEMAPI_URL
  value: '{{ include "cem.services.cemapi" . }}'
- name: FRAMEANCESTORS_URL
  value: '''self'''
- name: METRICREST_URL
  value: '{{ include "cem.services.metricrest" . }}'
- name: NOTIFICATIONPROCESSOR_URL
  value: '{{ include "cem.services.notificationprocessor" . }}'
- name: SCHEDULINGUI_URL
  value: '{{ include "cem.services.schedulingui" . }}'
- name: MODEL_KEYNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-model-secret'
      key: keyname
- name: MODEL_KEYVALUE
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-model-secret'
      key: keyvalue
- name: MODEL_HKEYNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-model-secret'
      key: hkeyname
- name: MODEL_HKEYVALUE
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-model-secret'
      key: hkeyvalue
- name: REDIS_SSH_USERNAME
  value: none
- name: REDIS_SERVER_SECURED
  value: '{{ include "cem.services.redissecured" . }}'
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-ibm-redis-cred-secret'
      key: password
- name: REDIS_SSH_HOSTS
  value: '[]'
- name: REDIS_DST_HOST
  value: '{{ include "cem.services.redishost" . }}'
- name: REDIS_DST_PORT
  value: '6379'
- name: REDIS_DESTINATIONS
  value: '[{"host":"{{ include "cem.services.redishost" . }}","port":6379}]'
- name: REDIS_LOCAL_HOST
  value: 127.0.0.1
- name: REDIS_LOCAL_PORT
  value: '6780'
- name: REDIS_INDEX
  value: '0'
- name: REDIS_KEEP_ALIVE
  value: 'true'
- name: REDIS_SSH_KEY
  value: ''
- name: SSH_READY_TIMEOUT
  value: '30000'
- name: REDIS_SENTINEL_HOST
  value: '{{ include "cem.services.redissentinelsvc" . }}'
- name: REDIS_SENTINEL_PORT
  value: '26379'
- name: REDIS_SENTINEL_NAME
  value: mymaster
- name: REDIS_CONNECT_SENTINELS
  value: 'false'
- name: AUTH_PROVIDER_MODE
  value: '{{ .Values.auth.type }}'
- name: AUTH_REDIRECT_URIS
  value: 'https://{{ .Values.global.ingress.domain }}{{ if ne .Values.global.ingress.port 443.0 }}:{{ .Values.global.ingress.port }}{{ end }}/{{ include "cem.ingress.prefix" . }}cemui,{{ include "cem.services.rba" . }},{{ include "cem.services.uiserver" . }},{{ include "cem.services.apm" . }},https://{{ .Values.global.ingress.domain }}{{ if ne .Values.global.ingress.port 443.0 }}:{{ .Values.global.ingress.port }}{{ end }}/{{ include "cem.ingress.prefix" . }}apmui/auth/cemusers/redirect,https://{{ .Values.global.ingress.domain }}{{ if ne .Values.global.ingress.port 443.0 }}:{{ .Values.global.ingress.port }}{{ end }}/{{ include "cem.ingress.prefix" . }}apmui/callback'
- name: BLUEMIX_API_URL
  value: 'https://api.REGION.bluemix.net'
- name: BLUEMIX_CONSOLE_URL
  value: 'https://cloud.ibm.com'
- name: BLUEMIX_MCCP_URL
  value: 'https://mccp.REGION.bluemix.net/v2/info'
- name: BLUEMIX_LOGIN_URL
  value: 'https://login.REGION.bluemix.net/UAALoginServerWAR/oauth/token'
- name: BLUEMIX_UAA_CLIENTID
  value: none
- name: BLUEMIX_UAA_CLIENTSEC
  value: none
- name: BLUEMIX_SERVICE_PROVIDER_API
  value: 'https://serviceprovider.REGION.bluemix.net'
- name: BLUEMIX_ACCOUNT_MANAGEMENT_API
  value: 'https://accountmanagement.REGION.bluemix.net'
- name: BLUEMIX_USER_PREFERENCES_API
  value: 'https://user-preferences.REGION.bluemix.net'
{{- if eq .Values.auth.type "cf" }}
- name: BLUEID_CLIENTID
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-blueid-auth-secret'
      key: blueidClientId
{{- else }}
- name: BLUEID_CLIENTID
  value: ''
{{- end }}
{{- if eq .Values.auth.type "cf" }}
- name: BLUEID_CLIENTSEC
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-blueid-auth-secret'
      key: blueidClientSecret
{{- else }}
- name: BLUEID_CLIENTSEC
  value: ''
{{- end }}
- name: BLUEID_ISSUERID
  value: '{{.Values.blueid.issuer}}'
- name: BLUEID_AUTHURL
  value: '{{.Values.blueid.authorizationurl}}'
- name: BLUEID_TOKENURL
  value: '{{.Values.blueid.tokenurl}}'
- name: BLUEID_INTROSPECTIONURL
  value: '{{.Values.blueid.introspectionurl}}'
- name: BLUEID_LOGOUTURLS
  value: '["https://www-947.ibm.com/pkmslogout", "https://www-304.ibm.com/pkmslogout"]'
- name: BLUEID_REDIRECT
  value: '{{.Values.blueid.blueidredirect}}'
- name: AUTH_ICP_HOST
  value: '{{ .Values.global.masterIP }}:{{ .Values.global.masterPort }}'
- name: AUTH_ICP_CLIENT_ID
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: oidcclientid
- name: AUTH_ICP_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: oidcclientsecret
- name: AUTH_ICP_IAMROLE_MANAGER
  value: '^crn:v1:icp:private:iam::::role:(Account|Cluster)?Administrator$'
- name: AUTH_ICP_IAMROLE_ENGINEER
  value: '^crn:v1:icp:private:iam::::role:Editor$'
- name: AUTH_ICP_IAMROLE_USER
  value: '^crn:v1:icp:private:iam::::role:(Operator|Viewer)$'
- name: SYSLOG_TARGETS
  value: '[]'
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
{{- end -}}

{{- define "cloudeventmanagement.channelservices.env" -}}
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
- name: COUCHDB_URL
  value: '{{ include "cem.services.couchdb" . }}'
- name: COUCHDB_USERNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-{{ .Values.couchdb.secretName }}'
      key: username
- name: COUCHDB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-{{ .Values.couchdb.secretName }}'
      key: password
- name: COUCHDB_MAXRETRIES
  value: '15'
- name: COUCHDB_DBNAME
  value: collabopsuser
- name: MAINTENANCE_DISABLED_URIS
  value: ''
- name: MAINTENANCE_GAMS
  value: '100'
- name: SYSLOG_TARGETS
  value: '[]'
- name: UAG_URL
  value: '{{ include "cem.services.cemusers" . }}'
- name: UAG_USERNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: username
- name: UAG_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: password
- name: UAG_CLIENT_ID
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: clientid
- name: UAG_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: clientsecret
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
- name: BROKERS_URL
  value: '{{ include "cem.services.brokers" . }}'
- name: UISERVER_URL
  value: '{{ include "cem.services.uiserver" . }}'
- name: EVENTPREPROCESSOR_URL
  value: '{{ include "cem.services.eventpreprocessor" . }}'
- name: INCIDENTPROCESSOR_URL
  value: '{{ include "cem.services.incidentprocessor" . }}'
- name: NORMALIZER_URL
  value: '{{ include "cem.services.normalizer" . }}'
- name: INTEGRATIONCONTROLLER_URL
  value: '{{ include "cem.services.integrationcontroller" . }}'
- name: ALERTNOTIFICATION_URL
  value: '{{ include "cem.services.alertnotification" . }}'
- name: RBA_URL
  value: '{{ include "cem.services.rba" . }}'
- name: APMUI_URL
  value: '{{ include "cem.services.apm" . }}'
- name: CEMAPI_URL
  value: '{{ include "cem.services.cemapi" . }}'
- name: FRAMEANCESTORS_URL
  value: '''self'''
- name: METRICREST_URL
  value: '{{ include "cem.services.metricrest" . }}'
- name: NOTIFICATIONPROCESSOR_URL
  value: '{{ include "cem.services.notificationprocessor" . }}'
- name: SCHEDULINGUI_URL
  value: '{{ include "cem.services.schedulingui" . }}'
- name: MODEL_KEYNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-model-secret'
      key: keyname
- name: MODEL_KEYVALUE
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-model-secret'
      key: keyvalue
- name: MODEL_HKEYNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-model-secret'
      key: hkeyname
- name: MODEL_HKEYVALUE
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-model-secret'
      key: hkeyvalue
- name: GCM_APIKEY
  value: none
- name: EMAIL_MAIL
  value: '{{.Values.email.mail}}'
- name: EMAIL_TYPE
  value: '{{.Values.email.type}}'
- name: EMAIL_SMTPHOST
  value: '{{.Values.email.smtphost}}'
- name: EMAIL_SMTPPORT
  value: '{{.Values.email.smtpport}}'
- name: EMAIL_SMTPAUTH
  value: '{{.Values.email.smtpauth}}'
- name: EMAIL_SMTPUSER
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-email-auth-secret'
      key: smtpuser
- name: EMAIL_SMTPPASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-email-auth-secret'
      key: smtppassword
- name: EMAIL_SMTPREJECTUNAUTHORIZED
  value: '{{.Values.email.smtprejectunauthorized}}'
- name: EMAIL_DEBUG
  value: 'false'
- name: EMAIL_APIKEY
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-email-auth-secret'
      key: apikey
- name: APN_PRODUCTION
  value: 'false'
- name: APN_PASSPHRASE
  value: none
- name: APN_PFX
  value: none
- name: APN_FBINTERVAL
  value: '3600'
- name: NEXMO_KEY
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-nexmo-auth-secret'
      key: key
- name: NEXMO_SECRET
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-nexmo-auth-secret'
      key: secret
- name: NEXMO_SMS
  value: '{{.Values.nexmo.sms}}'
- name: NEXMO_VOICE
  value: '{{.Values.nexmo.voice}}'
- name: NEXMO_ENABLED
  value: '{{.Values.nexmo.enabled}}'
- name: NEXMO_NUMBER
  value: '{{.Values.nexmo.numbers}}'
- name: NEXMO_RESTURL
  value: 'https://rest.nexmo.com'
- name: NEXMO_APIURL
  value: 'https://api.nexmo.com'
- name: NEXMO_COUNTRYBLACKLIST
  value: '{{.Values.nexmo.countryblacklist}}'
- name: REDIS_SSH_USERNAME
  value: none
- name: REDIS_SERVER_SECURED
  value: '{{ include "cem.services.redissecured" . }}'
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-ibm-redis-cred-secret'
      key: password
- name: REDIS_SSH_HOSTS
  value: '[]'
- name: REDIS_DST_HOST
  value: '{{ include "cem.services.redishost" . }}'
- name: REDIS_DST_PORT
  value: '6379'
- name: REDIS_DESTINATIONS
  value: '[{"host":"{{ include "cem.services.redishost" . }}","port":6379}]'
- name: REDIS_LOCAL_HOST
  value: 127.0.0.1
- name: REDIS_LOCAL_PORT
  value: '6780'
- name: REDIS_INDEX
  value: '0'
- name: REDIS_KEEP_ALIVE
  value: 'true'
- name: REDIS_SSH_KEY
  value: ''
- name: SSH_READY_TIMEOUT
  value: '30000'
- name: REDIS_SENTINEL_HOST
  value: '{{ include "cem.services.redissentinelsvc" . }}'
- name: REDIS_SENTINEL_PORT
  value: '26379'
- name: REDIS_SENTINEL_NAME
  value: mymaster
- name: REDIS_CONNECT_SENTINELS
  value: 'false'
- name: SLACK_USERNAME
  value: alertnotification
- name: CHANNELSERVICES_BLACKLIST
  value: '12154033633,12154033634'
- name: CHANNELSERVICES_URL
  value: '{{ include "cem.services.channelservices" . }}/api/send/v1'
- name: CHANNELSERVICES_USERNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-channelservices-cred-secret'
      key: username
- name: CHANNELSERVICES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-channelservices-cred-secret'
      key: password
- name: IMAGE_URLS_CEM50
  value: 'https://ibm.biz/cem50png'
- name: IMAGE_URLS_CEM64
  value: 'https://ibm.biz/cem64png'
- name: IMAGE_URLS_APM50
  value: 'https://ibm.biz/apm50png'
- name: IMAGE_URLS_APM64
  value: 'https://ibm.biz/apm64png'
- name: IMAGE_URLS_EXPLORE
  value: 'https://ibm.biz/explorepng'
{{- end -}}

{{- define "cloudeventmanagement.incidentprocessor.env" -}}
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
- name: BROKERS_URL
  value: '{{ include "cem.services.brokers" . }}'
- name: UISERVER_URL
  value: '{{ include "cem.services.uiserver" . }}'
- name: EVENTPREPROCESSOR_URL
  value: '{{ include "cem.services.eventpreprocessor" . }}'
- name: INCIDENTPROCESSOR_URL
  value: '{{ include "cem.services.incidentprocessor" . }}'
- name: NORMALIZER_URL
  value: '{{ include "cem.services.normalizer" . }}'
- name: INTEGRATIONCONTROLLER_URL
  value: '{{ include "cem.services.integrationcontroller" . }}'
- name: ALERTNOTIFICATION_URL
  value: '{{ include "cem.services.alertnotification" . }}'
- name: RBA_URL
  value: '{{ include "cem.services.rba" . }}'
- name: APMUI_URL
  value: '{{ include "cem.services.apm" . }}'
- name: CEMAPI_URL
  value: '{{ include "cem.services.cemapi" . }}'
- name: FRAMEANCESTORS_URL
  value: '''self'''
- name: METRICREST_URL
  value: '{{ include "cem.services.metricrest" . }}'
- name: NOTIFICATIONPROCESSOR_URL
  value: '{{ include "cem.services.notificationprocessor" . }}'
- name: SCHEDULINGUI_URL
  value: '{{ include "cem.services.schedulingui" . }}'
- name: COUCHDB_URL
  value: '{{ include "cem.services.couchdb" . }}'
- name: COUCHDB_USERNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-{{ .Values.couchdb.secretName }}'
      key: username
- name: COUCHDB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-{{ .Values.couchdb.secretName }}'
      key: password
- name: COUCHDB_MAXRETRIES
  value: '15'
- name: COUCHDB_DBNAME
  value: collabopsuser
- name: DATALAYER_DISABLED
  value: 'false'
- name: DATALAYER_URL
  value: '{{ include "cem.services.datalayer" . }}'
- name: DATALAYER_KEEPALIVE
  value: '10000'
- name: DATALAYER_CA
  value: '[]'
{{- if .Values.global.internalTLS.enabled  }}
- name: DATALAYER_CERT
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-ibm-cem-certificate'
      key: tls.crt
{{- else }}
- name: DATALAYER_CERT
  value: ''
{{- end }}
{{- if .Values.global.internalTLS.enabled  }}
- name: DATALAYER_KEY
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-ibm-cem-certificate'
      key: tls.key
{{- else }}
- name: DATALAYER_KEY
  value: ''
{{- end }}
- name: KAFKA_ENABLED
  value: 'true'
- name: KAFKA_BROKERS_SASL_BROKERS
  value: '{{ include "cem.services.kafkabrokers" . }}'
- name: KAFKA_USERNAME
  value: '{{ .Values.kafka.client.username }}'
- name: KAFKA_PASSWORD
  value: '{{ .Values.kafka.client.password }}'
- name: KAFKA_SECURED
  value: '{{ .Values.kafka.ssl.enabled }}'
- name: KAFKA_SSL_CA_LOCATION
  value: /etc/keystore/ca-cert
- name: KAFKA_SSL_CERT_LOCATION
  value: /etc/keystore/client.pem
- name: KAFKA_SSL_KEY_LOCATION
  value: /etc/keystore/client.key
- name: KAFKA_SSL_KEY_PASSWORD
  value: '{{ .Values.kafka.ssl.password }}'
- name: KAFKA_ADMIN_URL
  value: '{{ include "cem.services.kafkaadmin" . }}'
- name: KAFKA_TOPICS
  value: '[{"name":"cem-notifications","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"},{"name":"cem-serviceinstances","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=-1"},{"name":"incidents","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"},{"name":"incidentResourceDashboard","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"},{"name":"incidentStateDashboard","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"},{"name":"incidentTrendDashboard","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"},{"name":"timeline","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"},{"name":"cem-usage","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"}]'
- name: MAINTENANCE_DISABLED_URIS
  value: ''
- name: MAINTENANCE_GAMS
  value: '100'
- name: MAINTENANCE_KAFKA_CQUEUE_SIZE_KB
  value: '100000'
- name: MAINTENANCE_LCDLR
  value: '10'
- name: MAINTENANCE_POLICY_EXPIRY
  value: '3600'
- name: MAINTENANCE_POLICY_EXPIRY_MEM
  value: '10000'
- name: MAINTENANCE_POLICY_EXPIRY_UPDATE
  value: '30'
- name: MAINTENANCE_POLICY_CACHE_RETRY
  value: '20'
- name: MAINTENANCE_IGNORE_KAFKA_SUBSCRIPTIONS
  value: (AUTOTEST-).*
- name: MAINTENANCE_CHANGES_MAX_DAYS
  value: '30'
- name: MODEL_KEYNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-model-secret'
      key: keyname
- name: MODEL_KEYVALUE
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-model-secret'
      key: keyvalue
- name: MODEL_HKEYNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-model-secret'
      key: hkeyname
- name: MODEL_HKEYVALUE
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-model-secret'
      key: hkeyvalue
- name: SYSLOG_TARGETS
  value: '[]'
- name: UAG_URL
  value: '{{ include "cem.services.cemusers" . }}'
- name: UAG_USERNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: username
- name: UAG_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: password
- name: UAG_CLIENT_ID
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: clientid
- name: UAG_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: clientsecret
- name: MH_BROKERS_SASL_BROKERS
  value: ''
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
- name: MH_MQLIGHT_LOOKUP_URL
  value: 'https://mqlight-lookup-prod01.messagehub.services.us-south.bluemix.net/Lookup?serviceId=INSTANCE_ID'
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
- name: REDIS_SSH_USERNAME
  value: none
- name: REDIS_SERVER_SECURED
  value: '{{ include "cem.services.redissecured" . }}'
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-ibm-redis-cred-secret'
      key: password
- name: REDIS_SSH_HOSTS
  value: '[]'
- name: REDIS_DST_HOST
  value: '{{ include "cem.services.redishost" . }}'
- name: REDIS_DST_PORT
  value: '6379'
- name: REDIS_DESTINATIONS
  value: '[{"host":"{{ include "cem.services.redishost" . }}","port":6379}]'
- name: REDIS_LOCAL_HOST
  value: 127.0.0.1
- name: REDIS_LOCAL_PORT
  value: '6780'
- name: REDIS_INDEX
  value: '0'
- name: REDIS_KEEP_ALIVE
  value: 'true'
- name: REDIS_SSH_KEY
  value: ''
- name: SSH_READY_TIMEOUT
  value: '30000'
- name: REDIS_SENTINEL_HOST
  value: '{{ include "cem.services.redissentinelsvc" . }}'
- name: REDIS_SENTINEL_PORT
  value: '26379'
- name: REDIS_SENTINEL_NAME
  value: mymaster
- name: REDIS_CONNECT_SENTINELS
  value: 'false'
{{- end -}}

{{- define "cloudeventmanagement.integrationcontroller.env" -}}
- name: BLUEMIX_API_URL
  value: 'https://api.REGION.bluemix.net'
- name: BLUEMIX_CONSOLE_URL
  value: 'https://cloud.ibm.com'
- name: BLUEMIX_MCCP_URL
  value: 'https://mccp.REGION.bluemix.net/v2/info'
- name: BLUEMIX_LOGIN_URL
  value: 'https://login.REGION.bluemix.net/UAALoginServerWAR/oauth/token'
- name: BLUEMIX_UAA_CLIENTID
  value: none
- name: BLUEMIX_UAA_CLIENTSEC
  value: none
- name: BLUEMIX_SERVICE_PROVIDER_API
  value: 'https://serviceprovider.REGION.bluemix.net'
- name: BLUEMIX_ACCOUNT_MANAGEMENT_API
  value: 'https://accountmanagement.REGION.bluemix.net'
- name: BLUEMIX_USER_PREFERENCES_API
  value: 'https://user-preferences.REGION.bluemix.net'
{{- if eq .Values.auth.type "cf" }}
- name: BLUEID_CLIENTID
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-blueid-auth-secret'
      key: blueidClientId
{{- else }}
- name: BLUEID_CLIENTID
  value: ''
{{- end }}
{{- if eq .Values.auth.type "cf" }}
- name: BLUEID_CLIENTSEC
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-blueid-auth-secret'
      key: blueidClientSecret
{{- else }}
- name: BLUEID_CLIENTSEC
  value: ''
{{- end }}
- name: BLUEID_ISSUERID
  value: '{{.Values.blueid.issuer}}'
- name: BLUEID_AUTHURL
  value: '{{.Values.blueid.authorizationurl}}'
- name: BLUEID_TOKENURL
  value: '{{.Values.blueid.tokenurl}}'
- name: BLUEID_INTROSPECTIONURL
  value: '{{.Values.blueid.introspectionurl}}'
- name: BLUEID_LOGOUTURLS
  value: '["https://www-947.ibm.com/pkmslogout", "https://www-304.ibm.com/pkmslogout"]'
- name: BLUEID_REDIRECT
  value: '{{.Values.blueid.blueidredirect}}'
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
- name: BROKERS_URL
  value: '{{ include "cem.services.brokers" . }}'
- name: UISERVER_URL
  value: '{{ include "cem.services.uiserver" . }}'
- name: EVENTPREPROCESSOR_URL
  value: '{{ include "cem.services.eventpreprocessor" . }}'
- name: INCIDENTPROCESSOR_URL
  value: '{{ include "cem.services.incidentprocessor" . }}'
- name: NORMALIZER_URL
  value: '{{ include "cem.services.normalizer" . }}'
- name: INTEGRATIONCONTROLLER_URL
  value: '{{ include "cem.services.integrationcontroller" . }}'
- name: ALERTNOTIFICATION_URL
  value: '{{ include "cem.services.alertnotification" . }}'
- name: RBA_URL
  value: '{{ include "cem.services.rba" . }}'
- name: APMUI_URL
  value: '{{ include "cem.services.apm" . }}'
- name: CEMAPI_URL
  value: '{{ include "cem.services.cemapi" . }}'
- name: FRAMEANCESTORS_URL
  value: '''self'''
- name: METRICREST_URL
  value: '{{ include "cem.services.metricrest" . }}'
- name: NOTIFICATIONPROCESSOR_URL
  value: '{{ include "cem.services.notificationprocessor" . }}'
- name: SCHEDULINGUI_URL
  value: '{{ include "cem.services.schedulingui" . }}'
- name: UAG_URL
  value: '{{ include "cem.services.cemusers" . }}'
- name: UAG_USERNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: username
- name: UAG_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: password
- name: UAG_CLIENT_ID
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: clientid
- name: UAG_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: clientsecret
- name: COUCHDB_URL
  value: '{{ include "cem.services.couchdb" . }}'
- name: COUCHDB_USERNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-{{ .Values.couchdb.secretName }}'
      key: username
- name: COUCHDB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-{{ .Values.couchdb.secretName }}'
      key: password
- name: COUCHDB_MAXRETRIES
  value: '15'
- name: COUCHDB_DBNAME
  value: collabopsuser
- name: BOOTSTRAP_URLS
  value: '{{ include "cem.services.normalizer" . }}/api/broker'
- name: BOOTSTRAP_NAMES
  value: normalizer
- name: BOOTSTRAP_DELAY
  value: '60000'
- name: IC_HMAC_SECRET
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-intctl-hmac-secret'
      key: keyvalue
- name: IC_HMAC_NAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-intctl-hmac-secret'
      key: keyname
- name: IC_USERNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-integrationcontroller-cred-secret'
      key: username
- name: IC_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-integrationcontroller-cred-secret'
      key: password
- name: IC_HISTORY_MAX_RECENT
  value: '10'
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
- name: MAINTENANCE_CHANGES_MAX_DAYS
  value: '30'
- name: MODEL_KEYNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-model-secret'
      key: keyname
- name: MODEL_KEYVALUE
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-model-secret'
      key: keyvalue
- name: MODEL_HKEYNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-model-secret'
      key: hkeyname
- name: MODEL_HKEYVALUE
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-model-secret'
      key: hkeyvalue
- name: REDIS_SSH_USERNAME
  value: none
- name: REDIS_SERVER_SECURED
  value: '{{ include "cem.services.redissecured" . }}'
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-ibm-redis-cred-secret'
      key: password
- name: REDIS_SSH_HOSTS
  value: '[]'
- name: REDIS_DST_HOST
  value: '{{ include "cem.services.redishost" . }}'
- name: REDIS_DST_PORT
  value: '6379'
- name: REDIS_DESTINATIONS
  value: '[{"host":"{{ include "cem.services.redishost" . }}","port":6379}]'
- name: REDIS_LOCAL_HOST
  value: 127.0.0.1
- name: REDIS_LOCAL_PORT
  value: '6780'
- name: REDIS_INDEX
  value: '0'
- name: REDIS_KEEP_ALIVE
  value: 'true'
- name: REDIS_SSH_KEY
  value: ''
- name: SSH_READY_TIMEOUT
  value: '30000'
- name: REDIS_SENTINEL_HOST
  value: '{{ include "cem.services.redissentinelsvc" . }}'
- name: REDIS_SENTINEL_PORT
  value: '26379'
- name: REDIS_SENTINEL_NAME
  value: mymaster
- name: REDIS_CONNECT_SENTINELS
  value: 'false'
- name: SYSLOG_TARGETS
  value: '[]'
{{- end -}}

{{- define "cloudeventmanagement.omaasui.env" -}}
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
- name: BROKERS_URL
  value: '{{ include "cem.services.brokers" . }}'
- name: UISERVER_URL
  value: '{{ include "cem.services.uiserver" . }}'
- name: EVENTPREPROCESSOR_URL
  value: '{{ include "cem.services.eventpreprocessor" . }}'
- name: INCIDENTPROCESSOR_URL
  value: '{{ include "cem.services.incidentprocessor" . }}'
- name: NORMALIZER_URL
  value: '{{ include "cem.services.normalizer" . }}'
- name: INTEGRATIONCONTROLLER_URL
  value: '{{ include "cem.services.integrationcontroller" . }}'
- name: ALERTNOTIFICATION_URL
  value: '{{ include "cem.services.alertnotification" . }}'
- name: RBA_URL
  value: '{{ include "cem.services.rba" . }}'
- name: APMUI_URL
  value: '{{ include "cem.services.apm" . }}'
- name: CEMAPI_URL
  value: '{{ include "cem.services.cemapi" . }}'
- name: FRAMEANCESTORS_URL
  value: '''self'''
- name: METRICREST_URL
  value: '{{ include "cem.services.metricrest" . }}'
- name: NOTIFICATIONPROCESSOR_URL
  value: '{{ include "cem.services.notificationprocessor" . }}'
- name: SCHEDULINGUI_URL
  value: '{{ include "cem.services.schedulingui" . }}'
- name: CHANNELSERVICES_URL
  value: '{{ include "cem.services.channelservices" . }}/api/send/v1'
- name: CHANNELSERVICES_USERNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-channelservices-cred-secret'
      key: username
- name: CHANNELSERVICES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-channelservices-cred-secret'
      key: password
- name: KAFKA_ENABLED
  value: 'true'
- name: KAFKA_BROKERS_SASL_BROKERS
  value: '{{ include "cem.services.kafkabrokers" . }}'
- name: KAFKA_USERNAME
  value: '{{ .Values.kafka.client.username }}'
- name: KAFKA_PASSWORD
  value: '{{ .Values.kafka.client.password }}'
- name: KAFKA_SECURED
  value: '{{ .Values.kafka.ssl.enabled }}'
- name: KAFKA_SSL_CA_LOCATION
  value: /etc/keystore/ca-cert
- name: KAFKA_SSL_CERT_LOCATION
  value: /etc/keystore/client.pem
- name: KAFKA_SSL_KEY_LOCATION
  value: /etc/keystore/client.key
- name: KAFKA_SSL_KEY_PASSWORD
  value: '{{ .Values.kafka.ssl.password }}'
- name: KAFKA_ADMIN_URL
  value: '{{ include "cem.services.kafkaadmin" . }}'
- name: KAFKA_TOPICS
  value: '[{"name":"cem-notifications","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"},{"name":"cem-serviceinstances","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=-1"},{"name":"incidents","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"},{"name":"incidentResourceDashboard","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"},{"name":"incidentStateDashboard","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"},{"name":"incidentTrendDashboard","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"},{"name":"timeline","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"},{"name":"cem-usage","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"}]'
- name: MH_MQLIGHT_LOOKUP_URL
  value: 'https://mqlight-lookup-prod01.messagehub.services.us-south.bluemix.net/Lookup?serviceId=INSTANCE_ID'
- name: MH_BROKERS_SASL_BROKERS
  value: ''
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
- name: UAG_URL
  value: '{{ include "cem.services.cemusers" . }}'
- name: UAG_USERNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: username
- name: UAG_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: password
- name: UAG_CLIENT_ID
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: clientid
- name: UAG_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: clientsecret
- name: REDIS_SSH_USERNAME
  value: none
- name: REDIS_SERVER_SECURED
  value: '{{ include "cem.services.redissecured" . }}'
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-ibm-redis-cred-secret'
      key: password
- name: REDIS_SSH_HOSTS
  value: '[]'
- name: REDIS_DST_HOST
  value: '{{ include "cem.services.redishost" . }}'
- name: REDIS_DST_PORT
  value: '6379'
- name: REDIS_DESTINATIONS
  value: '[{"host":"{{ include "cem.services.redishost" . }}","port":6379}]'
- name: REDIS_LOCAL_HOST
  value: 127.0.0.1
- name: REDIS_LOCAL_PORT
  value: '6780'
- name: REDIS_INDEX
  value: '0'
- name: REDIS_KEEP_ALIVE
  value: 'true'
- name: REDIS_SSH_KEY
  value: ''
- name: SSH_READY_TIMEOUT
  value: '30000'
- name: REDIS_SENTINEL_HOST
  value: '{{ include "cem.services.redissentinelsvc" . }}'
- name: REDIS_SENTINEL_PORT
  value: '26379'
- name: REDIS_SENTINEL_NAME
  value: mymaster
- name: REDIS_CONNECT_SENTINELS
  value: 'false'
- name: AUTH_SESSION_SECRET
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-event-analytics-ui-session-secret'
      key: session
- name: AUTH_SESSION_TTL
  value: '7200'
- name: BLUEMIX_API_URL
  value: 'https://api.REGION.bluemix.net'
- name: BLUEMIX_CONSOLE_URL
  value: 'https://cloud.ibm.com'
- name: BLUEMIX_MCCP_URL
  value: 'https://mccp.REGION.bluemix.net/v2/info'
- name: BLUEMIX_LOGIN_URL
  value: 'https://login.REGION.bluemix.net/UAALoginServerWAR/oauth/token'
- name: BLUEMIX_UAA_CLIENTID
  value: none
- name: BLUEMIX_UAA_CLIENTSEC
  value: none
- name: BLUEMIX_SERVICE_PROVIDER_API
  value: 'https://serviceprovider.REGION.bluemix.net'
- name: BLUEMIX_ACCOUNT_MANAGEMENT_API
  value: 'https://accountmanagement.REGION.bluemix.net'
- name: BLUEMIX_USER_PREFERENCES_API
  value: 'https://user-preferences.REGION.bluemix.net'
{{- if eq .Values.auth.type "cf" }}
- name: BLUEID_CLIENTID
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-blueid-auth-secret'
      key: blueidClientId
{{- else }}
- name: BLUEID_CLIENTID
  value: ''
{{- end }}
{{- if eq .Values.auth.type "cf" }}
- name: BLUEID_CLIENTSEC
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-blueid-auth-secret'
      key: blueidClientSecret
{{- else }}
- name: BLUEID_CLIENTSEC
  value: ''
{{- end }}
- name: BLUEID_ISSUERID
  value: '{{.Values.blueid.issuer}}'
- name: BLUEID_AUTHURL
  value: '{{.Values.blueid.authorizationurl}}'
- name: BLUEID_TOKENURL
  value: '{{.Values.blueid.tokenurl}}'
- name: BLUEID_INTROSPECTIONURL
  value: '{{.Values.blueid.introspectionurl}}'
- name: BLUEID_LOGOUTURLS
  value: '["https://www-947.ibm.com/pkmslogout", "https://www-304.ibm.com/pkmslogout"]'
- name: BLUEID_REDIRECT
  value: '{{.Values.blueid.blueidredirect}}'
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
- name: SEGMENT_KEY
  value: ''
- name: SEGMENT_ENABLED
  value: 'false'
- name: CEMSERVICEBROKER_APIURL
  value: '{{ include "cem.services.cemapi" . }}'
- name: MCM_HEADERURL
  value: '{{ .Values.global.masterIP }}:{{ .Values.global.masterPort }}'
- name: UI_MAX_LISTENERS
  value: '200'
- name: UI_XSRF_BACKWARD
  value: 'false'
- name: SYSLOG_TARGETS
  value: '[]'
{{- end -}}

{{- define "cloudeventmanagement.eventpreprocessor.env" -}}
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
- name: BROKERS_URL
  value: '{{ include "cem.services.brokers" . }}'
- name: UISERVER_URL
  value: '{{ include "cem.services.uiserver" . }}'
- name: EVENTPREPROCESSOR_URL
  value: '{{ include "cem.services.eventpreprocessor" . }}'
- name: INCIDENTPROCESSOR_URL
  value: '{{ include "cem.services.incidentprocessor" . }}'
- name: NORMALIZER_URL
  value: '{{ include "cem.services.normalizer" . }}'
- name: INTEGRATIONCONTROLLER_URL
  value: '{{ include "cem.services.integrationcontroller" . }}'
- name: ALERTNOTIFICATION_URL
  value: '{{ include "cem.services.alertnotification" . }}'
- name: RBA_URL
  value: '{{ include "cem.services.rba" . }}'
- name: APMUI_URL
  value: '{{ include "cem.services.apm" . }}'
- name: CEMAPI_URL
  value: '{{ include "cem.services.cemapi" . }}'
- name: FRAMEANCESTORS_URL
  value: '''self'''
- name: METRICREST_URL
  value: '{{ include "cem.services.metricrest" . }}'
- name: NOTIFICATIONPROCESSOR_URL
  value: '{{ include "cem.services.notificationprocessor" . }}'
- name: SCHEDULINGUI_URL
  value: '{{ include "cem.services.schedulingui" . }}'
- name: COUCHDB_URL
  value: '{{ include "cem.services.couchdb" . }}'
- name: COUCHDB_USERNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-{{ .Values.couchdb.secretName }}'
      key: username
- name: COUCHDB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-{{ .Values.couchdb.secretName }}'
      key: password
- name: COUCHDB_MAXRETRIES
  value: '15'
- name: COUCHDB_DBNAME
  value: collabopsuser
- name: DATALAYER_DISABLED
  value: 'false'
- name: DATALAYER_URL
  value: '{{ include "cem.services.datalayer" . }}'
- name: DATALAYER_KEEPALIVE
  value: '10000'
- name: DATALAYER_CA
  value: '[]'
{{- if .Values.global.internalTLS.enabled  }}
- name: DATALAYER_CERT
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-ibm-cem-certificate'
      key: tls.crt
{{- else }}
- name: DATALAYER_CERT
  value: ''
{{- end }}
{{- if .Values.global.internalTLS.enabled  }}
- name: DATALAYER_KEY
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-ibm-cem-certificate'
      key: tls.key
{{- else }}
- name: DATALAYER_KEY
  value: ''
{{- end }}
- name: MAINTENANCE_DISABLED_URIS
  value: ''
- name: MAINTENANCE_GAMS
  value: '100'
- name: MAINTENANCE_POLICY_EXPIRY
  value: '3600'
- name: MAINTENANCE_POLICY_EXPIRY_MEM
  value: '10000'
- name: MAINTENANCE_POLICY_EXPIRY_UPDATE
  value: '30'
- name: MAINTENANCE_POLICY_CACHE_RETRY
  value: '20'
- name: MAINTENANCE_CHANGES_MAX_DAYS
  value: '30'
- name: SYSLOG_TARGETS
  value: '[]'
- name: UAG_URL
  value: '{{ include "cem.services.cemusers" . }}'
- name: UAG_USERNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: username
- name: UAG_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: password
- name: UAG_CLIENT_ID
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: clientid
- name: UAG_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: clientsecret
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
- name: MODEL_KEYNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-model-secret'
      key: keyname
- name: MODEL_KEYVALUE
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-model-secret'
      key: keyvalue
- name: MODEL_HKEYNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-model-secret'
      key: hkeyname
- name: MODEL_HKEYVALUE
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-model-secret'
      key: hkeyvalue
- name: REDIS_SSH_USERNAME
  value: none
- name: REDIS_SERVER_SECURED
  value: '{{ include "cem.services.redissecured" . }}'
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-ibm-redis-cred-secret'
      key: password
- name: REDIS_SSH_HOSTS
  value: '[]'
- name: REDIS_DST_HOST
  value: '{{ include "cem.services.redishost" . }}'
- name: REDIS_DST_PORT
  value: '6379'
- name: REDIS_DESTINATIONS
  value: '[{"host":"{{ include "cem.services.redishost" . }}","port":6379}]'
- name: REDIS_LOCAL_HOST
  value: 127.0.0.1
- name: REDIS_LOCAL_PORT
  value: '6780'
- name: REDIS_INDEX
  value: '0'
- name: REDIS_KEEP_ALIVE
  value: 'true'
- name: REDIS_SSH_KEY
  value: ''
- name: SSH_READY_TIMEOUT
  value: '30000'
- name: REDIS_SENTINEL_HOST
  value: '{{ include "cem.services.redissentinelsvc" . }}'
- name: REDIS_SENTINEL_PORT
  value: '26379'
- name: REDIS_SENTINEL_NAME
  value: mymaster
- name: REDIS_CONNECT_SENTINELS
  value: 'false'
- name: KAFKA_ENABLED
  value: 'true'
- name: KAFKA_BROKERS_SASL_BROKERS
  value: '{{ include "cem.services.kafkabrokers" . }}'
- name: KAFKA_USERNAME
  value: '{{ .Values.kafka.client.username }}'
- name: KAFKA_PASSWORD
  value: '{{ .Values.kafka.client.password }}'
- name: KAFKA_SECURED
  value: '{{ .Values.kafka.ssl.enabled }}'
- name: KAFKA_SSL_CA_LOCATION
  value: /etc/keystore/ca-cert
- name: KAFKA_SSL_CERT_LOCATION
  value: /etc/keystore/client.pem
- name: KAFKA_SSL_KEY_LOCATION
  value: /etc/keystore/client.key
- name: KAFKA_SSL_KEY_PASSWORD
  value: '{{ .Values.kafka.ssl.password }}'
- name: KAFKA_ADMIN_URL
  value: '{{ include "cem.services.kafkaadmin" . }}'
- name: KAFKA_TOPICS
  value: '[{"name":"cem-notifications","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"},{"name":"cem-serviceinstances","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=-1"},{"name":"incidents","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"},{"name":"incidentResourceDashboard","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"},{"name":"incidentStateDashboard","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"},{"name":"incidentTrendDashboard","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"},{"name":"timeline","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"},{"name":"cem-usage","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"}]'
- name: MH_BROKERS_SASL_BROKERS
  value: ''
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
- name: MH_MQLIGHT_LOOKUP_URL
  value: 'https://mqlight-lookup-prod01.messagehub.services.us-south.bluemix.net/Lookup?serviceId=INSTANCE_ID'
- name: MCMSEARCH_SEARCHURL
  value: 'https://search-search-api.kube-system.svc:4010/searchapi/graphql'
- name: MCMSEARCH_SERVICEAPIKEY
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-service-secret'
      key: cem-service-apikey
{{- end -}}

{{- define "cloudeventmanagement.notificationprocessor.env" -}}
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
- name: CHANNELSERVICES_URL
  value: '{{ include "cem.services.channelservices" . }}/api/send/v1'
- name: CHANNELSERVICES_USERNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-channelservices-cred-secret'
      key: username
- name: CHANNELSERVICES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-channelservices-cred-secret'
      key: password
- name: CIRCUITBREAKER_TRIP_LIMIT
  value: '1000000'
- name: CIRCUITBREAKER_RESET_TIME
  value: '1'
- name: UAG_URL
  value: '{{ include "cem.services.cemusers" . }}'
- name: UAG_USERNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: username
- name: UAG_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: password
- name: UAG_CLIENT_ID
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: clientid
- name: UAG_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: clientsecret
- name: COUCHDB_URL
  value: '{{ include "cem.services.couchdb" . }}'
- name: COUCHDB_USERNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-{{ .Values.couchdb.secretName }}'
      key: username
- name: COUCHDB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-{{ .Values.couchdb.secretName }}'
      key: password
- name: COUCHDB_MAXRETRIES
  value: '15'
- name: COUCHDB_DBNAME
  value: collabopsuser
- name: DATALAYER_DISABLED
  value: 'false'
- name: DATALAYER_URL
  value: '{{ include "cem.services.datalayer" . }}'
- name: DATALAYER_KEEPALIVE
  value: '10000'
- name: DATALAYER_CA
  value: '[]'
{{- if .Values.global.internalTLS.enabled  }}
- name: DATALAYER_CERT
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-ibm-cem-certificate'
      key: tls.crt
{{- else }}
- name: DATALAYER_CERT
  value: ''
{{- end }}
{{- if .Values.global.internalTLS.enabled  }}
- name: DATALAYER_KEY
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-ibm-cem-certificate'
      key: tls.key
{{- else }}
- name: DATALAYER_KEY
  value: ''
{{- end }}
- name: IC_USERNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-integrationcontroller-cred-secret'
      key: username
- name: IC_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-integrationcontroller-cred-secret'
      key: password
- name: KAFKA_ENABLED
  value: 'true'
- name: KAFKA_BROKERS_SASL_BROKERS
  value: '{{ include "cem.services.kafkabrokers" . }}'
- name: KAFKA_USERNAME
  value: '{{ .Values.kafka.client.username }}'
- name: KAFKA_PASSWORD
  value: '{{ .Values.kafka.client.password }}'
- name: KAFKA_SECURED
  value: '{{ .Values.kafka.ssl.enabled }}'
- name: KAFKA_SSL_CA_LOCATION
  value: /etc/keystore/ca-cert
- name: KAFKA_SSL_CERT_LOCATION
  value: /etc/keystore/client.pem
- name: KAFKA_SSL_KEY_LOCATION
  value: /etc/keystore/client.key
- name: KAFKA_SSL_KEY_PASSWORD
  value: '{{ .Values.kafka.ssl.password }}'
- name: KAFKA_ADMIN_URL
  value: '{{ include "cem.services.kafkaadmin" . }}'
- name: KAFKA_TOPICS
  value: '[{"name":"cem-notifications","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"},{"name":"cem-serviceinstances","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=-1"},{"name":"incidents","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"},{"name":"incidentResourceDashboard","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"},{"name":"incidentStateDashboard","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"},{"name":"incidentTrendDashboard","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"},{"name":"timeline","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"},{"name":"cem-usage","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"}]'
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
- name: MAINTENANCE_KAFKA_CQUEUE_SIZE_KB
  value: '100000'
- name: MAINTENANCE_IGNORE_KAFKA_SUBSCRIPTIONS
  value: (AUTOTEST-).*
- name: MH_BROKERS_SASL_BROKERS
  value: ''
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
- name: MH_MQLIGHT_LOOKUP_URL
  value: 'https://mqlight-lookup-prod01.messagehub.services.us-south.bluemix.net/Lookup?serviceId=INSTANCE_ID'
- name: BROKERS_URL
  value: '{{ include "cem.services.brokers" . }}'
- name: UISERVER_URL
  value: '{{ include "cem.services.uiserver" . }}'
- name: EVENTPREPROCESSOR_URL
  value: '{{ include "cem.services.eventpreprocessor" . }}'
- name: INCIDENTPROCESSOR_URL
  value: '{{ include "cem.services.incidentprocessor" . }}'
- name: NORMALIZER_URL
  value: '{{ include "cem.services.normalizer" . }}'
- name: INTEGRATIONCONTROLLER_URL
  value: '{{ include "cem.services.integrationcontroller" . }}'
- name: ALERTNOTIFICATION_URL
  value: '{{ include "cem.services.alertnotification" . }}'
- name: RBA_URL
  value: '{{ include "cem.services.rba" . }}'
- name: APMUI_URL
  value: '{{ include "cem.services.apm" . }}'
- name: CEMAPI_URL
  value: '{{ include "cem.services.cemapi" . }}'
- name: FRAMEANCESTORS_URL
  value: '''self'''
- name: METRICREST_URL
  value: '{{ include "cem.services.metricrest" . }}'
- name: NOTIFICATIONPROCESSOR_URL
  value: '{{ include "cem.services.notificationprocessor" . }}'
- name: SCHEDULINGUI_URL
  value: '{{ include "cem.services.schedulingui" . }}'
- name: MODEL_KEYNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-model-secret'
      key: keyname
- name: MODEL_KEYVALUE
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-model-secret'
      key: keyvalue
- name: MODEL_HKEYNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-model-secret'
      key: hkeyname
- name: MODEL_HKEYVALUE
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-model-secret'
      key: hkeyvalue
- name: SYSLOG_TARGETS
  value: '[]'
- name: USAGE_NOTIFY_PERCENTS
  value: '75,90,100'
{{- end -}}

{{- define "cloudeventmanagement.normalizer.env" -}}
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
- name: IC_USERNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-integrationcontroller-cred-secret'
      key: username
- name: IC_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-integrationcontroller-cred-secret'
      key: password
- name: BROKERS_URL
  value: '{{ include "cem.services.brokers" . }}'
- name: UISERVER_URL
  value: '{{ include "cem.services.uiserver" . }}'
- name: EVENTPREPROCESSOR_URL
  value: '{{ include "cem.services.eventpreprocessor" . }}'
- name: INCIDENTPROCESSOR_URL
  value: '{{ include "cem.services.incidentprocessor" . }}'
- name: NORMALIZER_URL
  value: '{{ include "cem.services.normalizer" . }}'
- name: INTEGRATIONCONTROLLER_URL
  value: '{{ include "cem.services.integrationcontroller" . }}'
- name: ALERTNOTIFICATION_URL
  value: '{{ include "cem.services.alertnotification" . }}'
- name: RBA_URL
  value: '{{ include "cem.services.rba" . }}'
- name: APMUI_URL
  value: '{{ include "cem.services.apm" . }}'
- name: CEMAPI_URL
  value: '{{ include "cem.services.cemapi" . }}'
- name: FRAMEANCESTORS_URL
  value: '''self'''
- name: METRICREST_URL
  value: '{{ include "cem.services.metricrest" . }}'
- name: NOTIFICATIONPROCESSOR_URL
  value: '{{ include "cem.services.notificationprocessor" . }}'
- name: SCHEDULINGUI_URL
  value: '{{ include "cem.services.schedulingui" . }}'
- name: CEMSLACK_CLIENTID
  value: none
- name: CEMSLACK_CLIENTSECRET
  value: none
- name: INCOMING_EMAIL_DOMAIN
  value: ''
- name: UAG_URL
  value: '{{ include "cem.services.cemusers" . }}'
- name: UAG_USERNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: username
- name: UAG_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: password
- name: UAG_CLIENT_ID
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: clientid
- name: UAG_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: clientsecret
- name: REDIS_SSH_USERNAME
  value: none
- name: REDIS_SERVER_SECURED
  value: '{{ include "cem.services.redissecured" . }}'
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-ibm-redis-cred-secret'
      key: password
- name: REDIS_SSH_HOSTS
  value: '[]'
- name: REDIS_DST_HOST
  value: '{{ include "cem.services.redishost" . }}'
- name: REDIS_DST_PORT
  value: '6379'
- name: REDIS_DESTINATIONS
  value: '[{"host":"{{ include "cem.services.redishost" . }}","port":6379}]'
- name: REDIS_LOCAL_HOST
  value: 127.0.0.1
- name: REDIS_LOCAL_PORT
  value: '6780'
- name: REDIS_INDEX
  value: '0'
- name: REDIS_KEEP_ALIVE
  value: 'true'
- name: REDIS_SSH_KEY
  value: ''
- name: SSH_READY_TIMEOUT
  value: '30000'
- name: REDIS_SENTINEL_HOST
  value: '{{ include "cem.services.redissentinelsvc" . }}'
- name: REDIS_SENTINEL_PORT
  value: '26379'
- name: REDIS_SENTINEL_NAME
  value: mymaster
- name: REDIS_CONNECT_SENTINELS
  value: 'false'
- name: BLUEMIX_API_URL
  value: 'https://api.REGION.bluemix.net'
- name: BLUEMIX_CONSOLE_URL
  value: 'https://cloud.ibm.com'
- name: BLUEMIX_MCCP_URL
  value: 'https://mccp.REGION.bluemix.net/v2/info'
- name: BLUEMIX_LOGIN_URL
  value: 'https://login.REGION.bluemix.net/UAALoginServerWAR/oauth/token'
- name: BLUEMIX_UAA_CLIENTID
  value: none
- name: BLUEMIX_UAA_CLIENTSEC
  value: none
- name: BLUEMIX_SERVICE_PROVIDER_API
  value: 'https://serviceprovider.REGION.bluemix.net'
- name: BLUEMIX_ACCOUNT_MANAGEMENT_API
  value: 'https://accountmanagement.REGION.bluemix.net'
- name: BLUEMIX_USER_PREFERENCES_API
  value: 'https://user-preferences.REGION.bluemix.net'
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
- name: WATSONWORKSPACE_APPID
  value: none
- name: WATSONWORKSPACE_APPSECRET
  value: none
- name: WATSONWORKSPACE_SHARETOKEN
  value: none
- name: DOWNLOAD_SECRET
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-download-secret'
      key: keyvalue
- name: DOWNLOAD_TIMEOUT
  value: '300000'
- name: COUCHDB_URL
  value: '{{ include "cem.services.couchdb" . }}'
- name: COUCHDB_USERNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-{{ .Values.couchdb.secretName }}'
      key: username
- name: COUCHDB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-{{ .Values.couchdb.secretName }}'
      key: password
- name: COUCHDB_MAXRETRIES
  value: '15'
- name: COUCHDB_DBNAME
  value: collabopsuser
- name: MODEL_KEYNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-model-secret'
      key: keyname
- name: MODEL_KEYVALUE
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-model-secret'
      key: keyvalue
- name: MODEL_HKEYNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-model-secret'
      key: hkeyname
- name: MODEL_HKEYVALUE
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-model-secret'
      key: hkeyvalue
{{- end -}}

{{- define "cloudeventmanagement.schedulingui.env" -}}
- name: CHANNELSERVICES_URL
  value: '{{ include "cem.services.channelservices" . }}/api/send/v1'
- name: CHANNELSERVICES_USERNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-channelservices-cred-secret'
      key: username
- name: CHANNELSERVICES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-channelservices-cred-secret'
      key: password
- name: UAG_URL
  value: '{{ include "cem.services.cemusers" . }}'
- name: UAG_USERNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: username
- name: UAG_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: password
- name: UAG_CLIENT_ID
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: clientid
- name: UAG_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-cemusers-cred-secret'
      key: clientsecret
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
- name: KAFKA_ENABLED
  value: 'true'
- name: KAFKA_BROKERS_SASL_BROKERS
  value: '{{ include "cem.services.kafkabrokers" . }}'
- name: KAFKA_USERNAME
  value: '{{ .Values.kafka.client.username }}'
- name: KAFKA_PASSWORD
  value: '{{ .Values.kafka.client.password }}'
- name: KAFKA_SECURED
  value: '{{ .Values.kafka.ssl.enabled }}'
- name: KAFKA_SSL_CA_LOCATION
  value: /etc/keystore/ca-cert
- name: KAFKA_SSL_CERT_LOCATION
  value: /etc/keystore/client.pem
- name: KAFKA_SSL_KEY_LOCATION
  value: /etc/keystore/client.key
- name: KAFKA_SSL_KEY_PASSWORD
  value: '{{ .Values.kafka.ssl.password }}'
- name: KAFKA_ADMIN_URL
  value: '{{ include "cem.services.kafkaadmin" . }}'
- name: KAFKA_TOPICS
  value: '[{"name":"cem-notifications","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"},{"name":"cem-serviceinstances","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=-1"},{"name":"incidents","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"},{"name":"incidentResourceDashboard","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"},{"name":"incidentStateDashboard","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"},{"name":"incidentTrendDashboard","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"},{"name":"timeline","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"},{"name":"cem-usage","partitions":6,"replication":"{{ .Values.global.kafka.clusterSize }}","config":"retention.ms=3600000"}]'
- name: MH_BROKERS_SASL_BROKERS
  value: ''
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
- name: MH_MQLIGHT_LOOKUP_URL
  value: 'https://mqlight-lookup-prod01.messagehub.services.us-south.bluemix.net/Lookup?serviceId=INSTANCE_ID'
- name: COUCHDB_TIMEOUT
  value: '20000'
- name: COUCHDB_URL
  value: '{{ include "cem.services.couchdb" . }}'
- name: COUCHDB_USERNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-{{ .Values.couchdb.secretName }}'
      key: username
- name: COUCHDB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-{{ .Values.couchdb.secretName }}'
      key: password
- name: COUCHDB_MAXRETRIES
  value: '15'
- name: COUCHDB_DBNAME
  value: collabopsuser
- name: MAINTENANCE_DISABLEDFEATURES
  value: ''
- name: MAINTENANCE_GLOBALAGENTMAXSOCKETS
  value: '100'
- name: MAINTENANCE_KAFKA_CQUEUE_SIZE_KB
  value: '100000'
- name: MAINTENANCE_SHORTIDQUIESCENTTIMEOUT
  value: '6000'
- name: MAINTENANCE_USESHORTIDVIEW
  value: 'false'
- name: BROKERS_URL
  value: '{{ include "cem.services.brokers" . }}'
- name: UISERVER_URL
  value: '{{ include "cem.services.uiserver" . }}'
- name: EVENTPREPROCESSOR_URL
  value: '{{ include "cem.services.eventpreprocessor" . }}'
- name: INCIDENTPROCESSOR_URL
  value: '{{ include "cem.services.incidentprocessor" . }}'
- name: NORMALIZER_URL
  value: '{{ include "cem.services.normalizer" . }}'
- name: INTEGRATIONCONTROLLER_URL
  value: '{{ include "cem.services.integrationcontroller" . }}'
- name: ALERTNOTIFICATION_URL
  value: '{{ include "cem.services.alertnotification" . }}'
- name: RBA_URL
  value: '{{ include "cem.services.rba" . }}'
- name: APMUI_URL
  value: '{{ include "cem.services.apm" . }}'
- name: CEMAPI_URL
  value: '{{ include "cem.services.cemapi" . }}'
- name: FRAMEANCESTORS_URL
  value: '''self'''
- name: METRICREST_URL
  value: '{{ include "cem.services.metricrest" . }}'
- name: NOTIFICATIONPROCESSOR_URL
  value: '{{ include "cem.services.notificationprocessor" . }}'
- name: SCHEDULINGUI_URL
  value: '{{ include "cem.services.schedulingui" . }}'
- name: MODEL_KEYNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-model-secret'
      key: keyname
- name: MODEL_KEYVALUE
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-model-secret'
      key: keyvalue
- name: MODEL_HKEYNAME
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-model-secret'
      key: hkeyname
- name: MODEL_HKEYVALUE
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-model-secret'
      key: hkeyvalue
- name: REDIS_SSH_USERNAME
  value: none
- name: REDIS_SERVER_SECURED
  value: '{{ include "cem.services.redissecured" . }}'
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: '{{ template "cem.releasename" . }}-cem-ibm-redis-cred-secret'
      key: password
- name: REDIS_SSH_HOSTS
  value: '[]'
- name: REDIS_DST_HOST
  value: '{{ include "cem.services.redishost" . }}'
- name: REDIS_DST_PORT
  value: '6379'
- name: REDIS_DESTINATIONS
  value: '[{"host":"{{ include "cem.services.redishost" . }}","port":6379}]'
- name: REDIS_LOCAL_HOST
  value: 127.0.0.1
- name: REDIS_LOCAL_PORT
  value: '6780'
- name: REDIS_INDEX
  value: '0'
- name: REDIS_KEEP_ALIVE
  value: 'true'
- name: REDIS_SSH_KEY
  value: ''
- name: SSH_READY_TIMEOUT
  value: '30000'
- name: REDIS_SENTINEL_HOST
  value: '{{ include "cem.services.redissentinelsvc" . }}'
- name: REDIS_SENTINEL_PORT
  value: '26379'
- name: REDIS_SENTINEL_NAME
  value: mymaster
- name: REDIS_CONNECT_SENTINELS
  value: 'false'
- name: SYSLOG_TARGETS
  value: '[]'
- name: BSS_INTERVAL
  value: '7200'
- name: BSS_SUPPRESSREMINDERS
  value: 'false'
- name: BSS_PROCESSSUBS
  value: '20'
- name: RBAADMINACCESS_USER
  value: ''
- name: RBAADMINACCESS_PASSWORD
  value: ''
{{- end -}}
