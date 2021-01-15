{{- define "b2bi.nodeaffinity.onlyArch" }}
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    {{- include "b2bi.nodeAffinityRequiredDuringScheduling" . }}
{{- end }}

{{- define "b2bi.nodeAffinityRequiredDuringScheduling" }}
      nodeSelectorTerms:
      - matchExpressions:
      {{- include "b2bi.nodeAffinityArchRequired.matchExpressions" . | indent 8}}
{{- end }}



/*
  Apply the architecture nodeAffinity matchExpression to each of the matchExpressions provided in values.yaml.
*/
{{- define "b2bi.nodeAffinity" }}
{{- $rootCtx := index . 0 }}
{{- $currNodeAffinity := index . 1 }}
{{- $archRequiredMatchExpressions := include "b2bi.nodeAffinityArchRequired.matchExpressions" $rootCtx }}
nodeAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    nodeSelectorTerms:
    {{- if and ( $currNodeAffinity ) ( $currNodeAffinity.requiredDuringSchedulingIgnoredDuringExecution) }}
      {{- $nodeSelectorTerms := $currNodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms | default list }}
      {{- if gt (len $nodeSelectorTerms) 0  }}
        {{- range $nodeSelectorTerms }}
          {{- $nodeSelectorTerm := . }}
    - matchExpressions:
          {{- $archRequiredMatchExpressions | indent 6 }}
          {{- $matchExpressions := $nodeSelectorTerm.matchExpressions | default list }}
          {{- if gt (len $matchExpressions) 0 }}
{{ toYaml $nodeSelectorTerm.matchExpressions | indent 6 }}
          {{- end }}
        {{- end }}
      {{- else }}
    - matchExpressions:
      {{- $archRequiredMatchExpressions | indent 6 }}
      {{- end }}
    {{- else }}
    - matchExpressions:
      {{- $archRequiredMatchExpressions | indent 6 }}
    {{- end }}
  preferredDuringSchedulingIgnoredDuringExecution:
  {{- $preferDuringSchIgnoreDuringExec := $currNodeAffinity.preferredDuringSchedulingIgnoredDuringExecution | default list }}
  {{- if gt ( len $preferDuringSchIgnoreDuringExec ) 0 }}
{{ toYaml $preferDuringSchIgnoreDuringExec | indent 2 }}
  {{- end }}
{{- end }}

/*
 matchExpression for nodeAffinity based on architecture
*/
{{- define "b2bi.nodeAffinityArchRequired.matchExpressions" }}
- key: beta.kubernetes.io/arch
  operator: In
  values:
  - amd64
{{- end }}


/* Architecture Affinity
*/
{{- define "b2bi.architectureAffinity" }}
nodeAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    nodeSelectorTerms:
    - matchExpressions:
      - key: beta.kubernetes.io/arch
        operator: In
        values:
        - amd64
{{- end }}


/*
  Pod affinity
*/
{{- define "b2bi.podAffinity" }}
{{- $rootCtx := index . 0 }}
{{- $currpodAffinity := index . 1 }}
podAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
  {{- $requiredDuringSchedulingIgnoredDuringExecution := $currpodAffinity.requiredDuringSchedulingIgnoredDuringExecution | default list }}
  {{- if gt ( len $requiredDuringSchedulingIgnoredDuringExecution ) 0 }}
{{ toYaml $requiredDuringSchedulingIgnoredDuringExecution | indent 2 }}
  {{- end }}  
  preferredDuringSchedulingIgnoredDuringExecution:
  {{- $preferDuringSchIgnoreDuringExec := $currpodAffinity.preferredDuringSchedulingIgnoredDuringExecution | default list }}
  {{- if gt ( len $preferDuringSchIgnoreDuringExec ) 0 }}
{{ toYaml $preferDuringSchIgnoreDuringExec | indent 2 }}
  {{- end }}
{{- end }}



/* Pod Anti Affinity

*/
{{- define "b2bi.podAntiAffinity" }}
{{- $rootCtx := index . 0 }}
{{- $currpodAntiAffinity := index . 1 }}
podAntiAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
  {{- $requiredDuringSchedulingIgnoredDuringExecution := $currpodAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution | default list }}
  {{- if gt ( len $requiredDuringSchedulingIgnoredDuringExecution ) 0 }}
{{ toYaml $requiredDuringSchedulingIgnoredDuringExecution | indent 2 }}
  {{- end }}  
  preferredDuringSchedulingIgnoredDuringExecution:
  {{- $preferDuringSchIgnoreDuringExec := $currpodAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution | default list }}
  {{- if gt ( len $preferDuringSchIgnoreDuringExec ) 0 }}
{{ toYaml $preferDuringSchIgnoreDuringExec | indent 2 }}
  {{- end }}
{{- end }}







