{{/* SNMP Probe for configuration - only used when using standard rules*/}}
{{- define "probeSnmpRules" }}

mttrapd.rules: |
{{- include "probeSnmpRules-main" . | indent 2 }}

mttrapd_flood_control.rules: |
{{- include "probeSnmpRules-floodcontrol" . | indent 2 }}

{{- end }}