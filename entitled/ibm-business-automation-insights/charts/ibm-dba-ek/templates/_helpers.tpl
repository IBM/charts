{{- /*
"sch.version" contains the version information and tillerVersion constraint
for this version of the Shared Configurable Helpers.
*/ -}}
{{- define "sch.version" -}}
version: "1.2.0"
tillerVersion: ">=2.7.0"
{{- end -}}


{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "ibm-dba-ek.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ibm-dba-ek.imagePullSecretIbmDbaEk" }}
  {{- if and .Values.image.credentials .Values.image.credentials.registry }}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" .Values.image.credentials.registry (printf "%s:%s" .Values.image.credentials.username .Values.image.credentials.password | b64enc) | b64enc }}
  {{- else }}
{{- printf "" }}
  {{- end }}
{{- end }}

{{/*
Create a default fully qualified
elasticsearch name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "elasticsearch.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-elasticsearch" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified client node name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "client.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-client" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified data node name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "data.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-data" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified master node name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "master.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-master" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified security config job name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "security-config-job.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-security-config" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified kibana name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "kibana.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-kibana" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ibm-dba-ek.basicauth"  }}
{{- printf "%s:%s" .Values.kibana.username .Values.kibana.password | b64enc}}
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
Shared elasticsearch settings
*/}}
{{- define "elasticsearch.config" -}}
cluster.name: "{{ template "elasticsearch.fullname" . }}"
network.host: 0.0.0.0
discovery.zen.ping.unicast.hosts: {{ template "master.fullname" . }}
discovery.zen.minimum_master_nodes: {{ template "elasticsearch.master.minimumNodes" . }}
transport.tcp.port: 9300
node.name: ${HOSTNAME}
# Since that we are running the container as a normal user we can't opt for this option.
# Another option available on Linux systems is to ensure that the sysctl value vm.swappiness is set to 1.
# This reduces the kernel’s tendency to swap and should not lead to swapping under normal circumstances,
# while still allowing the whole system to swap in emergency conditions.
# So, we have set vm.swappiness to 1 from our initContainer.
#bootstrap.memory_lock: true
# ----------------------------------- Paths ------------------------------------
#
# Path to directory where to store the data (separate multiple locations by comma):
#
path.data: /usr/share/elasticsearch/data
#
# Path to log files:
#
path.logs: /usr/share/elasticsearch/logs
#
######## Start OpenDistro for Elasticsearch Security Demo Configuration ########
# WARNING: revise all the lines below before you go into production
opendistro_security.ssl.transport.pemcert_filepath: security/esnode.pem
opendistro_security.ssl.transport.pemkey_filepath: security/esnode-key.pem
opendistro_security.ssl.transport.pemtrustedcas_filepath: security/root-ca.pem
opendistro_security.ssl.transport.enforce_hostname_verification: false
opendistro_security.ssl.http.enabled: true
opendistro_security.ssl.http.pemcert_filepath: security/esnode.pem
opendistro_security.ssl.http.pemkey_filepath: security/esnode-key.pem
opendistro_security.ssl.http.pemtrustedcas_filepath: security/root-ca.pem
opendistro_security.allow_unsafe_democertificates: true
opendistro_security.allow_default_init_securityindex: true
opendistro_security.authcz.admin_dn:
  - CN=kirk,OU=client,O=client,L=test, C=de

opendistro_security.audit.type: internal_elasticsearch
opendistro_security.enable_snapshot_restore_privilege: true
opendistro_security.check_snapshot_restore_write_privileges: true
opendistro_security.restapi.roles_enabled: ["all_access", "security_rest_api_access"]
cluster.routing.allocation.disk.threshold_enabled: false
node.max_local_storage_nodes: 3
######## End OpenDistro for Elasticsearch Security Demo Configuration ########
{{- end -}}

{{/*
Elasticsearch node affinity settings. Only support amd64.
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
{{ end }}

{{- define "masterData.restart" -}}
checksum/config: {{ cat .Values.elasticsearch.data.snapshotStorage.enabled .Values.elasticsearch.master.replicas | sha256sum }}
{{ end }}

{{- define "client.restart" -}}
checksum/config: {{ cat .Values.elasticsearch.master.replicas | sha256sum }}
{{ end }}

{{- define "kibana.restart" -}}
checksum/config: {{ cat .Values.kibana.username .Values.kibana.password .Values.kibana.multitenancy .Values.security.openDistroKibanaConfigSecret | sha256sum }}
{{ end }}
