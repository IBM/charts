{{/* affinity - https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ */}}
{{- define "ibm-watson-speech-prod.watson-speech-nodeaffinity" }}
#https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    {{- include "ibm-watson-speech-prod.watson-speech-nodeAffinityRequiredDuringScheduling" . }}
    preferredDuringSchedulingIgnoredDuringExecution:
    {{- include "ibm-watson-speech-prod.watson-speech-nodeAffinityPreferredDuringScheduling" . }}
{{- end }}
{{- define "ibm-watson-speech-prod.watson-speech-nodeAffinityRequiredDuringScheduling" }}
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
        {{- range $key, $val := . }}
          {{- if gt ($val | trunc 1 | int) 0 }}
          - {{ $key }}
          {{- end }}
        {{- end }}
{{- end }}
{{- define "ibm-watson-speech-prod.watson-speech-nodeAffinityPreferredDuringScheduling" }}
  {{- range $key, $val := . }}
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
