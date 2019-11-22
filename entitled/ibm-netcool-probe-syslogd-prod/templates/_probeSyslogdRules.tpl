{{/* Syslogd Probe for configuration - only used when using standard rules*/}}
{{- define "ibm-netcool-probe-syslogd-prod.probeSyslogdRules" }}

syslogd.rules: |
{{- include "ibm-netcool-probe-syslogd-prod.probeSyslogdRules-main" . | indent 2 }}

{{- end }}