{{- define "ibm-eventstreams.fsGroupGid" -}}
  {{- $params := . -}}
  {{- /* root context required for accessing other sch files */ -}}
  {{- $root := first $params -}}
  {{- if $root.Values.global.fsGroupGid -}}
  fsGroup: {{ $root.Values.global.fsGroupGid }}
  {{- end -}}
{{- end -}}
