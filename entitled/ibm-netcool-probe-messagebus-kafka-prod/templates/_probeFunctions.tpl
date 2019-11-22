{{- define "ibm-netcool-probe-messagebus-kafka-prod.rbac.roleName" }}
{{- include "sch.config.init" (list . "probe.kafka.sch.chart.config.values") -}}
{{- $role :=  .sch.chart.components.rbac.roleName -}}
{{- $roleName := include "sch.names.fullCompName" (list . $role ) -}}
{{- printf "%s" $roleName -}}
{{ end -}}

{{- define "ibm-netcool-probe-messagebus-kafka-prod.rbac.roleBindingName" }}
{{- include "sch.config.init" (list . "probe.kafka.sch.chart.config.values") -}}
{{- $rolebinding :=  .sch.chart.components.rbac.roleBindingName -}}
{{- $roleBindingName := include "sch.names.fullCompName" (list . $rolebinding ) -}}
{{- printf "%s" $roleBindingName -}}
{{ end -}}

{{- define "ibm-netcool-probe-messagebus-kafka-prod.rbac.serviceAccountName" }}
{{- include "sch.config.init" (list . "probe.kafka.sch.chart.config.values") -}}
{{- $serviceaccount :=  .sch.chart.components.rbac.serviceAccountName -}}
{{- $serviceAccountName := include "sch.names.fullCompName" (list . $serviceaccount ) -}}
{{- printf "%s" $serviceAccountName -}}
{{ end -}}

{{/*
Process the netcool.connectionMode and return "true" if
SSL connection is enabled. It is enabled when
netcool.connectionMode is either sslonly or sslandauth
*/}}
{{- define "ibm-netcool-probe-messagebus-kafka-prod.secobj.netcoolConnectionSslEnabled" }}
{{- $connectionMode := ( default "default" .Values.messagebus.netcool.connectionMode | lower) -}}
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
{{- define "ibm-netcool-probe-messagebus-kafka-prod.secobj.netcoolConnectionAuthEnabled" }}
{{- $connectionMode := ( default "default" .Values.messagebus.netcool.connectionMode | lower) -}}
{{ if or (eq $connectionMode "authonly") (eq $connectionMode "sslandauth") }}
{{- printf "%s" "true" }}
{{- else -}}
{{- printf "%s" "false" }}
{{- end -}}
{{ end -}}
