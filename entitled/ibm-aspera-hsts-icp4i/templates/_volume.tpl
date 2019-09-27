{{- include "sch.config.init" (list . "hsts.sch.chart.config.values") -}}

{{ define "hsts.transfer.pvc" -}}
  {{- if .Values.persistence.existingClaimName -}}
    {{ .Values.persistence.existingClaimName }}
  {{- else -}}
    {{ include "sch.names.persistentVolumeClaimName" (list . .sch.chart.volumes.transfer) }}
  {{- end -}}
{{- end }}
