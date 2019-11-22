{{/* vim: set filetype=mustache: */}}
{{/*
InitContainer for Flink jobs
*/}}
{{- define "jobs.initContainers" -}}
initContainers:
  - name: wait-bai-flink-es
    image: {{ .Values.initImage.image.repository }}:{{ .Values.initImage.image.tag }}
    {{- if .Values.imagePullPolicy }}
    imagePullPolicy: {{ .Values.imagePullPolicy }}
    {{- end}}
    securityContext:
      runAsNonRoot: true
      runAsUser: 9999
    env:
    - name: ES_CONFIG_VERSION
      valueFrom:
        configMapKeyRef:
          name: {{ .Release.Name }}-bai-env
          key: es-config-version
    - name: ELASTICSEARCH_URL
      valueFrom:
        configMapKeyRef:
          name: {{ .Release.Name }}-bai-env
          key: elasticsearch-url
    - name: ELASTICSEARCH_USERNAME
      valueFrom:
{{- if .Values.elasticsearch.install }}
  {{- if index .Values "ibm-dba-ek" "ekSecret"  }}
        secretKeyRef:
          name: {{ index .Values "ibm-dba-ek" "ekSecret" }}
  {{- else }}
        configMapKeyRef:
          name: {{ .Release.Name }}-bai-env
  {{- end}}
{{- else }}
  {{- if .Values.baiSecret  }}
        secretKeyRef:
          name: {{ .Values.baiSecret }}
  {{- else }}
        configMapKeyRef:
          name: {{ .Release.Name }}-bai-env
  {{- end}}
{{- end}}
          key: elasticsearch-username
    - name: ELASTICSEARCH_PASSWORD
      valueFrom:
        secretKeyRef:
{{- if .Values.elasticsearch.install }}
  {{- if index .Values "ibm-dba-ek" "ekSecret"  }}
          name: {{ index .Values "ibm-dba-ek" "ekSecret" }}
  {{- else }}
          name: {{ .Release.Name }}-bai-secrets
  {{- end}}
{{- else }}
  {{- if .Values.baiSecret  }}
          name: {{ .Values.baiSecret }}
  {{- else }}
          name: {{ .Release.Name }}-bai-secrets
  {{- end}}
{{- end}}
          key: elasticsearch-password
    command: ['sh', '-c','
      [[ "${ELASTICSEARCH_URL: -1}" == "/" ]] && ELASTICSEARCH_URL=${ELASTICSEARCH_URL:$i:-1};
      templateUrl=$ELASTICSEARCH_URL/_template/{{ .ESTemplateName }};
      esRequest="curl -s -k -X GET -m 30 $templateUrl -u $ELASTICSEARCH_USERNAME:$ELASTICSEARCH_PASSWORD";

      while :; do
        echo "[`date`] Waiting for Flink cluster to start...";
        sleep 5;
        wget "https://{{ .Release.Name }}-bai-flink-jobmanager:8081/overview" -qO- -T 5 --no-check-certificate;
        if [[ "$?" == "0" ]]; then
          printf "\n[`date`] Flink cluster is ready.\n";
          break;
        fi;
      done;

      while :; do
        echo "[`date`] Waiting for Elasticsearch cluster availability...";
        ${esRequest};
        if [[ "$?" == "0" ]]; then
          printf "\n[`date`] Elasticsearch cluster is available.\n";
          break;
        fi;
      done;

      i=0;
      while :; do
        echo "[`date`] Checking if mappings version is up-to-date (${templateUrl}). Expecting version: $ES_CONFIG_VERSION... (iteration $i)";
        i=$((i+1));
        ${esRequest} | grep "\"version\":\"$ES_CONFIG_VERSION\"";
        if [[ "$?" == "0" ]]; then
          printf "\n[`date`] Mappings are up-to-date.\n";
          break;
        else
          printf "\n[`date`] Mappings are NOT up-to-date.\n";
        fi;
        sleep 5;
      done;
    ']
{{ end }}

{{/*
Environment variables for Flink jobs
*/}}
{{- define "jobs.envVars" -}}
env:
  - name: JOB_MANAGER_RPC_ADDRESS
    value: {{ .Release.Name }}-bai-flink-jobmanager
  - name: ZOOKEEPER_ADDRESS
    value: {{ .Release.Name }}-bai-flink-zk-cs
  - name: TAIGA_FEATURES
    valueFrom:
      configMapKeyRef:
        name: {{ .Release.Name }}-bai-env
        key: bai-features
  - name: KAFKA_USERNAME
    valueFrom:
  {{- if .Values.baiSecret }}
      secretKeyRef:
        name: {{ .Values.baiSecret }}
  {{- else }}
      configMapKeyRef:
        name: {{ .Release.Name }}-bai-env
  {{- end}}
        key: kafka-username
  - name: KAFKA_PASSWORD
    valueFrom:
      secretKeyRef:
  {{- if .Values.baiSecret }}
        name: {{ .Values.baiSecret }}
  {{- else }}
        name: {{ .Release.Name }}-bai-secrets
  {{- end}}
        key: kafka-password
  - name: KAFKA_BOOTSTRAP_SERVERS
    valueFrom:
      configMapKeyRef:
        name: {{ .Release.Name }}-bai-env
        key: kafka-bootstrap-servers
  - name: KAFKA_SECURITY_PROTOCOL
    valueFrom:
      configMapKeyRef:
        name: {{ .Release.Name }}-bai-env
        key: kafka-security-protocol
  - name: KAFKA_SASL_KERBEROS_SERVICE_NAME
    valueFrom:
      configMapKeyRef:
        name: {{ .Release.Name }}-bai-env
        key: kafka-sasl-kerberos-service-name
  - name: FLINK_SECURITY_KRB5_ENABLE_KAFKA
    valueFrom:
      configMapKeyRef:
        name: {{ .Release.Name }}-bai-env
        key: flink-security-krb5-enable-kafka
  - name: SSL_PASSWORD
    valueFrom:
      secretKeyRef:
  {{- if .Values.baiSecret }}
        name: {{ .Values.baiSecret }}
  {{- else }}
        name: {{ .Release.Name }}-bai-secrets
  {{- end}}
        key: flink-ssl-password
  - name: JOB_PARALLELISM
  
    value: {{ .Parallelism | default 1 | quote}}
  
  - name: CHECKPOINTING_INTERVAL
    valueFrom:
      configMapKeyRef:
        name: {{ .Release.Name }}-bai-env
        key: flink-job-checkpointing-interval
  - name: SUMMARY_END_AGGREGATION_DELAY_MS
    valueFrom:
      configMapKeyRef:
        name: {{ .Release.Name }}-bai-env
        key: bpmn-end-aggregation-delay
        optional: true
  - name: STORAGE_BATCH_SIZE
    valueFrom:
      configMapKeyRef:
        name: {{ .Release.Name }}-bai-env
        key: storage-batch-size
  - name: INACTIVE_BUCKET_CHECK_INTERVAL
    valueFrom:
      configMapKeyRef:
        name: {{ .Release.Name }}-bai-env
        key: storage-inactive-bucket-check-interval-ms
  - name: INACTIVE_BUCKET_THRESHOLD
    valueFrom:
      configMapKeyRef:
        name: {{ .Release.Name }}-bai-env
        key: storage-inactive-bucket-threshold-ms
  - name: STORAGE_BUCKET_URL
    valueFrom:
      configMapKeyRef:
        name: {{ .Release.Name }}-bai-env
        key: storage-bucket-url
  - name: INGRESS_TOPIC
    valueFrom:
      configMapKeyRef:
        name: {{ .Release.Name }}-bai-env
        key: ingress-topic
  - name: EGRESS_TOPIC
    valueFrom:
      configMapKeyRef:
        name: {{ .Release.Name }}-bai-env
        key: egress-topic
  - name: SERVICE_TOPIC
    valueFrom:
      configMapKeyRef:
        name: {{ .Release.Name }}-bai-env
        key: service-topic
  - name: SAVEPOINT
    value: {{ .RecoveryPath | quote}}
  {{- if not .IgnoreES }}
  - name: ELASTICSEARCH_URL
    valueFrom:
      configMapKeyRef:
        name: {{ .Release.Name }}-bai-env
        key: elasticsearch-url
  - name: ELASTICSEARCH_USERNAME
    valueFrom:
    {{- if .Values.elasticsearch.install }}
      {{- if index .Values "ibm-dba-ek" "ekSecret"  }}
      secretKeyRef:
        name: {{ index .Values "ibm-dba-ek" "ekSecret" }}
      {{- else }}
      configMapKeyRef:
        name: {{ .Release.Name }}-bai-env
      {{- end}}
    {{- else }}
      {{- if .Values.baiSecret  }}
      secretKeyRef:
        name: {{ .Values.baiSecret }}
      {{- else }}
      configMapKeyRef:
        name: {{ .Release.Name }}-bai-env
      {{- end}}
    {{- end}}
        key: elasticsearch-username
  - name: ELASTICSEARCH_PASSWORD
    valueFrom:
      secretKeyRef:
    {{- if .Values.elasticsearch.install }}
      {{- if index .Values "ibm-dba-ek" "ekSecret"  }}
        name: {{ index .Values "ibm-dba-ek" "ekSecret" }}
      {{- else }}
        name: {{ .Release.Name }}-bai-secrets
      {{- end}}
    {{- else }}
      {{- if .Values.baiSecret  }}
        name: {{ .Values.baiSecret }}
      {{- else }}
        name: {{ .Release.Name }}-bai-secrets
      {{- end}}
    {{- end}}
        key: elasticsearch-password
  - name: ELASTICSEARCH_MAX_ACTIONS
    valueFrom:
      configMapKeyRef:
        name: {{ .Release.Name }}-bai-env
        key: flink-job-elasticsearch-max-actions
  {{- end}}
{{ end }}

{{/*
Readiness and Liveness probes for Flink jobs
*/}}
{{- define "jobs.probes" -}}
readinessProbe:
  exec:
    command: ['sh', '-c',
            'ps aux | grep -v grep | grep "run-job"']
  periodSeconds: 10
livenessProbe:
  exec:
    command: ['sh', '-c',
            'ps aux | grep -v grep | grep "run-job"']
  initialDelaySeconds: 15
  periodSeconds: 20
{{ end }}

{{/*
VolumeMounts for Flink jobs
*/}}
{{- define "jobs.volumeMounts" -}}
volumeMounts:
- mountPath: /opt/flink/conf/log4j-cli.properties
  name: flink-log4j
  subPath: log4j-cli.properties
  {{- if .Values.kafka.propertiesConfigMap }}
- name: kafka-config-volume
  mountPath: /etc/kafka/config
  {{- end }}
  {{- if .Values.flink.rocksDbPropertiesConfigMap }}
- name: rocksdb-config-volume
  mountPath: /etc/rocksdb/config
  {{- end }}
- name: flink-ssl
  mountPath: /etc/flink-ssl
  readOnly: true
- name: nfs-storage
  mountPath: /mnt/pv
{{ end }}

{{/*
Volumes for Flink jobs
*/}}
{{- define "jobs.volumes" -}}
volumes:
- name: flink-log4j
  configMap:
    name: {{ template "flink.configmap.name" . }}
    items:
      - key: log4j-cli.properties
        path: log4j-cli.properties
  {{- if .Values.kafka.propertiesConfigMap }}
- name: kafka-config-volume
  configMap:
    name: {{ .Values.kafka.propertiesConfigMap }}
  {{- end }}
  {{- if .Values.flink.rocksDbPropertiesConfigMap }}
- name: rocksdb-config-volume
  configMap:
    name: {{ .Values.flink.rocksDbPropertiesConfigMap }}
  {{- end }}
- name: flink-ssl
  secret:
  {{- if .Values.baiSecret  }}
    secretName: {{ .Values.baiSecret }}
  {{- else }}
    secretName: {{ .Release.Name }}-bai-secrets
  {{- end }}
    items:
    - key: flink-ssl-keystore
      path: pods.keystore
    - key: flink-ssl-truststore
      path: ca.truststore
    - key: flink-ssl-internal-keystore
      path: internal.keystore 
- name: nfs-storage
  persistentVolumeClaim:
    {{- if .Values.flinkPv.existingClaimName }}
      claimName: {{ .Values.flinkPv.existingClaimName }}
    {{- else }}
      claimName: {{ .Release.Name }}-bai-pvc
    {{- end }}
{{ end }}