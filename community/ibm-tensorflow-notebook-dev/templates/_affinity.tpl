{{/* affinity - https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ */}}

{{- define "nodeaffinity" }}
#https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    {{- include "nodeAffinityRequiredDuringScheduling" . }}
{{- end }}

{{- define "nodeAffinityRequiredDuringScheduling" }}
      nodeSelectorTerms:
      - matchExpressions:
        - key: beta.kubernetes.io/arch
          operator: In
          values:
          - {{ .Values.node }}
{{- end }}
