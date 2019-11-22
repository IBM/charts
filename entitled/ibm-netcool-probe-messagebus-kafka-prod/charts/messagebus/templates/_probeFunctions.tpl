{{- define "messagebus.rbac.serviceAccountName" }}
{{- include "sch.config.init" (list . "probe.sch.chart.config.values") -}}
{{- $serviceaccount :=  .sch.chart.components.rbac.serviceAccountName -}}
{{- $serviceAccountName := include "sch.names.fullCompName" (list . $serviceaccount ) -}}
{{- printf "%s" $serviceAccountName -}}
{{ end -}}

{{/*
Process the netcool.connectionMode and return "true" if
SSL connection is enabled. It is enabled when
netcool.connectionMode is either sslonly or sslandauth
*/}}
{{- define "messagebus.secobj.netcoolConnectionSslEnabled" }}
{{- $connectionMode := ( default "default" .Values.netcool.connectionMode | lower) -}}
{{ if or (eq $connectionMode "sslonly") (eq $connectionMode "sslandauth") }}
{{- printf "%s" "true" }}
{{- else -}}
{{- printf "%s" "false" }}
{{- end -}}
{{ end -}}

{{/*
Process the netcool.connectionMode and return "true" if
Authentication is enabled. It is enabled when
netcool.connectionMode is either authonly or sslandauth
*/}}
{{- define "messagebus.secobj.netcoolConnectionAuthEnabled" }}
{{- $connectionMode := ( default "default" .Values.netcool.connectionMode | lower) -}}
{{ if or (eq $connectionMode "authonly") (eq $connectionMode "sslandauth") }}
{{- printf "%s" "true" }}
{{- else -}}
{{- printf "%s" "false" }}
{{- end -}}
{{ end -}}

{{/*
Process the netcool.connectionMode and return "true" if
a keys secret is required. This is when
netcool.connectionMode is either authonly, sslonly or sslandauth
*/}}
{{- define "messagebus.secobj.keySecretRequired" }}
{{- $netcoolsslenabled := include "messagebus.secobj.netcoolConnectionSslEnabled" ( . ) -}}
{{- $netcoolauthenabled := include "messagebus.secobj.netcoolConnectionAuthEnabled" ( . ) -}}
{{ if and (eq $netcoolsslenabled "false") (eq $netcoolauthenabled "false") }}
{{- printf "%s" "false" }}
{{- else -}}
{{- printf "%s" "true" }}
{{- end -}}
{{ end -}}
