{{/* vim: set filetype=mustache: */}}

{{- /* ################################### IMAGES ################################### */ -}}
{{- define "ibm-watson-lt.affinity" -}}
  {{- if .Values.global.affinity -}}
    {{ toYaml .Values.global.affinity }}
  {{- else -}}
    {{ include "sch.affinity.nodeAffinity" (list . .sch.chart.nodeAffinity) }}
  {{- end -}}
{{- end -}}
  
{{- /* ################################### IMAGES ################################### */ -}}

{{- define "ibm-watson-lt.repo" -}}
{{ if .Values.global.dockerRegistryPrefix }}{{ trimSuffix "/" .Values.global.dockerRegistryPrefix }}/{{ end }}
{{- end -}}
{{- /* PULL SECRET TEMPLATE */ -}}
{{- define "ibm-watson-lt.pullSecretTemplate" -}}
{{- if tpl .Values.global.image.pullSecret . }}
imagePullSecrets:
- name: {{ tpl .Values.global.image.pullSecret . | quote }}
{{- end }}
{{- end }}

{{- /* PULL POLICY */ -}}
{{- define "ibm-watson-lt.pullPolicyTemplate" -}}
{{- if .Values.global.image -}}{{- if .Values.global.image.pullPolicy -}}
imagePullPolicy: {{ .Values.global.image.pullPolicy }}
{{- end -}}{{- end -}}
{{- end -}}

{{/* Create the name of the service account to use */}}
{{- define "ibm-watson-lt.serviceAccountName" -}}
  {{- if tpl (.Values.global.serviceAccount.name | toString ) . -}}
    {{- tpl  (.Values.global.serviceAccount.name | toString ) . | trunc 63 -}}
  {{- else -}}
    {{- printf "%s-sa" .Release.Name -}}
  {{- end -}}
{{- end -}}

{{- /* ################################### SVC ENDPOINTS ################################### */ -}}

{{- define "ibm-watson-lt.apiSvcName" -}}
{{- printf "%s-%s-%s" .Release.Name .Values.global.appName "api" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- define "ibm-watson-lt.dtSvcName" -}}
{{- printf "%s-%s-%s" .Release.Name .Values.global.appName "documents" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- /* ################################### TRANSLATION MODELS ################################### */ -}}
{{- define "ibm-watson-lt.sourceLang" -}}
{{- $id := . -}}
{{ if eq $id "zh-TW-en" }}zh-TW{{ else }}{{ (split "-" $id )._0 }}{{ end }}
{{- end -}}

{{- define "ibm-watson-lt.targetLang" -}}
{{- $id := . -}}
{{- if eq $id "en-zh-TW" -}}zh-TW{{- else -}}
{{- if eq $id "zh-TW-en" -}}en{{ else }}{{ (split "-" $id )._1 }}{{ end }}{{- end -}}
{{- end -}}

{{- define "ibm-watson-lt.modelInsert" -}}
-- connect to database
\c {{ .Values.api.dbConfig.dbname }}
-- select schema
SET search_path TO {{ .Values.api.dbConfig.schemaname }};
{{ range $modelID, $modelConfig := .Values.translationModels }}
{{- $source := (include "ibm-watson-lt.sourceLang" $modelID) -}}
{{- $target := (include "ibm-watson-lt.targetLang" $modelID) -}}
{{- $domain := (split "_" $modelConfig.image.name )._3 -}}
{{- $mid := (printf "%s-%s" $source $target) -}}
{{ if $modelConfig.enabled }}
INSERT INTO MODEL(M_MODEL_ID, M_MQ_NAME, M_NAME, M_TYPE, M_SOURCE_LANGUAGE, M_TARGET_LANGUAGE, M_IS_CUSTOMIZABLE, M_IS_DEFAULT, M_DOMAIN, M_DESCRIPTION, M_STATUS)
    VALUES ('{{ $mid }}','{{ $mid }}','{{ $mid }}','lt','{{ $source }}','{{ $target }}',FALSE,TRUE,'{{ $domain }}','translation from {{ $source }} to {{ $target }}','AVAILABLE') ON CONFLICT DO NOTHING;
{{ else -}}
DELETE FROM model WHERE m_model_id = {{ $mid | squote }};
{{- end -}}
{{- end -}}
{{- end -}}

{{- /* ################################### DB SETUP ################################### */ -}}

{{- define "ibm-watson-lt.pgenv_common" -}}
- name: PGHOST
  value: {{ .Release.Name }}-ibm-postgresql-proxy-svc
- name: PGUSER
  value: {{ .Values.postgres.auth.pgSuperuserName }}
- name: PGPASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ default (printf "%s-ibm-postgresql-auth-secret" .Release.Name ) .Values.postgres.auth.authSecretName }}
      key: "pg_su_password"
- name: PGPORT
  value: {{ .Values.postgres.ports.externalPort | quote }}
- name: PGSSLMODE
  value: require
- name: PGSSLROOTCERT
  value: /etc/ssl/postgres/server.crt.pem
{{- end -}}

{{- define "ibm-watson-lt.pgenv_comp" -}}
- name: PGOPTIONS
  value: "--search_path={{ .dbConfig.schemaname }}"
- name: PGDATABASE
  value: {{ .dbConfig.dbname }}
- name: PGSCHEMA
  value: {{ .dbConfig.schemaname }}
{{- end -}}

{{- define "ibm-watson-lt.pg_cert_volume" -}}
- name: postgres-cert
  secret:
    secretName: {{ default (printf "%s-ibm-postgresql-tls-secret" .Release.Name ) .Values.postgres.tls.tlsSecretName }}
    items:
    - key: tls.crt
      path: server.crt.pem
{{- end -}}
{{- define "ibm-watson-lt.pg_cert_mount" -}}
- name: postgres-cert
  mountPath: /etc/ssl/postgres
{{- end -}}

{{- /* ################################### TLS ################################### */ -}}

{{- /* TLS SECRET NAME TEMPLATE
We assume that the tls secret already exists and is specific to a release, i.e.
there is a single shared tls secret instance per release that is provided by a parent chart.
We allow a parent chart to provide a different template though and pass it
in via .Values.global.tls.secret.nameTpl. In our deployment, we use whatever
template is provided in .Values.global.tls.nameTpl.
*/ -}}
{{- define "ibm-watson-lt.tlsSecretName" -}}
{{ tpl .Values.creds.tls.nameTpl . }}
{{- end -}}

{{- /* ################################### S3 - MINIO ################################### */ -}}

{{- define "ibm-watson-lt.s3AccessSecretNameTemplate" -}}
{{- default (printf "%s-ibm-minio-auth" .Release.Name) .Values.s3.existingSecret -}}
{{- end -}}

{{- define "ibm-watson-lt.s3TlsSecretNameTemplate" -}}
{{- default (printf "%s-ibm-minio-tls" .Release.Name) .Values.s3.tls.certSecret -}}
{{- end -}}

{{- define "ibm-watson-lt.s3EndpointTemplate" -}}
{{- printf "%s-ibm-minio-svc.%s.%s" .Release.Name .Release.Namespace .Values.global.clusterDomain -}}
{{- end -}}

{{- /* ################################### MISC ################################### */ -}}

{{- /* REQUEST BUFFER CALCULATION
Calculates the request buffer in each model runtime based on the amount of cpu limit given to the model lt.
The buffer will have a minimal size of 10 requests, otherwise will have 5 times the number of available virtual CPUs.

{{- define "ibm-watson-lt.requestBufferSize" -}}
{{ max 10 (mul 5 (ceil (div .Values.modelMeshDeployment.modelRuntimeContainer.cpuLimitMillis 1000))) }}
{{- end -}}
*/ -}}
{{- /* ROOT LOG LEVEL VALIDATION
Log level validation.
*/ -}}

{{- /*
{{- define "ibm-watson-lt.rootLogLevel" -}}
{{- if (has (lower .Values.modelMeshDeployment.modelRuntimeContainer.rootLogLevel) (list "all" "trace" "debug" "info" "warn" "error" "fatal") ) -}}
{{ lower .Values.modelMeshDeployment.modelRuntimeContainer.rootLogLevel | quote }}
{{- else -}}
"error"
{{- end -}}
{{- end -}}
*/ -}}
