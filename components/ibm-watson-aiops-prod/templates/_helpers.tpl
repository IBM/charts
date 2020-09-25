
{{/* vim: set filetype=mustache: */}}
{{/*
  Generic Helper Templates for AIOps
  Included in this file are:
  - Name Templates
  - Url Templates
  - Secret Environment Templtaes
  - Volume Templates
*/}}


{{/*
   A helper template to support templated boolean values.
   Takes a value (and converts it into Boolean equivalent string value).
     If the value is of type Boolean, then false value renders to empty string, otherwise renders to non-empty string.
     If the value is of type String, then takes (and renders the string) and if the value is true (case sensitive) or renders to (true) then renders to non-empty string, otherwise renders to empty string.

  Usage: For keys like `tls.enabled` "true/false" add possiblity to have also non-boolean value "{{ .Values.global.zeno.tls.enabled }}"

  Usage in templates:
    Instead of direct value test `{{ if .Values.tls.enabled }}` one has to use {{ if include "zeno.boolConvertor" (list .Values.tls.enabled . ) }}
*/}}
{{- define "zeno.boolConvertor" -}}
  {{- if typeIs "bool" (first .) -}}
    {{- if (first .) }}                            Type is Boolean  VALUE is TRUE           ==>  Generating a non-empty string{{- end -}}
  {{- else if typeIs "string" (first .) -}}
    {{- if eq "true" ( tpl (first .) (last .) )  }}Type is String   VALUE renders to "true" ==>  Generating a non-empty string{{- end -}}
  {{- end -}}
{{- end -}}

{{/* Force SCH to use our name even across deeply nested subcharts */}}
{{- define "zeno.globalServiceName" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{/* creating a root-like object to pass into sch that won't change $root (like by using `merge`) */}}
  {{- $rootOverride := (dict "Values" (dict "nameOverride" $root.Values.global.product.schName ) "sch" $root.sch "Release" $root.Release "Chart" $root.Chart) -}}
  {{- $compName := (include "sch.utils.getItem" (list $params 1 "")) -}}

  {{/* Values are from in sch/_config.yaml */}}
  {{- $maxLength := 63 -}}
  {{- $releaseNameTruncLength := 36 -}}
  {{- $appNameTruncLength := 13 -}}
  {{- $compNameTruncLength := 12 -}}
  {{- include "sch.names.releaseAppCompName" (list $rootOverride $compName $maxLength $releaseNameTruncLength $appNameTruncLength $compNameTruncLength) -}}
{{- end -}}

{{- define "zeno.meteringLabels" -}}
icpdsupport/addOnName: "aiops"
icpdsupport/app: "{{ .name }}"
icpdsupport/serviceInstanceId: "{{ .root.Values.global.zenServiceInstanceId | int64 }}"
{{- end -}}

{{/* ######################################## COMPONENT ENDPOINT ######################################### */}}
{{- define "zeno.componentUrl" -}}
"https://{{ include "sch.names.fullCompName" (list .root .service) }}.{{ .root.Release.Namespace }}.svc:8000"
{{- end -}}

{{- define "zeno.controllerService" -}}
{{ include "zeno.globalServiceName" (list . .Values.global.controller.name) }}
{{- end -}}

{{- define "zeno.addonService" -}}
{{ include "zeno.globalServiceName" (list . .Values.global.addon.name) }}
{{- end -}}

{{- define "zeno.chatopsSlackIntegratorService" -}}
{{ include "zeno.globalServiceName" (list . .Values.global.chatopsSlackIntegrator.name) }}
{{- end -}}
{{/* ######################################## COMPONENT ENDPOINT ######################################### */}}

{{/* ######################################## ZEN CORE API ENDPOINT TEMPLATE ################## */}}
{{- define "zeno.zenCoreApiEndpointTemplate" -}}
https://zen-core-api-svc.{{ .Values.global.zenControlPlaneNamespace }}.svc:4444
{{- end -}}

{{/* ######################################## ZEN CORE ENDPOINT TEMPLATE ################## */}}
{{- define "zeno.zenCoreEndpointTemplate" -}}
https://zen-core-svc.{{ .Values.global.zenControlPlaneNamespace }}.svc:3443
{{- end -}}

{{- define "zeno.cpdNginxEndpointTemplate" -}}
https://ibm-nginx-svc.{{ .Values.global.zenControlPlaneNamespace }}.{{ .Values.global.clusterDomain }}:443
{{- end -}}
{{/* ######################################## ZEN CORE API ENDPOINT TEMPLATE ################## */}}
{{/* ######################################## POD ANTI-AFFINITY ################################## */}}
{{- define "zeno.podAntiAffinity" -}}
  {{- $params := . }}
  {{- $root := first $params }}
  {{- $compName := (include "sch.utils.getItem" (list $params 1 "")) -}}
podAntiAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchExpressions:
      - key: app
        operator: In
        values:
        - {{$compName}}
    topologyKey: "kubernetes.io/hostname"
{{- end -}}
{{/* ######################################## POD ANTI-AFFINITY ################################## */}}

{{/* ######################################## FLINK ENDPOINT TEMPLATE ########################### */}}
{{- define "zeno.flinkJobManagerEndpointTemplate" -}}
https://{{ .Release.Name }}-ibm-flink-job-manager.{{ .Release.Namespace }}.svc:{{ .Values.flink.jobmanager.service.port }}
{{- end -}}
{{/* ######################################## FLINK ENDPOINT TEMPLATE ########################### */}}

{{/* ######################################## FLINK CONFIGMAP TEMPLATE ########################### */}}
{{- define "zeno.flinkConfigMapNameTemplate" -}}
{{ .Release.Name }}-ibm-flink-config
{{- end -}}
{{/* ######################################## FLINK CONFIGMAP TEMPLATE ########################### */}}

{{/* ######################################## IMAGE NAME ######################################### */}}
{{- define "zeno.imageName" -}}
"{{ if .root.Values.global.dockerRegistryPrefix}}{{ trimSuffix "/" .root.Values.global.dockerRegistryPrefix }}/{{ end }}{{ .service.image.repository | default .service.image.name }}{{ if hasPrefix "sha256:" .service.image.tag}}@{{ else }}:{{ end }}{{ .service.image.tag }}"
{{- end -}}
{{/* ######################################## IMAGE NAME ######################################### */}}

{{/* ######################################## PULL SECRET TEMPLATE ######################################## */}}
{{- define "zeno.imagePullSecretTemplate" -}}
{{- if ne .Values.global.image.pullSecret "" }}
imagePullSecrets:
- name: {{ .Values.global.image.pullSecret | quote }}
{{- end -}}
{{- end -}}
{{/* ######################################## PULL SECRET TEMPLATE ######################################## */}}

{{/* ######################################## IMAGE AFFINITY ################################## */}}
{{- define "zeno.nodeAffinity" -}}
{{- if .Values.global.affinity -}}
{{ toYaml .Values.global.affinity }}
{{- else -}}
{{ include "sch.affinity.nodeAffinity" (list . .sch.chart.nodeAffinity) }}
{{- end -}}
{{- end -}}
{{/* ######################################## IMAGE AFFINITY ################################## */}}

{{/* ######################################## CONFIG TEMPLATES ###################################### */}}
{{- define "zeno.tlsVolume" -}}
- name: aiops-tls-volume
  secret:
    items:
    - key: tls.crt
      path: tls.crt
    - key: tls.key
      path: tls.key
    - key: tls.cacrt
      path: tls.cacrt
    - key: tls.p12
      path: tls.p12
    secretName: {{ include .Values.global.tls.secret.nameTpl . }}
- name: aiops-truststore-volume
  secret:
    items:
    - key: flink-tls-keystore.key
      path: flink-tls-keystore.key
    - key: flink-tls-ca-truststore.jks
      path: flink-tls-ca-truststore.jks
    secretName: {{ include .Values.global.tls.truststoreSecret.nameTpl . }}
{{- end -}}

{{- define "zeno.tlsVolumeMounts" -}}
- mountPath: /etc/ssl/certs/ca-root-cert.pem
  name: aiops-tls-volume
  subPath: tls.crt
- mountPath: /etc/ssl/certs/aiops-cert.pem
  name: aiops-tls-volume
  subPath: tls.cacrt
- mountPath: /etc/ssl/certs/aiops-key.pem
  name: aiops-tls-volume
  subPath: tls.key
- mountPath: /config/tls.p12
  name: aiops-tls-volume
  subPath: tls.p12
- mountPath: /etc/ssl/certs/flink-tls-keystore.key
  name: aiops-truststore-volume
  subPath: flink-tls-keystore.key
- mountPath: /etc/ssl/certs/flink-tls-ca-truststore.jks
  name: aiops-truststore-volume
  subPath: flink-tls-ca-truststore.jks
- mountPath: /ca-truststore.jks
  name: aiops-truststore-volume
  subPath: flink-tls-ca-truststore.jks
{{- end -}}

{{- define "zeno.curatorConfigMapName" -}}
{{ .Release.Name }}-{{ .Values.global.product.schName }}-curator-config
{{- end -}}

{{- define "zeno.curatorConfigVolume" -}}
- name: curator-config
  configMap:
    name: {{ include "zeno.curatorConfigMapName" . }}
{{- end -}}

{{- define "zeno.curatorConfigVolumeMount" -}}
- name: curator-config
  mountPath: /etc/config
{{- end -}}

{{- define "zeno.globalConfigMapName" -}}
{{ .Release.Name }}-{{ .Values.global.product.schName }}-global-config
{{- end -}}

{{- define "zeno.globalConfigVolume" -}}
- name: zeno-conf
  configMap:
    name: {{ include "zeno.globalConfigMapName" . }}
{{- end -}}

{{- define "zeno.globalConfigVolumeMount" -}}
- name: zeno-conf
  mountPath: /etc/zeno
{{- end -}}

{{- define "zeno.kafkaConfigVolumeMount" -}}
- name: kafka-tls-secret
  mountPath: {{ .Values.global.kafka.sasl.ca.location }}
  subPath: es-cert.pem
{{- end -}}

{{- define "zeno.kafkaConfigVolume" -}}
{{- if .Values.global.kafka.strimzi.enabled -}}
- name: kafka-tls-secret
  secret:
    secretName: {{ .Values.global.kafka.strimzi.clusterName }}-cluster-ca-cert
    items:
    - key: ca.crt
      path: es-cert.pem
- name: kafka-truststore-ca
  secret:
    secretName: {{ .Values.global.controller.kafkaTruststoreSecret }}
{{- else -}}
- name: kafka-tls-secret
  secret:
    secretName: {{ .Values.global.kafka.sasl.ca.certSecretName }}
    items:
    - key: {{ .Values.global.kafka.sasl.ca.certSecretKey }}
      path: es-cert.pem
- name: kafka-truststore-ca
  secret:
    secretName: {{ .Values.global.controller.kafkaTruststoreSecret }}
{{- end -}}
{{- end -}}

{{- define "zeno.secretConfigVolumeMount" -}}
- name: zeno-secrets
  mountPath: /etc/zeno/secrets
{{- end -}}

{{- define "zeno.secretConfigVolume" -}}
{{- if .Values.global.kafka.strimzi.enabled }}
- name: zeno-secrets
  projected:
    sources:
    - secret:
        name: {{ include "zeno.kafkaUsername" . }}
        items:
        - key: password
          path: kafka.secret
    - secret:
        name: {{ .Values.global.controller.kafkaTruststoreSecret }}
    - secret:
        name: {{ include "zeno.elasticsearchAccessSecretNameTemplate" . }}
        items:
        - key: password
          path: elasticsearch.password
{{- else}}
- name: zeno-secrets
  projected:
    sources:
    - secret:
        name: {{ .Values.global.kafka.sasl.accessSecretName }}
    - secret:
        name: {{ .Values.global.controller.kafkaTruststoreSecret }}
    - secret:
        name: {{ include "zeno.elasticsearchAccessSecretNameTemplate" . }}
        items:
        - key: password
          path: elasticsearch.password
{{- end -}}
{{- end -}}

{{- define "zeno.kafkaUsername" -}}
{{- if .Values.global.kafka.strimzi.enabled -}}
{{ .Values.global.kafka.strimzi.user }}
{{- else -}}
{{ .Values.global.kafka.sasl.username }}
{{- end -}}
{{- end -}}

{{- define "zeno.strimziBrokers" -}}
{{ .Values.global.kafka.strimzi.clusterName }}-kafka-bootstrap.{{ .Release.Namespace }}.{{ .Values.global.clusterDomain }}:9093
{{- end -}}

{{- define "zeno.kafkaEnvSecrets" -}}
{{- if .Values.global.kafka.strimzi.enabled -}}
- name: KAFKA_SASL_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "zeno.kafkaUsername" . }}
      key: password
{{- else -}}
- name: KAFKA_SASL_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.global.kafka.sasl.accessSecretName }}
      key: kafka.secret
{{- end -}}
{{- end -}}

{{- define "zeno.elasticsearchConfigVolumeMount" -}}
- name: elasticsearch-certs
  mountPath: /etc/ssl/certs/elasticsearch-cert.pem
  subPath: elasticsearch-cert.pem
# Needed by Flink
- name: elasticsearch-certs
  mountPath: /etc/ssl/certs/elastic-cert.pem
  subPath: elasticsearch-cert.pem
{{- end -}}

{{- define "zeno.elasticsearchConfigVolume" -}}
- name: elasticsearch-certs
  secret:
    secretName: {{ include "zeno.elasticsearchTlsSecretNameTemplate" . }}
    items:
      - key: ca.pem
        path: elasticsearch-cert.pem
{{- end -}}

{{- define "zeno.elasticsearchEnvSecrets" -}}
- name: "ES_PASSWORD"
  valueFrom:
    secretKeyRef:
      name: {{ include "zeno.elasticsearchAccessSecretNameTemplate" . }}
      key: password
- name: "ES_USER"
  valueFrom:
    secretKeyRef:
      name: {{ include "zeno.elasticsearchAccessSecretNameTemplate" . }}
      key: username
- name: "ES_USERNAME"
  valueFrom:
    secretKeyRef:
      name: {{ include "zeno.elasticsearchAccessSecretNameTemplate" . }}
      key: username
{{- end -}}

{{/* ######################################## CONFIG TEMPLATES ###################################### */}}

{{/* ######################################## TLS SECRET NAME ############################################# */}}
{{- define "zeno.tlsSecretNameTemplate" -}}
{{- .Release.Name }}-{{ .Values.global.product.schName }}-tls
{{- end -}}
{{/* ######################################## TLS SECRET NAME ############################################# */}}
{{/* ######################################## TRUSTSTORE SECRET NAME ############################################# */}}
{{- define "zeno.truststoreSecretNameTemplate" -}}
{{- .Release.Name }}-{{ .Values.global.product.schName }}-truststores
{{- end -}}
{{/* ######################################## TRUSTSTORE SECRET NAME ############################################# */}}
{{/* ######################################## FLINK CONFIG TEMPLATE ######################################## */}}
{{- define "flink.flinkConfigSecretName" -}}
{{ .Release.Name }}-flink-config-secret
{{- end -}}
{{/* ######################################## FLINK CONFIG TEMPLATE ######################################## */}}

{{/* ######################################## GEN SECRETS ################################################# */}}
{{/* ######################################## ROLE NAME ######################################### */}}
{{- define "zeno.roleName" -}}
{{ include "sch.names.fullName" (list . ) }}
{{- end -}}
{{/* ######################################## ROLE NAME ######################################### */}}
{{/* ######################################## SERVICE ACCOUNT NAME ############################## */}}
{{- define "zeno.serviceAccountName" -}}
{{- default (include "sch.names.fullName" (list . )) (default .Values.global.existingServiceAccount .Values.existingServiceAccount) -}}
{{- end -}}
{{/* ######################################## SERVICE ACCOUNT NAME ############################## */}}
{{/* ######################################## ROLE BINDING NAME ################################# */}}
{{- define "zeno.roleBindingName" -}}
{{ include "sch.names.fullName" (list . ) }}
{{- end -}}
{{/* ######################################## ROLE BINDING NAME ################################# */}}
{{/* ######################################## GEN SECRETS ################################################# */}}

{{/* ######################################## MINIO ####################################################### */}}
{{/* ######################################## MINIO SECRET TEMPLATE ############################# */}}
{{- define "zeno.minioAccessSecretNameTemplate" -}}
{{- .Release.Name }}-ibm-minio-access-secret
{{- end -}}
{{/* ######################################## MINIO SECRET TEMPLATE ############################# */}}
{{/* ######################################## MINIO TLS SECRET TEMPLATE ############################# */}}
{{- define "zeno.minioTlsSecretNameTemplate" -}}
{{- .Release.Name }}-ibm-minio-tls
{{- end -}}
{{/* ######################################## MINIO TLS SECRET TEMPLATE ############################# */}}
{{/* ######################################## MINIO AUTH SECRET TEMPLATE ############################# */}}
{{- define "zeno.minioAuthSecretNameTemplate" -}}
{{- .Release.Name }}-ibm-minio-auth
{{- end -}}
{{/* ######################################## MINIO AUTH SECRET TEMPLATE ############################# */}}

{{/* ######################################## MINIO ENDPOINT TEMPLATE ########################### */}}
{{- define "zeno.minioEndpointTemplate" -}}
http{{ if .Values.global.minio.sslEnabled }}s{{ end }}://{{ .Release.Name }}-ibm-minio-svc.{{ .Release.Namespace }}.{{ .Values.global.clusterDomain }}:{{ .Values.global.minio.endpointPort }}
{{- end -}}
{{/* ######################################## MINIO ENDPOINT TEMPLATE ########################### */}}
{{/* ######################################## MINIO ####################################################### */}}

{{/* ######################################## ELASTICSEARCH ################################### */}}
{{/* ######################################## ELASTICSEARCH TLS SECRET TEMPLATE ############### */}}
{{- define "zeno.elasticsearchTlsSecretNameTemplate" -}}
{{ .Release.Name }}-ibm-{{ .Values.global.elastic.clusterName }}-cert
{{- end -}}
{{/* ######################################## ELASTICSEARCH TLS SECRET TEMPLATE ############### */}}
{{/* ######################################## ELASTICSEARCH AUTH SECRET TEMPLATE ############## */}}
{{- define "zeno.elasticsearchAccessSecretNameTemplate" -}}
{{ .Release.Name }}-ibm-{{ .Values.global.elastic.clusterName }}-secret
{{- end -}}
{{/* ######################################## ELASTICSEARCH AUTH SECRET TEMPLATE############### */}}
{{/* ######################################## ELASTIC ENDPOINT TEMPLATE ####################### */}}
{{- define "zeno.elasticsearchServiceTemplate" -}}
{{ .Release.Name }}-ibm-{{ .Values.global.elastic.clusterName }}-svc.{{ .Release.Namespace }}.{{ .Values.global.clusterDomain }}
{{- end -}}
{{- define "zeno.elasticsearchEndpointTemplate" -}}
{{ include "zeno.elasticsearchServiceTemplate" . }}:{{ .Values.elasticsearch.httpsPort}}
{{- end -}}
{{/* ######################################## ELASTIC ENDPOINT TEMPLATE ####################### */}}
{{/* ######################################## ELASTICSEARCH ################################### */}}

{{/* ###################################### MODELTRAIN TRAINER ENDPOINT TEMPLATE ######################### */}}
{{- define "zeno.modeltrainTrainerEndpointTemplate" -}}
{{- .Release.Name}}-ibm-dlaas-trainer-v2.{{ .Release.Namespace }}.{{ .Values.global.clusterDomain }}:8443
{{- end -}}
{{/* ###################################### MODELTRAIN TRAINER ENDPOINT TEMPLATE ######################### */}}
{{/* ###################################### MODELTRAIN TRAINER CERT CM TEMPLATE ######################### */}}
{{- define "zeno.modeltrainTrainerCertCmTemplate" -}}
{{- .Release.Name}}-ibm-dlaas-trainer-ca-certificate
{{- end -}}
{{/* ###################################### MODELTRAIN TRAINER CERT CM TEMPLATE ######################### */}}
{{/* ################################### POSTGRES ######################################## */}}
{{/* ################################### POSTGRES HOST NAME TEMPLATE ######################################## */}}
{{- define "zeno.postgresHostnameTemplate" -}}
{{- .Release.Name }}-{{ .Values.global.postgres.nameOverride }}-proxy-svc
{{- end -}}
{{/* ################################### POSTGRES HOST NAME TEMPLATE ######################################## */}}
{{/* ################################### POSTGRES AUTH SECRET NAME ######################################## */}}
{{- define "zeno.postgresAuthSecretNameTemplate" -}}
{{- .Release.Name }}-{{ .Values.global.postgres.nameOverride }}-auth-secret
{{- end -}}
{{/* ################################### POSTGRES AUTH SECRET NAME ######################################## */}}
{{/* ################################### POSTGRES TLS SECRET NAME ######################################## */}}
{{- define "zeno.postgresTlsSecretNameTemplate" -}}
{{- .Release.Name }}-{{ .Values.global.postgres.nameOverride }}-tls-secret
{{- end -}}
{{/* ################################### POSTGRES TLS SECRET NAME ######################################## */}}
{{/* ################################### POSTGRES ######################################## */}}

{{/* ################################### MOCK SERVER ########################################## */}}
{{/* ################################### MOCK SERVER SECRET NAME ############################## */}}
{{- define "zeno.mockServerSecretNameTemplate" -}}
{{- .Release.Name }}-mock-server-auth-secret
{{- end -}}
{{/* ################################### MOCK SERVER SECRET NAME ############################## */}}
{{/* ################################### MOCK SERVER ########################################## */}}


{{/* ######################################## S3FS ############################################ */}}
{{/* ######################################## S3FS SECRET TEMPLATE ############################ */}}
{{- define "zeno.s3fsSecretNameTemplate" -}}
{{- .Release.Name }}-ibm-s3fs-access-secret
{{- end -}}
{{/* ######################################## MINIO SECRET TEMPLATE ########################### */}}
{{/* ######################################## S3FS ############################################ */}}


{{/*
  Liveness Helper Templates for AIOps
  Included are the following:
  - Liveness and Readiness Probe Templates
  - initContainer templates

  TODO Split this section off into a new file _liveness.tpl
  For a later commit this one is too big already
*/}}

{{/* ################################### LIVENESS READINESS PROBE ############################# */}}
{{- define "zeno.livenessProbeTemplate" -}}
livenessProbe:
  httpGet:
    path: {{ default "/healthcheck" .livePath }}
    port: {{ default "http" .port }}
    scheme: {{ if .noTls }}HTTP{{ else }}HTTPS{{end}}
  initialDelaySeconds: {{ default 30 .liveDelay }}
  periodSeconds: {{ default 20 .livePeriod }}
  timeoutSeconds: {{ default 5 .liveTimeout }}
readinessProbe:
  httpGet:
    path: {{ default "/ready" .readyPath }}
    port: {{ default "http" .port }}
    scheme: {{ if .noTls }}HTTP{{ else }}HTTPS{{end}}
  initialDelaySeconds: {{ default (default 30 .liveDelay) .readyDelay }}
  periodSeconds: {{ default (default 10 .livePeriod) .readyPeriod }}
  timeoutSeconds: {{ default (default 5 .liveTimeout) .readyTimeout }}
{{- end -}}
{{/* ################################### LIVENESS READINESS PROBE ############################# */}}

{{/* ################################### INIT CONTAINER READINESS ############################# */}}
{{/* General Zeno Services Init Container Template */}}
{{- define "zeno.initContainerReadiness" -}}
################### initContainer for {{ .service }} ###############
# Ensure {{ .service }} is already up and running
- name: {{ .service }}-is-ready
  image: {{ include "zeno.imageName" (dict "root" .root "service" .root.Values.utils) }}
  imagePullPolicy: IfNotPresent
{{ include "sch.security.securityContext" (list .root .root.sch.chart.podSecurityContext) | trim | indent 2 }}
  resources:
{{ toYaml .root.Values.utils.resources | trim | indent 4 }}
  command:
  - "sh"
  - "-c"
  - |
    echo "Waiting until {{ .service }} is running and ready."
    cmd="curl --write-out %{http_code} --silent -k --output /dev/null https://{{ include "sch.names.fullCompName" (list .root .service) }}:8000{{ if .endpoint }}/{{ .endpoint }}{{ end }}"
    echo "Running command: $cmd"
    for i in {1..10} ; do
      response=$(eval $cmd)
      if [ "$response" -eq "200" ]; then
        echo "Done, {{ .service }} is running now."
        exit 0
      fi
      echo "- The command failed with response code: $response (retry in 5 sec)"
      sleep 15
    done
    echo "Failed, {{ .service }} is not running."
    exit 1
#################################################################
{{- end }}


{{/* Individual Zeno Services Init Container Templates */}}
{{- define "zeno.initContainerReadiness.persistence" -}}
{{ include "zeno.initContainerReadiness" (dict "root" . "service" .sch.chart.components.persistence "endpoint" "ready") }}
{{- end }}

{{- define "zeno.initContainerReadiness.topology" -}}
{{ include "zeno.initContainerReadiness" (dict "root" . "service" .sch.chart.components.topology "endpoint" "ready") }}
{{- end }}

{{- define "zeno.initContainerReadiness.alertLocalization" -}}
{{ include "zeno.initContainerReadiness" (dict "root" . "service" .sch.chart.components.alertLocalization "endpoint" "ready") }}
{{- end }}

{{- define "zeno.initContainerReadiness.eventGrouping" -}}
{{ include "zeno.initContainerReadiness" (dict "root" . "service" .sch.chart.components.eventGrouping "endpoint" "ready") }}
{{- end }}

{{- define "zeno.initContainerReadiness.similarIncidents" -}}
{{ include "zeno.initContainerReadiness" (dict "root" . "service" .sch.chart.components.similarIncidents "endpoint" "healthcheck") }}
{{- end }}

{{- define "zeno.initContainerReadiness.chatopsOrchestrator" -}}
{{ include "zeno.initContainerReadiness" (dict "root" . "service" .sch.chart.components.chatopsOrchestrator "endpoint" "ready") }}
{{- end }}

{{- define "zeno.initContainerReadiness.chatopsSlackIntegrator" -}}
{{ include "zeno.initContainerReadiness" (dict "root" . "service" .sch.chart.components.chatopsSlackIntegrator "endpoint" "ready") }}
{{- end }}

{{- define "zeno.initContainerReadiness.controller" -}}
{{ include "zeno.initContainerReadiness" (dict "root" . "service" .sch.chart.components.controller "endpoint" "ready") }}
{{- end }}

{{/* ################################### FLINK INIT CONTAINER ######################################## */}}
{{/* General Zeno Services Init Container Template */}}
{{- define "zeno.flinkInitContainerReadiness" -}}
- name: flink-is-ready
  image: {{ include "zeno.imageName" (dict "root" . "service" .Values.utils) }}
  imagePullPolicy: IfNotPresent
{{ include "sch.security.securityContext" (list . .sch.chart.podSecurityContext) | trim | indent 2 }}
  resources:
{{ toYaml .Values.utils.resources | trim | indent 4 }}
  command:
  - "sh"
  - "-c"
  - |
    echo "Waiting until flink at {{ include "zeno.flinkJobManagerEndpointTemplate" . }} is running and ready."
    until curl --fail -k {{ include "zeno.flinkJobManagerEndpointTemplate" . }}; do
      echo "Flink not up yet waiting 5..."
      sleep 5
    done
    exit 0
#################################################################
{{- end }}

{{/* Minio Init Container Template */}}
{{- define "zeno.minioInitContainerReadiness" -}}
################### initContainer for minio ###############
# Ensure minio is already up and running
- name: minio-is-ready
  image: {{ include "zeno.imageName" (dict "root" .root "service" .root.Values.minio.minioClient) }}
  imagePullPolicy: IfNotPresent
{{ include "sch.security.securityContext" (list .root .root.sch.chart.podSecurityContext) | trim | indent 2 }}
  resources:
    requests:
      memory: 128Mi
      cpu: 100m
    limits:
      memory: 128Mi
      cpu: 100m
  command:
  - "/bin/bash"
  - -c
  - |
    set -e ; # Have script exit in the event of a failed command.

    # connectToMinio
    # Use a check-sleep-check loop to wait for Minio service to be available
    connectToMinio() {
      ATTEMPTS=0 ; LIMIT=29 ; # Allow 30 attempts
      set +e ; # The connections to minio are allowed to fail.
      echo "Connecting to Minio server: $MINIO_ENDPOINT" ;
      MC_COMMAND="mc config host add myminio $MINIO_ENDPOINT $MINIO_ACCESS_KEY $MINIO_SECRET_KEY";
      $MC_COMMAND ;
      STATUS=$? ;
      until [ $STATUS = 0 ]
      do
        ATTEMPTS=`expr $ATTEMPTS + 1` ;
        echo \"Failed attempts: $ATTEMPTS\" ;
        if [ $ATTEMPTS -gt $LIMIT ]; then
          exit 1 ;
        fi ;
        sleep 2 ; # 1 second intervals between attempts
        $MC_COMMAND ;
        STATUS=$? ;
      done ;
      set -e ; # reset `e` as active
      return 0
    }

    # checkBucketExists ($bucket)
    # Check if the bucket exists, by using the exit code of `mc ls`
    checkBucketExists() {
      BUCKET=$1
      CMD=$(/workdir/bin/mc ls myminio/$BUCKET > /dev/null 2>&1)
      return $?
    }

    # Connect to MinIO and check if bucket exists
    connectToMinio
    echo "Minio Connection Established"
    {{- if .bucketName }}
    while true ; do
      checkBucketExists {{ .bucketName }} && break || sleep 30
    done
    echo "Bucket exists! Start service."
    {{- end }}
  env:
  - name: MINIO_ENDPOINT
    value: {{ include .root.Values.global.minio.endpointTpl .root }}
  - name: MINIO_ACCESS_KEY
    valueFrom:
      secretKeyRef:
        name: {{ include .root.Values.global.minio.accessSecret.nameTpl .root | quote }}
        key: accesskey
  - name: MINIO_SECRET_KEY
    valueFrom:
      secretKeyRef:
        name: {{ include .root.Values.global.minio.accessSecret.nameTpl .root | quote }}
        key: secretkey
  volumeMounts:
  - name: {{ .tlsVolumeName }}
    mountPath: /workdir/home/.mc/certs/CAs/public.crt
    subPath: tls.cacrt
#################################################################
{{- end }}

{{- define "zeno.elasticsearchInitContainerReadiness" -}}
################### initContainer for Elasticsearch ###############
# Ensure Elasticsearch is already up and running
- name: elasticsearch-is-ready
  image: {{ include "zeno.imageName" (dict "root" . "service" .Values.elasticsearch) }}
  imagePullPolicy: IfNotPresent
{{ include "sch.security.securityContext" (list . .sch.chart.podSecurityContext) | trim | indent 2 }}
  resources:
{{ toYaml .Values.resources | trim | indent 4 }}
  command:
  - "sh"
  - "-c"
  - |
    echo "Waiting until Elasticsearch is running and store database and users are created"
    while true ; do
      curl -l --cacert ${ES_CACERT} -u ${ES_USER}:${ES_PASSWORD} ${ES_URL}/_cluster/health | grep '"status":"yellow"\|"status":"green"'
      if [ $? -eq 0 ]
      then
        echo "Elasticsearch has started."
        break
      fi
      sleep 5
    done
    echo "Done. Elasticsearch is running now. Let go to create/update the DB schema for store microservice."
  envFrom:
  - configMapRef:
      name: {{ include "sch.names.fullCompName" (list . .sch.chart.config.elasticsearch) }}
  env:
{{ include "zeno.elasticsearchEnvSecrets" . | indent 2 }}
  volumeMounts:
{{ include "zeno.elasticsearchConfigVolumeMount" . | indent 2 }}
#################################################################
{{- end }}

{{- define "zeno.postgresInitContainerReadiness" -}}
################### initContainer for postgres ###############
# Ensure postgres is already up and running
- name: postgres-is-ready
  image: {{ include "zeno.imageName" (dict "root" .root "service" .root.Values.postgres.postgres) }}
  imagePullPolicy: IfNotPresent
{{ include "sch.security.securityContext" (list .root .root.sch.chart.podSecurityContext) | trim | indent 2 }}
  resources:
{{ toYaml .root.Values.resources | trim | indent 4 }}
  command:
  - "sh"
  - "-c"
  - |
    echo "Waiting until postgres is running"
    while true ; do
      pg_isready -h $PGHOST -d postgres -U $PGUSER && break || sleep 30
    done
    echo "Done. Postgres is running now."
  env: # connection info for postgres
  - name: "PGHOST"
    value: {{ include .root.Values.global.postgres.tls.hostnameTpl .root | quote }}
  - name: "PGPORT"
    value: {{ .root.Values.global.postgres.endpointPort | quote }}
  - name: "PGDATABASE"
    value: {{ .root.Values.postgres.nameOverride | quote  }}
  - name: "PGUSER"
    value: {{ .root.Values.global.postgres.authSecret.pgSuperuserName | quote }}
  - name: "PGPASSWORD"
    valueFrom:
      secretKeyRef:
        name: {{ include .root.Values.global.postgres.authSecret.nameTpl .root | quote }}
        key: pg_su_password
  - name: "PGSSLMODE"
    value: "verify-full"
  - name: "PGSSLROOTCERT"
    value: "/etc/ssl/certs/postgres-cert.pem"
  volumeMounts:
  - name: {{ .tlsVolumeName | quote }}
    mountPath: /etc/ssl/certs/postgres-cert.pem
    subPath: tls.crt
#################################################################
{{- end -}}
{{/* ################################### INIT CONTAINER READINESS ######################################## */}}
