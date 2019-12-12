{{/* vim: set filetype=mustache: */}}

{{- /* PULL SECRET TEMPLATE */ -}}
{{- define "nlu.imagePullSecretTemplate" -}}
{{- if or (ne .Values.global.imagePullSecretName "") (ne .Values.global.image.pullSecret "") }}
imagePullSecrets:
{{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
{{ printf "- name: sa-%s" .Release.Namespace -}}
{{- end -}}
{{- if ne .Values.global.imagePullSecretName "" }}
{{ printf "- name: %s" .Values.global.imagePullSecretName -}}
{{- end -}}
{{- if and (ne .Values.global.image.pullSecret "") (ne .Values.global.image.pullSecret .Values.global.imagePullSecretName) }}
{{ printf "- name: %s" .Values.global.image.pullSecret -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- /* ################################### ETCD ################################### */ -}}
{{- /* ETCD SECRET NAME TEMPLATE
We assume that the etcd secret already exists and is specific to a release, i.e.
there is a single shared etcd instance per release that is provided by a parent chart.
We allow a parent chart to provide a different template though and pass it
in via .Values.global.etcd.accessSecret.nameTpl. In our deployment, we use whatever
template is provided in .Values.global.etcd.accessSecret.nameTpl.
*/ -}}
{{- define "nlu.etcdAccessSecretNameTemplate" -}}
{{- .Release.Name -}}-etcd-access
{{- end -}}

{{- /* ETCD SECRET NAME TEMPLATE
We assume that the etcd secret already exists and is specific to a release, i.e.
there is a single shared etcd instance per release that is provided by a parent chart.
We allow a parent chart to provide a different template though and pass it
in via .Values.global.etcd.secret.tlsSecret.nameTpl. In our deployment, we use whatever
template is provided in .Values.global.etcd.tlsSecret.nameTpl.
*/ -}}
{{- define "nlu.etcdTlsSecretNameTemplate" -}}
{{- .Release.Name -}}-etcd-tls
{{- end -}}

{{- /* ETCD ENDPOINT TEMPLATE
*/ -}}
{{- define "nlu.etcdEndpointTemplate" -}}
http{{ if .Values.global.etcd.sslEnabled }}s{{ end }}://{{ .Release.Name }}-ibm-etcd.{{ .Release.Namespace }}:{{ .Values.global.etcd.endpointPort }}
{{- end -}}
{{- /* ################################### ETCD ################################### */ -}}

{{/* ######################################## MINIO ################################### */}}
{{- define "nlu.minioAccessSecretNameTemplate" -}}
{{- printf "%s-nlu-minio-access-secret" .Release.Name -}}
{{- end -}}

{{- /* MINIO ENDPOINT TEMPLATE
*/ -}}
{{- define "nlu.minioEndpointTemplate" -}}
http{{ if .Values.global.s3.sslEnabled }}s{{ end }}://{{ .Release.Name }}-ibm-minio-svc.{{ .Release.Namespace }}.{{ .Values.global.clusterDomain }}:{{ .Values.global.s3.endpointPort }}
{{- end -}}
{{/* ######################################## MINIO ################################### */}}

{{/* ################################### POSTGRES AUTH SECRET NAME ################################### */}}
{{- define "nlu.postgresAuthSecretNameTemplate" -}}
{{- printf "%s-nlu-postgres-auth-secret" .Release.Name -}}
{{- end -}}
{{/* ################################### POSTGRES AUTH SECRET NAME ################################### */}}


{{/* ######################################## TLS SECRET NAME ######################################## */}}
{{- define "nlu.tlsSecretNameTemplate" -}}
{{- printf "%s-nlu-tls" .Release.Name -}}
{{- end -}}
{{/* ######################################## TLS SECRET NAME ######################################## */}}

{{- define "nlu.roleName" -}}
{{ include "sch.names.fullName" (list . ) }}
{{- end -}}

{{- define "nlu.serviceAccountName" -}}
{{- default (include "sch.names.fullName" (list . )) (default .Values.global.existingServiceAccount .Values.existingServiceAccount) -}}
{{- end -}}

{{- define "nlu.roleBindingName" -}}
{{ include "sch.names.fullName" (list . ) }}
{{- end -}}

{{/* ######################################## Gateway backend  ########################################## */}}
{{- define "gateway.backendService.name" -}}
{{- printf "%s-%s" .Release.Name "ibm-watson-nlu-nluserver" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "gateway.modelsServerService.name" -}}
{{- printf "%s-%s" .Release.Name "ibm-watson-nms-models-server" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{/* ######################################## Gateway backend ########################################### */}}
