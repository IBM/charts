{{- define "ibm-eventstreams.customNodeaffinity" -}}
{{- $params := . }}
{{- $root := first $params }}
nodeAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    nodeSelectorTerms:
      - matchExpressions:
          - key: beta.kubernetes.io/arch
            operator: In
            values:
              - {{ $root.Values.global.arch }}
{{- end }}

{{- define "ibm-eventstreams.archMatchExpression" -}}
{{- $params := . }}
{{- $root := first $params }}
- key: beta.kubernetes.io/arch
  operator: In
  values:
    - {{ $root.Values.global.arch }}
{{- end }}

{{- define "ibm-eventstreams.stsMatchExpression" -}}
{{- $root := index . 0 }}
{{- $label := index . 1 }}
{{- $zones := int (include "zones.to.template" (list $root)) }}
{{- if gt $zones 1 }}
- key: {{ $label | quote }}
  operator: In
  values:
    - "true"
{{- end }}
{{- end }}

{{- define "ibm-eventstreams.isolationMatchExpression" -}}
{{- $root := index . 0 }}
{{- $namePrefix := index . 1 }}
labelSelector:
  matchExpressions:
    - key: "release"
      operator: In
      values:
      -  {{ $root.Release.Name | quote }}
    - key: "serviceSelector"
      operator: In
      values:
      -  {{ $namePrefix | quote }}
topologyKey: "kubernetes.io/hostname"
{{- end }}

{{- define "ibm-eventstreams.zoneMatchExpression" -}}
{{- $root := index . 0 -}}
{{- $zoneIndex := index . 1 -}}
{{- $zones := int (include "zones.to.template" (list $root)) }}
{{- if gt $zones 1 }}
- key: {{ $root.Values.global.zones.apiLabel }}
  operator: In
  values:
    - {{ index $root.Values.global.zones.labels $zoneIndex }}
{{- end }}
{{- end }}
