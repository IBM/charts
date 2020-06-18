
{{- define "assistant.etcd.secretName" -}}
{{ .Release.Name }}-assistant-etcd-creds
{{- end -}}

{{- define "assistant.etcd.affinitiesEtcd.nodeAffinity" -}}
  {{- $originalAffinitiesStr     := include "sch.affinity.nodeAffinity" (list . .sch.chart.nodeAffinity) -}}
  {{- $affinities                := fromYaml $originalAffinitiesStr -}}

  {{- /* Patch requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0] - that sch chard generated just with arch key with additional LabelSelectorRequirements is specified in umbrella chart */ -}}
  {{- $additionalRequirements    := .Values.global.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms.matchExpressions -}}
  {{- $tmpNodeSelectorTerms      := $affinities.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms -}}
  {{- $tmpFirstNodeSelectorTerm  := first $tmpNodeSelectorTerms -}}
  {{- $tmpMatchExpressions       := $tmpFirstNodeSelectorTerm.matchExpressions -}}

  {{- /* Append additional match expression keys */ -}}
  {{- $tmpDict := (dict "updatedMatchExpressions" $tmpMatchExpressions) -}}
  {{- range $additionalLabelSelectorRequirement := $additionalRequirements -}}
    {{- $_  := set $tmpDict "updatedMatchExpressions" ( append $tmpDict.updatedMatchExpressions $additionalLabelSelectorRequirement) -}}
  {{- end -}}

  {{- /* Modify the affinities in place */ -}}
  {{- $_ := set $tmpFirstNodeSelectorTerm "matchExpressions" $tmpDict.updatedMatchExpressions -}}
  {{- $affinities | toYaml -}}
{{- end -}}
