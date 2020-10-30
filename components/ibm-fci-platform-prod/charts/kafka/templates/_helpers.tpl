{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "kafka.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kafka.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kafka.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Form the Zookeeper URL. If zookeeper is installed as part of this chart, use k8s service discovery,
else use user-provided URL
*/}}
{{- define "zookeeper.url" }}
{{- $port := .Values.zookeeper.port | toString }}
{{- printf "%s-zk:%s" (include "kafka.fullname" .) $port }}
{{- end -}}

{{/*
Form the Zookeeper servers string.
*/}}
{{- define "zookeeper.servers" }}
{{- $kafkaFullname := (include "kafka.fullname" .) }}
{{- $namespace := .Release.Namespace }}
{{- $replicas := .Values.zookeeperReplicaCount | int }}
{{- range $i, $e := until $replicas }}
{{- $index1 := $i | add1 -}}
{{- printf "%s-zk-%d.%s-zk.%s.svc:2888:3888" $kafkaFullname $i $kafkaFullname $namespace }}
{{- if ne $index1 $replicas }}
{{- printf ";" }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Form the Kafka Zookeeper connect string.
*/}}
{{- define "kafka.zookeeper.connect" }}
{{- $kafkaFullname := (include "kafka.fullname" .) }}
{{- $namespace := .Release.Namespace }}
{{- $replicas := .Values.zookeeperReplicaCount | int }}
{{- range $i, $e := until $replicas }}
{{- $index1 := $i | add1 -}}
{{- printf "%s-zk-%d.%s-zk.%s.svc:2182" $kafkaFullname $i $kafkaFullname $namespace }}
{{- if ne $index1 $replicas }}
{{- printf "," }}
{{- end -}}
{{- end -}}
{{- end -}}
