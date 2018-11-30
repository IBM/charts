# Licensed to the Apache Software Foundation (ASF) under one or more contributor
# license agreements; and to You under the Apache License, Version 2.0.

# This file defines template snippets for scheduler affinity and anti-affinity

{{/* Generic core affinity */}}
{{- define "openwhisk.affinity.core" -}}
# prefer to not run on an invoker node (only prefer because of single node clusters)
nodeAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 100
    preference:
      matchExpressions:
      - key: openwhisk-role
        operator: NotIn
        values:
        - {{ .Values.affinity.invokerNodeLabel }}
# prefer to run on a core node
nodeAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 80
    preference:
      matchExpressions:
      - key: openwhisk-role
        operator: In
        values:
        - {{ .Values.affinity.coreNodeLabel }}
{{- end -}}


{{/* Generic edge affinity */}}
{{- define "openwhisk.affinity.edge" -}}
# prefer to not run on an invoker node (only prefer because of single node clusters)
nodeAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 100
    preference:
      matchExpressions:
      - key: openwhisk-role
        operator: NotIn
        values:
        - {{ .Values.affinity.invokerNodeLabel }}
# prefer to run on a edge node
nodeAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 80
    preference:
      matchExpressions:
      - key: openwhisk-role
        operator: In
        values:
        - {{ .Values.affinity.edgeNodeLabel }}
{{- end -}}


{{/* Generic provder affinity */}}
{{- define "openwhisk.affinity.provider" -}}
# prefer to not run on an invoker node (only prefer because of single node clusters)
nodeAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 100
    preference:
      matchExpressions:
      - key: openwhisk-role
        operator: NotIn
        values:
        - {{ .Values.affinity.invokerNodeLabel }}
# prefer to run on a provider node
nodeAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 80
    preference:
      matchExpressions:
      - key: openwhisk-role
        operator: In
        values:
        - {{ .Values.affinity.providerNodeLabel }}
{{- end -}}


{{/* Invoker node affinity */}}
{{- define "openwhisk.affinity.invoker" -}}
# run only on nodes labeled with openwhisk-role={{ .Values.affinity.invokerNodeLabel }}
nodeAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    nodeSelectorTerms:
    - matchExpressions:
      - key: openwhisk-role
        operator: In
        values:
        - {{ .Values.affinity.invokerNodeLabel }}
{{- end -}}


{{/* Self anti-affinity */}}
{{- define "openwhisk.affinity.selfAntiAffinity" -}}
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