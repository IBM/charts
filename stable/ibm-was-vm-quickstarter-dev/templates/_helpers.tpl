{{/* vim: set filetype=mustache: */}}

{{- define "databaseName" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "selector.matchLabels" -}}
  {{- $params := . -}}
  {{- $top := first $params -}}
  {{- $compName := (include "sch.utils.getItem" (list $params 1 "")) -}}  
app: {{ include "sch.names.appName" (list $top)  | quote}}
release: {{ $top.Release.Name | quote }}
  {{- if $compName }}
component: {{ $compName | quote }}
  {{- end -}}    
{{- end -}}
