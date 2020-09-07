{{/* TEMPLATE TO GENERATE A COMMA SEPARATED LIST OF ZOOKEEPER SERVERS */}}
{{- define "zookeeper.getServerList" -}}
  {{- range $i := until (int (include "zookeeper.replicationFactor" . )) }}
    {{- printf "%s-zookeeper-%d.%s-zkensemble.%s:2181," $.Release.Name $i $.Release.Name $.Release.Namespace -}}
  {{- end -}}
{{- end -}}

{{/*
decides on using global or local zookeeper.clustersize, if neither are set, default to 1
*/}}
{{- define "zookeeper.rawReplicationFactor" }}
  {{- if .Values.global.zookeeper.clusterSize }}
    {{- .Values.global.zookeeper.clusterSize }}
  {{- else }}
    {{- .Values.clusterSize }}
  {{- end }}
{{- end -}}

{{/*
check if zookeeper.clusterSize == "environmentSizeDefault" and if so use value in _resouces.tpl
corresponding to environmentSize setting
*/}}
{{- define "zookeeper.replicationFactor" -}}
  {{- if eq ( (include "zookeeper.rawReplicationFactor" .) | toString) "environmentSizeDefault" }}
    {{- include "zookeeper.comp.size.data" (list . "replicas") }}
  {{- else }}
    {{- include "zookeeper.rawReplicationFactor" . }}
  {{- end }}
{{- end }}

{{- define "zookeeper.getImageRepo" -}}
{{- if .Values.global.image.repository -}}
{{- printf "%s" ( trimSuffix "/" .Values.global.image.repository ) }}
{{- end -}}
{{- end -}}

{{- define "zookeeper.getImage" -}}
{{- if or (eq (toString .Values.global.image.useTag) "true") (eq (toString .Values.image.digest) "") -}}
{{- printf "%s/%s:%s" (include "zookeeper.getImageRepo" .) .Values.image.name .Values.image.tag -}}
{{- else -}}
{{- printf "%s/%s@%s" (include "zookeeper.getImageRepo" .) .Values.image.name .Values.image.digest -}}
{{- end -}}
{{- end -}}

{{- define "zookeeper.getServiceAccountName" -}}
{{- if ne (toString .Values.serviceAccountName) "" -}}
  {{- tpl .Values.serviceAccountName . }}
{{- else if ne (toString .Values.global.rbac.serviceAccountName) "" -}}
  {{- tpl .Values.global.rbac.serviceAccountName . }}
{{- else if eq (toString .Values.global.rbac.create) "false" -}}
  {{- printf "%s" "default" | quote }}
{{- else -}}
  {{ include "sch.names.fullCompName" (list . "serviceaccount") }}
{{- end -}}
{{- end -}}
