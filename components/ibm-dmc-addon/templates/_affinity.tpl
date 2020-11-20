{{/* affinity - https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ */}}

{{- define "common.nodeAffinity" }}
#https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
nodeAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
  {{- include "common.nodeAffinityRequiredDuringScheduling" . }}
  preferredDuringSchedulingIgnoredDuringExecution:
  {{- include "common.nodeAffinityPreferredDuringScheduling" . }}
{{- end }}

{{- define "common.podAffinity" }}
#https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
  {{- if not (empty (.Values.customPodAffinity))  }}
podAffinity:
{{- include "common.customPodAffinity" . | indent 2 }}
  {{- end }}
{{- end }}

{{- define "common.podAntiAffinity" }}
#https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
  {{- if not (empty (.Values.customPodAntiAffinity))  }}
podAntiAffinity:
{{- include "common.customPodAntiAffinity" . | indent 2 }}
  {{- end }}
{{- end }}

{{- define "common.nodeAffinityRequiredDuringScheduling" }}
    #If you specify multiple nodeSelectorTerms associated with nodeAffinity types,
    #then the pod can be scheduled onto a node if one of the nodeSelectorTerms is satisfied.
    #
    #If you specify multiple matchExpressions associated with nodeSelectorTerms,
    #then the pod can be scheduled onto a node only if all matchExpressions can be satisfied.
    #
    #valid operators: In, NotIn, Exists, DoesNotExist, Gt, Lt
    nodeSelectorTerms:
    - matchExpressions:
{{- include "common.customNodeSelectorTerms" . | indent 6 }}
      - key: beta.kubernetes.io/arch
        operator: In
        values:
      {{- range $key, $val := .Values.arch }}
        {{- if gt ($val | trunc 1 | int) 0 }}
        - {{ $key }}
        {{- end }}
      {{- end }}
{{- end }}

{{- define "common.nodeAffinityPreferredDuringScheduling" }}
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

{{- define "common.customNodeSelectorTerms" }}
  {{- if not (empty (.Values.customNodeSelectorTerms))  }}
{{ toYaml .Values.customNodeSelectorTerms }}
  {{- end }}
{{- end }}

{{- define "common.customPodAffinity" }}
  {{- if not (empty (.Values.customPodAffinity))  }}
{{ toYaml .Values.customPodAffinity }}
  {{- end }}
{{- end }}

{{- define "common.customPodAntiAffinity" }}
  {{- if not (empty (.Values.customPodAntiAffinity))  }}
{{ toYaml .Values.customPodAntiAffinity }}
  {{- end }}
{{- end }}

