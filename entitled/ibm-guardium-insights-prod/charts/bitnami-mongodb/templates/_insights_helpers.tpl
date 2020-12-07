{{/* vim: set filetype=mustache: */}}
{{/*
Insights template additions
*/}}
{{/*
Return the proper image name for the extraInitContainer create-tls-data
*/}}
{{- define "extraInitContainer.image" -}}
{{- $registryName := .Values.extraInitContainer.image.registry -}}
{{- $repositoryName := .Values.extraInitContainer.image.repository -}}
{{- $tag := .Values.extraInitContainer.image.tag | toString -}}
{{/*
Helm 2.11 supports the assignment of a value to a variable defined in a different scope,
but Helm 2.9 and 2.10 doesn't support it, so we need to implement this if-else logic.
Also, we can't use a single if because lazy evaluation is not an option
*/}}
{{- if .Values.global }}
    {{- if .Values.global.imageRegistry }}
        {{- printf "%s/%s:%s" .Values.global.imageRegistry $repositoryName $tag -}}
    {{- else -}}
        {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
    {{- end -}}
{{- else -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the mongodb additional command line server flags
*/}}
{{- define "mongodb.extraFlags" -}}
{{- $serverMode := "requireTLS" -}}
{{- if .Values.global }}
  {{- if .Values.global.tls }}
    {{- if .Values.global.tls.mongoServerMode }}
      {{- $serverMode := .Values.global.tls.mongoServerMode -}}
      {{- printf "--tlsMode %s --tlsCertificateKeyFile /service/certs/bitnami-mongodb/pem/tls.pem" $serverMode -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return the SAN DNS entries for bitnami-mongodb-tls secret
Note: Interservice calls are via the cluster service URL. See templates
  statefulset-primary-rs.yaml for the pod name and MONGODB_ADVERTISED_HOSTNAME.
  Our DNS entry for the service URL mirror these.
*/}}
{{- define "mongodb.cert.san.dns" -}}
  - {{ template "mongodb.fullname" . }}
  {{- if .Values.replicaSet.useHostnames }}
  {{- if .Values.clusterDomain }}
    - {{ template "mongodb.fullname" . }}-primary-0.{{ template "mongodb.fullname" . }}-headless.{{ .Release.Namespace }}.svc.{{ .Values.clusterDomain }}
  {{- else }}
    - {{ template "mongodb.fullname" . }}-primary-0.{{ template "mongodb.fullname" . }}-headless.{{ .Release.Namespace }}
  {{- end }}
  {{- end }}
{{- end -}}


{{/*
Insights labels
*/}}
{{- define "mongodb.labels" -}}
app.kubernetes.io/name: {{ include "mongodb.name" . }}
helm.sh/chart: {{ include "mongodb.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}