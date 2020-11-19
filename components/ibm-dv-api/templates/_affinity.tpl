{{/* affinity - https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ */}}

{{- define "dvapi.NodeAffinity" }}
#https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
nodeAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
  {{- include "dvapi.NodeAffinityRequiredDuringScheduling" . }}
  preferredDuringSchedulingIgnoredDuringExecution:
  {{- include "dvapi.NodeAffinityPreferredDuringScheduling" . }}
{{- end }}

{{- define "dvapi.NodeAffinityRequiredDuringScheduling" }}
    #If you specify multiple nodeSelectorTerms associated with nodeAffinity types,
    #then the pod can be scheduled onto a node if one of the nodeSelectorTerms is satisfied.
    #
    #If you specify multiple matchExpressions associated with nodeSelectorTerms,
    #then the pod can be scheduled onto a node only if all matchExpressions can be satisfied.
    #
    #valid operators: In, NotIn, Exists, DoesNotExist, Gt, Lt
    nodeSelectorTerms:
    - matchExpressions:
{{- include "dvapi.CustomNodeSelectorTerms" . | indent 6 }}
      - key: beta.kubernetes.io/arch
        operator: In
        values:
      {{- range $key, $val := .Values.arch }}
        {{- if gt ($val | trunc 1 | int) 0 }}
        - {{ $key }}
        {{- end }}
      {{- end }}
{{- end }}

{{- define "dvapi.NodeAffinityPreferredDuringScheduling" }}
  {{- range $key, $val := .Values.arch }}
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

{{- define "dvapi.CustomNodeSelectorTerms" }}
  {{- if not (empty (.Values.customNodeSelectorTerms))  }}
{{ toYaml .Values.customNodeSelectorTerms }}
  {{- end }}
{{- end }}
