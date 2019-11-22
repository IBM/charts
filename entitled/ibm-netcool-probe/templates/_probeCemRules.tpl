{{/* Probe for Message Bus Rules for CEM */}}
{{- define "ibm-netcool-probe.probeCemRules" }}
message_bus.rules: |
{{ .Files.Get "files/message_bus_cem.rules" | indent 2 }}
{{- end }}
