{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{ if .Values.global.icp4Data }}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- $instanceid := default 97000079.0 .Values.zenServiceInstanceId -}}
{{- printf "ca%.0f-%s" $instanceid $name | trunc 48 | trimSuffix "-" -}}
{{ else }}
{{- default .Chart.Name .Values.nameOverride | trunc 48 | trimSuffix "-" -}}
{{ end }}
{{- end -}}


{{/*
Role name template. Example: <release-name>role-<role-name>. The caller should append the <role-name> suffix.
We truncate at 48 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "role-name" -}}
{{ if .Values.global.icp4Data }}
{{- $instanceid := default 97000079.0 .Values.zenServiceInstanceId -}}
{{- printf "ca%.0f-%s" $instanceid "role" | trunc 48 | trimSuffix "-" -}}
{{ else }}
{{- printf "%s-%s" .Release.Name "role" | trunc 48 | trimSuffix "-" -}}
{{ end }}
{{- end -}}


{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{ if .Values.global.icp4Data }}
{{- $instanceid := default 97000079.0 .Values.zenServiceInstanceId -}}
{{- printf "ca%.0f-%s" $instanceid $name | trunc 48 | trimSuffix "-" -}}
{{ else }}
{{- printf "%s-%s" .Release.Name $name | trunc 48 | trimSuffix "-" -}}
{{ end }}
{{- end -}}

{{/*
Expand the name of the chart (used by service objects.
*/}}
{{- define "service.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 48 | trimSuffix "-" -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "cognos.analytics.name" -}}
{{ if .Values.global.icp4Data }}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- $instanceid := default 97000079.0 .Values.zenServiceInstanceId -}}
{{- printf "ca%.0f-%s" $instanceid $name | trunc 48 | trimSuffix "-" -}}
{{ else }}
{{- default .Chart.Name .Values.nameOverride | trunc 48 | trimSuffix "-" -}}
{{ end }}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 24 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cognos.analytics.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{ if .Values.global.icp4Data }}
{{- $instanceid := default 97000079.0 .Values.zenServiceInstanceId -}}
{{- printf "ca%.0f-%s" $instanceid $name | trunc 48 | trimSuffix "-" -}}
{{ else }}
{{- printf "%s-%s" .Release.Name $name | trunc 48 | trimSuffix "-" -}}
{{ end }}
{{- end -}}

{{/*
Create a standard set of labels to be used by all objects
*/}}
{{- define "cognos-analytics.labels" }}
app: {{ template "name" . }}
chart: {{ .Chart.Name }}
release: {{ .Release.Name }}
heritage: {{ .Release.Service }}
{{- end -}}

{{/*
Create the artifacts-pvc name. This pvc is shared by all charts. 
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "artifacts-pvc.name" -}}
{{ if .Values.global.icp4Data }}
{{- $instanceid := default 97000079.0 .Values.zenServiceInstanceId -}}
{{- printf "ca%.0f-%s" $instanceid "artifacts" | trunc 48 | trimSuffix "-" -}}
{{ else }}
{{- printf "%s-%s" .Release.Name "artifacts" | trunc 48 | trimSuffix "-" -}}
{{ end }}
{{- end -}}

{{/*
Create the configuration-overrides-pvc name. This pvc is shared by all charts.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "configuration-overrides-pvc.name" -}}
{{ if .Values.global.icp4Data }}
{{- $instanceid := default 97000079.0 .Values.zenServiceInstanceId -}}
{{- printf "ca%.0f-%s" $instanceid "config-overrides" | trunc 48 | trimSuffix "-" -}}
{{ else }}
{{- printf "%s-%s" .Release.Name "config-overrides" | trunc 48 | trimSuffix "-" -}}
{{ end }}
{{- end -}}

{{/*
Create the configuration-data-pvc name. This pvc is shared by all charts.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "configuration-data-pvc.name" -}}
{{ if .Values.global.icp4Data }}
{{- $instanceid := default 97000079.0 .Values.zenServiceInstanceId -}}
{{- printf "ca%.0f-%s" $instanceid "config-data" | trunc 48 | trimSuffix "-" -}}
{{ else }}
{{- printf "%s-%s" .Release.Name "config-data" | trunc 48 | trimSuffix "-" -}}
{{ end }}
{{- end -}}

{{/*
Define the gateway ingress path. This path will be shared by the other charts (i.e artifacts). 
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "gateway-ingress.path" -}}
{{ if .Values.global.icp4Data }}
{{- $instanceid := default 97000079.0 .Values.zenServiceInstanceId -}}
{{- printf "ca%.0f-%s" $instanceid "gateway" | trunc 48 | trimSuffix "-" -}}
{{ else }}
{{- printf "%s-%s" .Release.Name "gateway" | trunc 48 | trimSuffix "-" -}}
{{ end }}
{{- end -}}

{{/*
Define the content store secrets name used by all charts that need it.
*/}}
{{- define "cs-secrets-name" -}}
{{ if .Values.global.icp4Data }}
{{- $instanceid := default 97000079.0 .Values.zenServiceInstanceId -}}
{{- printf "ca%.0f-%s" $instanceid "cs-creds" | trunc 48 | trimSuffix "-" -}}
{{ else }}
{{- printf "%s-%s" .Release.Name "cs-creds" | trunc 48 | trimSuffix "-" -}}
{{ end }}
{{- end -}}

{{/*
Create a standard filebeat template
*/}}
{{- define "standard-filebeat-yml" -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ template "fullname" . }}-filebeat-config

  labels:
    {{- include "cognos-analytics.labels" . | indent 4 }}
data:
 filebeat.yml: |-
   filebeat.prospectors:
     - input_type: log
       encoding: '${ENCODING:utf-8}'
       paths: '${LOG_DIRS}'

       exclude_lines: '${EXCLUDE_LINES:[]}'
       include_lines: '${INCLUDE_LINES:[]}'

       ignore_older: '${IGNORE_OLDER:0}'
       scan_frequency: '${SCAN_FREQUENCY:10s}'
       symlinks: '${SYMLINKS:true}'
       max_bytes: '${MAX_BYTES:10485760}'
       harvester_buffer_size: '${HARVESTER_BUFFER_SIZE:16384}'

       multiline.pattern: '${MULTILINE_PATTERN:^\s}'
       multiline.match: '${MULTILINE_MATCH:after}'
       multiline.negate: '${MULTILINE_NEGATE:false}'

       fields_under_root: '${FIELDS_UNDER_ROOT:true}'
       fields:
         type: '${FIELDS_TYPE:kube-logs}'
         pod_name: '${MY_POD_NAME}'
         namespace: '${MY_POD_NAMESPACE}'
         node_host_ip: '${MY_NODE_NAME}'
         pod_ip: '${MY_POD_IP}'
       tags: '${TAGS:sidecar}'

   filebeat.config.modules:
     # Set to true to enable config reloading
     reload.enabled: true

{{ if .Values.global.filebeat.output.logstashEnabled }}
   output.logstash:
     # Make sure the default points to an existing Logstash service
     hosts: '${LOGSTASH:logstash:5000}'
     timeout: 15
{{ end }}
{{ if .Values.global.filebeat.output.consoleEnabled }}
   output.console:
     pretty: true
{{ end }}

   logging.level: '${LOG_LEVEL:info}'
{{- end -}}


{{/*
Create a standard filebeat fields template
*/}}
{{ define "standard-filebeat-fields" }}
- name: MY_NODE_NAME
  valueFrom:
    fieldRef:
      fieldPath: spec.nodeName
- name: MY_POD_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
- name: MY_POD_NAMESPACE
  valueFrom:
    fieldRef:
      fieldPath: metadata.namespace
- name: MY_POD_IP
  valueFrom:
    fieldRef:
      fieldPath: status.podIP
- name: LOGSTASH
{{- if .Values.global.filebeat.output.logstashEnabled }}
  value: {{ .Values.global.logstash.ip }}:{{ .Values.global.logstash.port }}
{{- end }}
{{- if .Values.global.filebeat.output.consoleEnabled }}
  value: output.console
{{- end }}
{{- end }}

{{/*
Create a standard filebeat volumes template
*/}}
{{ define "standard-filebeat-volumes-config" }}
- name: filebeat-config
  configMap:
    name: {{ template "fullname" . }}-filebeat-config
    items:
      - key: filebeat.yml
        path: filebeat.yml
{{- end }}

{{/*
Create a standard filebeat volumes template
*/}}
{{ define "standard-filebeat-volumeMounts-config" }}
- name: filebeat-config
  mountPath: /usr/share/filebeat/filebeat.yml
  subPath: filebeat.yml
{{- end }}

{{/*
Helper functions which can be used for used for .Values.global.arch in PPA Charts
Check if tag contains specific platform suffix and if not set based on kube platform
uncomment this section for PPA charts, can be removed in github.com charts
*/}}

{{- define "platform" -}}
{{- if not .Values.global.arch }}
  {{- if (eq "linux/amd64" .Capabilities.KubeVersion.Platform) }}
    {{- printf "-%s" "x86_64" }}
  {{- end -}}
  {{- if (eq "linux/ppc64le" .Capabilities.KubeVersion.Platform) }}
    {{- printf "-%s" "ppc64le" }}
  {{- end -}}
{{- else -}}
  {{- if eq .Values.global.arch "amd64" }}
    {{- printf "-%s" "x86_64" }}
  {{- else -}}
    {{- printf "-%s" .Values.global.arch }}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "arch" -}}
  {{- if (eq "linux/amd64" .Capabilities.KubeVersion.Platform) }}
    {{- printf "%s" "amd64" }}
  {{- end -}}
  {{- if (eq "linux/ppc64le" .Capabilities.KubeVersion.Platform) }}
    {{- printf "%s" "ppc64le" }}
  {{- end -}}
{{- end -}}

{{/*
Helper template to define pod annotations for metering
*/}}
{{- define "metering.annotations" -}}
  {{- if .Values.global.icp4Data }}
productID: ICP4D-addon-{{ .Values.global.metering.productID }}
productName: {{ .Values.global.metering.productName }}
productVersion: {{ .Values.global.metering.productVersion }}
  {{- else }}
productID: {{ .Values.global.metering.productID }}
productName: {{ .Values.global.metering.productName }}
productVersion: {{ .Values.global.metering.productVersion }}
  {{ end }}
{{- end -}}

{{/*
Create a CAMID.
*/}}
{{- define "jwt.camid" -}}
  {{- if .Values.global.icp4Data -}}
value: {{ printf "CAMID(&quot;jwt:u:%s&quot;)" .Values.zenServiceInstanceUserName | quote }}
  {{- else -}}
value: {{ .Values.global.initialAdminCamId | quote }}
  {{- end -}}
{{- end -}}

{{/*
Create an image spec
*/}}
{{- define "imageSpec" -}}
  {{- if .Values.global.icp4Data -}}
image: {{ .Values.docker_registry_prefix }}/{{ .Values.image.name }}:{{ .Values.image.tag }}{{ .Values.global.branchTag }}
  {{- else -}}
image: {{ .Values.global.image.registry }}{{ .Values.image.repository }}{{ .Values.image.name }}:{{ .Values.image.tag }}{{ .Values.global.branchTag }}
  {{- end -}}
{{- end -}}

{{/*
Create an image filebeat spec
*/}}
{{- define "imageFilebeatSpec" -}}
  {{- if .Values.global.icp4Data -}}
image: {{ .Values.docker_registry_prefix }}/{{ .Values.global.filebeat.image.name }}:{{ .Values.global.filebeat.image.tag }}
  {{- else -}}
image: {{ .Values.global.filebeat.image.registry }}{{ .Values.global.filebeat.image.repository }}{{ .Values.global.filebeat.image.name }}:{{ .Values.global.filebeat.image.tag }}
  {{- end -}}
{{- end -}}

{{/*
Create an image base spec
*/}}
{{- define "imageBaseSpec" -}}
  {{- if .Values.global.icp4Data -}}
image: {{ .Values.docker_registry_prefix }}/{{ .Values.global.base.image.name }}:{{ .Values.global.base.image.tag }}{{ .Values.global.branchTag }}
  {{- else -}}
image: {{ .Values.global.image.registry }}{{ .Values.global.base.image.repository }}{{ .Values.global.base.image.name }}:{{ .Values.global.base.image.tag }}{{ .Values.global.branchTag }}
  {{- end -}}
{{- end -}}
