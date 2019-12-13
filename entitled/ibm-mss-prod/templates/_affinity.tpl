{{/* affinity - https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ */}}

{{- define "mss.nodeaffinity" }}
  # https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    {{- include "mss.nodeAffinityRequiredDuringScheduling" . }}
    preferredDuringSchedulingIgnoredDuringExecution:
    {{- include "mss.nodeAffinityPreferredDuringScheduling" . }}
{{- end }}

{{- define "mss.nodeAffinityRequiredDuringScheduling" }}
    # If you specify multiple nodeSelectorTerms associated with nodeAffinity types,
    # then the pod can be scheduled onto a node if one of the nodeSelectorTerms is satisfied.
    #
    # If you specify multiple matchExpressions associated with nodeSelectorTerms,
    # then the pod can be scheduled onto a node only if all matchExpressions can be satisfied.
    #
    # valid operators: In, NotIn, Exists, DoesNotExist, Gt, Lt
      nodeSelectorTerms:
      - matchExpressions:
        - key: beta.kubernetes.io/arch
          operator: In
          values:
        {{- range $key, $val := .Values.global.arch }}
          {{- if gt ($val | trunc 1 | int) 0 }}
          - {{ $key }}
          {{- end }}
        {{- end }}
      {{- if .Values.global.nodesLabelKey }}
        - key: {{ .Values.global.nodesLabelKey }}
          operator: Exists
      {{- end }}
{{- end }}

{{- define "mss.nodeAffinityPreferredDuringScheduling" }}
  {{- range $key, $val := .Values.global.arch }}
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
