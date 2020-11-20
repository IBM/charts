{{/* affinity - https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ */}}

{{- define "eventstore.nodeAffinity" }}
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    {{- include "eventstore.nodeAffinityRequiredDuringScheduling" . }}
    {{ if eq .Values.runtime "ICP4Data" -}}
      {{- include "eventstore.nodeAffinityICP4Data" . }}
    {{- else }}
      {{- include "eventstore.nodeAffinitySelector" . }}
    {{- end }}
{{- end }}

{{- define "eventstore.nodeAffinityControl" }}
  {{- include "eventstore.nodeAffinity" . }}
    {{- include "eventstore.nodeAffinityRoleControl" . }}
{{- end }}

{{- define "eventstore.nodeAffinityRoleControl" }}
        - key: node-role.db2eventstore.ibm.com/control
          operator: In
          values: ["true"]
{{- end }}

#If you need a node affinity that does not require any eventstore labels. Ex. the prereq label job
{{- define "eventstore.nodeAffinityNoLabels" }}
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    {{- include "eventstore.nodeAffinityRequiredDuringScheduling" . }}
{{- end }}

{{- define "eventstore.nodeAffinityRequiredDuringScheduling" }}
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

{{- define "eventstore.nodeAffinityICP4Data" }}
        {{- if eq .Values.global.nodeLabel.key "" }}
        - key: icp4data
        {{- else }}
        - key: {{ .Values.global.nodeLabel.key }}
        {{- end }}
          operator: In
          values:
            {{- if eq .Values.global.nodeLabel.value "" }}
            - {{ .Values.servicename }}
            {{- else }}
            - {{ .Values.global.nodeLabel.value }}
            {{- end }}
{{- end }}

{{- define "eventstore.nodeAffinitySelector" }}
        - key: "is_eventstore"
          operator: In
          values: ["true"]
{{- end }}
