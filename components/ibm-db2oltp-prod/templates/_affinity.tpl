{{/* affinity - https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ */}}

{{- define "nodeaffinity" }}
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    {{- include "nodeAffinityRequiredDuringScheduling" . }}
{{- end }}

{{- define "podAntiAffinityDb2" }}
podAntiAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    - topologyKey: "kubernetes.io/hostname"
      labelSelector:
        matchLabels:
          type: "engine"
{{- end }}

{{- define "podAffinityDedicated" }}
{{- if and ( eq .Values.runtime "ICP4Data" ) ( .Values.dedicated ) }}
podAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    - topologyKey: "kubernetes.io/hostname"
      labelSelector:
        matchLabels:
          app: {{ template "fullname" . }}
{{- end }}
{{- end }}

{{- define "podAntiAffinityEtcd" }}
{{- if ge (int .Values.images.db2u.replicas) 3 }}
podAntiAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    - topologyKey: "kubernetes.io/hostname"
      labelSelector:
        matchLabels:
          app: {{ template "fullname" . }}
          release: "{{ .Release.Name }}"
          component: "etcd"
{{- end }}
{{- end }}

#If you need a node affinity that does not require any eventstore labels. Ex. the prereq label job
{{- define "nodeAffinityNoLabels" }}
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    {{- include "nodeAffinityRequiredDuringScheduling" . }}
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
        {{- if and ( eq .Values.runtime "ICP4Data" ) ( .Values.dedicated ) }}
{{- include "nodeAffinityICP4Data" . }}
        {{- end }}
        - key: beta.kubernetes.io/arch
          operator: In
          values:
            - {{ template "helperplatform" . }}
{{- end }}

{{- define "nodeAffinityICP4Data" }}
      nodeSelectorTerms:
      - matchExpressions:
  {{- if eq .Values.global.nodeLabel.key "" }}
        - key: icp4data
  {{- else }}
        - key: {{ .Values.global.nodeLabel.key }}
  {{- end }}
          operator: In
          values:
  {{- if eq .Values.global.nodeLabel.value "" }}
            - database-{{ .Values.global.dbType }}
  {{- else }}
            - {{ .Values.global.nodeLabel.value }}
  {{- end }}
{{- end }}

{{- define "nodeAffinitySelector" }}
      nodeSelectorTerms:
      - matchExpressions:
        - key: "is_{{ .Values.global.dbType }}"
          operator: In
          values: ["true"]
{{- end }}

{{- define "uc.customNodeSelectorTerms" }}
{{- if .Values.dedicated }}
  {{- if eq .Values.global.nodeLabel.key "" }}
- key: icp4data
  {{- else }}
- key: {{ .Values.global.nodeLabel.key }}
  {{- end }}
  operator: In
  values:
  {{- if eq .Values.global.nodeLabel.value "" }}
    - database-{{ .Values.global.dbType }}
  {{- else }}
    - {{ .Values.global.nodeLabel.value }}
  {{- end }}
{{- end }}
{{- end }}

{{- define "uc.podAffinity" }}
{{- if .Values.dedicated }}
podAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    - topologyKey: "kubernetes.io/hostname"
      labelSelector:
        matchLabels:
          release: "{{ .Release.Name }}"
          type: "engine"
{{- end }}
{{- end }}
