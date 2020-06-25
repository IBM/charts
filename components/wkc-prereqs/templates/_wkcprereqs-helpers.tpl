{{- /*
  Helper function node affinity
*/ -}}
{{- define "wkcprereqs.nodeAffinity" }}
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            - key: beta.kubernetes.io/arch
              operator: In
              values:
                - amd64
                - ppc64le
{{- end }}
