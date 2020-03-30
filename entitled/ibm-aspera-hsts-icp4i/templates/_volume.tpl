{{ define "hsts.transfer.pvc" -}}
  {{- $params := . -}}
  {{- $outer := index $params 0 -}}
  {{- $p := index $params 1 -}}
  {{- $ordinal := index $params 2 -}}
  {{- if $p.claimName -}}
    {{ $p.claimName }}
  {{- else -}}
    {{ printf "%s-%d" (include "sch.names.persistentVolumeClaimName" (list $outer $outer.sch.chart.volumes.transfer)) $ordinal }}
  {{- end -}}
{{- end }}
