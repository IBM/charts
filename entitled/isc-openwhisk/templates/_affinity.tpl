#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# This file defines template snippets for scheduler affinity and anti-affinity

{{/* Generic core affinity */}}
{{- define "openwhisk.affinity.core" -}}
# prefer to not run on an invoker node (only prefer because of single node clusters)
nodeAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    nodeSelectorTerms:
    - matchExpressions:
      - key: beta.kubernetes.io/arch
        operator: In
        values:
        - "amd64"
  preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 100
    preference:
      matchExpressions:
      - key: openwhisk-role
        operator: NotIn
        values:
        - {{ .Values.affinity.invokerNodeLabel }}
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
