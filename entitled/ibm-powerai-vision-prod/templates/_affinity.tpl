{{/* IBM_SHIP_PROLOG_BEGIN_TAG                                              */}}
{{/* *****************************************************************      */}}
{{/*                                                                        */}}
{{/* Licensed Materials - Property of IBM                                   */}}
{{/*                                                                        */}}
{{/* (C) Copyright IBM Corp. 2018. All Rights Reserved.                     */}}
{{/*                                                                        */}}
{{/* US Government Users Restricted Rights - Use, duplication or            */}}
{{/* disclosure restricted by GSA ADP Schedule Contract with IBM Corp.      */}}
{{/*                                                                        */}}
{{/* *****************************************************************      */}}
{{/* IBM_SHIP_PROLOG_END_TAG                                                */}}
{{/* affinity - https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ */}}

{{- define "nodeaffinity-ppc64le" }}
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: beta.kubernetes.io/arch
          operator: In
          values:
            - ppc64le
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 3
      preference:
        matchExpressions:
        - key: beta.kubernetes.io/arch
          operator: In
          values:
            - ppc64le
{{- end }}

{{- define "nodeaffinity-any" }}
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: beta.kubernetes.io/arch
          operator: In
          values:
            - ppc64le
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 3
      preference:
        matchExpressions:
        - key: beta.kubernetes.io/arch
          operator: In
          values:
            - ppc64le
    - weight: 2
      preference:
        matchExpressions:
        - key: beta.kubernetes.io/arch
          operator: In
          values:
            - amd64
    - weight: 2
      preference:
        matchExpressions:
        - key: beta.kubernetes.io/arch
          operator: In
          values:
            - s390x
{{- end }}
