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

{{/*
Set Impact replica count
*/}}
{{- define "noi.impact.replicas" -}}
{{- $root := ( index . 0 ) -}}
{{- $replicas := ( index . 1 ) -}}
{{- if eq $root.Values.global.enableImpact false -}}
0
{{- else -}}
  {{- if eq ( $replicas | toString) "environmentSizeDefault" }}
    {{- if eq $root.Values.global.environmentSize "size0" -}}
1
    {{- else if eq $root.Values.global.environmentSize "size1" -}}   
1
    {{- end }} 
  {{- else }}
    {{- $replicas }}
  {{- end }}
{{- end -}}
{{- end -}}

{{/*
Set nciservers replica count
*/}}
{{- define "noi.nciservers.replicas" -}}
{{- $root := ( index . 0 ) -}}
{{- $replicas := ( index . 1 ) -}}
{{- if eq $root.Values.global.enableImpact false -}}
0
{{- else -}}
  {{- if eq ( $replicas | toString) "environmentSizeDefault" }}
    {{- if eq $root.Values.global.environmentSize "size0" -}}
1
    {{- else if eq $root.Values.global.environmentSize "size1" -}}   
1
    {{- end }} 
  {{- else }}
    {{- $replicas }}
  {{- end }}
{{- end -}}
{{- end -}}
