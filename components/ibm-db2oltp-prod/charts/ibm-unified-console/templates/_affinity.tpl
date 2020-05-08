{{/* affinity - https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ */}}

{{- define "uc.nodeAffinity" }}
#https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
nodeAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
  {{- include "uc.nodeAffinityRequiredDuringScheduling" . }}
  preferredDuringSchedulingIgnoredDuringExecution:
  {{- include "uc.nodeAffinityPreferredDuringScheduling" . }}
{{- end }}

{{- define "uc.podAffinity" }}
#https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
  {{- if not (empty (.Values.customPodAffinity))  }}
podAffinity:
{{- include "uc.customPodAffinity" . | indent 2 }}
  {{- end }}
{{- end }}

{{- define "uc.podAntiAffinity" }}
#https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
  {{- if not (empty (.Values.customPodAntiAffinity))  }}
podAntiAffinity:
{{- include "uc.customPodAntiAffinity" . | indent 2 }}
  {{- end }}
{{- end }}

{{- define "uc.nodeAffinityRequiredDuringScheduling" }}
    #If you specify multiple nodeSelectorTerms associated with nodeAffinity types,
    #then the pod can be scheduled onto a node if one of the nodeSelectorTerms is satisfied.
    #
    #If you specify multiple matchExpressions associated with nodeSelectorTerms,
    #then the pod can be scheduled onto a node only if all matchExpressions can be satisfied.
    #
    #valid operators: In, NotIn, Exists, DoesNotExist, Gt, Lt
    nodeSelectorTerms:
    - matchExpressions:
{{- include "uc.customNodeSelectorTerms" . | indent 6 }}
      - key: beta.kubernetes.io/arch
        operator: In
        values:
      {{- range $key, $val := .Values.arch }}
        {{- if gt ($val | trunc 1 | int) 0 }}
        - {{ $key }}
        {{- end }}
      {{- end }}
{{- end }}

{{- define "uc.nodeAffinityPreferredDuringScheduling" }}
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

{{- define "uc.customNodeSelectorTerms" }}
  {{- if not (empty (.Values.customNodeSelectorTerms))  }}
{{ toYaml .Values.customNodeSelectorTerms }}
  {{- end }}
{{- end }}

{{- define "uc.customPodAffinity" }}
  {{- if not (empty (.Values.customPodAffinity))  }}
{{ toYaml .Values.customPodAffinity }}
  {{- end }}
{{- end }}

{{- define "uc.customPodAntiAffinity" }}
  {{- if not (empty (.Values.customPodAntiAffinity))  }}
{{ toYaml .Values.customPodAntiAffinity }}
  {{- end }}
{{- end }}

{{- define "uc.annotations" }}
productName: {{ .Values.productName }}
productID: {{ .Values.productID }}
  {{- if .Values.productVersion  }}
productVersion: {{ .Values.productVersion }}
  {{- else }}
productVersion: {{ .Values.image.tag }}
  {{- end }}
{{- end }}