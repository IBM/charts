{{/* Tivoli EIF Probe for configuration - only used when using standard rules*/}}
{{- define "probeTivoliEIFRules" }}

tivoli_eif.rules: |
{{- include "probeTivoliEIFRules-default" . | indent 2 }}

{{ if .Values.probe.rulesFile.taddm }}
tivoli_eif_taddm.rules: |
{{- include "probeTivoliEIFRules-taddm" . | indent 2 }}
{{- end }}

{{ if .Values.probe.rulesFile.tpc }}
tivoli_eif_tpc.rules: |
{{- include "probeTivoliEIFRules-tpc" . | indent 2 }}
{{- end }}

{{ if .Values.probe.rulesFile.tsm }}
tivoli_eif_tsm.rules: |
{{- include "probeTivoliEIFRules-tsm" . | indent 2 }}
{{- end }}

{{- end }}