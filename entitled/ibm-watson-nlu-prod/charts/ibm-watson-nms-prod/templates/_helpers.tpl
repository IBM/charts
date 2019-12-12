{{/* vim: set filetype=mustache: */}}

{{- /* PULL SECRET TEMPLATE */ -}}
{{- define "nms.imagePullSecretTemplate" -}}
{{- if ne .Values.global.imagePullSecretName "" }}
imagePullSecrets:
{{ printf "- name: %s" .Values.global.imagePullSecretName -}}
{{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
{{ printf "- name: sa-%s" .Release.Namespace -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* ######################################## TLS SECRET NAME ######################################## */}}
{{- define "nms.tlsSecretNameTemplate" -}}
{{- printf "%s-nms-tls-secrets" .Release.Name -}}
{{- end -}}
{{/* ######################################## TLS SECRET NAME ######################################## */}}

{{/* ######################################## MINIO ################################### */}}
{{- define "nms.minioAccessSecretNameTemplate" -}}
{{- printf "%s-nms-minio-access-secret" .Release.Name -}}
{{- end -}}

{{- /* MINIO ENDPOINT TEMPLATE
*/ -}}
{{- define "nms.minioEndpointTemplate" -}}
http{{ if .Values.global.s3.sslEnabled }}s{{ end }}://{{ .Release.Name }}-ibm-minio-svc.{{ .Release.Namespace }}.{{ .Values.global.clusterDomain }}:{{ .Values.global.s3.endpointPort }}
{{- end -}}
{{/* ######################################## MINIO ################################### */}}
