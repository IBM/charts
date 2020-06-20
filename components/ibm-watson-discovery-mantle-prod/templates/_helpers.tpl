{{/* vim: set filetype=mustache: */}}

{{- define "discovery.crust.minio.secret" -}}
  {{- if tpl .Values.global.crust.objectStorage.secret . }}
    {{- tpl .Values.global.crust.objectStorage.secret . }}
  {{- else }}
    {{- (index .Values.global.components "ibm-watson-discovery-crust-prod").releaseName }}-
    {{- .Values.global.appName }}-minio-secret
  {{- end }}
{{- end -}}

{{- define "discovery.crust.minio.service" -}}
  {{- (index .Values.global.components "ibm-watson-discovery-crust-prod").releaseName }}-
  {{- .Values.global.appName }}-minio-svc
{{- end -}}

{{- define "discovery.crust.minio.hostPort" -}}
  {{- printf "https://%s:9000" (include "discovery.crust.minio.service" .) -}}
{{- end -}}

{{- define "discovery.crust.minio.configmap" -}}
  {{- if tpl .Values.global.crust.objectStorage.configmap . }}
    {{- tpl .Values.global.crust.objectStorage.configmap . }}
  {{- else }}
    {{- (index .Values.global.components "ibm-watson-discovery-crust-prod").releaseName }}-
    {{- .Values.global.appName }}-minio-cxn
  {{- end }}
{{- end }}

{{- define "discovery.admin.tlsSecret" -}}
  {{- $appName := .Values.global.appName -}}
  {{- $adminName := (index .Values.global.components "ibm-watson-discovery-admin-prod").releaseName -}}
  {{- printf "%s-%s-tls" $adminName $appName | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "discovery.admin.privilegedServiceAccount" -}}
  {{- .Values.global.privilegedServiceAccount.name -}}
{{- end -}}

{{- define "discovery.admin.serviceAccount" -}}
  {{- .Values.global.serviceAccount.name -}}
{{- end -}}

{{- define "discovery.crust.postgresql.host" }}
  {{- (index .Values.global.components "ibm-watson-discovery-crust-prod").releaseName }}-
  {{- .Values.global.appName }}-postgresql-proxy-svc.
  {{- .Release.Namespace }}.svc.
  {{- .Values.global.clusterDomain }}
{{- end }}

{{- define "discovery.crust.postgresql.port" }}5432{{- end }}

{{- define "discovery.crust.etcd.secret" -}}
  {{- if tpl .Values.global.crust.etcd.secret . }}
    {{- tpl .Values.global.crust.etcd.secret . }}
  {{- else }}
    {{- (index .Values.global.components "ibm-watson-discovery-crust-prod").releaseName }}-
    {{- .Values.global.appName }}-etcd-root
  {{- end }}
{{- end -}}

{{- define "discovery.crust.etcd.service" }}
  {{- $appName := .Values.global.appName -}}
  {{- $crustName := (index .Values.global.components "ibm-watson-discovery-crust-prod").releaseName -}}
  {{ printf "%s-%s-etcd" $crustName $appName | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "discovery.crust.etcd.configmap" -}}
  {{- if tpl .Values.global.crust.etcd.configmap . }}
    {{- tpl .Values.global.crust.etcd.configmap . }}
  {{- else }}
    {{- (index .Values.global.components "ibm-watson-discovery-crust-prod").releaseName }}-
    {{- .Values.global.appName }}-etcd
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

{{- define "discovery.glimpse.replicas" -}}
  {{- if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    1
  {{- end -}}
{{- end -}}

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

{{- define "discovery.core.dfs.hostPort" -}}
  {{- $coreName := (index .Values.global.components "ibm-watson-discovery-core-prod").releaseName -}}
  {{- $svcName := printf "%s-dfs-induction" (printf "%s-%s" $coreName .Values.global.appName | trunc 49) -}}
  {{- printf "%s.%s.svc.%s:50058" $svcName .Release.Namespace .Values.global.clusterDomain -}}
{{- end -}}

{{- define "discovery.core.gateway.service" -}}
  {{- $coreName := (index .Values.global.components "ibm-watson-discovery-core-prod").releaseName -}}
  {{- printf "%s-%s-gateway" $coreName .Values.global.appName | trunc 63 -}}
{{- end -}}

{{- define "discovery.core.management.service" -}}
  {{- $coreName := (index .Values.global.components "ibm-watson-discovery-core-prod").releaseName -}}
  {{- printf "%s-%s-management" $coreName .Values.global.appName | trunc 63 -}}
{{- end -}}

{{- define "discovery.core.serveRanker.hostPort" -}}
  {{- $coreName := (index .Values.global.components "ibm-watson-discovery-core-prod").releaseName -}}
  {{- $svcName := printf "%s-serve-ranker" (printf "%s-%s" $coreName .Values.global.appName | trunc 50) -}}
  {{- printf "%s.%s.svc.%s:8033" $svcName .Release.Namespace .Values.global.clusterDomain -}}
{{- end -}}

{{- define "discovery.core.trainingDataCrud.hostPort" -}}
  {{- $coreName := (index .Values.global.components "ibm-watson-discovery-core-prod").releaseName -}}
  {{- $svcName := printf "%s-training-data-crud" (printf "%s-%s" $coreName .Values.global.appName | trunc 44) -}}
  {{- printf "%s.%s.svc.%s:50051" $svcName .Release.Namespace .Values.global.clusterDomain -}}
{{- end -}}
