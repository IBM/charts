{{/*
########################################################################
#
# Licensed Materials - Property of IBM
#
# 5725Q09
#
# (C) Copyright IBM Corp.
#
# 2018 All Rights Reserved
#
# US Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
########################################################################
*/}}

{{ define "objectserver.username" -}}
    {{- if eq .Values.global.hybrid.disabled true -}}
        {{- .Values.objectserver.username -}}
    {{- else if  .Values.objectserver.username -}}
        {{- .Values.global.hybrid.objectserver.username -}}
    {{- else -}}
        root
    {{- end }}
{{- end }}

{{ define "objectserver.primary.hostname" -}}
    {{- if  .Values.objectserver.primary.hostname -}}
        {{- .Values.objectserver.primary.hostname -}}
    {{- else if not .Values.global.hybrid.disabled -}}
        {{- .Values.global.hybrid.objectserver.primary.hostname -}}
    {{- else -}}
        {{- if .Values.global.authentication.objectserver.secretRelease  }}
        {{- .Values.global.authentication.objectserver.secretRelease | default .Release.Name }}-objserv-agg-primary.{{ .Values.global.authentication.objectserver.secretNamespace | default .Release.Namespace }}.svc
        {{- else }}
           {{- .Release.Name }}-objserv-agg-primary
        {{- end }}
     {{- end }}
{{- end }}

{{ define "objectserver.backup.hostname" -}}
    {{- if  .Values.objectserver.backup.hostname -}}
        {{- .Values.objectserver.backup.hostname -}}
    {{- else if not .Values.global.hybrid.disabled -}}
        {{- .Values.global.hybrid.objectserver.backup.hostname -}}
    {{- else -}}
        {{- if .Values.global.authentication.objectserver.secretRelease  }}
        {{- .Values.global.authentication.objectserver.secretRelease | default .Release.Name }}-objserv-agg-backup.{{ .Values.global.authentication.objectserver.secretNamespace | default .Release.Namespace }}.svc
        {{- else }}
           {{- .Release.Name }}-objserv-agg-backup
        {{- end }}
    {{- end }}
{{- end }}

{{ define "objectserver.primary.port" -}}
    {{- if  .Values.objectserver.primary.port -}}
        {{- .Values.objectserver.primary.port -}}
    {{- else if not .Values.global.hybrid.disabled -}}
        {{- .Values.global.hybrid.objectserver.primary.port -}}
    {{- else -}}
        4100
    {{- end }}
{{- end }}

{{ define "objectserver.backup.port" -}}
    {{- if  .Values.objectserver.backup.port -}}
        {{- .Values.objectserver.backup.port -}}
    {{- else if not .Values.global.hybrid.disabled -}}
        {{- .Values.global.hybrid.objectserver.backup.port -}}
    {{- else -}}
        4100
    {{- end }}
{{- end }}

{{/*
Use either image tag or digest
*/}}
{{- define "ibmeanoilayer.image.suffix" -}}
{{- $root := (index . 0) -}}
{{- $image := (index . 1) -}}
{{- if or (eq (toString $root.Values.global.image.useTag) "true") (eq (toString $image.digest) "") -}}
{{- printf ":%s" $image.tag -}}
{{- else -}}
{{- printf "@%s" $image.digest -}}
{{- end -}}
{{- end -}}
