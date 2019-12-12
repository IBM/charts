{{/* vim: set filetype=mustache: */}}

{{- /* PULL SECRET TEMPLATE */ -}}
{{- define "cs.imagePullSecretTemplate" -}}
{{- if ne .Values.global.imagePullSecretName "" }}
imagePullSecrets:
{{ printf "- name: %s" .Values.global.imagePullSecretName -}}
{{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
{{ printf "- name: sa-%s" .Release.Namespace -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- /* ################################### TLS ################################### */ -}}

{{- /* TLS SECRET NAME TEMPLATE
We assume that the tls secret already exists and is specific to a release, i.e.
there is a single shared tls secret instance per release that is provided by a parent chart.
We allow a parent chart to provide a different template though and pass it
in via .Values.global.tls.secret.nameTpl. In our deployment, we use whatever
template is provided in .Values.global.tls.nameTpl.
*/ -}}
{{- define "cs.tlsSecretNameTemplate" -}}
{{- if .Values.useFixedTemplates -}}
nlu-tls
{{- else -}}
{{- .Release.Name -}}-nlu-tls
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
{{- define "cs.etcdAccessSecretNameTemplate" -}}
{{- .Release.Name -}}-etcd-access
{{- end -}}

{{- /* ETCD SECRET NAME TEMPLATE
We assume that the etcd secret already exists and is specific to a release, i.e.
there is a single shared etcd instance per release that is provided by a parent chart.
We allow a parent chart to provide a different template though and pass it
in via .Values.global.etcd.secret.tlsSecret.nameTpl. In our deployment, we use whatever
template is provided in .Values.global.etcd.tlsSecret.nameTpl.
*/ -}}
{{- define "cs.etcdTlsSecretNameTemplate" -}}
{{- .Release.Name -}}-nlu-tls
{{- end -}}

{{- /* ETCD ENDPOINT TEMPLATE
*/ -}}
{{- define "cs.etcdEndpointTemplate" -}}
http{{ if .Values.global.etcd.sslEnabled }}s{{ end }}://{{ .Release.Name }}-ibm-etcd.{{ .Release.Namespace }}:{{ .Values.global.etcd.endpointPort }}
{{- end -}}



{{- /* ################################### S3 ################################### */ -}}

{{- /* S3 ACCESS SECRET NAME TEMPLATE
We assume that the s3 secret already exists and is specific to a release, i.e.
there is a single shared s3 instance per release that is provided by a parent chart.
We allow a parent chart to provide a different template though and pass it
in via .Values.global.s3.accessSecret.nameTpl. In our deployment, we use whatever
template is provided in .Values.global.s3.accessSecret.nameTpl.
*/ -}}
{{- define "cs.minioAccessSecretNameTemplate" -}}
{{- .Release.Name -}}-minio
{{- end -}}

{{- /* S3 TLS SECRET NAME TEMPLATE
We assume that the s3 secret already exists and is specific to a release, i.e.
there is a single shared s3 instance per release that is provided by a parent chart.
We allow a parent chart to provide a different template though and pass it
in via .Values.global.s3.tlsSecret.nameTpl. In our deployment, we use whatever
template is provided in .Values.global.s3.tlsSecret.nameTpl.
*/ -}}
{{- define "cs.minioTlsSecretNameTemplate" -}}
{{- .Release.Name -}}-ibm-minio-objectstore
{{- end -}}

{{- /* S3 ENDPOINT TEMPLATE
*/ -}}
{{- define "cs.minioEndpointTemplate" -}}
http{{ if .Values.global.s3.sslEnabled }}s{{ end }}://{{ .Release.Name }}-ibm-minio-svc.{{ .Release.Namespace }}.{{ .Values.global.clusterDomain }}:{{ .Values.global.s3.endpointPort }}
{{- end -}}


{{- define "cs.prometheusAnnotations" -}}
prometheus.io/path: "/metrics"
prometheus.io/port: "{{ .Values.commonService.prometheusPort }}"
prometheus.io/scrape: "true"
prometheus.io/scheme: "http"
{{- end -}}
