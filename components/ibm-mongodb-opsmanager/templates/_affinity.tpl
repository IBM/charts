{{/* affinity - https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ */}}

{{- define "nodeaffinity" }}
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    {{- include "nodeAffinityRequiredDuringScheduling" . }}
    {{ if eq .Values.runtime "ICP4Data" -}}
      {{- if .Values.dedicated }}
      {{- include "nodeAffinityICP4Data" . }}
      {{- end }}
    {{- end }}
{{- end }}

{{- define "nodeAffinityRequiredDuringScheduling" }}
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
            - amd64
{{- end }}

{{- define "nodeAffinityICP4Data" }}
      nodeSelectorTerms:
      - matchExpressions:
        - key: icp4data
          operator: In
          values:
            - database-mongodb
{{- end }}
