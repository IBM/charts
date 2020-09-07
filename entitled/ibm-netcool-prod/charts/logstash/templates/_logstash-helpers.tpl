{{/*
########################################################################
#
# Licensed Materials - Property of IBM
#
# 5725Q09
#
# (C) Copyright IBM Corp.
#
# 2020 All Rights Reserved
#
# US Government Users Restricted Rights - Use, duplication or disclosure 
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
########################################################################
*/}}

{{/*
When replicaCount is set to "environmentSizeDefault" then use 1 replica at size0
and 3 replicas at size1.
*/}}
{{- define "logstash.replicas" -}}
  {{- if eq ( .Values.global.logstash.replicaCount | toString) "environmentSizeDefault" }}
    {{- if eq .Values.global.environmentSize "size0" }}
      {{- printf "%d" 1 }}
    {{- else -}}
      {{- printf "%d" 3 }}
    {{- end -}}
  {{- else }}
    {{- .Values.global.logstash.replicaCount }}
  {{- end }}
{{- end }}

{{- define "logstash.getImageRepo" -}}
{{- if .Values.global.image.repository -}}
{{- printf "%s" ( trimSuffix "/" .Values.global.image.repository ) }}
{{- end -}}
{{- end -}}
