{{/* affinity - https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ */}}

{{- define "ibm-reactive-platform-console-prod.nodeaffinity" }}
#https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    {{- include "ibm-reactive-platform-console-prod.nodeAffinityRequiredDuringScheduling" . }}
    preferredDuringSchedulingIgnoredDuringExecution:
    {{- include "ibm-reactive-platform-console-prod.nodeAffinityPreferredDuringScheduling" . }}
{{- end }}

{{- define "ibm-reactive-platform-console-prod.nodeAffinityRequiredDuringScheduling" }}
    #If you specify multiple nodeSelectorTerms associated with nodeAffinity types,
    #then the pod can be scheduled onto a node if one of the nodeSelectorTerms is satisfied.
    #
    #If you specify multiple matchExpressions associated with nodeSelectorTerms,
    #then the pod can be scheduled onto a node only if all matchExpressions can be satisfied.
    #
    #valid operators: In, NotIn, Exists, DoesNotExist, Gt, Lt
      nodeSelectorTerms:
      - matchExpressions:
        - key: beta.kubernetes.io/arch
          operator: In
          values:
            - {{ .Values.arch }}
{{- end }}

{{- define "ibm-reactive-platform-console-prod.nodeAffinityPreferredDuringScheduling" }}
    - weight: 3
      preference:
        matchExpressions:
        - key: beta.kubernetes.io/arch
          operator: In
          values:
          - {{ .Values.arch }}
{{- end }}
