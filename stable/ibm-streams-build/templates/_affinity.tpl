{{/* affinity - https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ 

    #If you specify multiple nodeSelectorTerms associated with nodeAffinity types,
    #then the pod can be scheduled onto a node if one of the nodeSelectorTerms is satisfied.
    #
    #If you specify multiple matchExpressions associated with nodeSelectorTerms,
    #then the pod can be scheduled onto a node only if all matchExpressions can be satisfied.
    #
    #valid operators: In, NotIn, Exists, DoesNotExist, Gt, Lt
*/}}

{{- define "build.nodeaffinity" }}
nodeAffinity:
{{- include "build.nodeAffinityRequiredDuringScheduling" . | indent 2}}
{{- end }}

{{- define "build.nodeAffinityRequiredDuringScheduling" }}
requiredDuringSchedulingIgnoredDuringExecution:
  nodeSelectorTerms:
  - matchExpressions:
    - key: beta.kubernetes.io/arch
      operator: In
      values:
      - amd64
{{- end }}
