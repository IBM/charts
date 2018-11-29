# Licensed to the Apache Software Foundation (ASF) under one or more contributor
# license agreements; and to You under the Apache License, Version 2.0.

{{/* Init container that waits for couchdb to be ready */}}
{{- define "openwhisk.readiness.waitForCouchDB" -}}
{{ if not .Values.db.wipeAndInit }}
# if not db.wipeAndInit, the external db must already be ready; so no need for init container
{{- else -}}
- name: "wait-for-couchdb"
  image: "busybox"
  imagePullPolicy: "IfNotPresent"
  env:
  - name: "READINESS_URL"
    value: {{ .Values.db.protocol }}://{{ include "openwhisk.db_host" . }}:{{ .Values.db.port }}/ow_kube_couchdb_initialized_marker
  command: ["sh", "-c", "while true; do echo 'checking CouchDB readiness'; wget -T 5 --spider $READINESS_URL --header=\"Authorization: Basic {{ include "openwhisk.db_authentication" . | b64enc }}\"; result=$?; if [ $result -eq 0 ]; then echo 'Success: CouchDB is ready!'; break; fi; echo '...not ready yet; sleeping 3 seconds before retry'; sleep 3; done;"]
{{- end -}}
{{- end -}}

{{/* Init container that waits for kafka to be ready */}}
{{- define "openwhisk.readiness.waitForKafka" -}}
- name: "wait-for-kafka"
  image: "busybox"
  imagePullPolicy: "IfNotPresent"
  # TODO: I haven't found an easy external test to determine that kafka is up, so as a hack we wait for zookeeper and then sleep for 10 seconds and cross our fingers!
  command: ["sh", "-c", 'result=1; until [ $result -eq 0 ]; do OK=$(echo ruok | nc -w 1 {{ include "openwhisk.zookeeper_zero_host" . }} {{ .Values.zookeeper.port }}); if [ "$OK" == "imok" ]; then result=0; echo "zookeeper returned imok!"; else echo waiting for zookeeper to be ready; sleep 1; fi done; echo "Zookeeper is up; will wait for 10 seconds to give kafka time to initialize"; sleep 10;']
{{- end -}}

{{/* Init container that waits for zookeeper to be ready */}}
{{- define "openwhisk.readiness.waitForZookeeper" -}}
- name: "wait-for-zookeeper"
  image: "busybox"
  imagePullPolicy: "IfNotPresent"
  command: ["sh", "-c", 'result=1; until [ $result -eq 0 ]; do OK=$(echo ruok | nc -w 1 {{ include "openwhisk.zookeeper_zero_host" . }} {{ .Values.zookeeper.port }}); if [ "$OK" == "imok" ]; then result=0; echo "zookeeper returned imok!"; else echo waiting for zookeeper to be ready; sleep 1; fi; done; echo "Success: zookeeper is up"']
{{- end -}}

{{/* Init container that waits for controller to be ready */}}
{{- define "openwhisk.readiness.waitForController" -}}
- name: "wait-for-controller"
  image: "busybox"
  imagePullPolicy: "IfNotPresent"
  env:
  - name: "READINESS_URL"
    value: http://{{ include "openwhisk.controller_host" . }}:{{ .Values.controller.port }}/ping
  command: ["sh", "-c", "result=1; until [ $result -eq 0 ]; do echo 'Checking controller readiness'; wget -T 5 --spider $READINESS_URL; result=$?; sleep 1; done; echo 'Success: controller is ready'"]
{{- end -}}

{{/* Init container that waits for at least 1 healthy invoker */}}
{{- define "openwhisk.readiness.waitForHealthyInvoker" -}}
- name: "wait-for-healthy-invoker"
  image: "busybox"
  imagePullPolicy: "IfNotPresent"
  env:
  - name: "READINESS_URL"
    value: "http://{{ include "openwhisk.controller_host" . }}:{{ .Values.controller.port }}/invokers/healthy/count"
  command: ["sh", "-c", "echo 0 > /tmp/count.txt; while true; do echo 'waiting for healthy invoker'; wget -T 5 -qO /tmp/count.txt --no-check-certificate \"$READINESS_URL\"; NUM_HEALTHY_INVOKERS=$(cat /tmp/count.txt); if [ $NUM_HEALTHY_INVOKERS -gt 0 ]; then echo \"Success: there are $NUM_HEALTHY_INVOKERS healthy invokers\"; break; fi; echo '...not ready yet; sleeping 3 seconds before retry'; sleep 3; done;"]
{{- end -}}
