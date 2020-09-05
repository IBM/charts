{{- define "affinity.node" }}
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
          - key: beta.kubernetes.io/arch
            operator: In
            values:
            - {{ template "helperplatform" . }}
{{- end }}


{{- define "affinity.node.ifx" }}
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
          - key: beta.kubernetes.io/arch
            operator: In
            values:
            - {{ template "helperplatform" . }}
{{- printf "\n    " -}}
{{- if .Values.affinity.eng.affinityStrict -}}
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
          - key: informix-scc-nodes
            operator: In
            values:
            - ifx-custom-scc
{{- else -}}
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        preference:
          matchExpressions:
          - key: informix-scc-nodes
            operator: In
            values:
            - ifx-custom-scc
{{- end -}}
{{- end }}
