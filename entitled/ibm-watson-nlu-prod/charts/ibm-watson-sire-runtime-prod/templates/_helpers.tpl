{{/* vim: set filetype=mustache: */}}

{{- /* ################################### IMAGES ################################### */ -}}

{{- /* PULL SECRET TEMPLATE */ -}}
{{- define "sire.imagePullSecretTemplate" -}}
{{- if ne .Values.global.imagePullSecretName "" }}
imagePullSecrets:
{{ printf "- name: %s" .Values.global.imagePullSecretName -}}
{{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
{{ printf "- name: sa-%s" .Release.Namespace -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- /* PULL POLICY */ -}}
{{- define "sireRuntime.pullPolicyTemplate" -}}
{{- if .Values.global.image -}}{{- if .Values.global.image.pullPolicy -}}
imagePullPolicy: {{ .Values.global.image.pullPolicy }}
{{- end -}}{{- end -}}
{{- end -}}

{{- /* ################################### TLS ################################### */ -}}

{{- /* TLS SECRET NAME TEMPLATE
We assume that the tls secret already exists and is specific to a release, i.e.
there is a single shared tls secret instance per release that is provided by a parent chart.
We allow a parent chart to provide a different template though and pass it
in via .Values.global.tls.secret.nameTpl. In our deployment, we use whatever
template is provided in .Values.global.tls.nameTpl.
*/ -}}
{{- define "sireRuntime.tlsSecretNameTemplate" -}}
{{- if .Values.useFixedTemplates -}}
tls-secret
{{- else -}}
{{- .Release.Name -}}-tls-secret
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
{{- define "sireRuntime.etcdAccessSecretNameTemplate" -}}
{{- .Release.Name -}}-etcd-access
{{- end -}}

{{- /* ETCD SECRET NAME TEMPLATE
We assume that the etcd secret already exists and is specific to a release, i.e.
there is a single shared etcd instance per release that is provided by a parent chart.
We allow a parent chart to provide a different template though and pass it
in via .Values.global.etcd.secret.tlsSecret.nameTpl. In our deployment, we use whatever
template is provided in .Values.global.etcd.tlsSecret.nameTpl.
*/ -}}
{{- define "sireRuntime.etcdTlsSecretNameTemplate" -}}
{{- .Release.Name -}}-etcd-tls
{{- end -}}

{{- /* ETCD ENDPOINT TEMPLATE
*/ -}}
{{- define "sireRuntime.etcdEndpointTemplate" -}}
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
{{- define "sireRuntime.s3AccessSecretNameTemplate" -}}
{{- .Release.Name -}}-minio
{{- end -}}

{{- /* S3 TLS SECRET NAME TEMPLATE
We assume that the s3 secret already exists and is specific to a release, i.e.
there is a single shared s3 instance per release that is provided by a parent chart.
We allow a parent chart to provide a different template though and pass it
in via .Values.global.s3.tlsSecret.nameTpl. In our deployment, we use whatever
template is provided in .Values.global.s3.tlsSecret.nameTpl.
*/ -}}
{{- define "sireRuntime.s3TlsSecretNameTemplate" -}}
{{- .Release.Name -}}-ibm-minio-objectstore
{{- end -}}

{{- /* S3 ENDPOINT TEMPLATE
*/ -}}
{{- define "sireRuntime.s3EndpointTemplate" -}}
http{{ if .Values.global.s3.sslEnabled }}s{{ end }}://{{ .Release.Name }}-ibm-minio-svc.{{ .Release.Namespace }}.{{ .Values.global.clusterDomain }}:{{ .Values.global.s3.endpointPort }}
{{- end -}}

{{- /* ################################### MISC ################################### */ -}}

{{- /* REQUEST BUFFER CALCULATION
Calculates the request buffer in each model runtime based on the amount of cpu limit given to the model runtime.
The buffer will have a minimal size of 10 requests, otherwise will have 5 times the number of available virtual CPUs.
*/ -}}
{{- define "sireRuntime.requestBufferSize" -}}
{{ max 10 (mul 5 (ceil (div .Values.modelMeshDeployment.modelRuntimeContainer.cpuLimitMillis 1000))) }}
{{- end -}}

{{- /* MODEL DISK CACHE SZE CALCULATION
Calculate model disk cache size based on user input, making sure in range 10G <= SIZE <= 100G.
*/ -}}
{{- define "sireRuntime.modelDiskCacheSize" -}}
{{ mul 1000000 (max 10000 (min 100000 .Values.modelMeshDeployment.modelRuntimeContainer.modelDiskCacheSizeMB)) }}
{{- end -}}

{{- /* ROOT LOG LEVEL VALIDATION
Log level validation.
*/ -}}
{{- define "sireRuntime.rootLogLevel" -}}
{{- if (has (lower .Values.modelMeshDeployment.modelRuntimeContainer.rootLogLevel) (list "all" "trace" "debug" "info" "warn" "error" "fatal") ) -}}
{{ lower .Values.modelMeshDeployment.modelRuntimeContainer.rootLogLevel | quote }}
{{- else -}}
"error"
{{- end -}}
{{- end -}}
