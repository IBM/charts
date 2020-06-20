{{- include "sch.config.init" (list . "discovery.sch.chart.config.values") -}}

{{/* ###################################################################### */}}
{{/* ########################### GLOBAL HELPERS ########################### */}}
{{/* ###################################################################### */}}
{{- define "discovery.admin.tls" -}}
  {{- (index .Values.global.components "ibm-watson-discovery-admin-prod").releaseName }}-
  {{- .Values.global.appName }}-tls
{{- end -}}

{{- define "discovery.core.javaKeyStore" -}}
  {{- include "sch.names.fullCompName" (list . "jks-secret") -}}
{{- end -}}

{{- define "discovery.admin.privilegedServiceAccount" -}}
  {{- .Values.global.privilegedServiceAccount.name -}}
{{- end -}}

{{- define "discovery.admin.serviceAccount" -}}
  {{- .Values.global.serviceAccount.name -}}
{{- end -}}

{{/* ###################################################################### */}}
{{/* ############################# CNM HELPERS ############################ */}}
{{/* ###################################################################### */}}
{{- define "discovery.cnm.service" -}}
  {{- printf "%s-%s" (index .Values.global.components "ibm-watson-discovery-core-prod").releaseName .Values.global.appName | trunc 55 }}-cnm-api
{{- end -}}

{{- define "discovery.cnm.apiEndpoint" -}}
  {{- $svc := include "discovery.cnm.service" . -}}
  {{- printf "https://%s.%s.svc.%s:9443" $svc .Release.Namespace .Values.global.clusterDomain }}
{{- end -}}

{{- define "discovery.cnm.apiServer.replicas" -}}
  {{- if .Values.cnm.apiServer.replicas -}}
    {{- .Values.cnm.apiServer.replicas -}}
  {{- else if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    1
  {{- end -}}
{{- end -}}

{{- define "discovery.cnm.postgresql.envvars" -}}
  {{- $root := (index . 0) -}}
  {{- $pgDatabase := (index . 1 ) -}}
- name: PGDATABASE
  value: {{ $pgDatabase }}
- name: PGUSER
  valueFrom:
    configMapKeyRef:
      name: {{ include "discovery.crust.postgresql.configmap" $root }}
      key: username
- name: PGPASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "discovery.crust.postgresql.secret" $root }}
      key: pg_su_password
- name: PGPORT
  valueFrom:
    configMapKeyRef:
      name: {{ include "discovery.crust.postgresql.configmap" $root }}
      key: port
- name: PGHOST
  valueFrom:
    configMapKeyRef:
      name: {{ include "discovery.crust.postgresql.configmap" $root }}
      key: host
- name: PGSSLMODE
  value: "require"
{{- end -}}

{{- define "discovery.mantle.glimpse.builder.serviceName" -}}
{{- $mantle := (index .Values.global.components "ibm-watson-discovery-mantle-prod").releaseName -}}
{{- if .Values.global.private -}}
  {{- $mantle }}-{{ .Values.global.appName }}-glimpse-builder
{{- else -}}
  glimpse-builder-{{ $mantle }}-ser
{{- end -}}
{{- end }}

{{- define "discovery.mantle.glimpse.query.serviceName" -}}
{{- $mantle := (index .Values.global.components "ibm-watson-discovery-mantle-prod").releaseName -}}
{{- if .Values.global.private -}}
  {{- $mantle }}-{{ .Values.global.appName }}-glimpse-query
{{- else -}}
  glimpse-query-{{ $mantle }}-ser
{{- end -}}
{{- end }}


{{/* ###################################################################### */}}
{{/* ############################# DFS HELPERS ############################ */}}
{{/* ###################################################################### */}}
{{- define "discovery.dfs.configmapName" -}}
  {{- printf "%s-%s-dfs-configmap" .Release.Name .Values.global.appName -}}
{{- end -}}

{{- define "discovery.dfs.secretName" -}}
  {{- printf "%s-%s-dfs-secret" .Release.Name .Values.global.appName -}}
{{- end -}}

{{- define "discovery.dfs.CN" -}}
  {{- printf "%s.%s.svc.%s" "dfs" .Release.Namespace .Values.global.clusterDomain -}}
{{- end -}}

{{- define "discovery.dfs.service" -}}
  {{- $coreName := (index .Values.global.components "ibm-watson-discovery-core-prod").releaseName }}
  {{- printf "%s-%s" $coreName .Values.global.appName | trunc 49 }}-dfs-induction
{{- end -}}

{{- define "discovery.dfs.dfsReplicas" -}}
  {{- if .Values.dfs.replicas -}}
    {{- .Values.dfs.replicas -}}
  {{- else if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    1
  {{- end -}}
{{- end -}}

{{- define "discovery.dfs.mmReplicas" -}}
  {{- if .Values.mm.replicas -}}
    {{- .Values.mm.replicas -}}
  {{- else if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    1
  {{- end -}}
{{- end -}}

{{- define "discovery.dfs.bucketName" -}}
  {{- if .Values.global.private -}}
    {{- printf "discovery-dfs" }}
  {{- else -}}
    {{- printf "disco-dfs-%s-%s" .Values.global.env .Release.Name }}
  {{- end -}}
{{- end -}}

{{/* ###################################################################### */}}
{{/* ############################ DLAAS HELPERS ########################### */}}
{{/* ###################################################################### */}}

{{- define "dlaas.hostPort" -}}
  {{- if .Values.global.private -}}
    {{- $releaseName := (index .Values.global.components "ibm-watson-discovery-mantle-prod" "releaseName") -}}
    {{- printf "https://%s-ibm-dlaas-trainer-v2:8443" $releaseName }}
  {{- else -}}
    {{- .Values.dfs.dlaasCloudHostPort }}
  {{- end -}}
{{- end -}}

{{- define "dlaas.secretName" -}}
  {{- (index .Values.global.components "ibm-watson-discovery-mantle-prod" "releaseName") }}-ibm-dlaas-trainer-tls
{{- end -}}

{{- define "dlaas.learner.dockerRegistry" -}}
  {{- if .Values.dfs.learner.dockerRegistry -}}
    {{- .Values.dfs.learner.dockerRegistry -}}
  {{- else -}}
    {{- .Values.global.dockerRegistryPrefix | splitList "/" | first -}}
  {{- end -}}
{{- end -}}

{{- define "dlaas.learner.dockerRegistryNamespace" -}}
  {{- if .Values.dfs.learner.dockerNamespace -}}
    {{- .Values.dfs.learner.dockerNamespace -}}
  {{- else -}}
    {{- .Values.global.dockerRegistryPrefix | splitList "/" | rest | first -}}
  {{- end -}}
{{- end -}}

{{/* ###################################################################### */}}
{{/* ########################### ELASTIC HELPERS ########################## */}}
{{/* ###################################################################### */}}
{{- define "discovery.mantle.elastic.ca" -}}
  {{- if tpl .Values.global.mantle.elastic.ca . }}
    {{- tpl .Values.global.mantle.elastic.ca . }}
  {{- else }}
    {{- include "discovery.admin.tls" . }}
  {{- end }}
{{- end }}

{{- define "discovery.mantle.elastic.secret" -}}
  {{- if tpl .Values.global.mantle.elastic.secret . }}
    {{- tpl .Values.global.mantle.elastic.secret . }}
  {{- else }}
    {{- (index .Values.global.components "ibm-watson-discovery-mantle-prod").releaseName }}-
    {{- .Values.global.appName }}-elastic-secret
  {{- end }}
{{- end -}}

{{- define "discovery.mantle.elastic.configmap" -}}
  {{- if tpl .Values.global.mantle.elastic.configmap . }}
    {{- tpl .Values.global.mantle.elastic.configmap . }}
  {{- else }}
    {{- (index .Values.global.components "ibm-watson-discovery-mantle-prod").releaseName }}-
    {{- .Values.global.appName }}-elastic
  {{- end }}
{{- end -}}

{{/* ###################################################################### */}}
{{/* ############################ ETCD HELPERS ############################ */}}
{{/* ###################################################################### */}}
{{- define "discovery.crust.etcd.ca" -}}
  {{- if tpl .Values.global.crust.etcd.ca . }}
    {{- tpl .Values.global.crust.etcd.ca . }}
  {{- else }}
    {{- include "discovery.admin.tls" . }}
  {{- end }}
{{- end }}

{{- define "discovery.crust.etcd.configmap" -}}
  {{- if tpl .Values.global.crust.etcd.configmap . }}
    {{- tpl .Values.global.crust.etcd.configmap . }}
  {{- else }}
    {{- (index .Values.global.components "ibm-watson-discovery-crust-prod").releaseName }}-
    {{- .Values.global.appName }}-etcd
  {{- end }}
{{- end }}

{{- define "discovery.crust.etcd.secret" -}}
  {{- if tpl .Values.global.crust.etcd.secret . }}
    {{- tpl .Values.global.crust.etcd.secret . }}
  {{- else }}
    {{- (index .Values.global.components "ibm-watson-discovery-crust-prod").releaseName }}-
    {{- .Values.global.appName }}-etcd-root
  {{- end }}
{{- end -}}

{{/* ###################################################################### */}}
{{/* ########################### GATEWAY HELPERS ########################## */}}
{{/* ###################################################################### */}}
{{- define "watson.gateway.service" -}}
  {{- include "sch.config.init" (list . "discovery.sch.chart.config.values") -}}
  {{- $compAddonName := .sch.chart.components.gateway.name }}
  {{- include "sch.names.fullCompName" (list . $compAddonName ) -}}
{{- end -}}

{{- define "watson.gateway.endpoint" -}}
  {{- $name := include "watson.gateway.service" . -}}
  {{ printf "https://%s.%s.svc.%s:%.0f" $name .Release.Namespace .Values.global.clusterDomain .Values.gateway.addonService.port }}
{{- end }}

{{- define "cp4d.nginx.endpoint" -}}
  {{- include "sch.config.init" (list . "discovery.sch.chart.config.values") -}}
  {{- $nginxName := .sch.chart.components.cp4d.nginx.name }}
  {{- printf "https://%s.%s.svc.%s" $nginxName .Release.Namespace .Values.global.clusterDomain }}
{{- end }}

{{- define "watson.gateway.replicas" -}}
  {{- if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    1
  {{- end -}}
{{- end -}}

{{/* We are purposefully overwriting the subchart's function */}}
{{- define "gateway.icpDockerRepo" -}}
  {{ .Values.global.dockerRegistryPrefix }}/
{{- end -}}

{{/* ###################################################################### */}}
{{/* ############################# HDP HELPERS ############################ */}}
{{/* ###################################################################### */}}
{{- define "discovery.mantle.hdp.nn.service" -}}
  {{- $mantle := (index .Values.global.components "ibm-watson-discovery-mantle-prod").releaseName -}}
  {{- $app := .Values.global.appName -}}
  {{ $mantle }}-{{ $app }}-hdp-nn.{{ .Release.Namespace }}.svc
{{- end -}}

{{- define "discovery.mantle.hdp.rm.service" -}}
  {{- $mantle := (index .Values.global.components "ibm-watson-discovery-mantle-prod").releaseName -}}
  {{- $app := .Values.global.appName -}}
  {{- $mantle }}-{{ $app }}-hdp-rm.{{ .Release.Namespace }}.svc
{{- end -}}

{{/* ###################################################################### */}}
{{/* ############################ MINIO HELPERS ########################### */}}
{{/* ###################################################################### */}}

{{- define "discovery.crust.minio.secret" -}}
  {{- if tpl .Values.global.crust.objectStorage.secret . }}
    {{- tpl .Values.global.crust.objectStorage.secret . }}
  {{- else }}
    {{- (index .Values.global.components "ibm-watson-discovery-crust-prod").releaseName }}-
    {{- .Values.global.appName }}-minio-secret
  {{- end }}
{{- end -}}

{{- define "discovery.crust.minio.configmap" -}}
  {{- if tpl .Values.global.crust.objectStorage.configmap . }}
    {{- tpl .Values.global.crust.objectStorage.configmap . }}
  {{- else }}
    {{- (index .Values.global.components "ibm-watson-discovery-crust-prod").releaseName }}-
    {{- .Values.global.appName }}-minio-cxn
  {{- end }}
{{- end }}


{{/* ###################################################################### */}}
{{/* ########################## RABBITMQ HELPERS ########################## */}}
{{/* ###################################################################### */}}
{{- define "discovery.crust.rabbitmq.ca" -}}
  {{- if tpl .Values.global.crust.rabbitmq.ca . }}
    {{- tpl .Values.global.crust.rabbitmq.ca . }}
  {{- else }}
    {{- include "discovery.admin.tls" . }}
  {{- end }}
{{- end }}

{{- define "discovery.crust.rabbitmq.secret" -}}
  {{- if tpl .Values.global.crust.rabbitmq.secret . }}
    {{- tpl .Values.global.crust.rabbitmq.secret . }}
  {{- else }}
    {{- (index .Values.global.components "ibm-watson-discovery-crust-prod").releaseName }}-
    {{- .Values.global.appName }}-rabbitmq-auth-secret
  {{- end }}
{{- end -}}

{{- define "discovery.crust.rabbitmq.configmap" -}}
  {{- if tpl .Values.global.crust.rabbitmq.configmap . }}
    {{- tpl .Values.global.crust.rabbitmq.configmap . }}
  {{- else }}
    {{- (index .Values.global.components "ibm-watson-discovery-crust-prod").releaseName }}-
    {{- .Values.global.appName }}-rabbitmq-cxn
  {{- end }}
{{- end -}}

{{/* ###################################################################### */}}
{{/* ######################### POSTGRESQL HELPERS ######################### */}}
{{/* ###################################################################### */}}
{{- define "discovery.crust.postgresql.ca" -}}
  {{- if tpl .Values.global.crust.postgresql.ca . }}
    {{- tpl .Values.global.crust.postgresql.ca . }}
  {{- else }}
    {{- include "discovery.admin.tls" . }}
  {{- end }}
{{- end }}

{{- define "discovery.crust.postgresql.secret" -}}
  {{- if tpl .Values.global.crust.postgresql.secret . }}
    {{- tpl .Values.global.crust.postgresql.secret . }}
  {{- else }}
    {{- (index .Values.global.components "ibm-watson-discovery-crust-prod").releaseName }}-
    {{- .Values.global.appName }}-postgresql-auth-secret
  {{- end }}
{{- end }}

{{- define "discovery.crust.postgresql.configmap" -}}
  {{- if tpl .Values.global.crust.postgresql.configmap . }}
    {{- tpl .Values.global.crust.postgresql.configmap . }}
  {{- else }}
    {{- (index .Values.global.components "ibm-watson-discovery-crust-prod").releaseName }}-
    {{- .Values.global.appName }}-postgresql
  {{- end }}
{{- end }}

{{/* ###################################################################### */}}
{{/* ############################# SDU HELPERS ############################ */}}
{{/* ###################################################################### */}}
{{- define "discovery.sdu.replicas" -}}
  {{- if .Values.sdu.replicas -}}
    {{ .Values.sdu.replicas }}
  {{- else if (eq .Values.global.deploymentType "Production") -}}
    2
  {{- else -}}
    1
  {{- end -}}
{{- end -}}

{{- define "discovery.sdu.logs.dir" -}}/wexdata/logs/sdu{{- end -}}

{{/* ###################################################################### */}}
{{/* ########################## TOOLING HELPERS ########################### */}}
{{/* ###################################################################### */}}

{{- define "discovery.tooling.replicas" -}}
  {{- if .Values.tooling.replicas -}}
    {{- .Values.tooling.replicas -}}
  {{- else if (eq .Values.global.deploymentType "Production") -}}
    2
  {{- else -}}
    1
  {{- end -}}
{{- end }}

{{- define "discovery.tooling.service" -}}
  {{- printf "%s-%s" (index .Values.global.components "ibm-watson-discovery-core-prod").releaseName .Values.global.appName | trunc 55 }}-tooling
{{- end -}}

{{- define "discovery.tooling.path" -}}
  {{- if tpl .Values.tooling.pathTemplate . -}}
    {{- tpl .Values.tooling.pathTemplate . -}}
  {{- else -}}
    {{- printf "/%s/%s" .Values.gateway.addon.serviceId .Release.Name -}}
  {{- end -}}
{{- end -}}

{{/* ###################################################################### */}}
{{/* ########################## WEX CORE HELPERS ########################## */}}
{{/* ###################################################################### */}}
{{- define "discovery.core.ck.secret" -}}
  {{- include "sch.config.init" (list . "discovery.sch.chart.config.values") -}}
  {{- $compName := .sch.chart.components.wexCore.ck.credential.secret.name -}}
  {{- include "sch.names.fullCompName" (list . $compName ) -}}
{{- end }}

{{- define "discovery.core.elastic.envVars" -}}
- name: ELASTIC_ENDPOINT
  valueFrom:
    configMapKeyRef:
      name: {{ include "discovery.mantle.elastic.configmap" . }}
      key: endpoint
- name: ELASTIC_USER
  valueFrom:
    secretKeyRef:
      name: {{ include "discovery.mantle.elastic.secret" . }}
      key: username
- name: ELASTIC_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "discovery.mantle.elastic.secret" . }}
      key: password
{{- end -}}

{{- define "discovery.core.etcd.envVars" -}}
- name: ETCD_USER
  valueFrom:
    secretKeyRef:
      name: {{ include "discovery.crust.etcd.secret" . }}
      key: username
- name: ETCD_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "discovery.crust.etcd.secret" . }}
      key: password
- name: ETCD_HOST
  valueFrom:
    configMapKeyRef:
      name: {{ include "discovery.crust.etcd.configmap" . }}
      key: host
- name: ETCD_PORT
  valueFrom:
    configMapKeyRef:
      name: {{ include "discovery.crust.etcd.configmap" . }}
      key: port
- name: ETCDCTL_USER
  value: "$(ETCD_USER):$(ETCD_PASSWORD)"
- name: ETCD_TLS_ENABLED
  value: "true"
  {{- if .Values.global.private }}
- name: ETCDCTL_CACERT
  value: "/opt/tls/etcd/tls.cacrt"
- name: ETCDCTL_CERT
  value: "/opt/tls/etcd/tls.crt"
- name: ETCDCTL_KEY
  value: "/opt/tls/etcd/tls.key"
  {{- else }}
- name: ETCDCTL_CACERT
  value: "/opt/tls/etcd/tls.cacrt"
  {{- end }}
- name: ETCDCTL_ENDPOINTS
  value: "$(ETCD_HOST):$(ETCD_PORT)"
{{- end -}}

{{- define "discovery.core.s3.envVars" -}}
- name: S3_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "discovery.crust.minio.secret" . }}
      key: accesskey
- name: S3_SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "discovery.crust.minio.secret" . }}
      key: secretkey
- name: S3_ENDPOINT_URL
  valueFrom:
    configMapKeyRef:
      name: {{ include "discovery.crust.minio.configmap" . }}
      key: endpoint
- name: S3_FILERESOURCE_BUCKET
  valueFrom:
    configMapKeyRef:
      name: {{ include "discovery.crust.minio.configmap" . }}
      key: bucketCommon
- name: S3_EXPORTED_DOCUMENTS_BUCKET
  valueFrom:
    configMapKeyRef:
      name: {{ include "discovery.crust.minio.configmap" . }}
      key: bucketExportedDocuments
- name: S3_HDP_BUCKET
  valueFrom:
    configMapKeyRef:
      name: {{ include "discovery.crust.minio.configmap" . }}
      key: bucketCommon
{{- end -}}

{{- define "discovery.core.pg.envVars" -}}
- name: PGHOST
  valueFrom:
    configMapKeyRef:
      name: {{ include "discovery.crust.postgresql.configmap" . }}
      key: host
- name: PGPORT
  valueFrom:
    configMapKeyRef:
      name: {{ include "discovery.crust.postgresql.configmap" . }}
      key: port
- name: PGUSER
  valueFrom:
    configMapKeyRef:
      name: {{ include "discovery.crust.postgresql.configmap" . }}
      key: username
- name: PGPASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "discovery.crust.postgresql.secret" . }}
      key: pg_su_password
{{- end -}}

{{- define "discovery.core.sdu.envVars" -}}
- name: SDU_DB_HOST
  valueFrom:
    configMapKeyRef:
      name: {{ include "discovery.crust.postgresql.configmap" . }}
      key: host
- name: SDU_DB_PORT
  valueFrom:
    configMapKeyRef:
      name: {{ include "discovery.crust.postgresql.configmap" . }}
      key: port
- name: SDU_DB_PWD
  valueFrom:
    secretKeyRef:
      name: {{ include "discovery.crust.postgresql.secret" . }}
      key: pg_su_password
- name: SDU_DB_USER
  valueFrom:
    configMapKeyRef:
      name: {{ include "discovery.crust.postgresql.configmap" . }}
      key: username
{{- end -}}

{{- define "discovery.core.rabbitmq.envVars" -}}
- name: RABBITMQ_HOSTNAME
  valueFrom:
    configMapKeyRef:
      name: {{ include "discovery.crust.rabbitmq.configmap" . }}
      key: host
- name: RABBITMQ_MANAGEMENT_PORT
  valueFrom:
    configMapKeyRef:
      name: {{ include "discovery.crust.rabbitmq.configmap" . }}
      key: http_port
- name: RABBITMQ_PORT
  valueFrom:
    configMapKeyRef:
      name: {{ include "discovery.crust.rabbitmq.configmap" . }}
      key: port
- name: RABBITMQ_VHOST
  valueFrom:
    configMapKeyRef:
      name: {{ include "discovery.crust.rabbitmq.configmap" . }}
      key: vhost
- name: RABBITMQ_USERNAME
  valueFrom:
    configMapKeyRef:
      name: {{ include "discovery.crust.rabbitmq.configmap" . }}
      key: user
- name: RABBITMQ_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "discovery.crust.rabbitmq.secret" . }}
      key: rabbitmq-password
{{- end -}}

{{- define "discovery.core.gateway.envVars" -}}
{{ include "discovery.core.elastic.envVars" . }}
{{ include "discovery.core.etcd.envVars" . }}
{{ include "discovery.core.s3.envVars" . }}
{{ include "discovery.core.pg.envVars" . }}
{{ include "discovery.core.sdu.envVars" . }}
{{- end }}

{{- define "discovery.core.initContainer.commonConfig" -}}
image: "{{ .Values.global.dockerRegistryPrefix }}/{{ .Values.core.image.utils.name }}:{{ .Values.core.image.utils.tag }}"
imagePullPolicy: "{{ .Values.global.image.pullPolicy }}"
{{- include "sch.security.securityContext" (list . .sch.chart.wexUserPodSecurityContext) }}
envFrom:
- configMapRef:
    name: {{ include "sch.names.fullCompName" (list . .sch.chart.components.wexCore.gateway.init.name ) }}
resources:
{{ toYaml .Values.core.initContainer.resources | indent 2 }}
{{- end -}}

{{- define "discovery.core.initContainer.elasticCheck" -}}
- name: elastic-check
{{ include "discovery.core.initContainer.commonConfig" . | indent 2 }}
  env:
{{ include "discovery.core.elastic.envVars" . | indent 2 }}
  command:
  - bash
  - -c
  - |
    countElasticStart=0
    while true; do
      curl -ks -u ${ELASTIC_USER}:${ELASTIC_PASSWORD} "${ELASTIC_ENDPOINT}/_cluster/health" -w "%{http_code}" -o /dev/null | grep 200 && break;
      countElasticStart=$(( $countElasticStart + 1 ))
      echo "Waiting for ElasticSearch to start. count=${countElasticStart}";
      sleep 1;
    done;
    echo "OK - elasticsearch started";
{{- end -}}

{{- define "discovery.core.initContainer.etcdCheck" -}}
- name: etcd-check
{{ include "discovery.core.initContainer.commonConfig" . | indent 2 }}
  env:
{{ include "discovery.core.etcd.envVars" . | indent 2 }}
  command:
  - bash
  - -c
  - |
    countEtcdStart=0
    while true; do
      STATUS=$(curl -w "%{http_code}" -o /dev/null -m {{ .Values.core.initContainer.etcdTimeoutSeconds }} -ks "https://${ETCD_HOST}:${ETCD_PORT}/health")
      if [ "$STATUS" = "200" ] ; then
        break
      else
        countEtcdStart=$(( $countEtcdStart + 1 ))
        echo "waiting for etcd to start. count=${countEtcdStart}"
        sleep 1
      fi
    done
    echo "OK - etcd started"
{{- end -}}

{{- define "discovery.core.initContainer.postgresqlCheck" -}}
- name: postgresql-check
{{ include "discovery.core.initContainer.commonConfig" . | indent 2 }}
  env:
{{ include "discovery.core.pg.envVars" . | indent 2 }}
  command:
  - bash
  - -c
  - |
    countPsqlStart=0
    while true; do
      psql -q -d postgres -c "SELECT version()" > /dev/null 2>&1 && break
      countPsqlStart=$(( $countPsqlStart + 1 ))
      echo "waiting for postgresql to start. count=${countPsqlStart}"
      sleep 1
    done
    echo "OK - postgresql started"
{{- end -}}

{{- define "discovery.core.initContainer.minioCheck" -}}
- name: minio-check
{{ include "discovery.core.initContainer.commonConfig" . | indent 2 }}
  env:
{{ include "discovery.core.s3.envVars" . | indent 2 }}
  command:
  - bash
  - -c
  - |
    countMinioStart=0
    while true; do
      curl -ks "$S3_ENDPOINT_URL/minio/health/ready" -w "%{http_code}" -o /dev/null | grep 200 && break;
      countMinioStart=$(( countMinioStart + 1 ))
      echo "Waiting for MinIO to start. count=${countMinioStart}";
      sleep 1;
    done;
    echo "OK - MinIO started";
{{- end -}}

{{- define "discovery.core.initContainer.rabbitmqCheck" -}}
- name: rabbitmq-check
{{ include "discovery.core.initContainer.commonConfig" . | indent 2 }}
  env:
{{ include "discovery.core.rabbitmq.envVars" . | indent 2 }}
  command:
  - bash
  - -c
  - |
    countRabbitmqStart=0
    while true; do
      curl -ks -u "${RABBITMQ_USERNAME}:${RABBITMQ_PASSWORD}" "https://${RABBITMQ_HOSTNAME}:${RABBITMQ_MANAGEMENT_PORT}${RABBITMQ_VHOST}api/overview" -w "%{http_code}" -o /dev/null | grep 200 && break;
      countRabbitmqStart=$(( countRabbitmqStart + 1 ))
      echo "Waiting for RabbitMQ to start. count=${countRabbitmqStart}";
      sleep 1;
    done;
    echo "OK - Rabbitmq started";
{{- end -}}

{{- define "discovery.core.initContainer.ingestionApiCheck" -}}
- name: ingestion-api-check
{{ include "discovery.core.initContainer.commonConfig" . | indent 2 }}
  command:
  - bash
  - -c
  - |
    countIngestionApiStart=0
    while true; do
      curl -ks "${AMA_ZING_API_ENDPOINT}/ping" -w "%{http_code}" -o /dev/null | grep 200 && break;
      countIngestionApiStart=$(( countIngestionApiStart + 1 ))
      echo "Waiting for Ingestion API to start. count=${countIngestionApiStart}";
      sleep 1;
    done;
    echo "OK - Ingestion API started";
{{- end -}}

{{- define "discovery.core.initContainer.haywireCheck" -}}
- name: haywire-check
{{ include "discovery.core.initContainer.commonConfig" . | indent 2 }}
  command:
  - bash
  - -c
  - |
    countHaywireStart=0
    while true; do
      curl -ks "${NOTICE_SERVER_ENDPOINT}" -w "%{http_code}" -o /dev/null | grep 415 && break;
      countHaywireStart=$(( counthaywireStart + 1 ))
      echo "Waiting for haywire to start. count=${countHaywireStart}";
      sleep 1;
    done;
    echo "OK - haywire started";
{{- end -}}

{{- define "discovery.core.initContainer.managementCheck" -}}
- name: management-check
{{ include "discovery.core.initContainer.commonConfig" . | indent 2 }}
  command:
  - bash
  - -c
  - |
    countManagementStart=0
    while true; do
      curl -k "$MANAGEMENT_API_ENDPOINT/collections" -s | grep -q "items" && break;
      countManagementStart=$(( countManagementStart + 1 ))
      echo "Waiting for management to start. count=${countManagementStart}";
      sleep 1;
    done;
    echo "OK - management started";
{{- end -}}

{{- define "discovery.core.initContainer.orchestratorCheck" -}}
- name: orchestrator-check
{{ include "discovery.core.initContainer.commonConfig" . | indent 2 }}
  command:
  - bash
  - -c
  - |
    countOrchestratorStart=0
    while true; do
      curl -ks "${ORCHESTRATOR_API_ENDPOINT}/control/info" -w "%{http_code}" -o /dev/null | grep 200 && break;
      countOrchestratorStart=$(( countOrchestratorStart + 1 ))
      echo "Waiting for Orchestrator to start. count=${countOrchestratorStart}";
      sleep 1;
    done;
    echo "OK -Orchestrator started";
{{- end -}}

{{- define "discovery.core.initContainer.rapiCheck" -}}
- name: rapi-check
{{ include "discovery.core.initContainer.commonConfig" . | indent 2 }}
  command:
  - bash
  - -c
  - |
    countRapiStart=0
    while true; do
      curl -ks "${RAPI_SERVER_ENDPOINT}" -w "%{http_code}" -o /dev/null | grep 200 && break;
      countRapiStart=$(( countRapiStart + 1 ))
      echo "Waiting for rapi to start. count=${countRapiStart}";
      sleep 1;
    done;
    echo "OK - Rapi started";
{{- end -}}

{{- define "discovery.core.initContainer.atVolumeCheck" -}}
  {{- if and (not .Values.global.private) .Values.global.activityTracker.enabled }}
- name: at-volume-check
  image: "{{ .Values.global.dockerRegistryPrefix }}/{{ .Values.atCheck.image.name }}:{{ .Values.atCheck.image.tag }}"
  imagePullPolicy: "{{ .Values.global.image.pullPolicy }}"
  resources:
{{ toYaml .Values.core.initContainer.resources | indent 4 }}
  command:
  - bash
  - -c
  - |
    chmod 775 /var/log/at;
    mkdir -p /var/log/at/Discovery;
    chgrp -R 0 /var/log/at/Discovery;
    chmod -R 777 /var/log/at/Discovery;
    echo "OK - AT volume permissions";
  securityContext:
    runAsUser: 0
  volumeMounts:
  - name: at-events
    mountPath: {{ .Values.global.activityTracker.path }}
  {{- end }}
{{- end -}}

{{- define "discovery.core.converter.replicas" -}}
  {{- if .Values.core.converter.replica -}}
    {{- .Values.core.converter.replica -}}
  {{- else if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    {{- /* Development (or other value) */ -}}
    1
  {{- end -}}
{{- end -}}

{{- define "discovery.core.crawler.replicas" -}}
  {{- if .Values.core.crawler.replica -}}
    {{- .Values.core.crawler.replica -}}
  {{- else if eq .Values.global.deploymentType "Production" -}}
    1
  {{- else -}}
    {{- /* Development (or other value) */ -}}
    1
  {{- end -}}
{{- end -}}

{{- define "discovery.core.gateway.replicas" -}}
  {{- if .Values.core.gateway.replica -}}
    {{- .Values.core.gateway.replica -}}
  {{- else if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    {{- /* Development (or other value) */ -}}
    1
  {{- end -}}
{{- end -}}

{{- define "discovery.core.ingestionApi.replicas" -}}
  {{- if .Values.core.ingestionApi.replica -}}
    {{- .Values.core.ingestionApi.replica -}}
  {{- else if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    {{- /* Development (or other value) */ -}}
    1
  {{- end -}}
{{- end -}}

{{- define "discovery.core.inlet.replicas" -}}
  {{- if .Values.core.inlet.replica -}}
    {{- .Values.core.inlet.replica -}}
  {{- else if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    {{- /* Development (or other value) */ -}}
    1
  {{- end -}}
{{- end -}}

{{- define "discovery.core.management.replicas" -}}
  {{- if .Values.core.management.replica -}}
    {{- .Values.core.management.replica -}}
  {{- else if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    {{- /* Development (or other value) */ -}}
    1
  {{- end -}}
{{- end -}}

{{- define "discovery.core.minerapp.replicas" -}}
  {{- if .Values.core.minerapp.replica -}}
    {{- .Values.core.minerapp.replica -}}
  {{- else if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    {{- /* Development (or other value) */ -}}
    1
  {{- end -}}
{{- end -}}

{{- define "discovery.core.minerapp.path" -}}
  {{- if tpl .Values.core.minerapp.pathTemplate . -}}
    {{- tpl .Values.core.minerapp.pathTemplate . -}}
  {{- else -}}
    {{- printf "/%s/%s/cm/miner" .Values.gateway.addon.serviceId .Release.Name -}}
  {{- end -}}
{{- end -}}

{{- define "discovery.core.adminapp.path" -}}
  {{- if tpl .Values.core.minerapp.adminapp.pathTemplate . -}}
    {{- tpl .Values.core.minerapp.adminapp.pathTemplate . -}}
  {{- else -}}
    {{- printf "/%s/%s/cm/admin" .Values.gateway.addon.serviceId .Release.Name -}}
  {{- end -}}
{{- end -}}

{{- define "discovery.core.orchestrator.replicas" -}}
  {{- if .Values.core.orchestrator.replica -}}
    {{- .Values.core.orchestrator.replica -}}
  {{- else if eq .Values.global.deploymentType "Production" -}}
    1
  {{- else -}}
    {{- /* Development (or other value) */ -}}
    1
  {{- end -}}
{{- end -}}

{{- define "discovery.core.outlet.replicas" -}}
  {{- if .Values.core.outlet.replica -}}
    {{- .Values.core.outlet.replica -}}
  {{- else if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    {{- /* Development (or other value) */ -}}
    1
  {{- end -}}
{{- end -}}

{{- define "discovery.core.rapi.replicas" -}}
  {{- if .Values.core.rapi.replica -}}
    {{- .Values.core.rapi.replica -}}
  {{- else if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    {{- /* Development (or other value) */ -}}
    1
  {{- end -}}
{{- end -}}

{{- define "discovery.core.wksml.replicas" -}}
  {{- if .Values.core.wksml.replica -}}
    {{- .Values.core.wksml.replica -}}
  {{- else if eq .Values.global.deploymentType "Production" -}}
    1
  {{- else -}}
    {{- /* Development (or other value) */ -}}
    1
  {{- end -}}
{{- end -}}

{{- define "discovery.core.statelessApi.runtime.replicas" -}}
  {{- if .Values.core.statelessApi.runtime.replica -}}
    {{- .Values.core.statelessApi.runtime.replica -}}
  {{- else if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    {{- /* Development (or other value) */ -}}
    1
  {{- end -}}
{{- end -}}

{{- define "discovery.core.statelessApi.proxy.replicas" -}}
  {{- if .Values.core.statelessApi.proxy.replica -}}
    {{- .Values.core.statelessApi.proxy.replica -}}
  {{- else if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    {{- /* Development (or other value) */ -}}
    1
  {{- end -}}
{{- end -}}

{{- define "discovery.core.statelessApi.secret" -}}
  {{- include "sch.config.init" (list . "discovery.sch.chart.config.values") -}}
  {{- $compName := .sch.chart.components.wexCore.statelessApi.secret.name -}}
  {{- include "sch.names.fullCompName" (list . $compName ) -}}
{{- end }}

{{- define "discovery.core.gateway.hostname" -}}
  {{- $compGatewayName := .sch.chart.components.wexCore.gateway.name }}
  {{- $gatewayServiceName := include "sch.names.fullCompName" (list . $compGatewayName ) -}}
  {{ printf "%s.%s.svc.%s" $gatewayServiceName .Release.Namespace .Values.global.clusterDomain }}
{{- end -}}

{{- define "discovery.core.ingestionApi.hostname" -}}
  {{- $compIngestionApiName := .sch.chart.components.wexCore.ingestionApi.name }}
  {{- $ingestionApiServiceName := include "sch.names.fullCompName" (list . $compIngestionApiName ) -}}
  {{ printf "%s.%s.svc.%s" $ingestionApiServiceName .Release.Namespace .Values.global.clusterDomain }}
{{- end -}}

{{- define "discovery.core.management.hostname" -}}
  {{- $compManagementName := .sch.chart.components.wexCore.management.name }}
  {{- $managementServiceName := include "sch.names.fullCompName" (list . $compManagementName) -}}
  {{ printf "%s.%s.svc.%s" $managementServiceName .Release.Namespace .Values.global.clusterDomain }}
{{- end -}}

{{- define "discovery.core.minerapp.hostname" -}}
  {{- $compMinerName := .sch.chart.components.wexCore.minerapp.name }}
  {{- $minerServiceName := include "sch.names.fullCompName" (list . $compMinerName ) -}}
  {{ printf "%s.%s.svc.%s" $minerServiceName .Release.Namespace .Values.global.clusterDomain }}
{{- end -}}

{{- define "discovery.core.notice.hostname" -}}
  {{- $compHaywireName := .sch.chart.components.haywire.name -}}
  {{- $haywireServiceName := include "sch.names.fullCompName" (list . $compHaywireName ) -}}
  {{ printf "%s.%s.svc.%s" $haywireServiceName .Release.Namespace .Values.global.clusterDomain }}
{{- end -}}

{{- define "discovery.core.orchestrator.hostname" -}}
  {{- $compOrchestratorName := .sch.chart.components.wexCore.orchestrator.name }}
  {{- $orchestratorServiceName := include "sch.names.fullCompName" (list . $compOrchestratorName ) -}}
  {{ printf "%s.%s.svc.%s" $orchestratorServiceName .Release.Namespace .Values.global.clusterDomain }}
{{- end -}}

{{- define "discovery.core.rapi.hostname" -}}
  {{- $compRapiName := .sch.chart.components.wexCore.rapi.name }}
  {{- $rapiServiceName := include "sch.names.fullCompName" (list . $compRapiName ) -}}
  {{ printf "%s.%s.svc.%s" $rapiServiceName .Release.Namespace .Values.global.clusterDomain }}
{{- end -}}

{{- define "discovery.core.wksml.hostname" -}}
  {{- $compWksmlName := .sch.chart.components.wexCore.wksml.name }}
  {{- $wksmlServiceName := include "sch.names.fullCompName" (list . $compWksmlName ) -}}
  {{ printf "%s.%s.svc.%s" $wksmlServiceName .Release.Namespace .Values.global.clusterDomain }}
{{- end -}}

{{- define "discovery.core.statelessApi.hostname" -}}
  {{- $compStatelessApiName := .sch.chart.components.wexCore.statelessApi.proxy.name }}
  {{- $statelessApiServiceName := include "sch.names.fullCompName" (list . $compStatelessApiName ) -}}
  {{ printf "%s.%s.svc.%s" $statelessApiServiceName .Release.Namespace .Values.global.clusterDomain }}
{{- end -}}

{{- define "discovery.core.gatewayService" -}}
  {{- printf "%s-%s-gateway" (index .Values.global.components "ibm-watson-discovery-core-prod").releaseName .Values.global.appName | trunc 63 }}
{{- end -}}

{{- define "discovery.core.gatewayEndpoint" -}}
  {{- $compGatewayName := .sch.chart.components.wexCore.gateway.name }}
  {{- $name := (include "sch.names.fullCompName" (list . $compGatewayName )) -}}
  {{ printf "https://%s.%s.svc.%s:%.0f" $name .Release.Namespace .Values.global.clusterDomain .Values.tooling.backend.port }}
{{- end -}}

{{/* ###################################################################### */}}
{{/* ############################ WIRE HELPERS ############################ */}}
{{/* ###################################################################### */}}

{{- define "discovery.ranker.secret" -}}
{{- if and (not .Values.global.private) .Values.wire.rankerCloudSecretName -}}
  {{ .Values.wire.rankerCloudSecretName }}
{{- else -}}
  {{ include "sch.names.fullCompName" (list . .sch.chart.components.rankerSecret.name) }}
{{- end -}}
{{- end -}}

{{- define "discovery.wire.cosSecretName" -}}
{{- if .Values.wire.rankerCloudSecretName -}}
  {{ .Values.wire.rankerCloudSecretName }}
{{- else -}}
  {{- $appName:= .Values.global.appName -}}
  {{- printf "%s-%s-wire-cos-secret" .Release.Name $appName | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "discovery.wire.docker.namespace" -}}
  {{- if .Values.wire.rankerMaster.rankerTraining.dockerNamespace }}
    {{- .Values.wire.rankerMaster.rankerTraining.dockerNamespace }}
  {{- else -}}
    {{- .Values.global.dockerRegistryPrefix | splitList "/" | rest | first -}}
  {{- end -}}
{{- end -}}

{{- define "discovery.wire.docker.registry" -}}
  {{- if .Values.wire.rankerMaster.rankerTraining.dockerRegistry -}}
    {{- .Values.wire.rankerMaster.rankerTraining.dockerRegistry -}}
  {{- else -}}
    {{- .Values.global.dockerRegistryPrefix | splitList "/" | first -}}
  {{- end -}}
{{- end -}}

{{- define "discovery.wire.haywireReplicas" -}}
  {{- if .Values.wire.haywire.replicas -}}
    {{- .Values.wire.haywire.replicas -}}
  {{- else if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    1
  {{- end -}}
{{- end -}}

{{- define "discovery.wire.master.CN" -}}
  {{- printf "%s.%s.svc.%s" .Values.wire.rankerMaster.etcdConfigJob.wirePublicCertCNName .Release.Namespace .Values.global.clusterDomain -}}
{{- end -}}

{{- define "discovery.wire.rankerMasterReplicas" -}}
  {{- if .Values.wire.rankerMaster.replicas -}}
    {{- .Values.wire.rankerMaster.replicas -}}
  {{- else if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    1
  {{- end -}}
{{- end -}}

{{- define "discovery.wire.rankerRestReplicas" -}}
  {{- if .Values.wire.rankerRest.replicas -}}
    {{- .Values.wire.rankerRest.replicas -}}
  {{- else if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    1
  {{- end -}}
{{- end -}}

{{- define "discovery.wire.rankerRest.hostname" -}}
  {{- if .Values.global.private }}
    {{- $rankerRestName := .sch.chart.components.rankerRest.name -}}
    {{- include "sch.names.fullCompName" (list . $rankerRestName ) }}
  {{- else }}
    {{- $rankerRestSvc := "rest-v2" }}
    {{- $rankerRestNamespace := "discovery-wire-ranker" }}
    {{- printf "%s.%s" $rankerRestSvc $rankerRestNamespace }}
  {{- end }}
{{- end -}}

{{- define "discovery.wire.serveRankerReplicas" -}}
  {{- if .Values.wire.serveRanker.serveRankerReplicas -}}
    {{- .Values.wire.serveRanker.serveRankerReplicas -}}
  {{- else if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    1
  {{- end -}}
{{- end -}}

{{- define "discovery.wire.serveRanker.service" -}}
  {{- $coreName := (index .Values.global.components "ibm-watson-discovery-core-prod").releaseName }}
  {{- printf "%s-%s" $coreName .Values.global.appName | trunc 50 }}-serve-ranker
{{- end -}}

{{- define "discovery.wire.trainingCrudReplicas" -}}
  {{- if .Values.wire.trainingCrud.trainingCrudReplicas -}}
    {{- .Values.wire.trainingCrud.trainingCrudReplicas -}}
  {{- else if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    1
  {{- end -}}
{{- end -}}

{{- define "discovery.wire.trainingCrud.service" -}}
  {{- $coreName := (index .Values.global.components "ibm-watson-discovery-core-prod").releaseName }}
  {{- printf "%s-%s" $coreName .Values.global.appName | trunc 44 }}-training-data-crud
{{- end }}

{{- define "discovery.wire.trainingRestReplicas" -}}
  {{- if .Values.wire.trainingRest.trainingRestReplicas -}}
    {{- .Values.wire.trainingRest.trainingRestReplicas -}}
  {{- else if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    1
  {{- end -}}
{{- end -}}
