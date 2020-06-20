{{- define "discovery.admin.securityContextConstraint" -}}
  {{- if .Values.securityContextConstraint.name -}}
    {{ .Values.securityContextConstraint.name }}
  {{- else -}}
    {{ include "sch.names.fullCompName" (list . .sch.chart.components.securityContextConstraint.name) }}
  {{- end -}}
{{- end }}

{{- define "discovery.admin.tlsSecret" -}}
  {{- if .Values.tlsSecret.name -}}
    {{ .Values.tlsSecret.name }}
  {{- else -}}
    {{- printf "%s-%s-tls" .Release.Name .Values.global.appName | trunc 63 | trimSuffix "-" -}}
  {{- end -}}
{{- end -}}
