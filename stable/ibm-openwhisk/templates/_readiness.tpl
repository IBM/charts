# Licensed to the Apache Software Foundation (ASF) under one or more contributor
# license agreements; and to You under the Apache License, Version 2.0.

{{/* Init container that waits for couchdb to be ready */}}
{{- define "readiness.waitForCouchDB" -}}
{{ if not .Values.db.wipeAndInit }}
# if not db.wipeAndInit, the external db must already be ready; so no need for init container
{{- else -}}
- name: "wait-for-couchdb"
  image: "busybox"
  imagePullPolicy: "IfNotPresent"
  env:
  - name: "READINESS_URL"
    value: {{ .Values.db.protocol }}://{{ include "db_host" . }}:{{ .Values.db.port }}/{{ .Values.db.activationsTable }}
  command: ["sh", "-c", "result=1; until [ $result -eq 0 ]; do echo verifying CouchDB readiness; wget -T 5 --spider $READINESS_URL --header=\"Authorization: Basic {{ include "db_authentication" . | b64enc }}\"; result=$?; sleep 1; done;"]
{{- end -}}
{{- end -}}

{{/* Init container that waits for kafka to be ready */}}
{{- define "readiness.waitForKafka" -}}
- name: "wait-for-kafka"
  image: "busybox"
  imagePullPolicy: "IfNotPresent"
  # TODO: I haven't found an easy external test to determine that kafka is up, so as a hack we wait for zookeeper and then sleep for 10 seconds and cross our fingers!
  command: ["sh", "-c", 'result=1; until [ $result -eq 0 ]; do OK=$(echo ruok | nc -w 1 {{ include "zookeeper_zero_host" . }} {{ .Values.zookeeper.port }}); if [ "$OK" == "imok" ]; then result=0; echo "zookeeper returned imok!"; fi; echo waiting for zookeeper to be ready; sleep 1; done; echo zookeeper is up, sleeping for 10 seconds; sleep 10;']
{{- end -}}

{{/* Init container that waits for zookeeper to be ready */}}
{{- define "readiness.waitForZookeeper" -}}
- name: "wait-for-zookeeper"
  image: "busybox"
  imagePullPolicy: "IfNotPresent"
  command: ["sh", "-c", 'result=1; until [ $result -eq 0 ]; do OK=$(echo ruok | nc -w 1 {{ include "zookeeper_zero_host" . }} {{ .Values.zookeeper.port }}); if [ "$OK" == "imok" ]; then result=0; echo "zookeeper returned imok!"; fi; echo waiting for zookeeper to be ready; sleep 1; done;']
{{- end -}}

{{/* Init container that waits for controller to be ready */}}
{{- define "readiness.waitForController" -}}
- name: "wait-for-controller"
  image: "busybox"
  imagePullPolicy: "IfNotPresent"
  env:
  - name: "READINESS_URL"
    value: http://{{ include "controller_host" . }}:{{ .Values.controller.port }}/ping
  command: ["sh", "-c", "result=1; until [ $result -eq 0 ]; do echo verifying controller readiness; wget -T 5 --spider $READINESS_URL; result=$?; sleep 1; done;"]
{{- end -}}
