{{/* vim: set filetype=mustache: */}}

{{/*
Create common master service name.
*/}}
{{- define "waMdm.ServiceName" -}}
{{- $name := default .Chart.Name .Release.Name -}}
{{- printf "%s-%s" $name "waserver" -}}
{{- end -}}

{{- define "waserver.ConfigName" -}}
{{- $name := default .Chart.Name .Release.Name -}}
{{- printf "%s-%s-%s" $name "waserver" "config" -}}
{{- end -}}
