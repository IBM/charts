{{ include "ibm-app-navigator.utils.isICP" (list .) }}
{{- define "ibm-app-navigator.affinity.nodeAffinity" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
nodeAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
{{ include "ibm-app-navigator.nodeAffinityRequiredDuringScheduling" (list $root) | indent 4 }}
  preferredDuringSchedulingIgnoredDuringExecution:
{{- include "ibm-app-navigator.nodeAffinityPreferredDuringScheduling" (list $root) | indent 2 }}
{{- end -}}

{{- define "ibm-app-navigator.nodeAffinityRequiredDuringScheduling" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
nodeSelectorTerms:
- matchExpressions:
  {{- if $root.Values.isICP }}
  - key: management
    operator: Exists
  {{- end }}  
  - key: beta.kubernetes.io/arch
    operator: In
    values:
    {{- range $key, $val := $root.Values.arch }}
    {{- if gt ($val | trunc 1 | int) 0 }}
    - {{ $key }}
    {{- end }}
    {{- end }}
{{- end -}}

{{- define "ibm-app-navigator.nodeAffinityPreferredDuringScheduling" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- range $key, $val := $root.Values.arch }}
  {{- if gt ($val | trunc 1 | int) 0 }}
- weight: {{ $val | trunc 1 | int }}
  preference:
    matchExpressions:
    - key: beta.kubernetes.io/arch
      operator: In
      values:
      - {{ $key }}
    {{- end }}
  {{- end }}
{{- end }}