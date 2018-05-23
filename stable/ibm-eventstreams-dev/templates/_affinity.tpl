{{- define "customNodeaffinity" }}
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            - key: beta.kubernetes.io/arch
              operator: In
              values:
                - amd64
            - key: beta.kubernetes.io/os
              operator: In
              values:
                - linux
{{- end }}
