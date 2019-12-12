{{/* affinity - https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ */}}

{{- define "ibm-wml-accelerator-prod.nodeaffinity" }}
  # https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    {{- include "ibm-wml-accelerator-prod.nodeAffinityRequiredDuringScheduling" . }}
{{- end }}

{{- define "ibm-wml-accelerator-prod.nodeAffinityRequiredDuringScheduling" }}
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
        {{- range $key, $val := .Values.arch }}
          {{- if gt ($val | trunc 1 | int) 0 }}
          - {{ $key }}
          {{- end }}
        {{- end }}
      {{- if .Values.cluster.mgmtNodesLabelKey }}
        - key: {{.Values.cluster.mgmtNodesLabelKey }}
          operator: Exists
      {{- end }}
{{- end }}

{{- define "ibm-wml-accelerator-prod.condaNodeAffinity" }}
nodeAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    nodeSelectorTerms:
    # Match GPU pods in IKS
    - matchExpressions:
      - key: ibm-cloud.kubernetes.io/gpu-enabled
        operator: In
        values:
        - "true"
    # Match worker pods in ICP
    - matchExpressions:
      - key: node-role.kubernetes.io/worker
        operator: In
        values:
        - "true"
{{- end }}
