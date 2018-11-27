# Licensed to the Apache Software Foundation (ASF) under one or more contributor
# license agreements; and to You under the Apache License, Version 2.0.

{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "openwhisk.fullname" -}}
{{- $name := default .Chart.Name -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* boilerplate labels */}}
{{- define "openwhisk.label_boilerplate" -}}
heritage: {{ .Release.Service | quote }}
release: {{ .Release.Name | quote }}
chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
app: {{ template "openwhisk.fullname" . }}
{{- end -}}

{{/* hostname for apigateway */}}
{{- define "openwhisk.apigw_host" -}}
{{ .Values.apigw.name }}.{{ .Release.Namespace }}.svc.{{ .Values.k8s.domain }}
{{- end -}}

{{/* hostname for controller */}}
{{- define "openwhisk.controller_host" -}}
{{ .Values.controller.name }}.{{ .Release.Namespace }}.svc.{{ .Values.k8s.domain }}
{{- end -}}

{{/* hostname for database */}}
{{- define "openwhisk.db_host" -}}
{{- if .Values.db.external -}}
{{ .Values.db.host }}
{{- else -}}
{{ .Values.db.name }}.{{ .Release.Namespace }}.svc.{{ .Values.k8s.domain }}
{{- end -}}
{{- end -}}

{{- define "openwhisk.db_authentication" -}}
{{ .Values.db.auth.username }}:{{ .Values.db.auth.password }}
{{- end -}}

{{/* hostname for kafka */}}
{{- define "openwhisk.kafka_host" -}}
{{- if .Values.kafka.external -}}
{{ .Values.kafka.name }}
{{- else -}}
{{ .Values.kafka.name }}.{{ .Release.Namespace }}.svc.{{ .Values.k8s.domain }}
{{- end -}}
{{- end -}}

{{/* hostname for redis */}}
{{- define "openwhisk.redis_host" -}}
{{ .Values.redis.name }}.{{ .Release.Namespace }}.svc.{{ .Values.k8s.domain }}
{{- end -}}

{{/* client connection string for zookeeper cluster (server1:port server2:port ... serverN:port)*/}}
{{- define "openwhisk.zookeeper_connect" -}}
{{- if .Values.zookeeper.external -}}
{{ .Values.zookeeper.name }}
{{- else -}}
{{- $zkname := .Values.zookeeper.name }}
{{- $zkport := .Values.zookeeper.port }}
{{- $kubeDomain := .Values.k8s.domain }}
{{- range $i, $e := until (int .Values.zookeeper.replicaCount) -}}{{ if ne $i 0 }},{{ end }}{{ $zkname }}-{{ . }}.{{ $zkname }}.{{ $.Release.Namespace }}.svc.{{ $kubeDomain }}:{{ $zkport }}{{ end }}
{{- end -}}
{{- end -}}

{{/* host name for server.0 in zookeeper cluster */}}
{{- define "openwhisk.zookeeper_zero_host" -}}
{{- if .Values.zookeeper.external -}}
{{ .Values.zookeeper.name }}
{{- else -}}
{{ .Values.zookeeper.name }}-0.{{ .Values.zookeeper.name }}.{{ $.Release.Namespace }}.svc.{{ .Values.k8s.domain }}
{{- end -}}
{{- end -}}


{{/* Runtimes manifest */}}
{{- define "openwhisk.runtimes_manifest" -}}
{{ .Files.Get .Values.whisk.runtimes | quote }}
{{- end -}}

{{/* Environment variables required for accessing CouchDB from a pod */}}
{{- define "openwhisk.dbEnvVars" -}}
- name: "CONFIG_whisk_couchdb_username"
  valueFrom:
    secretKeyRef:
      name: db.auth
      key: db_username
- name: "CONFIG_whisk_couchdb_password"
  valueFrom:
    secretKeyRef:
      name: db.auth
      key: db_password
- name: "CONFIG_whisk_couchdb_port"
  valueFrom:
    configMapKeyRef:
      name: db.config
      key: db_port
- name: "CONFIG_whisk_couchdb_protocol"
  valueFrom:
    configMapKeyRef:
      name: db.config
      key: db_protocol
- name: "CONFIG_whisk_couchdb_host"
  value: {{ include "openwhisk.db_host" . | quote }}
- name: "CONFIG_whisk_couchdb_provider"
  valueFrom:
    configMapKeyRef:
      name: db.config
      key: db_provider
- name: "CONFIG_whisk_couchdb_databases_WhiskActivation"
  valueFrom:
    configMapKeyRef:
      name: db.config
      key: db_whisk_activations
- name: "CONFIG_whisk_couchdb_databases_WhiskEntity"
  valueFrom:
    configMapKeyRef:
      name: db.config
      key: db_whisk_actions
- name: "CONFIG_whisk_couchdb_databases_WhiskAuth"
  valueFrom:
    configMapKeyRef:
      name: db.config
      key: db_whisk_auths
{{- end -}}


{{/* tlssecretname for ingress */}}
{{- define "openwhisk.tls_secret_name" -}}
{{ .Values.whisk.ingress.tlssecretname | default "ow-ingress-tls-secret" | quote }}
{{- end -}}
