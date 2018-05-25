{{/*
  Licensed Materials - Property of IBM
  5737-E67
  @ Copyright IBM Corporation 2016, 2018. All Rights Reserved.
  US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
*/}}

{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified filebeat server name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "filebeat.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.filebeat.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified client node name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "client.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.elasticsearch.client.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified elasticsearch name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "elasticsearch.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.elasticsearch.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified data node name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "data.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.elasticsearch.data.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified master node name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "master.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.elasticsearch.master.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified kibana name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "kibana.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.kibana.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified logstash name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "logstash.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.logstash.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Shared Searchguard settings
*/}}
{{- define "elasticsearch.searchguard" -}}
  {{- if and .Values.security.enabled (eq .Values.security.provider "searchguard-tls") }}
searchguard:
  disabled: "false"
  nodes_dn:
    - "CN=elasticsearch-transport,OU=devops,C=COM"
  authcz.admin_dn:
    - "CN=sgadmin,OU=devops,C=COM"
  ssl.transport:
    enabled: true
    enabled_protocols:
      - "TLSv1.2"
    enable_openssl_if_available: true
    enforce_hostname_verification: false
    keystore_type: JKS
    keystore_filepath: tls/elasticsearch-transport-keystore.jks
    keystore_password: ${APP_KEYSTORE_PASSWORD}
    truststore_type: JKS
    truststore_filepath: tls/truststore.jks
    truststore_password: ${CA_TRUSTSTORE_PASSWORD}
  ssl.http:
    enabled: true
    enabled_protocols:
      - "TLSv1.2"
    clientauth_mode: OPTIONAL
    enable_openssl_if_available: true
    keystore_type: JKS
    keystore_filepath: tls/elasticsearch-keystore.jks
    keystore_password: ${APP_KEYSTORE_PASSWORD}
    truststore_type: JKS
    truststore_filepath: tls/truststore.jks
    truststore_password: ${CA_TRUSTSTORE_PASSWORD}
  {{- end -}}
{{- end -}}

{{/*
To avoid split-brain we need to set the minimum number of master pods to (elasticsearch.master.replicas / 2) + 1.
Expected input -> output:
  - 0 -> 0
  - 1 -> 1
  - 2 -> 2
  - 3 -> 2
  - 9 -> 5, etc
If the calculated value is higher than the # of replicas, use the replica value.
*/}}
{{- define "elasticsearch.master.minimumNodes" -}}
{{- $replicas := int (default 1 .Values.elasticsearch.master.replicas) -}}
{{- $min := add1 (div $replicas 2) -}}
{{- if gt $min $replicas -}}
  {{- printf "%d" $replicas -}}
{{- else -}}
  {{- printf "%d" $min -}}
{{- end -}}
{{- end -}}

{{/*
Shared elasticsearch general settings
*/}}
{{- define "elasticsearch.config" -}}
cluster.name: "{{ .Values.elasticsearch.name }}"
network.host: 0.0.0.0
discovery.zen.ping.unicast.hosts: {{ .Values.elasticsearch.master.name }}-discovery
discovery.zen.minimum_master_nodes: {{ template "elasticsearch.master.minimumNodes" . }}
transport.tcp.port: {{ .Values.elasticsearch.internalPort }}
node.name: ${HOSTNAME}
{{- end -}}

{{/*
Shared x-pack security settings
*/}}
{{- define "elasticsearch.xpack.security" -}}
  {{- if and .Values.security.enabled (eq .Values.security.provider "xpack") -}}
xpack:
  security:
    enabled: true
    authc:
      accept_default_password: false
      realms:
        pki1:
          type: pki
          truststore:
            path: "/usr/share/elasticsearch/config/tls/truststore.jks"
            password: "${CA_TRUSTSTORE_PASSWORD}"
    transport:
      ssl:
        enabled: true
        client_authentication: required
    http:
      ssl:
        enabled: true
        client_authentication: required
  ssl:
    keystore:
      path: "/usr/share/elasticsearch/config/tls/elasticsearch-keystore.jks"
      password: ${APP_KEYSTORE_PASSWORD}
    truststore:
      path: "/usr/share/elasticsearch/config/tls/truststore.jks"
      password: "${CA_TRUSTSTORE_PASSWORD}"
    supported_protocols: TLSv1.2
    client_authentication: required
    verification_mode: certificate
  monitoring:
    enabled: {{ .Values.xpack.monitoring }}
  ml:
    enabled: {{ .Values.xpack.ml }}
  watcher:
    enabled: {{ .Values.xpack.watcher }}
  {{- else }}
xpack.security.enabled: false
xpack.monitoring.enabled: {{ .Values.xpack.monitoring }}
xpack.ml.enabled: {{ .Values.xpack.ml }}
xpack.watcher.enabled: {{ .Values.xpack.watcher }}
  {{- end}}
{{ end }}

{{/*
Elasticsearch node affinity settings. Only needed when in managed mode or when X-Pack is the TLS provider.
*/}}
{{- define "elasticsearch.nodeaffinity" -}}
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: beta.kubernetes.io/arch
          operator: In
          values:
          - amd64
        {{- if not (.Values.security.enabled) }}
          - ppc64le
        {{- end }}
        {{- if eq .Values.mode "managed" }}
        - key: management
          operator: In
          values:
          - "true"
        {{- end }}
{{- end }}

{{/*
Kibana general settings
*/}}
{{- define "kibana.config" -}}
server.name: "{{ .Values.kibana.name }}"
server.host: "0"
server.port: {{ if eq .Values.mode "managed" }}5602{{ else }}{{ .Values.kibana.internal }}{{ end }}
{{- if eq .Values.mode "managed" }}
server.basePath: "/kibana"
{{- end }}
{{- if .Values.security.enabled }}
elasticsearch.url: "https://{{ .Values.elasticsearch.name }}:{{ .Values.elasticsearch.client.restPort }}"
elasticsearch.ssl.certificate: /usr/share/elasticsearch/config/tls/kibana.crt
elasticsearch.ssl.key: /usr/share/elasticsearch/config/tls/kibana.key
elasticsearch.ssl.certificateAuthorities: /usr/share/elasticsearch/config/tls/ca.crt
elasticsearch.ssl.keyPassphrase: "{{ .Values.security.app.keystore.password }}"
elasticsearch.ssl.verificationMode: certificate
{{- else }}
elasticsearch.url: "http://{{ .Values.elasticsearch.name }}:{{ .Values.elasticsearch.client.restPort }}"
{{- end }}

{{- if .Values.security.enabled }}
# SSL for outgoing requests from the Kibana Server (PEM formatted)
server.ssl.enabled: true
server.ssl.key: /usr/share/elasticsearch/config/tls/kibana.key
server.ssl.certificate: /usr/share/elasticsearch/config/tls/kibana.crt
server.ssl.certificateAuthorities: /usr/share/elasticsearch/config/tls/ca.crt
{{- end }}
{{ end }}

{{/*
Kibana X-Pack settings
*/}}
{{- define "kibana.xpack" -}}
xpack.monitoring.enabled: {{ .Values.xpack.monitoring }}
xpack.security.enabled: false
xpack.graph.enabled: {{ .Values.xpack.graph }}
xpack.reporting.enabled: {{ .Values.xpack.reporting }}
xpack.ml.enabled: {{ .Values.xpack.ml }}
{{ end }}

{{/*
Logstash general settings. Do NOT move xpack.monitoring.enabled to the logstash.xpack
template, because:
1. You have to set the value via XPACK_MONITORING_ENABLED env variable
2. Logstash will then attempt to write that value to the logstash.yml config file directly
3. Step 2 will fail because K8s files are mounted as read-only
*/}}
{{- define "logstash.config" -}}
config.reload.automatic: true
http.host: "0.0.0.0"
path.config: /usr/share/logstash/pipeline
xpack.monitoring.enabled: {{ .Values.xpack.monitoring }}
{{ end }}

{{/*
Logstash X-Pack settings
*/}}
{{- define "logstash.xpack" -}}
{{- if .Values.xpack.monitoring }}
  {{- if .Values.security.enabled }}
xpack.monitoring.elasticsearch.url: "https://{{ .Values.elasticsearch.name }}:{{ .Values.elasticsearch.client.restPort }}"
xpack.monitoring.elasticsearch.ssl.truststore.path: "/usr/share/elasticsearch/config/tls/truststore.jks"
xpack.monitoring.elasticsearch.ssl.truststore.password: "${CA_TRUSTSTORE_PASSWORD}"
xpack.monitoring.elasticsearch.ssl.keystore.path: "/usr/share/elasticsearch/config/tls/logstash-monitoring-keystore.jks"
xpack.monitoring.elasticsearch.ssl.keystore.password: "${APP_KEYSTORE_PASSWORD}"
# this value overrides the default logstash_system username
xpack.monitoring.elasticsearch.username:
xpack.monitoring.elasticsearch.password:
  {{- else }}
xpack.monitoring.elasticsearch.url: "http://{{ .Values.elasticsearch.name }}:{{ .Values.elasticsearch.client.restPort }}"
  {{- end }}
{{- end }}
{{ end }}

{{/*
The name of the cluster_domain for ICP's OIDC.
*/}}
{{- define "clusterDomain" -}}
{{- default "cluster.local" .Values.cluster_domain -}}
{{- end -}}
