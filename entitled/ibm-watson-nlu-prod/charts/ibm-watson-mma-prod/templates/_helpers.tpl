{{/* vim: set filetype=mustache: */}}

{{- /* PULL SECRET TEMPLATE */ -}}
{{- define "mma.imagePullSecretTemplate" -}}
{{- if ne .Values.global.imagePullSecretName "" }}
imagePullSecrets:
{{ printf "- name: %s" .Values.global.imagePullSecretName -}}
{{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
{{ printf "- name: sa-%s" .Release.Namespace -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* ######################################## TLS SECRET NAME ######################################## */}}
{{- define "mma.tlsSecretNameTemplate" -}}
{{- printf "%s-mma-tls-secrets" .Release.Name -}}
{{- end -}}
{{/* ######################################## TLS SECRET NAME ######################################## */}}

{{/* ################################### POSTGRES AUTH SECRET NAME ################################### */}}
{{- define "mma.postgresAuthSecretNameTemplate" -}}
{{- printf "%s-mma-postgres-auth-secret" .Release.Name -}}
{{- end -}}
{{/* ################################### POSTGRES AUTH SECRET NAME ################################### */}}
