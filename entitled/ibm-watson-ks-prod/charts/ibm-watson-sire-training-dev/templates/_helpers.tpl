{{/* vim: set filetype=mustache: */}}

{{- /* IMAGE TEMPLATE */ -}}
{{- define "sireTraining.imageTpl" -}}
{{- $rootContext := (index . 0) -}}
{{- $component := (index . 1 ) -}}
image: {{ printf "%s%s:%s" $rootContext.Values.global.icpDockerRepo $component.image.repository $component.image.tag | quote }}
{{- end -}}

{{- /* PULL SECRET TEMPLATE (modification by WKS team for pulling image in case of pulling image from ICP private registry*/ -}}
{{- define "sireTraining.pullSecretTemplate" -}}
imagePullSecrets:
{{ printf "- name: %s"  (default (printf "sa-%s" .Release.Namespace) .Values.global.image.pullSecretCsfdev | quote) }}
{{- end -}}

{{- /* PULL POLICY */ -}}
{{- define "sireTraining.pullPolicyTemplate" -}}
{{- if .Values.global.image -}}{{- if .Values.global.image.pullPolicy -}}
imagePullPolicy: {{ .Values.global.image.pullPolicy }}
{{- end -}}{{- end -}}
{{- end -}}

{{- /* REPLICA COUNT */ -}}
{{- define "sireTraining.replicaCountTemplate" -}}
{{ if (and .Values.highAvailabilityMode .Values.global.highAvailabilityMode ) }}2{{ else }}1{{ end }}
{{- end -}}


{{- /* TLS SECRET NAME TEMPLATE
We assume that the tls secret already exists and is specific to a release, i.e.
there is a single shared tls secret instance per release that is provided by a parent chart.
We allow a parent chart to provide a different template though and pass it
in via .Values.global.tls.secret.nameTpl. In our deployment, we use whatever
template is provided in .Values.global.tls.nameTpl.
*/ -}}
{{- define "sireTraining.tlsSecretNameTemplate" -}}
{{- if .Values.useFixedTemplates -}}
tls-secret
{{- else -}}
{{- .Release.Name -}}-tls-secret
{{- end -}}
{{- end -}}


{{- /* POSTGRESQL AUTH SECRET NAME TEMPLATE
We assume that the PostgreSQL auth secret already exists and is specific to a release, i.e.
there is a single shared PostgreSQL instance per release that is provided by a parent chart.
We allow a parent chart to provide a different template though and pass it
in via .Values.global.postgresql.authSecret.nameTpl. In our deployment, we use whatever
template is provided in .Values.global.postgresql.authSecret.nameTpl.
*/ -}}
{{- define "sireTraining.postgresqlAuthSecretNameTemplate" -}}
{{- .Release.Name -}}-postgresql-auth
{{- end -}}

{{- /* POSTGRESQL TLS SECRET NAME TEMPLATE
We assume that the PostgreSQL auth secret already exists and is specific to a release, i.e.
there is a single shared PostgreSQL instance per release that is provided by a parent chart.
We allow a parent chart to provide a different template though and pass it
in via .Values.global.postgresql.tlsSecret.nameTpl. In our deployment, we use whatever
template is provided in .Values.global.postgresql.tlsSecret.nameTpl.
*/ -}}
{{- define "sireTraining.postgresqlTlsSecretNameTemplate" -}}
{{- .Release.Name -}}-postgresql-tls
{{- end -}}

{{- /* POSTGRESQL SERVICE NAME TEMPLATE
We assume that the PostgreSQL host already exists and is specific to a release, i.e.
there is a single shared PostgreSQL instance per release that is provided by a parent chart.
We allow a parent chart to provide a different template though and pass it
in via .Values.global.postgres.hostNameTpl. In our deployment, we use whatever
template is provided in .Values.global.postgres.hostNameTpl.
*/ -}}
{{- define "sireTraining.postgresqlHostNameTemplate" -}}
{{- .Release.Name -}}-postgresql
{{- end -}}

{{- define "sireTraining.postgresqlSslModeTpl" -}}
{{ if .Values.global.postgresql.sslEnabled -}}
{{ if .Values.global.postgresql.tlsSecret.fieldRootCertificate }}verify-ca{{ else }}require{{ end }}
{{- else -}}
disable
{{- end }}
{{- end -}}

{{- define "sireTraining.jobqDbName" -}}
{{- printf "%s-%s" .Values.jobq.postgres.db_prefix .Release.Name | replace "-" "_" -}}
{{- end -}}

{{- define "sireTraining.jobqTenantInit" -}}
{{- $rootContext := (index . 0) -}}
{{- $t := (index . 1 ) -}}
psql -a -d {{ include "sireTraining.jobqDbName" $rootContext }} -c "{{ printf "INSERT INTO tenant (tenant_id, description, quota_cpu_millis, quota_memory_megabytes, quota_gpus, max_queued_and_active_per_user, max_active_per_user) VALUES ('%s', '%s', %d, %d, %d, %d, %d)" $t.tenant_id $t.description (int64 $t.quota_cpu_millis) (int64 $t.quota_memory_megabytes) (int64 $t.quota_gpus) (int64 $t.max_queued_and_active_per_user) (int64 $t.max_active_per_user) }}";\
psql -a -d {{ include "sireTraining.jobqDbName" $rootContext }} -c "SELECT tenant_id FROM tenant WHERE tenant_id = '{{ $t.tenant_id }}'" | grep '1 row' && \
{{- end -}}

{{- /* S3 ACCESS SECRET NAME TEMPLATE
*/ -}}
{{- define "sireTraining.s3AccessSecretNameTemplate" -}}
{{- .Release.Name -}}-s3-access
{{- end -}}

{{- /* S3 TLS SECRET NAME TEMPLATE
*/ -}}
{{- define "sireTraining.s3TlsSecretNameTemplate" -}}
{{- .Release.Name -}}-s3-tls
{{- end -}}

{{- /* S3 ENDPOINT TEMPLATE
*/ -}}
{{- define "sireTraining.s3EndpointTemplate" -}}
"http{{ if .Values.global.s3.sslEnabled }}s{{ end }}://{{ .Release.Name }}-s3.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:{{ .Values.global.s3.endpointPort }}"
{{- end -}}

{{- /* S3 BUCKET NAME TEMPLATE
*/ -}}
{{- define "sireTraining.s3BucketNameTemplate" -}}
{{ .Release.Name }}-sire-training
{{- end -}}

{{- define "sireTraining.roleName" -}}
{{ include "sch.names.fullName" (list . ) }}
{{- end -}}

{{- define "sireTraining.serviceAccountName" -}}
{{- if or (.Values.global.existingServiceAccount) (.Values.jobq.existingServiceAccount) -}}
{{- default .Values.global.existingServiceAccount .Values.jobq.existingServiceAccount -}}
{{- else -}}
{{ include "sch.names.fullName" (list . ) }}
{{- end -}}
{{- end -}}

{{- define "sireTraining.roleBindingName" -}}
{{ include "sch.names.fullName" (list . ) }}
{{- end -}}

{{- define "sireTraining.siregEndpointTpl" -}}
{{- $rootContext := (index . 0) -}}
{{- $lang := (index . 1 ) -}}
{{ include "sch.names.fullCompName" (list $rootContext (printf "sireg-%s" $lang)) | quote }}
{{- end -}}
