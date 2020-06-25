{{- /*
  Helper function node affinity
*/ -}}
{{- define "wkcbase2.nodeAffinity" }}
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            - key: beta.kubernetes.io/arch
              operator: In
              values:
                - amd64
{{- end }}
