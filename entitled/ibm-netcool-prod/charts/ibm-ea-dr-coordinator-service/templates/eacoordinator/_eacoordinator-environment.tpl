{{- /*
Creates the environment for the UI server
*/ -}}
{{- define "ibm-ea-dr-coordinator-service.eacoordinator.environment" -}}

env:
  - name: LICENSE
    value: {{ .Values.global.license | quote }}

  - name: LOGGING_LEVEL
    value: 'INFO'

  - name: COORDINATOR_LOGGING_LEVEL
    value: {{ .Values.coordinatorSettings.logLevel | quote }}

  - name: API_USERNAME
    valueFrom:
     secretKeyRef:
      name: {{ printf "%s-coordinator-api-secret" .Release.Name | quote }}
      key: api_username

  - name: API_PASSWORD
    valueFrom:
     secretKeyRef:
      name: {{ printf "%s-coordinator-api-secret" .Release.Name | quote }}
      key: api_password
  - name: IS_BACKUP
    value: {{ .Values.global.serviceContinuity.isBackupDeployment | quote }}
  - name: DR_PROXY_URLS
    value: {{ .Values.coordinatorSettings.backupDeploymentSettings.proxyURLs | quote }}
  - name: COORDINATOR_USER
    valueFrom:
     secretKeyRef:
      name: {{ printf "%s-coordinator-api-secret" .Release.Name | quote }}
      key: primary_api_username
  - name: COORDINATOR_PASSWORD
    valueFrom:
     secretKeyRef:
      name: {{ printf "%s-coordinator-api-secret" .Release.Name | quote }}
      key: primary_api_password

  - name: LOCAL_NORMALIZER_URL
    value: {{ printf "http://%s-ibm-hdm-analytics-dev-normalizer-aggregationservice:5600" .Release.Name| quote }}
  - name: LOCAL_NORMALIZER_USER
    valueFrom:
      secretKeyRef:
        name: {{ .Release.Name }}-systemauth-secret
        key: username

  - name: LOCAL_NORMALIZER_PASSWORD
    valueFrom:
      secretKeyRef:
        name: {{ .Release.Name }}-systemauth-secret
        key: password

  - name: REDIS_SENTINEL_HOST
    value: '{{ .Release.Name }}-ibm-redis'
  - name: REDIS_SENTINEL_PORT
    value: {{ .Values.coordinatorSettings.redis.sentinelPort | quote}}
  - name: REDIS_SENTINEL_NAME
    value: {{ .Values.coordinatorSettings.redis.sentinelName | quote }}
  - name: REDIS_PASSWORD
    valueFrom:
      secretKeyRef:
        name: {{ default (nospace (cat .Release.Name "-ibm-redis-authsecret")) (tpl .Values.ibmRedis.auth.authSecretName .) }}
        key: password

  - name: PROXY_CONNECTION_CHECK_SIZE
    value: {{ .Values.coordinatorSettings.backupDeploymentSettings.numberOfProxyConnectionCheck | quote}}
  - name: PROXY_CONNECTION_CHECK_MAX_WINDOW_SECONDS
    value: {{ .Values.coordinatorSettings.backupDeploymentSettings.proxyCatchMaxSeconds | quote}}
  - name: RETRY_INTERVAL_IN_MILLISECONDS
    value: {{ .Values.coordinatorSettings.backupDeploymentSettings.intervalBetweenRetry | quote}}
  - name: DR_PROXY_SSL_CHECK
    value: {{ .Values.coordinatorSettings.backupDeploymentSettings.proxySSLCheck | quote}}
  - name: DR_PROXY_CERTIFICATE_DIR
    value: '/opt/app/certs'
  - name: DR_PROXY_TRUST_STORE_LOCATION
    value: '/opt/app/dr_proxy.tks'
  - name: DR_PROXY_TRUST_STORE_PASSWORD
    valueFrom:
     secretKeyRef:
      name: {{ printf "%s-coordinator-api-secret" .Release.Name | quote }}
      key: trust_store_password

{{- end -}}
