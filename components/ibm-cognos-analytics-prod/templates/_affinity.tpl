{{/* affinity - https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ */}}

{{- define "nodeaffinity" }}
#https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
  nodeAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    {{- include "nodeAffinityPreferredDuringScheduling" . }}
    requiredDuringSchedulingIgnoredDuringExecution:
    {{- include "nodeAffinityRequiredDuringScheduling" . }}
{{- end }}

{{- define "nodeAffinityRequiredDuringScheduling" }}
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
{{- end }}

{{- define "nodeAffinityPreferredDuringScheduling" }}
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

{{/*
Helper function to create nodeAffinity for deployments
*/}}
{{- define "deploymentNodeAffinity" }}
{{- if not .Values.global.ppaChart }}
  {{- include "nodeaffinity" . }}
{{- else }}
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
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
          {{- if .Values.global.arch }}
            - {{ .Values.global.arch }}
          {{- else }}
            - {{ template "arch" . }}
          {{- end }}
{{- end -}}
{{- end -}}

{{/*
It creates additional node affinity criteria, which is appended to the deployment node affinity.
The "additionalNodeAffn" is a list of "key, value" pairs, which is provided from the values.yaml file.
e.g. of additionalNodeAffn:
disktype: "ssd"
cpu:  "intel"
*/}}
{{- define "additionalNodeAffinity" }}
        {{- range .additionalNodeAffn }}
        - key: {{ .key }}
          operator: In
          values:
          - {{ .value }}
        {{- end }}
{{- end }}