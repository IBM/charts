# Licensed to the Apache Software Foundation (ASF) under one or more contributor
# license agreements; and to You under the Apache License, Version 2.0.

# This file defines template snippets for scheduler affinity and anti-affinity

{{/* affinity - https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ */}}

{{- define "nodeaffinity" }}
#https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    {{- include "nodeAffinityRequiredDuringScheduling" . }}
    preferredDuringSchedulingIgnoredDuringExecution:
    {{- include "nodeAffinityPreferredDuringScheduling" . }}
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
        {{- range $key, $val := .Values.arch }}
          {{- if gt ($val | trunc 1 | int) 0 }}
          - {{ $key }}
          {{- end }}
        {{- end }}
{{- end }}

{{- define "nodeAffinityPreferredDuringScheduling" }}
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

  # prefer to not run on an invoker node (only prefer because of single node clusters)
    - weight: 100
      preference:
        matchExpressions:
        - key: openwhisk-role
          operator: NotIn
          values:
          - {{ .Values.affinity.invokerNodeLabel }}
  # prefer to run on a core node
    - weight: 80
      preference:
        matchExpressions:
        - key: openwhisk-role
          operator: In
          values:
          - {{ .Values.affinity.coreNodeLabel }}
{{- end -}}

{{/* Generic edge affinity */}}
{{- define "affinity.edge" -}}
# prefer to not run on an invoker node (only prefer because of single node clusters)
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: beta.kubernetes.io/arch
          operator: In
          values:
        {{- range $key, $val := .Values.arch }}
          {{- if gt ($val | trunc 1 | int) 0 }}
          - {{ $key }}
          {{- end }}
        {{- end }}
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      preference:
        matchExpressions:
        - key: openwhisk-role
          operator: NotIn
          values:
          - {{ .Values.affinity.invokerNodeLabel }}
  # prefer to run on a edge node
    - weight: 80
      preference:
        matchExpressions:
        - key: openwhisk-role
          operator: In
          values:
          - {{ .Values.affinity.edgeNodeLabel }}
{{- end -}}


{{/* Invoker node affinity */}}
{{- define "affinity.invoker" -}}
# run only on nodes labeled with openwhisk-role={{ .Values.affinity.invokerNodeLabel }}
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: openwhisk-role
          operator: In
          values:
          - {{ .Values.affinity.invokerNodeLabel }}
        - key: beta.kubernetes.io/arch
          operator: In
          values:
        {{- range $key, $val := .Values.arch }}
          {{- if gt ($val | trunc 1 | int) 0 }}
          - {{ $key }}
          {{- end }}
        {{- end }}
{{- end -}}


{{/* Self anti-affinity */}}
{{- define "affinity.selfAntiAffinity" -}}
# Fault tolerance: prevent multiple instances of {{ . }} from running on the same node
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchExpressions:
        - key: name
          operator: In
          values:
          - {{ . }}
      topologyKey: "kubernetes.io/hostname"
{{- end -}}
