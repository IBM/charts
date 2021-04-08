{{/*

This linkage utility template is needed until https://git.io/JvuGN is resolved.
It allows to call a template from the context of a subchart:

  {{ include "fci-entity-research.call-nested" (list . "<subchart_name>" "<subchart_template_name>") }}

*/}}
{{- define "fci-entity-research.call-nested" }}
{{- $dot := index . 0 }}
{{- $subchart := index . 1 | splitList "." }}
{{- $template := index . 2 }}
{{- $values := $dot.Values }}
{{- range $subchart }}
{{- $values := index $values . }}
{{- end }}
{{- include $template (dict "Chart" (dict "Name" (last $subchart)) "Values" $values "Release" $dot.Release "Capabilities" $dot.Capabilities) }}
{{- end }}
