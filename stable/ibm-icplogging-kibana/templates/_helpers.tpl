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
The name of the cluster_domain for ICP's OIDC.
*/}}
{{- define "clusterDomain" -}}
{{- default "cluster.local" .Values.cluster_domain -}}
{{- end -}}

{{/*
Node affinity settings. Only needed when in managed mode or when security is enabled.
*/}}
{{- define "kibana.nodeaffinity" -}}
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: beta.kubernetes.io/arch
          operator: In
          values:
          - amd64
        {{- if not (.Values.elasticsearch.security.enabled) }}
          - ppc64le
        {{- end }}
        {{- if .Values.kibana.managedMode }}
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
server.port: {{ if .Values.kibana.managedMode }}5602{{ else }}{{ .Values.kibana.internal }}{{ end }}
{{- if .Values.kibana.managedMode }}
server.basePath: "/kibana"
{{- end }}
{{- if .Values.elasticsearch.security.enabled }}
elasticsearch.url: "https://{{ .Values.elasticsearch.service.name }}:{{ .Values.elasticsearch.service.port }}"
elasticsearch.ssl.certificate: /usr/share/elasticsearch/config/tls/kibana.crt
elasticsearch.ssl.key: /usr/share/elasticsearch/config/tls/kibana.key
elasticsearch.ssl.certificateAuthorities: /usr/share/elasticsearch/config/tls/ca.crt
#elasticsearch.ssl.keyPassphrase configured via env var
elasticsearch.ssl.verificationMode: certificate
{{- else }}
elasticsearch.url: "http://{{ .Values.elasticsearch.service.name }}:{{ .Values.elasticsearch.service.port }}"
{{- end }}

{{- if .Values.elasticsearch.security.enabled }}
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
